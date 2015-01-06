# NAME

Validate::SPF - Validates SPF text string

[![Build Status](https://travis-ci.org/Wu-Wu/Validate-SPF.svg?branch=master)](https://travis-ci.org/Wu-Wu/Validate-SPF)

# VERSION

version 0.004

# SYNOPSIS

    use Validate::SPF qw( validate );

    my $spf_text = 'v=spf1 +a/24 mx mx:mailer.example.com ip4:192.168.0.1/16 -all';

    print $spf_text . "\n";
    print ( validate( $spf_text ) ? 'valid' : 'NOT valid' ) . "\n";

# DESCRIPTION

This module implements basic SPF validation.

**This is ALPHA quality software. The API may change without notification!**

# FUNCTIONS

## validate

Parse and validate SPF string..

# EXPORTS

Module does not export any symbols by default.

# SEE ALSO

Please see those modules/websites for more information related to this module.

- [RFC 7208: Sender Policy Framework (SPF) for Authorizing Use of Domains in Email, Version 1](http://tools.ietf.org/html/rfc7208)

# BUGS

Please report any bugs or feature requests on the bugtracker website
https://github.com/Wu-Wu/Validate-SPF/issues

When submitting a bug or request, please include a test-file or a
patch to an existing test-file that illustrates the bug or desired
feature.

# AUTHOR

Anton Gerasimov <chim@cpan.org>

# COPYRIGHT AND LICENSE

This software is copyright (c) 2014 by Anton Gerasimov.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
