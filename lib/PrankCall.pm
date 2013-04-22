package PrankCall;
use strict;
use warnings;

use HTTP::Request;
use IO::Socket;
use URI;

# ABSTRACT: PrankCall Fast non blocking GET requests

sub new {
  my ($class, %params) = @_;

  my $self = {
    host => $params{host},
    port => $params{port} ||= 80,
    request_obj => $params{request_obj},
    # TODO: other params
  };

  bless $self, $class;
}

sub get {
  my ($self, %params) = @_;  

  my $req = $self->{request_obj} || do {
    my $path = $params{path};
    my $params = $params{params};

    my $uri = URI->new($self->{host});
    $uri->path($path);
    $uri->port($self->{port});
    $uri->query_form($params);

    my $req = HTTP::Request->new(GET => $uri->as_string);
    $req->protocol("HTTP/1.1");
    $req;
  };

  my $http_string = $req->as_string;
  my $port = $req->uri->port;
  my $raw_host = $req->uri->host;

  $req->protocol("HTTP/1.1");
  my $error = do {
    eval {
      my $remote = IO::Socket::INET->new( Proto => 'tcp', PeerAddr => $raw_host, PeerPort => $port ) || die "Ah shoot Johny $!";
      $remote->autoflush(1);
      $remote->send($http_string);
      close $remote;
    };
    $@;
  };

  if ($error) {
    # TODO if they want errors?
    warn $error;
  }
}

1;
