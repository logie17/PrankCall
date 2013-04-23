package PrankCall;
use strict;
use warnings;

use HTTP::Headers;
use HTTP::Request;
use IO::Socket;
use URI;

sub new {
  my ($class, %params) = @_;

  my ($host, $port, $raw_host);

  if ($params{host}) {
    ($host, $port) = $params{host} =~ m{^(.*?)(?::(\d+))?$};
    $host = 'http://' . $host unless $host =~ /^http/;
    $port ||= $params{port};
    $raw_host = $host;
    $raw_host =~ s{https?://}{};
  } 

  my $self = {
    host => $host,
    port => $port,
    raw_host => $raw_host,
    cb => $params{cb},
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
  my $body  = $params{body};

  my $uri = URI->new($self->{host});
  $uri->path($path);
  $uri->port($self->{port});
  $uri->query_form($params);
  my $headers = HTTP::Headers->new;

  $headers->header('Content-Type' => 'application/x-www-form-urlencoded');
  my $req = HTTP::Request->new($params{method} => $uri->as_string, $headers);

  if ($body) {
    my $uri = URI->new('http:');
    $uri->query_form(%$body);
    my $content = $uri->query;
    $req->content($content);
    $req->content_length(length($content));
  }

  $req->protocol("HTTP/1.1");
  return $req;
}

sub _send_request {
  my ($self, $req) = @_;

  my $http_string = $req->as_string;
  my $port = $self->{port} || $req->uri->port || '80';
  my $raw_host =  $self->{raw_host} || $req->uri->host;

  my $error = do {
    local $@;
    eval {
      my $remote = IO::Socket::INET->new( Proto => 'tcp', PeerAddr => $raw_host, PeerPort => $port ) || die "Ah shoot Johny $!";
      $remote->autoflush(1);
      $remote->send($http_string);
      close $remote;
      if ( $self->{cb}) {
        $self->{cb}();
      }
    };
    $@;
  };

  if ($error && $self->{cb} ) {
    $self->{cb}($error);
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
        cb => sub {
          my $error = pop;
          # Callback called after service has been called
        }
    );

    $prank->get(path => '/', params => { 'bobby' => 'darin' }); # note, prank calls always succeed
    $prank->post(path => '/', body => { 'pizza' => 'hut' }); # note, prank calls always succeed

=head1 DESCRIPTION

Sometimes you just wanna call someone and hang up without waiting for them to say anything.
PrankCall is your friend (but, oddly, also your nemesis).

=head1 METHODS

=head2 new( host => $str, [ port => $str], [ cb => $sub_ref] )

The constructor can take a number of paremeters, being the usual host/port. It can also accept
a callback method which is called after the socket completes, if there was an error this will come
back as a parameter.

=head2 get( path => $str, params => $hashref, [ request_obj => HTTP::Request ] )

Will perform a GET request, also accepts an optional HTTP::Request object.

=head2 post( path => $str, body => $hashref, [ request_obj => HTTP::Request ] )

Will perform a POST request, also accepts an optional HTTP::Request object.

=head1 AUTHOR

Logan Bell, with help from Belden Lyman.

=head1 LICENSE

This is released under the "Don't blame me" license. Don't blame me for this idea.
