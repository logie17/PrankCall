package PrankCall;
use strict;
use warnings;

use HTTP::Request;
use IO::Socket;
use URI;

sub new {
  my ($class, %params) = @_;

  my $self = {
    host => $params{host},
    port => $params{port} ||= 80,
    # TODO: other params
  };

  bless $self, $class;
}

sub get {
  my ($self, %params) = @_;  

  my $req = $params{request_obj} || $self->_build_request(method => 'GET', %params);
  $self->_send_request($req);

  return 1;
}

sub post {
  my ($self, %params) = @_;

  my $req = $params{request_obj} || $self->_build_request(method => 'POST', %params);
  $self->_send_request($req);

  return 1;
}

sub _build_request {
  my ($self, %params) = @_;
  my $path = $params{path};
  my $params = $params{params};

  my $uri = URI->new($self->{host});
  $uri->path($path);
  $uri->port($self->{port});
  $uri->query_form($params);

  my $req = HTTP::Request->new($params{method} => $uri->as_string);
  $req->protocol("HTTP/1.1");
  return $req;
}

sub _send_request {
  my ($self, $req) = @_;

  my $http_string = $req->as_string;
  my $port = $req->uri->port;
  my $raw_host = $req->uri->host;

  my $error = do {
    local $@;
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

__END__

=head1 NAME

PrankCall - call remote services and hang up without waiting for a response

=head1 SYNOPSIS

    my $prank = PrankCall->new(
        host => 'somewhere.beyond.the.sea',
        port => '10827',
    );

    $prank->get(path => '/', params => { 'bobby' => 'darin' }); # note, prank calls always succeed
    $prank->post(path => '/', params => { 'pizza' => 'hut' }); # note, prank calls always succeed

=head1 DESCRIPTION

Sometimes you just wanna call someone and hang up without waiting for them to say anything.
PrankCall is your friend (but, oddly, also your nemesis).

=head1 AUTHOR

Logan Bell

=head1 LICENSE

This is released under the "Don't blame me" license. Don't blame me for this idea.
