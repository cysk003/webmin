
require 'apache-lib.pl';

# acl_security_form(&options)
# Output HTML for editing security options for the apache module
sub acl_security_form
{
my ($o) = @_;

my $conf = &get_config();
my @virts = ( { 'value' => '__default__' },
	      &find_directive_struct("VirtualHost", $conf) );
my @vsel = $o->{'virts'} eq '*' ? () : split(/\s+/, $o->{'virts'});
my %vcan = map { $_, 1 } @vsel;
my @vopts;
foreach my $v (@virts) {
	my @vn = &virt_acl_name($v);
	my ($can) = grep { $vcan{$_} } @vn;
	my $show = $can || $vn[0];
	push(@vopts, [ $show,
		       $show eq "__default__" ? $text{'acl_defserv'}
					      : $show ]);
	delete($vcan{$can}) if ($can);
	}
print &ui_table_row($text{'acl_virts'},
	&ui_radio("virts_def", $o->{'virts'} eq '*' ? 1 : 0,
		  [ [ 1, $text{'acl_vall'} ],
		    [ 0, $text{'acl_vsel'} ] ])."<br>\n".
	&ui_select("virts", \@vsel, \@vopts, 5, 1, 1),
	3);

print &ui_table_row($text{'acl_global'},
	&ui_select("global",
		   defined($o->{'global'}) && $o->{'global'} ne '' ?
			$o->{'global'} : 0,
		   [ [ 1, $text{'yes'} ],
		     [ 2, $text{'acl_htaccess'} ],
		     [ 0, $text{'no'} ] ]));
print &ui_table_row($text{'acl_create'},
	&ui_yesno_radio("create", $o->{'create'}));

print &ui_table_row($text{'acl_vuser'},
	&ui_yesno_radio("vuser", $o->{'vuser'}));
print &ui_table_row($text{'acl_vaddr'},
	&ui_yesno_radio("vaddr", $o->{'vaddr'}));

print &ui_table_row($text{'acl_pipe'},
	&ui_yesno_radio("pipe", $o->{'pipe'}));
print &ui_table_row($text{'acl_stop'},
	&ui_yesno_radio("stop", $o->{'stop'}));

print &ui_table_row($text{'acl_apply'},
	&ui_yesno_radio("apply", $o->{'apply'}));
print &ui_table_row($text{'acl_names'},
	&ui_yesno_radio("names", $o->{'names'}));

print &ui_table_row($text{'acl_dir'},
	&ui_textbox("dir", $o->{'dir'}, 30)." ".
	&file_chooser_button("dir", 1),
	3);

print &ui_table_row($text{'acl_aliasdir'},
	&ui_textbox("aliasdir", $o->{'aliasdir'}, 30)." ".
	&file_chooser_button("aliasdir", 1),
	3);

my @typesel = $o->{'types'} eq '*' ? () : split(/\s+/, $o->{'types'});
my @typeopts;
for (my $i = 0; $text{"type_$i"}; $i++) {
	push(@typeopts, [ $i, $text{"type_$i"} ]);
	}
print &ui_table_row($text{'acl_types'},
	&ui_radio("types_def", $o->{'types'} eq '*' ? 1 : 0,
		  [ [ 1, $text{'acl_all'} ],
		    [ 0, $text{'acl_sel'} ] ])."<br>\n".
	&ui_select("types", \@typesel, \@typeopts, 5, 1),
	3);

print &ui_table_row($text{'acl_dirs'},
	&ui_radio("dirsmode", $o->{'dirsmode'},
		  [ [ 0, $text{'acl_dirs0'} ],
		    [ 1, $text{'acl_dirs1'} ],
		    [ 2, $text{'acl_dirs2'} ] ])."<br>\n".
	&ui_textarea("dirs", join("\n", split(/\s+/, $o->{'dirs'})), 5, 50),
	3);
}

# acl_security_save(&options)
# Parse the form for security options for the apache module
sub acl_security_save
{
if ($in{'virts_def'}) {
	$_[0]->{'virts'} = "*";
	}
else {
	$_[0]->{'virts'} = join(" ", split(/\0/, $in{'virts'}));
	}
$_[0]->{'global'} = $in{'global'};
$_[0]->{'create'} = $in{'create'};
$_[0]->{'vuser'} = $in{'vuser'};
$_[0]->{'stop'} = $in{'stop'};
$_[0]->{'apply'} = $in{'apply'};
$_[0]->{'vaddr'} = $in{'vaddr'};
$_[0]->{'dir'} = $in{'dir'};
$_[0]->{'aliasdir'} = $in{'aliasdir'};
$_[0]->{'types'} = $in{'types_def'} ? '*'
				    : join(" ", split(/\0/, $in{'types'}));
$_[0]->{'pipe'} = $in{'pipe'};
$_[0]->{'names'} = $in{'names'};
$_[0]->{'dirsmode'} = $in{'dirsmode'};
$_[0]->{'dirs'} = join(" ", split(/\s+/, $in{'dirs'}));
}
