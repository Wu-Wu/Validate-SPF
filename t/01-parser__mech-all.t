use Test::Spec;
use Validate::SPF::Parser;

my $mech = 'all';

describe "Validate::SPF::Parser [$mech]" => sub {
    my ( $parser );

    before all => sub {
        $parser = Validate::SPF::Parser->new;
    };

    my @positive = (
        'all' =>
            { qualifier => '+' },
        '?all' =>
            { qualifier => '?' },
        '-all' =>
            { qualifier => '-' },
        '+all' =>
            { qualifier => '+' },
        '~all' =>
            { qualifier => '~' },
        '?All' =>
            { qualifier => '?' },
    );

    my @negative = (
        'all/24' =>
            { code => 'E_UNEXPECTED_BITMASK', context => 'all/24' },
        '?all/32' =>
            { code => 'E_UNEXPECTED_BITMASK', context => '?all/32' },
        'all:foo.bar.com' =>
            { code => 'E_UNEXPECTED_DOMAIN', context => 'all:foo.bar.com' },
        '-all:quux.com' =>
            { code => 'E_UNEXPECTED_DOMAIN', context => '-all:quux.com' },
        'all:quux.com/21' =>
            { code => 'E_UNEXPECTED_BITMASK', context => 'all:quux.com/21' },
        '~all:www.quux.com/32' =>
            { code => 'E_UNEXPECTED_BITMASK', context => '~all:www.quux.com/32' },
        'all:127.0.0.1' =>
            { code => 'E_UNEXPECTED_IPADDR', context => 'all:127.0.0.1' },
        '+all:127.0.0.9/8' =>
            { code => 'E_UNEXPECTED_IPADDR', context => '+all:127.0.0.9/8' },
        'all:fe80::6203:be4a' =>
            { code => 'E_UNEXPECTED_IPADDR', context => 'all:fe80::6203:be4a' },
        '?all:fe80::ffff/64' =>
            { code => 'E_UNEXPECTED_IPADDR', context => '?all:fe80::ffff/64' },
        '%all' =>
            { code => 'E_SYNTAX', context => '<*>%all' },
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
