
require 'samba-lib.pl';

# acl_security_form(&options)
# Output HTML for editing security options for the samba module
sub acl_security_form
{
my ($o) = @_;

foreach my $f ('apply', 'view_all_con', 'kill_con') {
	print &ui_table_row($text{'acl_'.$f},
		&ui_yesno_radio($f, $o->{$f}));
	}

print &ui_table_hr();

foreach my $f ('conf_net', 'conf_smb', 'conf_pass', 'conf_print',
	       'conf_misc', 'swat', 'manual', 'winbind') {
	print &ui_table_row($text{'acl_'.$f},
		&ui_yesno_radio($f, $o->{$f}));
	}
print &ui_table_row($text{'acl_bind'},
	&ui_yesno_radio("conf_bind", $o->{'conf_bind'}));

print &ui_table_hr();
print &ui_table_span($text{'acl_enc_passwd_opts'});

foreach my $f ('view_users', 'maint_users', 'maint_makepass', 'maint_sync') {
	print &ui_table_row($text{'acl_'.$f},
		&ui_yesno_radio($f, $o->{$f}));
	}

print &ui_table_hr();
print &ui_table_span($text{'acl_group_opts'});

foreach my $f ('maint_groups', 'maint_gsync') {
	print &ui_table_row($text{'acl_'.$f},
		&ui_yesno_radio($f, $o->{$f}));
	}

print &ui_table_hr();

print &ui_table_row($text{'acl_hide'},
	&ui_yesno_radio("hide", defined($o->{'hide'}) ? $o->{'hide'} : 0));

print &ui_table_hr();

print &ui_table_row($text{'acl_afs'},
	join("", map { &ui_checkbox($_."_fs", 1, $text{"acl_".$_}, $o->{$_."_fs"}) }
		    qw(c r w)),
	3);

print &ui_table_row($text{'acl_aps'},
	join("", map { &ui_checkbox($_."_ps", 1, $text{"acl_".$_}, $o->{$_."_ps"}) }
		    qw(c r w)),
	3);

print &ui_table_row($text{'acl_copy'},
	&ui_yesno_radio("copy", $o->{'copy'}));

print &ui_table_hr();

print &ui_table_row($text{'acl_per_fs_acls'},
	&ui_yesno_radio("per_fs_acls", $o->{'per_fs_acls'}));
print &ui_table_row($text{'acl_per_ps_acls'},
	&ui_yesno_radio("per_ps_acls", $o->{'per_ps_acls'}));

print &ui_table_hr();

my @heads = (
	$text{'acl_sname'},
	$text{'acl_saccess'},
	$text{'acl_sconn'},
	$text{'acl_ssec'},
	$text{'acl_sperm'},
	$text{'acl_snaming'},
	$text{'acl_smisc'}." / ".$text{'acl_sprn'},
	);
my $stable = &ui_columns_start(\@heads, 100);
foreach (&list_shares()) {
	$stable .= &display_acl_row($o, $_);
	}
$stable .= &ui_columns_end();
print &ui_table_row($text{'acl_per_share_acls'}, $stable, 3);
}

