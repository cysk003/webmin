
require 'format-lib.pl';

# acl_security_form(&options)
# Output HTML for editing security options for the format module
sub acl_security_form
{
my ($o) = @_;
my @dlist = &list_disks();
my @dopts;
foreach my $d (@dlist) {
	$d->{'device'} =~ s/^.*\///;
	push(@dopts, [ $d->{'device'}, "$d->{'desc'} ($d->{'type'})" ]);
	}

print &ui_table_row($text{'acl_disks'},
	&ui_radio("disks_def", $o->{'disks'} eq '*' ? 1 : 0,
		  [ [ 1, $text{'acl_dall'} ],
		    [ 0, $text{'acl_dsel'} ] ])."<br>\n".
	&ui_select("disks", [ split(/\s+/, $o->{'disks'}) ], \@dopts, 4, 1),
	3);

print &ui_table_row($text{'acl_view'},
	&ui_radio("view", $o->{'view'},
		  [ [ 0, $text{'yes'} ], [ 1, $text{'no'} ] ]));
}

# acl_security_save(&options)
# Parse the form for security options for the format module
sub acl_security_save
{
if ($in{'disks_def'}) {
	$_[0]->{'disks'} = "*";
	}
else {
	$_[0]->{'disks'} = join(" ", split(/\0/, $in{'disks'}));
	}
$_[0]->{'view'} = $in{'view'};
}

