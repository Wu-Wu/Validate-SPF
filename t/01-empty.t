#!/usr/bin/env perl

use Test::Spec;
use Validate::SPF;

describe "Validate::SPF" => sub {

    before all => sub {
        use_ok( 'Validate::SPF' );
    };

    describe "empty string" => sub {
        my @spfs = (
            'undefined' => undef,   'no SPF string',
            'empty'     => '',      'no SPF string',
            'blank'     => ' ',     'empty SPF string',
        );

        while ( my ( $case, $spf, $error ) = splice @spfs, 0, 3 ) {
            my ( $got_result, $got_error ) = Validate::SPF::validate( $spf );

            it "should not be ok for $case SPF" => sub {
                ok( ! $got_result );
            };
            it "should return correct error for $case SPF" => sub {
                is( $got_error, $error );
            };
        }
    };
};

runtests unless caller;
