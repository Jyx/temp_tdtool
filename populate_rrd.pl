#!/usr/bin/perl
################################################################################
# Author: Joakim Bech (joakim.bech@gmail.com)                                  #
# Site  : http://joakimbech.com                                                #
#         http://jyx.se                                                        #
#         http://jyx.dyndns.org                                                #
################################################################################
use strict;
use warnings;
use Switch;
use RRDs;

# The ID's of the sensors that you are interested in. If you add remove these,
# you also need to add and remove on all places below.
my $DOWN = 132;
my $UPPER = 123;
my $OUT = 10;

my %temps = ( $DOWN, "NaN",
	      $UPPER, "NaN",
	      $OUT, "NaN" );

# The full path to the rrd-database.
my $RRD_DB = "/home/jyx/bin/temp.rrd";
#my $RRD_DB = "/home/jyx/devel/temp_tdtool/temp.rrd";
my @tdtool_data = `tdtool -l`;

foreach my $line (@tdtool_data) {
	chomp($line);
	$line =~ m/.*temperature[ \t]*(\d{1,3})[ \t]*([-\.0-9]*).*/;
	my $sensor = $1 if defined $1;
	my $temp = $2 if defined $2;
	# If sensor or temp isn't set, then the match has probably found an
	# invalid line from tdtool (humidity for example).
	next if (not defined $sensor and not defined $temp);

	switch ($sensor) {
		case ($UPPER) { $temps{$UPPER} = $temp; }
		case ($DOWN) { $temps{$DOWN} = $temp; }
		case ($OUT) { $temps{$OUT} = $temp; }
	}

	# When all sensors has a valid value, we update the rrd database, and
	# then immediately exit since we are done with out job.
	if ($temps{$UPPER} ne "NaN" and
	    $temps{$DOWN} ne "NaN" and
	    $temps{$OUT} ne "NaN") {
		my $time;
		$time = `date +%s`; # Seconds since 1970-01-01 00:00:00 UTC
		chomp($time);
		# The order here is VERY important, it must match the same as
		# the rrd-database.
		# print "$time $temps{$DOWN}:$temps{$UPPER}:$temps{$OUT}\n";
		RRDs::update($RRD_DB, "$time:$temps{$DOWN}:$temps{$UPPER}:$temps{$OUT}");
		my $err=RRDs::error;
		if ($err) {
			{print "problem generating the graph: $err\n";}
			exit;
		}
		exit
	}
}
