use strict;
use warnings;
use Test::More tests => 4;
use Test::Fake::HTTPD;
use HTTP::Request;

require_ok('PrankCall');

my $class = 'PrankCall';
my ($obj, $httpd);

my $called = 0;
$httpd = run_http_server {
  my $request = shift;
  my $path = $request->uri->path;
  if ( $path eq '/' ) {
    $called++;
  }
  is $called, 1;
  return [ 200 , [ 'Content-Type' => 'text/plain'], ['Success!'] ];
};

ok $httpd;

$obj = $class->new(host => 'http://127.0.0.1', port => $httpd->port);
$obj->get(path => '/', params => { 'foo' => 'bar' });

$httpd = run_http_server {
  my $request = shift;
  my $path = $request->uri->path;
  if ( $path eq '/http_request' ) {
    $called++;
  }
  is $called, 1;
  return [ 200 , [ 'Content-Type' => 'text/plain'], ['Success!'] ];
};

$obj = $class->new;
$obj->get( request_obj => HTTP::Request->new(GET => join('/', $httpd->endpoint, 'http_request')));

sleep 2;
