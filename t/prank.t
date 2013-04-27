use strict;
use warnings;
use Test::More tests => 9;
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

$httpd = run_http_server {
  my $request = shift;
  my $path = $request->uri->path;
  if ( $path eq '/http_post_request' ) {
    $called++;
  }
  is $called, 1;
  return [ 200 , [ 'Content-Type' => 'text/plain'], ['Success!'] ];
};

$obj = $class->new;
$obj->post( request_obj => HTTP::Request->new(POST => join('/', $httpd->endpoint, 'http_post_request')));

$httpd = run_http_server {
  my $called;
  my $request = shift;
  my $path = $request->uri->path;
  if ( $path eq '/http_post_request_with_body' ) {
    is $request->content, 'foo=bar';
    $called++;
  }
  is $called, 1;
  return [ 200 , [ 'Content-Type' => 'text/plain'], ['Success!'] ];
};

$obj = $class->new(host => 'http://127.0.0.1', port => $httpd->port, cache_socket => 1, timeout => 10);
$obj->post( path => '/http_post_request_with_body', body => { foo => 'bar' }, callback => sub {
  my ($prank, $error) = @_;
  sleep 1;
  $prank->redial;
});

sleep 5;
