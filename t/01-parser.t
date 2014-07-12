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
                { qualifier => '+' },
            '?all' =>
                { qualifier => '?' },
            '-all' =>
                { qualifier => '-' },
            '+all' =>
                { qualifier => '+' },
            '?All' =>
                { qualifier => '?' },
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
                { qualifier => '+', ipaddress => '127.0.0.1' },
            '?ip4:1.2.3.4' =>
                { qualifier => '?', ipaddress => '1.2.3.4' },
            '~ip4:10.90.90.90' =>
                { qualifier => '~', ipaddress => '10.90.90.90' },
            '-ip4:172.16.1.250' =>
                { qualifier => '-', ipaddress => '172.16.1.250' },
            # Subnet
            'ip4:10.0.0.0/8' =>
                { qualifier => '+', network => '10.0.0.0', bitmask => '8' },
            '?ip4:192.168.1.0/24' =>
                { qualifier => '?', network => '192.168.1.0', bitmask => '24' },
            '-ip4:20.0.0.0/0' =>
                { qualifier => '-', network => '20.0.0.0', bitmask => '0' },
            '~ip4:6.7.8.9/32' =>
                { qualifier => '~', network => '6.7.8.9', bitmask => '32' },
            # TODO
            # XXX: fix it? or not fix?
            'ip4:11.22.33.500' =>
                { qualifier => '+', domain => '11.22.33.500' },
            'ip4:11.22.33.501/44' =>
                { qualifier => '+', domain => '11.22.33.501', bitmask => '44' },
            'ip4:7.8.9.10/33' =>
                { qualifier => '+', network => '7.8.9.10', bitmask => '33' },
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

    describe "[ip6]" => sub {
        my @ip6s_ok = (
            # IP address
            'ip6:2a00:f940::37' =>
                { qualifier => '+', ipaddress => '2a00:f940::37' },
            '?ip6:1::8' =>
                { qualifier => '?', ipaddress => '1::8' },
            '-ip6:3ffe:0b00:0000:000:0001:00:0:000a' =>
                { qualifier => '-', ipaddress => '3ffe:0b00:0000:000:0001:00:0:000a' },
            # TODO
            # '~ip6:2001:0db8:1234::' =>
            #     { qualifier => '~', ipaddress => '2001:0db8:1234::' },
            # '?ip6:fe80::217:f2ff:254.7.237.98' =>
            #     { qualifier => '?', ipaddress => 'fe80::217:f2ff:254.7.237.98' },
            # Subnet
            'ip6:2a00:f940::37/96' =>
                { qualifier => '+', network => '2a00:f940::37', bitmask => '96' },
        );

        my @ip6s_not_ok = (
            'ip6' =>
                { code => 'E_IPADDR_EXPECTED', context => 'ip6' },
            '?ip6' =>
                { code => 'E_IPADDR_EXPECTED', context => '?ip6' },
            'ip6/96' =>
                { code => 'E_IPADDR_EXPECTED', context => 'ip6/96' },
            '~ip6/' =>
                { code => 'E_IPADDR_EXPECTED', context => '~ip6' },
            '+ip6:1111:::3:4:5:6:7:8888/96' =>
                { code => 'E_SYNTAX', context => '+ip6:<*>1111:::3:4:5:6:7:8888/96' },
        );

        while ( my ( $case, $result ) = splice @ip6s_ok, 0, 2 ) {
            it "should return result for '$case'" => sub {
                my $got_result = $stash{parser}->parse( $case );

                diag( explain( $stash{parser}->error ) )    unless $got_result;
                is_deeply( $got_result, [ { %$result, type => 'mech', mechanism => 'ip6' } ] );
            };
        }

        while ( my ( $case, $err ) = splice @ip6s_not_ok, 0, 2 ) {
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
