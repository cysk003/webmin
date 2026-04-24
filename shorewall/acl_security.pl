
do 'shorewall-lib.pl';

# acl_security_form(&options)
# Output HTML for editing security options for the acl module
sub acl_security_form
{
my ($o) = @_;

print &ui_table_row($text{'acl_nochange'},
	&ui_yesno_radio("nochange", int($o->{'nochange'}), 0, 1));

print &ui_table_row($text{'acl_files'},
	&ui_radio("files_def", $o->{'files'} eq '*' ? 1 : 0,
		  [ [ 1, $text{'acl_all'} ], [ 0, $text{'acl_sel'} ] ])."<br>\n".
	&ui_select("files", [ split(/\s+/, $o->{'files'}) ],
		   [ map { [ $_, $text{$_."_title"}." ($_)" ] }
			 @shorewall_files ], 5, 1),
	3);
}

# acl_security_save(&options)
# Parse the form for security options for the acl module
sub acl_security_save
{
$_[0]->{'nochange'} = $in{'nochange'};
$_[0]->{'files'} = $in{'files_def'} ? "*"
				    : join(" ", split(/\0/, $in{'files'}));
}

