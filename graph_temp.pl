#!/usr/bin/perl

use RRDs;

my $cur_time = time();
my $start_time = $cur_time - 86400;     # set end time to 24 hours ago
                
RRDs::graph "/var/www/temp/out.png",   
			"--start= $start_time",
			"--end= $cur_time",
			"--title= Temperatur Johanna Wolls Väg, Kävlinge",
			"--height= 300",
			"--width= 500",
			"--vertical-label= °C",
	      "DEF:OutsideTemp=/home/jyx/devel/temp_tdtool/temp.rrd:out:AVERAGE",
	      "DEF:temp_upper=/home/jyx/devel/temp_tdtool/temp.rrd:upper:AVERAGE",
	      "DEF:temp_down=/home/jyx/devel/temp_tdtool/temp.rrd:down:AVERAGE",
	      "DEF:comp=/home/jyx/devel/temp_tdtool/temp.rrd:comp:AVERAGE",
			"COMMENT:\t\t\t\tNu     Medel    Max    Min\\n",
			"HRULE:0#0000FF",         
	      "LINE1:OutsideTemp#0000FF:Ute\t\t\t",    
			"GPRINT:OutsideTemp:LAST:%6.1lf",
			"GPRINT:OutsideTemp:AVERAGE:%6.1lf",
			"GPRINT:OutsideTemp:MAX:%6.1lf",
			"GPRINT:OutsideTemp:MIN:%6.1lf\\n",
	      "LINE1:temp_upper#FF0000:Uppe\t\t\t",
			"GPRINT:temp_upper:LAST:%6.1lf",
			"GPRINT:temp_upper:AVERAGE:%6.1lf",
			"GPRINT:temp_upper:MAX:%6.1lf",
			"GPRINT:temp_upper:MIN:%6.1lf\\n",
	      "LINE1:temp_down#00FF00:Nere\t\t\t",
			"GPRINT:temp_down:LAST:%6.1lf",
			"GPRINT:temp_down:AVERAGE:%6.1lf",
			"GPRINT:temp_down:MAX:%6.1lf",
			"GPRINT:temp_down:MIN:%6.1lf\\n",
	      "LINE1:comp#00FFFF:Dator\t\t\t",
			"GPRINT:comp:LAST:%6.1lf",
			"GPRINT:comp:AVERAGE:%6.1lf",
			"GPRINT:comp:MAX:%6.1lf",
			"GPRINT:comp:MIN:%6.1lf\\n";

my $err=RRDs::error;
if ($err) {print "problem generating the graph: $err\n";}

print "Done!\n"
