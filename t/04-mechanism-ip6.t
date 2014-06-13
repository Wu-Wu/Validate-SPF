#!/usr/bin/env perl

use Test::Spec;
use Validate::SPF;

describe "Validate::SPF" => sub {

    before all => sub {
        use_ok( 'Validate::SPF' );
    };

    xdescribe "ip6 mechanism" => sub {
        my @spfs = (
            'v=spf1 +ip6:1080::8:800:200C:417A' =>
                1, undef,
            'v=spf1 -ip6:1080::8:800:68.0.3.1/96' =>
                1, undef,
            'v=spf1 ip6:::2:3:4:5:6:7:8' =>
                1, undef,
            'v=spf1 ip6:1::8' =>
                1, undef,
            'v=spf1 ip6:::ffff:255.255.255.255' =>
                1, undef,
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
