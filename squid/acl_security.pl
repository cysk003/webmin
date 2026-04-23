
require 'squid-lib.pl';
@accopts = ('portsnets', 'othercaches', 'musage', 'logging', 'copts',
	    'hprogs', 'actrl', 'admopts', 'proxyauth', 'miscopt', 'cms',
	    'rebuild', 'calamaris', 'delay', 'headeracc', 'refresh', 'cachemgr',
	    'authparam', 'iptables', 'manual');

# acl_security_form(&options)
# Output HTML for editing security options for the squid module
sub acl_security_form
{
my ($o) = @_;

print &ui_table_row($text{'acl_sections'},
	&ui_select("sections",
		   [ grep { $o->{$_} } @accopts ],
		   [ map { [ $_, $text{"index_${_}"} ] } @accopts ],
		   6, 1),
	3);

print &ui_table_row($text{'acl_root'},
	&ui_textbox("root", $o->{'root'}, 40)." ".&file_chooser_button("root", 1),
	3);

print &ui_table_row($text{'acl_start'},
	&ui_yesno_radio("start", $o->{'start'}));
print &ui_table_row($text{'acl_restart'},
	&ui_yesno_radio("restart", $o->{'restart'}));
}

# acl_security_save(&options)
# Parse the form for security options for the squid module
sub acl_security_save
{
$_[0]->{'root'} = $in{'root'};
map { $sections{$_} = 1 } split(/\0/, $in{'sections'});
foreach $s (@accopts) {
	$_[0]->{$s} = $sections{$s};
	}
$_[0]->{'start'} = $in{'start'};
$_[0]->{'restart'} = $in{'restart'};
}

