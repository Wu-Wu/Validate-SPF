use Test::Spec;
use Validate::SPF::Parser;

my $mech = 'ptr';

describe "Validate::SPF::Parser [$mech]" => sub {
    my ( $parser );

    before all => sub {
        $parser = Validate::SPF::Parser->new;
    };

    my @positive = (
        'ptr' =>
            { qualifier => '+', domain => '@' },
        '?ptr' =>
            { qualifier => '?', domain => '@' },
        '-ptr' =>
            { qualifier => '-', domain => '@' },
        '~ptr' =>
            { qualifier => '~', domain => '@' },
        'ptr:foo.example.net' =>
            { qualifier => '+', domain => 'foo.example.net' },
        '?ptr:bar.example.com' =>
            { qualifier => '?', domain => 'bar.example.com' },
    );

    my @negative = (
        'ptr/26' =>
            { code => 'E_UNEXPECTED_BITMASK', context => 'ptr/26' },
        '+ptr/32' =>
            { code => 'E_UNEXPECTED_BITMASK', context => '+ptr/32' },
        '?ptr:foo.net/18' =>
            { code => 'E_UNEXPECTED_BITMASK', context => '?ptr:foo.net/18' },
        'ptr:quux.net/32' =>
            { code => 'E_UNEXPECTED_BITMASK', context => 'ptr:quux.net/32' },
        '-ptr:127.0.0.1' =>
            { code => 'E_UNEXPECTED_IPADDR', context => '-ptr:127.0.0.1' },
        '~ptr:fe80::1/128' =>
            { code => 'E_UNEXPECTED_IPADDR', context => '~ptr:fe80::1/128' },
        'ptr:fe80::2/96' =>
            { code => 'E_UNEXPECTED_IPADDR', context => 'ptr:fe80::2/96' },
        '+ptr=www.example.com' =>
            { code => 'E_SYNTAX', context => '+ptr<*>=www.example.com' },
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
