#!/usr/bin/env perl

use Test::Spec;

my $module = 'Validate::SPF::Parser';

describe $module => sub {
    share my %stash;

    before all => sub {
        use_ok( $module );
        $stash{parser} = new_ok( $module );
    };

    describe "[version]" => sub {
        it "should parse 'v=spf1' without errors" => sub {
            is_deeply(
                $stash{parser}->parse('v=spf1'),
                [ { type => 'ver', version => 'v=spf1' } ]
            );
        };

        it "should not parse and raise error for 'v=spf2'" => sub {
            $stash{parser}->parse('v=spf2');
            is_deeply(
                $stash{parser}->error,
                {
                    code    => 'E_INVALID_VERSION',
                    context => 'v=spf2',
                    text    => 'Invalid SPF version',
                }
            );
        };
    };

    describe "[all]" => sub {
        my @alls_ok = (
            'all' =>
                { type => 'mech', qualifer => '+', mechanism => 'all' },
            '?all' =>
                { type => 'mech', qualifer => '?', mechanism => 'all' },
            '-all' =>
                { type => 'mech', qualifer => '-', mechanism => 'all' },
            '+all' =>
                { type => 'mech', qualifer => '+', mechanism => 'all' },
            '?All' =>
                { type => 'mech', qualifer => '?', mechanism => 'all' },
        );

        while ( my ( $case, $result ) = splice @alls_ok, 0, 2 ) {
            it "should return result for '$case'" => sub {
                my $got_result = $stash{parser}->parse( $case );
                is_deeply( $got_result, [ $result ] );
            };
        }

        it "should return syntax error for '%all'" => sub {
            $stash{parser}->parse( '%all' );

            is $stash{parser}->error->{code}, 'E_SYNTAX';
        };
    };
};

runtests unless caller;
