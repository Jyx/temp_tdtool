#!/usr/bin/perl
use strict;
use warnings;
use RRD::Simple();
my $rrd_file = "/home/jyx/devel/temp_tdtool/temp.rrd";
my $rrd = RRD::Simple->new();
$rrd->add_source($rrd_file, 'comp' => 'GAUGE');
