package PrankCall;
use strict;
use warnings;

use HTTP::Request;
use IO::Socket;
use URI;

# ABSTRACT: PrankCall Fast non blocking GET requests

sub new {
  my ($class, %params) = @_;

  my $raw_host = $params{host};
  $raw_host =~ s#http://##;

  my $self = {
    host => $params{host},
    port => $params{port} ||= 80,
    raw_host => $raw_host,
    # TODO: other params
  };

  bless $self, $class;
}

sub get {
  my ($self, %params) = @_;  

  my $path = $params{path};
  my $params = $params{params};

  my $uri = URI->new(sprintf("%s/%s", $self->{host}, $path));
  $uri->query_form($params);

  my $req = HTTP::Request->new(GET => $uri->as_string);
  $req->protocol("HTTP/1.1");
  my $http_string = $req->as_string;

  my $error = do {
    eval {
      my $remote = IO::Socket::INET->new( Proto => 'tcp', PeerAddr => $self->{raw_host}, PeerPort => $self->{port} ) || die "Ah shoot Johny $!";
      $remote->autoflush(1);
      print $remote $http_string;
      my $line = <$remote>;
      close $remote;
    };
    $@;
  };

  if ($error) {
    # TODO if they want errors?
  }
  
}

1;
