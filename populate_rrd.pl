#!/usr/bin/perl
use strict;
use warnings;
use Switch;
use RRDs;

# The ID's of the sensors that you are interested in.
my $DOWN = 132;
my $UPPER = 123;
my $OUT = 186;

# The full path to the rrd-database.
#my $RRD_DB = "/home/jyx/bin/temp.rrd";
my $RRD_DB = "/home/jyx/devel/temp_tdtool/temp.rrd";
my @tdtool_data = `tdtool -l`;

my $temp_out;
my $temp_upper;
my $temp_down;

foreach my $line (@tdtool_data) {
	chomp($line);
	$line =~ m/.*temperature[ \t]*(\d{1,3})[ \t]*([-\.0-9]*).*/;
	my $sensor = $1 if defined $1;
	my $temp = $2 if defined $2;
	# If sendor or temp isn't set, then the match has probably found an
	# invalid line from tdtool (humidity for example).
	next if (not defined $sensor and not defined $temp);

	switch ($sensor) {
		case ($UPPER) { $temp_upper = $temp; }
		case ($DOWN) { $temp_down = $temp; }
		case ($OUT) { $temp_out = $temp; }
	}

	if (defined $temp_upper and $temp_down and $temp_out) {
		my $time = `date +%s`;
		chomp($time);
		# The order here is VERY important, it must match the same as
		# the rrd-database.
		print "$time $temp_down:$temp_upper:$temp_out\n";
		RRDs::update($RRD_DB, "$time:$temp_down:$temp_upper:$temp_out");
		my $err=RRDs::error;
		if ($err) {
			{print "problem generating the graph: $err\n";}
			exit;
		}
		undef $temp_upper;
		undef $temp_down;
		undef $temp_out;
	}
}
