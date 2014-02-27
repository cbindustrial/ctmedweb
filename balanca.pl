#!/usr/bin/perl
use warnings;
use strict;
use Device::SerialPort;

my $port = Device::SerialPort->new("/dev/serial/by-id/usb-1a86_USB2.0-Ser_-if00-port0") || print "2.56|2.26|0.30|30|127";
$port->databits(8);
$port->baudrate(9600);
$port->parity("none");
$port->stopbits(1);
my $STALL_DEFAULT=2; # how many seconds to wait for new input
my $timeout=$STALL_DEFAULT;
$port->read_char_time(0);     # don't wait for each character
$port->read_const_time(1000); # 1 second per unfulfilled "read" call
my $chars=0;
my $buffer="";
while ($chars<512) {
my ($count,$saw)=$port->read(512); # will read _up to_ 255 chars
#	if ($count > 0) {
			$chars += $count;
			$buffer = $saw;
			# Check here to see if what we want is in the $buffer
			# say "last" if we find it
#	}	else {
#		$timeout--;
#	}
}
#if ( $timeout == 0 ) {
#	$port -> close || print "2.56|2.26|0.30|22|22";
#	undef $port;
	# 	print "2.56|2.26|0.30|33|33";
#}
$port->close || print "2.56|2.26|0.30|44|44";
undef $port;
### é preciso para geral $1
#print ">>>>$buffer<<<<<<\n";
#$buffer =~ /(\nG(.*)\nN(.*)\nT(.*)\n)/i;
#print ">>$1<<<\n$buffer";
#if ($buffer =~ /G(.*)s/){
#  my $cont = "G".$1."s\n";
#  print $cont;
#}
#my @lin=split("\r",$buffer);
#my $l1=$lin[0];
my $lin = $buffer;
$lin =~ /(\nG  (.*)\n)/i;
my $l1 = $1;
if( $l1 =~ /\+ (.*)kg/){ $l1=$1; }
$l1 =~ s/^\s+|\s+$//g ;

#my $l2=$lin[1];
$lin = $buffer;
$lin =~ /(\nN  (.*)\n)/i;
my $l2 = $1;
if ($l2 =~ /\+ (.*)kg/){ $l2=$1; }
$l2 =~ s/^\s+|\s+$//g ;

$lin = $buffer;
$lin =~ /(\nT  (.*)\n)/i;
my $l3=$1;
if ($l3 =~ /\+ (.*)kg/){ $l3=$1; }
$l3 =~ s/^\s+|\s+$//g ;

#my $l4=$lin[3];
#if ($l4 =~ /\+ (.*)kg/){ $l4=$1; }
#$l4 =~ s/^\s+|\s+$//g ;
$lin = $buffer;
$lin =~ /(\nU\/W  (.*)\n)/i;
my $l4 = $1;
if ($l4 =~ /U\/W  (.*)g/){ $l4=$1; }
$l4 =~ s/^\s+|\s+$//g ;

$lin = $buffer;
$lin =~ /(\nQ (.*)\n)/i;
my $l5 = $1;
if ($l5 =~ /Q (.*)/){ $l5=$1; }
$l5 =~ s/^\s+|\s+$//g ;
$l5 =~ s/ pcs//g ;

print "$l1|$l2|$l3|$l4|$l5";

exit;
