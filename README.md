# NAME

Validate::SPF - Validates SPF text string

# VERSION

version 0.002

# SYNOPSIS

    use Validate::SPF qw( validate );

    my $spf_text = 'v=spf1 +a/24 mx mx:mailer.example.com ip4:192.168.0.1/16 -all';

    print $spf_text . "\n";
    print ( validate( $spf_text ) ? 'valid' : 'NOT valid' ) . "\n";

# DESCRIPTION

This module implements basic SPF validation.

**This is ALPHA quality software. The API may change without notification!**

# EXPORTS

Module does not export any symbols by default. At request available the following symbols:

## validate

See ["validate"](#validate).

# FUNCTIONS

## validate

Parse and validate SPF string..

## check\_extra

Checks extra parameters of the tokens (mechanisms, modifiers). Uses the appropriate private function
to validate it. Returns the result of calling this function, or 0 if no function found.

# PRIVATE FUNCTIONS

## \_validate\_a

Additional checks for A mechanism.

The A records can be passed as

    a
    a/<prefix-length>
    a:<domain-name>
    a:<domain-name>/<prefix-length>

If no _domain-name_ given, the **current domain** is used.

## \_validate\_mx

Additional checks for MX mechanism.

The MX records can be passed as

    mx
    mx/<prefix-length>
    mx:<domain-name>
    mx:<domain-name>/<prefix-length>

If no _domain-name_ given, the **current domain** is used.

## \_validate\_ip4

Additional checks for IP4 mechanism.

IPv4 addresses can be passed as

    ip4:<IPv4-address>
    ip4:<IPv4-network>/<prefix-length>

If no _prefix-length_ given, the **/32** is assumed.

## \_validate\_ip6

Additional checks for IP6 mechanism.

IPv6 addresses can be passed as

    ip6:<IPv6-address>
    ip6:<IPv6-network>/<prefix-length>

If no _prefix-length_ given, the **/128** is assumed.

## \_validate\_ptr

Additional checks for PTR mechanism.

    ptr
    ptr:<domain>

## \_validate\_exists

Additional checks for EXISTS mechanism.

    exists:<domain>

## \_validate\_include

Additional checks for INCLUDE mechanism.

    include:<domain>

## \_validate\_redirect

Additional checks for REDIRECT modifier.

    redirect=<domain>

## \_validate\_exp

Additional checks for EXP modifier.

    exp=<domain>

# SEE ALSO

[RFC 7208](http://tools.ietf.org/html/rfc7208)

Sender Policy Framework (SPF) for Authorizing Use of Domains in Email, Version 1.

# AUTHOR

Anton Gerasimov <chim@cpan.org>

# COPYRIGHT AND LICENSE

This software is copyright (c) 2014 by Anton Gerasimov.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
