#!/usr/bin/perl
# delete_table.cgi
# Delete an existing nftables table

require './nftables-lib.pl'; ## no critic
use strict;
use warnings;
our (%in, %text);
ReadParse();
error_setup($text{'delete_err'});

my @tables = get_nftables_save();
my $table = $tables[$in{'table'}];
$table || error($text{'delete_notable'});

if ($in{'confirm'}) {
    splice(@tables, $in{'table'}, 1);
    my $err = save_configuration(@tables);
    error(text('delete_failed', $err)) if ($err);
    webmin_log("delete", "table", $table->{'name'},
                { 'family' => $table->{'family'} });
    redirect("index.cgi");
}

ui_print_header(undef, $text{'delete_title'}, "", "intro", 1, 1);
print ui_form_start("delete_table.cgi");
print ui_hidden("table", $in{'table'});
print "<center><b>",
      text('delete_confirm',
            "<tt>$table->{'family'} $table->{'name'}</tt>"),
      "</b><p>\n";
print ui_submit($text{'delete'}, "confirm");
print "</center>\n";
print ui_form_end();
ui_print_footer("index.cgi?table=$in{'table'}", $text{'index_return'});