# acl_security_save(&options)
# Parse the form for security options for the samba module
sub acl_security_save
{
if ($in{'r_fs'} < $in{'w_fs'} || $in{'r_ps'} < $in{'w_ps'}) {
	&error($text{'acl_ernow'});
	}

# If create, read, AND write are all turned off... don't SHOW file shares...
$_[0]->{'conf_fs'}=1;
if ($in{'c_fs'} == "" && $in{'r_fs'} == "" && $in{'w_fs'} == "") {
        $_[0]->{'conf_fs'}=0;
        }
# If create, read, AND write are all turned off... don't SHOW print shares...
$_[0]->{'conf_ps'}=1;
if ($in{'c_ps'} == "" && $in{'r_ps'} == "" && $in{'w_ps'} == "") {
        $_[0]->{'conf_ps'}=0;
        }

$_[0]->{'apply'}=$in{'apply'};
$_[0]->{'view_all_con'}=$in{'view_all_con'};
$_[0]->{'kill_con'}=$in{'kill_con'};
$_[0]->{'conf_net'}=$in{'conf_net'};
$_[0]->{'conf_smb'}=$in{'conf_smb'};
$_[0]->{'conf_pass'}=$in{'conf_pass'};
$_[0]->{'conf_print'}=$in{'conf_print'};
$_[0]->{'conf_misc'}=$in{'conf_misc'};
$_[0]->{'swat'}=$in{'swat'};
$_[0]->{'manual'}=$in{'manual'};
$_[0]->{'hide'}=$in{'hide'};
$_[0]->{'per_fs_acls'}=$in{'per_fs_acls'};
$_[0]->{'per_ps_acls'}=$in{'per_ps_acls'};
$_[0]->{'c_fs'}=$in{'c_fs'};
$_[0]->{'r_fs'}=$in{'r_fs'};
$_[0]->{'w_fs'}=$in{'w_fs'};
$_[0]->{'c_ps'}=$in{'c_ps'};
$_[0]->{'r_ps'}=$in{'r_ps'};
$_[0]->{'w_ps'}=$in{'w_ps'};
$_[0]->{'copy'}=$in{'copy'};
$_[0]->{'view_users'}=$in{'view_users'};
$_[0]->{'maint_users'}=$in{'maint_users'};
$_[0]->{'maint_makepass'}=$in{'maint_makepass'};
$_[0]->{'maint_sync'}=$in{'maint_sync'};
$_[0]->{'maint_groups'}=$in{'maint_groups'};
$_[0]->{'maint_gsync'}=$in{'maint_gsync'};
$_[0]->{'winbind'}=$in{'winbind'};
$_[0]->{'conf_bind'}=$in{'conf_bind'};

foreach (keys %in) {
	  $_[0]->{$1} .= $in{$_} if /^\w\w_(ACL\w\w_\w+)$/;
	  }
}

# display_acl_row(\%access, $share_name)									
sub display_acl_row
{
local($acc,$name)=@_;
local %share;
&get_share($name);
local $stype=&istrue('printable') ? 'ps' : 'fs';
local $aclname='ACL' . $stype . '_' . $name;

return &ui_columns_row([
	$stype eq 'fs' ? "<b>$name</b>" : "<i>$name</i>",
	&display_acl_cell($acc, $name, 'r', 'w', $aclname,
			  $text{'acl_na'}, $text{'acl_r1'}, $text{'acl_rw'}),
	&display_acl_cell($acc, $name, 'v', 'V', $aclname,
			  $text{'acl_na'}, $text{'acl_view'}, $text{'acl_kill'}),
	&display_acl_cell($acc, $name, 's', 'S', $aclname,
			  $text{'acl_na'}, $text{'acl_view'}, $text{'acl_edit'}),
	$stype eq 'fs' ? &display_acl_cell($acc, $name, 'p', 'P', $aclname,
					   $text{'acl_na'}, $text{'acl_view'},
					   $text{'acl_edit'}) : "",
	$stype eq 'fs' ? &display_acl_cell($acc, $name, 'n', 'N', $aclname,
					   $text{'acl_na'}, $text{'acl_view'},
					   $text{'acl_edit'}) : "",
	&display_acl_cell($acc, $name, 'o', 'O', $aclname,
			  $text{'acl_na'}, $text{'acl_view'}, $text{'acl_edit'}),
	]);
}

#display_acl_cell(\%access, $name, 
#				  $rperm, $wperm, $aclname, 
#				  $text1, $text2, $text3)
sub display_acl_cell
{
local ($acc, $name, $rp, $wp, $aclname, $text1, $text2, $text3) = @_;
local $rn = $rp . $wp . '_' . $aclname;
my $sel = !$acc->{$aclname} || !&perm_to($rp, $acc, $aclname) ? '' :
	  &perm_to($rp.$wp, $acc, $aclname) ? $rp.$wp : $rp;
return &ui_radio($rn, $sel,
	[ [ '', $text1."<br>" ],
	  [ $rp, $text2."<br>" ],
	  [ $rp.$wp, $text3 ] ]);
}

# perm_to($permissions_string,\%access,$ACLname)
# check only per-share permissions
sub perm_to
{
local $acl=$_[1]->{$_[2]};
foreach (split //,$_[0]) {
	return 0 if index($acl,$_) == -1;
	}
return 1;
}
		
1;
