package Validate::SPF;

# ABSTRACT: Validates SPF text string

use strict;
use warnings;
use Exporter 'import';
use Validate::SPF::Parser;

# VERSION
# AUTHORITY

our @EXPORT = ();
our @EXPORT_OK = qw(
    validate
);

=head1 SYNOPSIS

    use Validate::SPF qw( validate );

    my $spf_text = 'v=spf1 +a/24 mx mx:mailer.example.com ip4:192.168.0.1/16 -all';

    print $spf_text . "\n";
    print ( validate( $spf_text ) ? 'valid' : 'NOT valid' ) . "\n";

=head1 DESCRIPTION

This module implements basic SPF validation.

B<This is ALPHA quality software. The API may change without notification!>

=head1 EXPORTS

Module does not export any symbols by default.

=func validate

Parse and validate SPF string..

=cut

sub validate {
    my ( $text ) = @_;

    unless ( $text ) {
        return wantarray ? ( 0, 'no SPF string' ) : 0;
    }

    my $parser = Validate::SPF::Parser->new;

    my $parsed = $parser->parse( $text );

    my $is_valid = $parsed ? 1 : 0;
    my $error = $is_valid
                    ? undef
                    : $parser->error->{text} . ": '" . $parser->error->{context} . "'"
                    ;

    return wantarray ? ( $is_valid, $error ) : $is_valid;
}

# a
# a/<prefix-length>
# a:<domain-name>
# a:<domain-name>/<prefix-length>

# mx
# mx/<prefix-length>
# mx:<domain-name>
# mx:<domain-name>/<prefix-length>

# ip4:<IPv4-address>
# ip4:<IPv4-network>/<prefix-length>

# ip6:<IPv6-address>
# ip6:<IPv6-network>/<prefix-length>

# ptr
# ptr:<domain>

# exists:<domain>

# include:<domain>

# redirect=<domain>

# exp=<domain>

=head1 SEE ALSO

L<RFC 7208: Sender Policy Framework (SPF) for Authorizing Use of Domains in Email, Version 1|http://tools.ietf.org/html/rfc7208>

=cut

1;
