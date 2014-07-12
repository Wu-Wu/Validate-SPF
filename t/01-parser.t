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
                { qualifer => '+' },
            '?all' =>
                { qualifer => '?' },
            '-all' =>
                { qualifer => '-' },
            '+all' =>
                { qualifer => '+' },
            '?All' =>
                { qualifer => '?' },
        );

        while ( my ( $case, $result ) = splice @alls_ok, 0, 2 ) {
            it "should return result for '$case'" => sub {
                my $got_result = $stash{parser}->parse( $case );
                is_deeply( $got_result, [ { %$result, type => 'mech', mechanism => 'all' } ] );
            };
        }

        it "should return error E_SYNTAX for '%all'" => sub {
            $stash{parser}->parse( '%all' );

            is $stash{parser}->error->{code}, 'E_SYNTAX';
        };
    };

    describe "[ip4]" => sub {
        my @ip4s_ok = (
            # IP address
            'ip4:127.0.0.1' =>
                { qualifer => '+', ipaddress => '127.0.0.1' },
            '?ip4:1.2.3.4' =>
                { qualifer => '?', ipaddress => '1.2.3.4' },
            '~ip4:10.90.90.90' =>
                { qualifer => '~', ipaddress => '10.90.90.90' },
            '-ip4:172.16.1.250' =>
                { qualifer => '-', ipaddress => '172.16.1.250' },
            # Subnet
            'ip4:10.0.0.0/8' =>
                { qualifer => '+', network => '10.0.0.0', bitmask => '8' },
            '?ip4:192.168.1.0/24' =>
                { qualifer => '?', network => '192.168.1.0', bitmask => '24' },
            '-ip4:20.0.0.0/0' =>
                { qualifer => '-', network => '20.0.0.0', bitmask => '0' },
            '~ip4:6.7.8.9/32' =>
                { qualifer => '~', network => '6.7.8.9', bitmask => '32' },
            # TODO
            # XXX: fix it? or not fix?
            'ip4:11.22.33.500' =>
                { qualifer => '+', domain => '11.22.33.500' },
            'ip4:11.22.33.501/44' =>
                { qualifer => '+', domain => '11.22.33.501', bitmask => '44' },
            'ip4:7.8.9.10/33' =>
                { qualifer => '+', network => '7.8.9.10', bitmask => '33' },
        );

        my @ip4s_not_ok = (
            'ip4' =>
                { code => 'E_IPADDR_EXPECTED', context => 'ip4' },
            '?ip4' =>
                { code => 'E_IPADDR_EXPECTED', context => '?ip4' },
            'ip4/24' =>
                { code => 'E_IPADDR_EXPECTED', context => 'ip4/24' },
            '~ip4/' =>
                { code => 'E_IPADDR_EXPECTED', context => '~ip4' },
        );

        while ( my ( $case, $result ) = splice @ip4s_ok, 0, 2 ) {
            it "should return result for '$case'" => sub {
                my $got_result = $stash{parser}->parse( $case );
                is_deeply( $got_result, [ { %$result, type => 'mech', mechanism => 'ip4' } ] );
            };
        }

        while ( my ( $case, $err ) = splice @ip4s_not_ok, 0, 2 ) {
            it "should return error $err->{code} for '$case'" => sub {
                $stash{parser}->parse( $case );

                cmp_deeply(
                    $stash{parser}->error,
                    { %$err, text => ignore() }
                );
            };
        }
    };
};

runtests unless caller;
