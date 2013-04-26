#! /usr/bin/env perl

use strict;
use warnings;
use Benchmark qw{cmpthese};
use PrankCall;

for (1..1000) {
  my $prank = PrankCall->new(host => 'http://localhost', port => 5000);
  $prank->get(path => '/');
}
