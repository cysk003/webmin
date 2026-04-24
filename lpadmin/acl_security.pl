
require 'lpadmin-lib.pl';

# acl_security_form(&options)
# Output HTML for editing security options for the lpadmin module
sub acl_security_form
{
my ($o) = @_;
my @plist = &list_printers();
my @popts = map {
	my $prn = &get_printer($_);
	[ $_, $prn->{'desc'}." ($_)" ]
	} @plist;

print &ui_table_row($text{'acl_printers'},
	&ui_radio("printers_def", $o->{'printers'} eq '*' ? 1 : 0,
		  [ [ 1, $text{'acl_pall'} ],
		    [ 0, $text{'acl_psel'} ] ])."<br>\n".
	&ui_select("printers", [ split(/\s+/, $o->{'printers'}) ], \@popts, 4, 1),
	3);

print &ui_table_row($text{'acl_cancel'},
	&ui_radio_table("cancel",
		defined($o->{'cancel'}) ? $o->{'cancel'} : 0,
		[ [ 0, $text{'no'} ],
		  [ 1, $text{'yes'} ],
		  [ 2, $text{'acl_listed'},
		    &ui_select("jobs", [ split(/\s+/, $o->{'jobs'}) ], \@popts, 4, 1) ] ], 1),
	3);

my $user_def = $o->{'user'} eq '*' ? 1 : $o->{'user'} ? 0 : 2;
print &ui_table_row($text{'acl_user'},
	&ui_radio_table("user_def", $user_def,
		[ [ 1, $text{'acl_user_all'} ],
		  [ 2, $text{'acl_user_this'} ],
		  [ 0, "", &ui_textbox("user",
				       $user_def == 0 ? $o->{'user'} : "", 13) ] ], 1),
	3);

print &ui_table_row($text{'acl_add'},
	&ui_yesno_radio("add", $o->{'add'}));
print &ui_table_row($text{'acl_stop'},
	&ui_radio("stop", defined($o->{'stop'}) ? $o->{'stop'} : 0,
		  [ [ 1, $text{'yes'} ],
		    [ 2, $text{'acl_restart'} ],
		    [ 0, $text{'no'} ] ]));

print &ui_table_row($text{'acl_view'},
	&ui_yesno_radio("view", $o->{'view'}));
print &ui_table_row($text{'acl_test'},
	&ui_yesno_radio("test", $o->{'test'}));

print &ui_table_row($text{'acl_delete'},
	&ui_yesno_radio("delete", $o->{'delete'}));
print &ui_table_row($text{'acl_cluster'},
	&ui_yesno_radio("cluster", $o->{'cluster'}));
}

# acl_security_save(&options)
# Parse the form for security options for the lpadmin module
sub acl_security_save
{
if ($in{'printers_def'}) {
	$_[0]->{'printers'} = '*';
	}
else {
	$_[0]->{'printers'} = join(" ", split(/\0/, $in{'printers'}));
	}
$_[0]->{'cancel'} = $in{'cancel'};
$_[0]->{'jobs'} = $in{'cancel'} == 2 ? join(" ", split(/\0/, $in{'jobs'})) : "";
$_[0]->{'add'} = $in{'add'};
$_[0]->{'stop'} = $in{'stop'};
$_[0]->{'view'} = $in{'view'};
$_[0]->{'user'} = $in{'user_def'} == 1 ? '*' :
		  $in{'user_def'} == 2 ? undef : $in{'user'};
$_[0]->{'delete'} = $in{'delete'};
$_[0]->{'test'} = $in{'test'};
$_[0]->{'cluster'} = $in{'cluster'};
}

