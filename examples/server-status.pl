#!/usr/bin/perl
use strict;
use warnings;
use Parse::Apache::ServerStatus;

my $request  = 'http://localhost/server-status';
my $timeout  = 10;
my $prs      = Parse::Apache::ServerStatus->new();
my @order    = qw(r i p _ S R W K D C L G I .);
my $head_int = 20;
my $interval = 3;
my $h_int    = 0;

while ( 1 ) {
   my $stat = $prs->get(url => $request, timeout => $timeout)
      or die $prs->errstr();

   if ($h_int == 0) {
      print map { sprintf("%6s", $_) } @order;
      print "\n";
      $h_int = $head_int;
   }

   print map { sprintf("%6s", $stat->{$_}) } @order;
   print "\n";

   sleep($interval);
   --$h_int;
}
