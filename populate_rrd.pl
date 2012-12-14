#!/usr/bin/perl
################################################################################
# Author: Joakim Bech (joakim.bech@gmail.com)                                  #
# Site  : http://joakimbech.com                                                #
#         http://jyx.se                                                        #
#         http://jyx.dyndns.org                                                #
################################################################################
use strict;
use warnings;
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

	# It doesn't matter that we store values from other sensors in the hash,
	# since we right after check for just the sensors that we are interested
	# in.
	$temps{$sensor} = $temp;

	# When all sensors has a valid value, we update the rrd database, and
	# then immediately exit since we are done with out job.
	if ($temps{$UPPER} ne "NaN" and
	    $temps{$DOWN} ne "NaN" and
	    $temps{$OUT} ne "NaN") {
		# The order here is VERY important, it must match the same as
		# the rrd-database.
		#print time() . " $temps{$DOWN}:$temps{$UPPER}:$temps{$OUT}\n";
		RRDs::update($RRD_DB, time() . ":$temps{$DOWN}:$temps{$UPPER}:$temps{$OUT}");
		my $err = RRDs::error;
		print "problem generating the graph: $err\n" if $err;
		exit
	}
}
