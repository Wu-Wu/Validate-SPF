#!/usr/bin/env perl

use Test::Spec;
use Validate::SPF;

describe "Validate::SPF" => sub {

    before all => sub {
        use_ok( 'Validate::SPF' );
    };

    describe "version" => sub {
        my @spfs = (
            'v=spf1 all'    => 1, undef,
            '+all'          => 0, 'SPF should start with version token: v=spf1',
            'v=spf2 -all'   => 0, 'SPF should start with version token: v=spf1',
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
