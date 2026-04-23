
require 'mysql-lib.pl';

# acl_security_form(&options)
# Output HTML for editing security options for the mysql module
sub acl_security_form
{
my ($o) = @_;
my @dbs = &list_databases();

print &ui_table_row($text{'acl_dbs'},
	&ui_radio("dbs_def", $o->{'dbs'} eq '*' ? 1 : 0,
		  [ [ 1, $text{'acl_dall'} ],
		    [ 0, $text{'acl_dsel'} ] ])."<br>\n".
	&ui_select("dbs", [ split(/\s+/, $o->{'dbs'}) ], \@dbs, 3, 1),
	3);

print &ui_table_row($text{'acl_delete'},
	&ui_yesno_radio("delete", $o->{'delete'}));
print &ui_table_row($text{'acl_stop'},
	&ui_yesno_radio("stop", $o->{'stop'}));
print &ui_table_row($text{'acl_edonly'},
	&ui_yesno_radio("edonly", $o->{'edonly'}));

print &ui_table_row($text{'acl_indexes'},
	&ui_yesno_radio("indexes", $o->{'indexes'}));
print &ui_table_row($text{'acl_views'},
	&ui_yesno_radio("views", $o->{'views'}));

print &ui_table_row($text{'acl_create'},
	&ui_radio_table("create",
		defined($o->{'create'}) ? $o->{'create'} : 0,
		[ [ 1, $text{'yes'} ],
		  [ 2, $text{'acl_max'},
		    &ui_textbox("max", $o->{'max'}, 5) ],
		  [ 0, $text{'no'} ] ], 1),
	3);

print &ui_table_row($text{'acl_perms'},
	&ui_radio("perms", defined($o->{'perms'}) ? $o->{'perms'} : 0,
		  [ [ 1, $text{'yes'} ],
		    [ 2, $text{'acl_only'} ],
		    [ 0, $text{'no'} ] ]),
	3);

print &ui_table_row($text{'acl_login'},
	&ui_radio_table("user_def", $o->{'user'} ? 0 : 1,
		[ [ 1, $text{'acl_user_def'} ],
		  [ 0, "",
		    $text{'acl_user'}." ".
		    &ui_textbox("user", $o->{'user'}, 10)." ".
		    $text{'acl_pass'}." ".
		    &ui_password("pass", $o->{'pass'}, 10) ] ], 1),
	3);

print &ui_table_row($text{'acl_buser'},
	&ui_opt_textbox("buser", $o->{'buser'}, 8, $text{'acl_bnone'})." ".
	&user_chooser_button("buser"),
	3);

print &ui_table_row($text{'acl_bpath'},
	&ui_textbox("bpath", $o->{'bpath'}, 40)." ".
	&file_chooser_button("bpath", 1),
	3);
}

# acl_security_save(&options)
# Parse the form for security options for the mysql module
sub acl_security_save
{
if ($in{'dbs_def'}) {
	$_[0]->{'dbs'} = '*';
	}
else {
	$_[0]->{'dbs'} = join(" ", split(/\0/, $in{'dbs'}));
	}
$_[0]->{'create'} = $in{'create'};
$_[0]->{'indexes'} = $in{'indexes'};
$_[0]->{'views'} = $in{'views'};
$_[0]->{'max'} = $in{'max'};
$_[0]->{'delete'} = $in{'delete'};
$_[0]->{'bpath'} = $in{'bpath'};
$_[0]->{'buser'} = $in{'buser_def'} ? undef : $in{'buser'};
$_[0]->{'stop'} = $in{'stop'};
$_[0]->{'perms'} = $in{'perms'};
$_[0]->{'edonly'} = $in{'edonly'};
if ($in{'user_def'}) {
	delete($_[0]->{'user'});
	delete($_[0]->{'pass'});
	}
else {
	$_[0]->{'user'} = $in{'user'};
	$_[0]->{'pass'} = $in{'pass'};
	}
}

