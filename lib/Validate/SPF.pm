package Validate::SPF;

use strict;
use warnings;
use Exporter 'import';

our $VERSION = '0.001';

our @EXPORT = ();
our @EXPORT_OK = (qw(
    validate
));

# parse and validate SPF string
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

sub _validate_a {
    my ( $extra, $options ) = @_;

    return 0;
}

sub _validate_mx {
    my ( $extra, $options ) = @_;

    return 0;
}

sub _validate_ip4 {
    my ( $extra, $options ) = @_;

    return 0;
}

sub _validate_ip6 {
    my ( $extra, $options ) = @_;

    return 0;
}

sub _validate_ptr {
    my ( $extra, $options ) = @_;

    return 0;
}

sub _validate_exists {
    my ( $extra, $options ) = @_;

    return 0;
}

sub _validate_include {
    my ( $extra, $options ) = @_;

    return 0;
}

sub _validate_redirect {
    my ( $extra, $options ) = @_;

    return 0;
}

sub _validate_exp {
    my ( $extra, $options ) = @_;

    return 0;
}

1;
