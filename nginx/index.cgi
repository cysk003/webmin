#!/usr/local/bin/perl
# Show Nginx server blocks and global config

use strict;
use warnings;
require './nginx-lib.pl';
my $ver = &get_nginx_version();
our (%text, %module_info, %config, $module_name, %access, %in);

my $action_links = -r $config{'nginx_config'} &&
		   &has_command($config{'nginx_cmd'}) ?
		   &nginx_action_links() : "";
&ui_print_header($ver ? &text('index_version', $ver) : undef,
		 $module_info{'desc'}, "", undef, 1, 1, undef,
		 $action_links);

# Check config
if (!-r $config{'nginx_config'}) {
	&ui_print_endpage(
		&text('index_econfig', "<tt>$config{'nginx_config'}</tt>",
		"../config.cgi?$module_name"));
	}
if (!&has_command($config{'nginx_cmd'})) {
	&ui_print_endpage(
		&text('index_ecmd', "<tt>$config{'nginx_cmd'}</tt>",
		"../config.cgi?$module_name"));
	}

my $conf = &get_config();
my $http = &find("http", $conf);
if (!$http) {
	&ui_print_endpage(
		&text('index_ehttp', "<tt>$config{'nginx_config'}</tt>"));
	}

my @tabs = ( );
my $can_create = !defined($access{'create'}) || $access{'create'};
push(@tabs, [ "global", $text{'index_tabglobal'}, "index.cgi?mode=global" ])
	if ($access{'global'});
push(@tabs, [ "list", $text{'index_tablist'}, "index.cgi?mode=list" ]);
push(@tabs, [ "create", $text{'index_tabcreate'}, "index.cgi?mode=create" ])
	if ($can_create);
my $mode = $in{'mode'} || "list";
my %tab = map { $_->[0], 1 } @tabs;
$mode = "list" if (!$tab{$mode});
print &ui_tabs_start(\@tabs, "mode", $mode, 1);

if ($access{'global'}) {
	# Show icons for global config types
	print &ui_tabs_start_tab("mode", "global");
	my @gpages = ( "net", "mime", "logs", "docs", "ssi", "misc", "manual" );
	&icons_table(
		[ map { "edit_".$_.".cgi" } @gpages ],
		[ map { $text{$_."_title"} } @gpages ],
		[ map { "images/".$_.".gif" } @gpages ],
		);
	print &ui_tabs_end_tab();
	}

# Show list of server blocks
print &ui_tabs_start_tab("mode", "list");
my @allservers = &find("server", $http);
my @servers = grep { &can_edit_server($_) } @allservers;
if (@servers) {
	my $can_delete = $access{'edit'};
	my @heads = ( $can_delete ? ( "" ) : ( ),
		      $text{'index_name'},
		      $text{'index_ip'},
		      $text{'index_port'},
		      $text{'index_root'} );
	my @data;
	foreach my $s (@servers) {
		my $name = &find_value("server_name", $s);
		$name ||= "";
		my $default = &is_default_server_block($s);
		my $showname = !$default ?
			&html_escape($name) : $text{'default_server_block'};

		# Extract all IPs and ports from listen directives
		my (@ips, @ports);
		foreach my $l (&find_value("listen", $s)) {
			my ($ip, $port) = &split_ip_port($l);
			$ip ||= $text{'index_any'};
			$ip = $text{'index_any6'} if ($ip eq "::");
			push(@ips, $ip);
			push(@ports, $port);
			}

		my $rootdir = &find_value("root", $s);
		my $root = $rootdir;
		if (!$root) {
			my @locs = &find("location", $s);
			my ($rootloc) = grep { $_->{'value'} eq '/' } @locs;
			if ($rootloc) {
				$rootdir = &find_value("root", $rootloc);
				$root = $rootdir ||
					"<i>$text{'index_noroot'}</i>";
				}
			else {
				$root = "<i>$text{'index_norootloc'}</i>";
				}
			$rootdir ||= "";
			}
		my $id = $name.";".$rootdir;
		my @cols = (
			"<a href='edit_server.cgi?id=".&urlize($id)."'>".
			  $showname."</a>",
			join("<br>", @ips),
			join("<br>", @ports),
			$root );
		if ($can_delete && !$default) {
			unshift(@cols, { 'type' => 'checkbox',
					 'name' => 'd',
					 'value' => $id });
			}
		elsif ($can_delete) {
			unshift(@cols, "");
			}
		push(@data, \@cols);
		}
	if ($can_delete) {
		print &ui_form_columns_table(
			"delete_servers.cgi",
			[ [ "delete", $text{'index_delete'} ] ],
			1, [ ], [ ], \@heads, 100, \@data);
		}
	else {
		print &ui_columns_table(\@heads, 100, \@data);
		}
	}
