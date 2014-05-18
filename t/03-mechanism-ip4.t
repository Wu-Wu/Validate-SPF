#!/usr/bin/env perl

use Test::Spec;
use Validate::SPF;

describe "Validate::SPF" => sub {

    before all => sub {
        use_ok( 'Validate::SPF' );
    };

    describe "ip4 mechanism" => sub {
        my @spfs = (
            'v=spf1 +ip4:127.0.0.1' =>
                1, undef,
            'v=spf1 -ip4:10.1.10.0/23' =>
                1, undef,
            'v=spf1 +ip4:1.2.3.4  ?ip4:192.168.1.0/24  ' =>
                1, undef,
            'v=spf1 ip4:192.157.005.0/24' =>
                1, undef,
            'v=spf1 ip4:10.90.90.90' =>
                1, undef,
            'v=spf1 ?ip4:10.90.90.91' =>
                1, undef,
            'v=spf1 ip4:0.0.0.0/0' =>
                1, undef,
            'v=spf1 ip4:0.0.0.0/32' =>
                1, undef,
            # invalid ip
            'v=spf1 ?ip4:100.2.300.1' =>
                0, '?ip4:100.2.300.1',
            'v=spf1 ip4:127.0.0.1  -ip4:1.2.3.290  ?ip4:1.2.3.290' =>
                0, '-ip4:1.2.3.290',
            'v=spf1 +ip4:1.2/16' =>
                0, '+ip4:1.2/16',
            # invalid bitmask
            'v=spf1  -ip4:1.2.3.0/34' =>
                0, '-ip4:1.2.3.0/34',
            'v=spf1 ip4:127.0.0.1  ?ip4:1.2.3.4/-1  ?ip4:1.2.3.290' =>
                0, '?ip4:1.2.3.4/-1',
        );

        while ( my ( $text, $result, $error ) = splice @spfs, 0, 3 ) {
            my ( $got_result, $got_error ) = Validate::SPF::validate( $text );

            it "should match result for '$text'" => sub {
                is( $got_result, $result );
            };

            it "should match error for '$text'" => sub {
                is( $got_error, $error );
            };
        }
    };
};

runtests unless caller;
