use Test::Spec;
use Validate::SPF::Parser;

spec_helper 'mechanism.pl';

my $mech = 'ip6';

describe "Validate::SPF::Parser [$mech]" => sub {
    share my %vars;

    before all => sub {
        $vars{parser} = Validate::SPF::Parser->new;
        $vars{mech} = $mech;
    };

    my @positive = (
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

    my @negative = (
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

    while ( my ( $case, $result ) = splice @positive, 0, 2 ) {
        describe "positive for '$case'" => sub {

            before sub {
                @vars{qw( case result )} = ( $case, $result );
            };

            it_should_behave_like "mechanism positive";
        };
    }

    while ( my ( $case, $result ) = splice @negative, 0, 2 ) {
        describe "negative for '$case'" => sub {

            before sub {
                @vars{qw( case result )} = ( $case, $result );
            };

            it_should_behave_like "mechanism negative";
        };
    }
};

runtests unless caller;
