
require 'sendmail-lib.pl';

# acl_security_form(&options)
# Output HTML for editing security options for the sendmail module
sub acl_security_form
{
my ($o) = @_;

foreach my $f ('opts', 'cws', 'masq', 'trusts', 'cgs', 'relay',
	       'mailers', 'access', 'domains', 'stop', 'manual') {
	print &ui_table_row($text{'acl_'.$f},
		&ui_yesno_radio($f, $o->{$f}));
	}

print &ui_table_row($text{'acl_mailq'},
	&ui_select("mailq",
		   defined($o->{'mailq'}) && $o->{'mailq'} ne '' ? $o->{'mailq'} : 0,
		   [ [ 2, $text{'acl_viewdel'} ],
		     [ 1, $text{'acl_view'} ],
		     [ 0, $text{'no'} ] ]));

print &ui_table_row($text{'acl_qdoms'},
	&ui_radio_table("qdoms_def", $o->{'qdoms'} ? 0 : 1,
		[ [ 1, $text{'acl_all'} ],
		  [ 0, $text{'acl_matching'},
		    &ui_textbox("qdoms", $o->{'qdoms'}, 40) ] ], 1),
	3);

print &ui_table_row($text{'acl_qdomsmode'},
	&ui_radio("qdomsmode",
		  defined($o->{'qdomsmode'}) ? $o->{'qdomsmode'} : 0,
		  [ map { [ $_, $text{'acl_qdomsmode'.$_} ] } 0 .. 2 ]),
	3);

print &ui_table_row($text{'acl_flushq'},
	&ui_yesno_radio("flushq", $o->{'flushq'}));
print &ui_table_row($text{'acl_ports'},
	&ui_yesno_radio("ports", $o->{'ports'}));

print &ui_table_hr();

print &ui_table_row($text{'acl_virtusers'},
	&ui_radio_table("vmode",
		defined($o->{'vmode'}) ? $o->{'vmode'} : 0,
		[ [ 0, $text{'acl_none'} ],
		  [ 1, $text{'acl_all'} ],
		  [ 3, $text{'acl_vsame'} ],
		  [ 2, $text{'acl_matching'},
		    &ui_textbox("vaddrs", $o->{'vaddrs'}, 40) ] ], 1),
	3);

print &ui_table_row($text{'acl_vtypes'},
	join("", map { &ui_checkbox("vedit_".$_, 1, $text{"acl_vtype".$_},
				    $o->{"vedit_".$_}) } 0 .. 2),
	3);

print &ui_table_row($text{'acl_vmax'},
	&ui_radio_table("vmax_def", $o->{'vmax'} ? 0 : 1,
		[ [ 1, $text{'acl_unlimited'} ],
		  [ 0, "", &ui_textbox("vmax", $o->{'vmax'}, 5) ] ], 1),
	3);

print &ui_table_row($text{'acl_vcatchall'},
	&ui_yesno_radio("vcatchall", int($o->{'vcatchall'})));

print &ui_table_hr();

print &ui_table_row($text{'acl_aliases'},
	&ui_radio_table("amode",
		defined($o->{'amode'}) ? $o->{'amode'} : 0,
		[ [ 0, $text{'acl_none'} ],
		  [ 1, $text{'acl_all'} ],
		  [ 3, $text{'acl_asame'} ],
		  [ 2, $text{'acl_matching'},
		    &ui_textbox("aliases", $o->{'aliases'}, 40) ] ], 1),
	3);

print &ui_table_row($text{'acl_atypes'},
	join("", map { &ui_checkbox("aedit_".$_, 1, $text{"acl_atype".$_},
				    $o->{"aedit_".$_}) } 1 .. 6),
	3);

print &ui_table_row($text{'acl_amax'},
	&ui_radio_table("amax_def", $o->{'amax'} ? 0 : 1,
		[ [ 1, $text{'acl_unlimited'} ],
		  [ 0, "", &ui_textbox("amax", $o->{'amax'}, 5) ] ], 1),
	3);

print &ui_table_row($text{'acl_apath'},
	&ui_textbox("apath", $o->{'apath'}, 40)." ".
	&file_chooser_button("apath", 1),
	3);

print &ui_table_hr();

print &ui_table_row($text{'acl_outgoing'},
	&ui_radio_table("omode",
		defined($o->{'omode'}) ? $o->{'omode'} : 0,
		[ [ 0, $text{'acl_none'} ],
		  [ 1, $text{'acl_all'} ],
		  [ 2, $text{'acl_matching'},
		    &ui_textbox("oaddrs", $o->{'oaddrs'}, 40) ] ], 1),
	3);

print &ui_table_hr();

print &ui_table_row($text{'acl_spam'},
	&ui_radio_table("smode", $o->{'smode'},
		[ [ 1, $text{'acl_all'} ],
		  [ 2, $text{'acl_matching'},
		    &ui_textbox("saddrs", $o->{'saddrs'}, 40) ] ], 1),
	3);
}

# acl_security_save(&options)
# Parse the form for security options for the sendmail module
sub acl_security_save
{
$_[0]->{'opts'} = $in{'opts'};
$_[0]->{'ports'} = $in{'ports'};
$_[0]->{'cws'} = $in{'cws'};
$_[0]->{'masq'} = $in{'masq'};
$_[0]->{'trusts'} = $in{'trusts'};
$_[0]->{'cgs'} = $in{'cgs'};
$_[0]->{'relay'} = $in{'relay'};
$_[0]->{'manual'} = $in{'manual'};
$_[0]->{'mailq'} = $in{'mailq'};
$_[0]->{'qdoms'} = $in{'qdoms_def'} ? undef : $in{'qdoms'};
$_[0]->{'qdomsmode'} = $in{'qdomsmode'};
$_[0]->{'mailers'} = $in{'mailers'};
$_[0]->{'access'} = $in{'access'};
$_[0]->{'domains'} = $in{'domains'};
$_[0]->{'stop'} = $in{'stop'};
$_[0]->{'vmode'} = $in{'vmode'};
$_[0]->{'vaddrs'} = $in{'vmode'} == 2 ? $in{'vaddrs'} : "";
$_[0]->{'vmax'} = $in{'vmax_def'} ? undef : $in{'vmax'};
foreach $i (0..2) {
	$_[0]->{"vedit_$i"} = $in{"vedit_$i"};
	}
$_[0]->{'vcatchall'} = $in{'vcatchall'};
$_[0]->{'amode'} = $in{'amode'};
$_[0]->{'aliases'} = $in{'amode'} == 2 ? $in{'aliases'} : "";
$_[0]->{'amax'} = $in{'amax_def'} ? undef : $in{'amax'};
$_[0]->{'apath'} = $in{'apath'};
foreach $i (1..6) {
	$_[0]->{"aedit_$i"} = $in{"aedit_$i"};
	}
$_[0]->{'omode'} = $in{'omode'};
$_[0]->{'oaddrs'} = $in{'omode'} == 2 ? $in{'oaddrs'} : "";
$_[0]->{'flushq'} = $in{'flushq'};
$_[0]->{'smode'} = $in{'smode'};
$_[0]->{'saddrs'} = $in{'smode'} == 2 ? $in{'saddrs'} : "";
}

