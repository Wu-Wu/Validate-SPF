# NAME

Validate::SPF - Validates SPF text string

# VERSION

version 0.001

# FUNCTIONS

## validate

parse and validate SPF string

## check\_extra

Checks extra parameters for mechanisms and modifiers.

# PRIVATE FUNCTIONS

## \_validate\_a

Additional checks for A mechanism.

## \_validate\_mx

Additional checks for MX mechanism.

## \_validate\_ip4

Additional checks for IP4 mechanism.

## \_validate\_ip6

Additional checks for IP6 mechanism.

## \_validate\_ptr

Additional checks for PTR mechanism.

## \_validate\_exists

Additional checks for EXISTS mechanism.

## \_validate\_include

Additional checks for INCLUDE mechanism.

## \_validate\_redirect

Additional checks for REDIRECT modifier.

## \_validate\_exp

Additional checks for EXP modifier.

# AUTHOR

Anton Gerasimov <chim@cpan.org>

# COPYRIGHT AND LICENSE

This software is copyright (c) 2014 by Anton Gerasimov.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
