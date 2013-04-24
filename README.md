# NAME

PrankCall - call remote services and hang up without waiting for a response

# SYNOPSIS

    my $prank = PrankCall->new(
        host => 'somewhere.beyond.the.sea',
        port => '10827',
        callback => sub {
          my $error = pop;
          # Callback called after service has been called
        }
    );

    $prank->get(path => '/', params => { 'bobby' => 'darin' }); # note, prank calls always succeed
    $prank->post(path => '/', body => { 'pizza' => 'hut' }); # note, prank calls always succeed

# DESCRIPTION

Sometimes you just wanna call someone and hang up without waiting for them to say anything.
PrankCall is your friend (but, oddly, also your nemesis).

# METHODS

## new( host => $str, \[ port => $str\], \[ callback => $sub\_ref\] )

The constructor can take a number of paremeters, being the usual host/port. It can also accept
a callback method which is called after the socket completes, if there was an error this will come
back as a parameter.

## get( path => $str, params => $hashref, \[ request\_obj => HTTP::Request \] )

Will perform a GET request, also accepts an optional HTTP::Request object.

## post( path => $str, body => $hashref, \[ request\_obj => HTTP::Request \] )

Will perform a POST request, also accepts an optional HTTP::Request object.

# AUTHOR

Logan Bell, with help from Belden Lyman.

# LICENSE

Copyright (c) 2013 Logan Bell and Shutterstock Inc (http://shutterstock.com).  All rights reserved.  This program is free software; you can redistribute it and/or modify it under the same terms as Perl itself.
