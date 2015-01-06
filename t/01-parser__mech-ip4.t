use Test::Spec;
use Validate::SPF::Parser;

my $mech = 'ip4';

describe "Validate::SPF::Parser [$mech]" => sub {
    my ( $parser );

    before all => sub {
        $parser = Validate::SPF::Parser->new;
    };

    my @positive = (
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

    my @negative = (
        'ip4' =>
            { code => 'E_IPADDR_EXPECTED', context => 'ip4' },
        '?ip4' =>
            { code => 'E_IPADDR_EXPECTED', context => '?ip4' },
        'ip4/24' =>
            { code => 'E_IPADDR_EXPECTED', context => 'ip4/24' },
        '~ip4/' =>
            { code => 'E_IPADDR_EXPECTED', context => '~ip4' },
    );

    while ( my ( $case, $result ) = splice @positive, 0, 2 ) {
        describe "positive for '$case'" => sub {

            it "should return correct result" => sub {
                cmp_deeply(
                    $parser->parse( $case ),
                    [
                        {
                            %{ $result },
                            type => 'mech',
                            mechanism => $mech
                        }
                    ]
                );
            };
        };
    }

    while ( my ( $case, $result ) = splice @negative, 0, 2 ) {
        describe "negative for '$case'" => sub {

            before sub {
                $parser->parse( $case );
            };

            it "should return correct error" => sub {
                cmp_deeply(
                    $parser->error,
                    { %{ $result }, text => ignore() }
                );
            };
        };
    }
};

runtests unless caller;
