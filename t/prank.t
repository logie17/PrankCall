use strict;
use warnings;
use Test::More tests => 3;
use Test::Fake::HTTPD;

require_ok('PrankCall');

my $httpd = run_http_server {
  my $request = shift;
  ok $request;
};

ok $httpd;

my $obj = PrankCall->new(host => 'http://127.0.0.1', port => $httpd->port);
$obj->get(path => '/', params => { 'foo' => 'bar' });
