#!/usr/local/bin/perl
# Delete selected server blocks

use strict;
use warnings;
require './nginx-lib.pl';
our (%text, %in, %config, %access);
&ReadParse();
&error_setup($text{'delete_err'});
$access{'edit'} || &error($text{'server_ecannotedit'});

my @ids = split(/\0/, $in{'d'} || "");
@ids || &error($text{'delete_enone'});

# Validate the selected server blocks before locking config files.
foreach my $id (@ids) {
	my $server = &find_server($id);
	$server || &error($text{'server_egone'});
	&can_edit_server($server) || &error($text{'server_ecannot'});
	&is_default_server_block($server) && &error($text{'delete_edefault'});
	}

&lock_all_config_files();
my $conf = &get_config();
my $http = &find("http", $conf);
if (!$http) {
	&unlock_all_config_files();
	&error(&text('index_ehttp', "<tt>$config{'nginx_config'}</tt>"));
	}
my @servers;
foreach my $id (@ids) {
	my $server = &find_server($id);
	if (!$server) {
		&unlock_all_config_files();
		&error($text{'server_egone'});
		}
	if (!&can_edit_server($server)) {
		&unlock_all_config_files();
		&error($text{'server_ecannot'});
		}
	if (&is_default_server_block($server)) {
		&unlock_all_config_files();
		&error($text{'delete_edefault'});
		}
	push(@servers, $server);
	}
foreach my $server (@servers) {
	&save_directive($http, [ $server ], [ ]);
	}
&flush_config_file_lines();
&unlock_all_config_files();
foreach my $server (@servers) {
	&delete_server_link($server);
	}
my %done_file;
foreach my $server (@servers) {
	next if ($done_file{$server->{'file'}}++);
	&delete_server_file_if_empty($server);
	}
&webmin_log("delete", "servers", scalar(@servers));
&redirect("");