elsif (@allservers) {
	print "<b>$text{'index_noneaccess'}</b><p>\n";
	}
else {
	print "<b>$text{'index_none'}</b><p>\n";
	}
print &ui_tabs_end_tab();

if ($can_create) {
	print &ui_tabs_start_tab("mode", "create");
	print &ui_form_start("save_server.cgi", "post");
	print &ui_hidden("new", 1);
	print &ui_table_start($text{'server_create'}, "width=100%", 2);

	# Server name
	my $server = { 'name' => 'server',
		       'members' => [ ] };
	print &nginx_text_input("server_name", $server, 70, undef, 1);

	# IP addresses / ports to listen on
	my @listen = ( &value_to_struct('listen', '80') );
	my $table = &ui_columns_start([ $text{'server_ip'},
					$text{'server_port'},
					$text{'server_default'},
					$text{'server_ssl'},
					$text{'server_http2'},
					$text{'server_ipv6'} ], 100);
	my $i = 0;
	my @tds = ( "valign=top", "valign=top", "valign=top",
		    "valign=top", "valign=top" );
	foreach my $l (@listen, { 'words' => [ ] }) {
		my @w = @{$l->{'words'}};
		my ($ip, $port) = @w ? &split_ip_port(shift(@w)) : ( );
		my ($default, $ssl, $http2, $ipv6) = (0, 0, 0, "");
		foreach my $w (@w) {
			if ($w eq "default" || $w eq "default_server") {
				$default = 1;
				}
			elsif ($w eq "ssl") {
				$ssl = 1;
				}
			elsif ($w eq "http2") {
				$http2 = 1;
				}
			elsif ($w =~ /^ipv6only=(\S+)/) {
				$ipv6 = lc($1);
				}
			}
		my $ipmode = !$ip && !$port ? 3 :
			     !$ip ? 1 : $ip eq "::" ? 2 : 0;
		$table .= &ui_columns_row([
			&ui_radio("ip_def_$i", $ipmode,
				  [ [ 3, $text{'server_none'}."<br>" ],
				    [ 1, $text{'server_ipany'}."<br>" ],
				    [ 2, $text{'server_ip6any'}."<br>" ],
				    [ 0, $text{'server_ipaddr'} ] ])." ".
			  &ui_textbox("ip_$i", $ipmode == 0 ? $ip : "", 30),
			&ui_textbox("port_$i", $port, 6),
			&ui_select("default_$i", $default,
			   [ [ 0, $text{'no'} ], [ 1, $text{'yes'} ] ]),
			&ui_select("ssl_$i", $ssl,
			   [ [ 0, $text{'no'} ], [ 1, $text{'yes'} ] ]),
			&ui_select("http2_$i", $http2,
			   [ [ 0, $text{'no'} ], [ 1, $text{'yes'} ] ]),
			&ui_select("ipv6_$i", $ipv6,
			   [ [ "", $text{'server_auto'} ],
			     [ "off", $text{'no'} ], [ "on", $text{'yes'} ] ]),
			], \@tds);
		$i++;
		}
	$table .= &ui_columns_end();
	print &ui_table_row($text{'server_listen'}, $table);

	# Root directory
	print &ui_table_row($text{'server_rootdir'},
		&ui_filebox("rootdir", undef, 50, 0, undef, undef, 1));

	print &ui_table_end();
	print &ui_form_end([ [ undef, $text{'create'} ] ]);
	print &ui_tabs_end_tab();
	}

print &ui_tabs_end(1);

&ui_print_footer("/", $text{'index'});
