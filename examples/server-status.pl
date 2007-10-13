#!/usr/bin/perl
use strict;
use warnings;
use Parse::Apache::ServerStatus;

$|++;
my %request  = (url => 'http://localhost/server-status', timeout => 10);
my $prs      = Parse::Apache::ServerStatus->new();
my @order    = qw/p ta tt r i _ S R W K D C L G I ./;
my $interval = 1;
my $header   = 20;

while ( 1 ) {
    print map { sprintf("%8s", $_) } @order;
    print "\n";
    for (my $i = 0; $i <= $header; $i++) {
        my $stat = $prs->get(\%request) or die $prs->errstr();
        print map { sprintf("%8s", $stat->{$_}) } @order;
        print "\n";
        sleep($interval);
    }
}
