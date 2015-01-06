use Test::Spec;
use Validate::SPF::Parser;

my $mech = 'include';

describe "Validate::SPF::Parser [$mech]" => sub {
    my ( $parser );

    before all => sub {
        $parser = Validate::SPF::Parser->new;
    };

    my @positive = (
        'include:mail.example.com' =>
            { qualifier => '+', domain => 'mail.example.com' },
        '-include:www.example.com' =>
            { qualifier => '-', domain => 'www.example.com' },
        '~include:example.net' =>
            { qualifier => '~', domain => 'example.net' },
        '?include:foo.com' =>
            { qualifier => '?', domain => 'foo.com' },
        '+include:bar.net' =>
            { qualifier => '+', domain => 'bar.net' },
    );

    my @negative = (
        'include:10.17.1.0' =>
            { code => 'E_UNEXPECTED_IPADDR', context => 'include:10.17.1.0' },
        '?include:172.16.23.0/26' =>
            { code => 'E_UNEXPECTED_IPADDR', context => '?include:172.16.23.0/26' },
        '-include:2001::abe0' =>
            { code => 'E_UNEXPECTED_IPADDR', context => '-include:2001::abe0' },
        '~include:30a9:a37::ff0f/96' =>
            { code => 'E_UNEXPECTED_IPADDR', context => '~include:30a9:a37::ff0f/96' },
        '+include:mail.example.com/23' =>
            { code => 'E_UNEXPECTED_BITMASK', context => '+include:mail.example.com/23' },
        '~include/18' =>
            { code => 'E_UNEXPECTED_BITMASK', context => '~include/18' },
        '?include' =>
            { code => 'E_DOMAIN_EXPECTED', context => '?include' },
        '%include' =>
            { code => 'E_SYNTAX', context => '<*>%include' },
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
