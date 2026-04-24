
require 'cluster-passwd-lib.pl';

# acl_security_form(&options)
# Output HTML for editing security options for the passwd module
sub acl_security_form
{
my ($o) = @_;

print &ui_table_row($passwd::text{'acl_users'},
	&ui_radio_table("mode", defined($o->{'mode'}) ? $o->{'mode'} : 0,
		[ [ 0, $passwd::text{'acl_mode0'} ],
		  [ 3, $passwd::text{'acl_mode3'} ],
		  [ 1, $passwd::text{'acl_mode1'},
		    &ui_textbox("users1", $o->{'mode'} == 1 ? $o->{'users'} : "",
				40)." ".&user_chooser_button("users1", 1) ],
		  [ 2, $passwd::text{'acl_mode2'},
		    &ui_textbox("users2", $o->{'mode'} == 2 ? $o->{'users'} : "",
				40)." ".&user_chooser_button("users2", 1) ],
		  [ 4, $passwd::text{'acl_mode4'},
		    &ui_textbox("low", $o->{'mode'} == 4 ? $o->{'low'} : "", 8).
		    " - ".&ui_textbox("high",
				      $o->{'mode'} == 4 ? $o->{'high'} : "", 8) ],
		  [ 5, $passwd::text{'acl_mode5'},
		    &ui_textbox("groups", $o->{'mode'} == 5 ? $o->{'users'} : "",
				20)." ".&group_chooser_button("groups", 1)."<br>\n".
		    &ui_checkbox("sec", 1, $passwd::text{'acl_sec'}, $o->{'sec'}) ],
		  [ 6, $passwd::text{'acl_mode6'},
		    &ui_textbox("match", $o->{'mode'} == 6 ? $o->{'users'} : "",
				15) ] ], 1),
		3);

print &ui_table_row($passwd::text{'acl_repeat'},
	&ui_yesno_radio("repeat", $o->{'repeat'}), 3);

print &ui_table_row($passwd::text{'acl_others'},
	&ui_radio("others", defined($o->{'others'}) ? $o->{'others'} : 0,
		  [ [ 1, $passwd::text{'yes'} ],
		    [ 2, $passwd::text{'acl_opt'} ],
		    [ 0, $passwd::text{'no'} ] ]),
	3);

print &ui_table_row($passwd::text{'acl_old'},
	&ui_radio("old", defined($o->{'old'}) ? $o->{'old'} : 0,
		  [ [ 1, $passwd::text{'yes'} ],
		    [ 2, $passwd::text{'acl_old_this'} ],
		    [ 0, $passwd::text{'no'} ] ]),
	3);
}

# acl_security_save(&options)
# Parse the form for security options for the bind8 module
sub acl_security_save
{
$_[0]->{'mode'} = $in{'mode'};
$_[0]->{'users'} = $in{'mode'} == 1 ? $in{'users1'} :
		   $in{'mode'} == 2 ? $in{'users2'} :
		   $in{'mode'} == 5 ? $in{'groups'} :
		   $in{'mode'} == 6 ? $in{'match'} : undef;
$_[0]->{'low'} = $in{'low'};
$_[0]->{'high'} = $in{'high'};
$_[0]->{'repeat'} = $in{'repeat'};
$_[0]->{'old'} = $in{'old'};
$_[0]->{'others'} = $in{'others'};
$_[0]->{'expire'} = $in{'expire'};
$_[0]->{'sec'} = $in{'sec'};
}

