package Validate::SPF;

# ABSTRACT: Validates SPF text string

use strict;
use warnings;
use Exporter 'import';

# VERSION
# AUTHORITY

our @EXPORT = ();
our @EXPORT_OK = (qw(
    validate
));

our $TOKENS;

=head1 SYNOPSIS

    use Validate::SPF qw( validate );

    my $spf_text = 'v=spf1 +a/24 mx mx:mailer.example.com ip4:192.168.0.1/16 -all';

    print $spf_text . "\n";
    print ( validate( $spf_text ) ? 'valid' : 'NOT valid' ) . "\n";

=head1 DESCRIPTION

This module implements basic SPF validation.

B<This is ALPHA quality software. The API may change without notification!>

=head1 EXPORTS

TODO

=head1 FUNCTIONS

=head2 validate

Parse and validate SPF string..

=cut

sub validate {
    my ( $text ) = @_;

    unless ( $text ) {
        return wantarray ? ( 0, 'no SPF string' ) : 0;
    }

    my @elements = split /\s+/ => $text;

    unless ( @elements ) {
        return wantarray ? ( 0, 'empty SPF string' ) : 0;
    }

    my $tokens = [];
    $TOKENS = $tokens;

    for my $el ( @elements ) {
        my ( $token, $qualifier, $mechanism, $modifier, $extra );

        if ( $el =~ /v=spf1/ ) {
            $token = {
                type        => 'VERSION',
                version     => $el,
                valid       => 1,
            };
        }
        elsif ( $el =~ /^([\Q+-~?\E]*)(all|ip4|ip6|a|mx|ptr|exists|include)(.*)/i ) {
            ( $qualifier, $mechanism, $extra ) = ( ( $1 || '+' ), $2, ( $3 || undef ) );

            $extra =~ s/^\://   if $extra;

            $mechanism = lc $mechanism;

            $token = {
                type        => 'MECHANISM',
                qualifier   => $qualifier,
                mechanism   => $mechanism,
                extra       => $extra,
                valid       => (
                    $qualifier && $mechanism
                        ? ! $extra
                            ? 1 : check_extra( $mechanism, $extra )
                        : 0
                ),
            };
        }
        elsif ( $el =~ /^(redirect|exp)\=(.+)/i ) {
            ( $modifier, $extra ) = ( $1, ( $2 || undef ) );

            $modifier = lc $modifier;

            $token = {
                type        => 'MODIFIER',
                modifier    => $modifier,
                extra       => $extra,
                valid       => (
                    $modifier && $extra
                        ? check_extra( $modifier, $extra )
                        : 0
                ),
            };
        }
        else {
            $token = {
                type        => 'UNKNOWN',
                valid       => 0,
            };
        }

        $token->{raw} = $el;

        push @$tokens, $token;
    }

    $TOKENS = $tokens;

    my @invalid;

    unless ( $tokens->[0]->{type} eq 'VERSION' ) {
        push @invalid, { raw => 'SPF should start with version token: v=spf1' };
    }
    else {
        @invalid = grep { ! $_->{valid} } @$tokens;
    }

    my $is_valid    = @invalid == 0 ? 1 : 0;
    my $error       = $is_valid ? undef : $invalid[0]->{raw};

    return wantarray ? ( $is_valid, $error ) : $is_valid;
}

=head2 check_extra

Checks extra parameters for mechanisms and modifiers.

=cut

sub check_extra {
    my ( $token, $extra ) = @_;

    my %validators = (
        'a'         => sub { _validate_a( @_ ) },
        'mx'        => sub { _validate_mx( @_ ) },
        'ip4'       => sub { _validate_ip4( @_ ) },
        'ip6'       => sub { _validate_ip6( @_) },
        'ptr'       => sub { _validate_ptr( @_) },
        'exists'    => sub { _validate_exists( @_) },
        'include'   => sub { _validate_include( @_) },
        'redirect'  => sub { _validate_redirect( @_) },
        'exp'       => sub { _validate_exp( @_) },
    );

    return 0    unless exists $validators{ $token };

    return $validators{ $token }->( $extra );
}

=head1 PRIVATE FUNCTIONS

=head2 _validate_a

Additional checks for A mechanism.

The A records can be passed as

    a
    a/<prefix-length>
    a:<domain-name>
    a:<domain-name>/<prefix-length>

If no I<domain-name> given, the B<current domain> is used.

=cut

sub _validate_a {
    my ( $extra, $options ) = @_;

    return 1;
}

=head2 _validate_mx

Additional checks for MX mechanism.

The MX records can be passed as

    mx
    mx/<prefix-length>
    mx:<domain-name>
    mx:<domain-name>/<prefix-length>

If no I<domain-name> given, the B<current domain> is used.

=cut

sub _validate_mx {
    my ( $extra, $options ) = @_;

    return 1;
}

=head2 _validate_ip4

Additional checks for IP4 mechanism.

IPv4 addresses can be passed as

    ip4:<IPv4-address>
    ip4:<IPv4-network>/<prefix-length>

If no I<prefix-length> given, the B</32> is assumed.

=cut

sub _validate_ip4 {
    my ( $ip, $options ) = @_;

    # TODO: support for 10.0/16, 127/8, ...

    my ( $ipaddr_valid, $prefix_valid ) = ( 0, 1 );

    if ( $ip =~ /^((?:[0-9]{1,3}\.){3}[0-9]{1,3})(.*)$/ ) {
        my ( $ipaddr, $prefix ) = ( $1, ( $2 || undef ) );

        if ( $ipaddr ) {
            my @octets =
                grep { $_ >= 0 && $_ <= 255 }   # [0 .. 255]
                map { $_ + 0 }                  # 192.168.001.002
                split /\./ => $ipaddr;

            $ipaddr_valid = @octets == 4 ? 1 : 0;
        }

        if ( $prefix && $prefix =~ m|^/(.*)| ) {
            $prefix = $1;

            $prefix_valid =
                $prefix > -1 && $prefix < 33    # [/0 .. /32]
                    ? 1 : 0;
        }

        return $ipaddr_valid && $prefix_valid;
    }

    return 0;
}

=head2 _validate_ip6

Additional checks for IP6 mechanism.

IPv6 addresses can be passed as

    ip6:<IPv6-address>
    ip6:<IPv6-network>/<prefix-length>

If no I<prefix-length> given, the B</128> is assumed.

=cut

sub _validate_ip6 {
    my ( $extra, $options ) = @_;

    return 1;
}

=head2 _validate_ptr

Additional checks for PTR mechanism.

    ptr
    ptr:<domain>

=cut

sub _validate_ptr {
    my ( $extra, $options ) = @_;

    return 1;
}

=head2 _validate_exists

Additional checks for EXISTS mechanism.

    exists:<domain>

=cut

sub _validate_exists {
    my ( $extra, $options ) = @_;

    return 1;
}

=head2 _validate_include

Additional checks for INCLUDE mechanism.

    include:<domain>

=cut

sub _validate_include {
    my ( $extra, $options ) = @_;

    return 1;
}

=head2 _validate_redirect

Additional checks for REDIRECT modifier.

    redirect=<domain>

=cut

sub _validate_redirect {
    my ( $extra, $options ) = @_;

    return 1;
}

=head2 _validate_exp

Additional checks for EXP modifier.

    exp=<domain>

=cut

sub _validate_exp {
    my ( $extra, $options ) = @_;

    return 1;
}

=head1 SEE ALSO

L<RFC 7208|http://tools.ietf.org/html/rfc7208>

Sender Policy Framework (SPF) for Authorizing Use of Domains in Email, Version 1.

=cut

1;
