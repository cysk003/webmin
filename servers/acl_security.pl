
require 'servers-lib.pl';

# acl_security_form(&options)
# Output HTML for editing security options for the servers module
sub acl_security_form
{
my ($o) = @_;
my @servers = sort { $a->{'host'} cmp $b->{'host'} } &list_servers();
my %scan = map { $_, 1 } split(/\s+/, $o->{'servers'});
my (@sopts, @ssel);
foreach my $s (sort { $a->{'value'} cmp $b->{'value'} } @servers) {
	push(@sopts, [ $s->{'id'}, $s->{'host'} ]);
	push(@ssel, $s->{'id'}) if ($scan{$s->{'host'}} || $scan{$s->{'id'}});
	}

print &ui_table_row($text{'acl_servers'},
	&ui_radio("servers_def", $o->{'servers'} eq '*' ? 1 : 0,
		  [ [ 1, $text{'acl_sall'} ],
		    [ 0, $text{'acl_ssel'} ] ])."<br>\n".
	&ui_select("servers", \@ssel, \@sopts, 4, 1),
	3);

print &ui_table_row($text{'acl_edit'},
	&ui_yesno_radio("edit", $o->{'edit'}));
print &ui_table_row($text{'acl_find'},
	&ui_yesno_radio("find", $o->{'find'}));

print &ui_table_row($text{'acl_auto'},
	&ui_yesno_radio("auto", $o->{'auto'}));
print &ui_table_row($text{'acl_add'},
	&ui_yesno_radio("add", $o->{'add'}));

print &ui_table_row($text{'acl_forcefast'},
	&ui_yesno_radio("forcefast", $o->{'forcefast'}));
print &ui_table_row($text{'acl_forcetype'},
	&ui_yesno_radio("forcetype", $o->{'forcetype'}));

print &ui_table_row($text{'acl_forcelink'},
	&ui_yesno_radio("forcelink", $o->{'forcelink'}));
print &ui_table_row($text{'acl_links'},
	&ui_yesno_radio("links", $o->{'links'}));
}

# acl_security_save(&options)
# Parse the form for security options for the servers module
sub acl_security_save
{
if ($in{'servers_def'}) {
        $_[0]->{'servers'} = "*";
        }
else {
        $_[0]->{'servers'} = join(" ", split(/\0/, $in{'servers'}));
        }
$_[0]->{'edit'} = $in{'edit'};
$_[0]->{'find'} = $in{'find'};
$_[0]->{'auto'} = $in{'auto'};
$_[0]->{'add'} = $in{'add'};
$_[0]->{'forcefast'} = $in{'forcefast'};
$_[0]->{'forcetype'} = $in{'forcetype'};
$_[0]->{'forcelink'} = $in{'forcelink'};
$_[0]->{'links'} = $in{'links'};
}

