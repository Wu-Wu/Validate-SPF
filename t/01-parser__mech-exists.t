use Test::Spec;
use Validate::SPF::Parser;

my $mech = 'exists';

describe "Validate::SPF::Parser [$mech]" => sub {
    share my %vars;

    before all => sub {
        $vars{parser} = Validate::SPF::Parser->new;
        $vars{mech} = $mech;
    };

    my @positive = (
        'exists:mail.example.com' =>
            { qualifier => '+', domain => 'mail.example.com' },
        '-exists:www.example.com' =>
            { qualifier => '-', domain => 'www.example.com' },
        '~exists:example.net' =>
            { qualifier => '~', domain => 'example.net' },
        '?exists:foo.com' =>
            { qualifier => '?', domain => 'foo.com' },
        '+exists:bar.net' =>
            { qualifier => '+', domain => 'bar.net' },
    );

    my @negative = (
        'exists:10.17.1.0' =>
            { code => 'E_UNEXPECTED_IPADDR', context => 'exists:10.17.1.0' },
        '?exists:172.16.23.0/26' =>
            { code => 'E_UNEXPECTED_IPADDR', context => '?exists:172.16.23.0/26' },
        '-exists:2001::abe0' =>
            { code => 'E_UNEXPECTED_IPADDR', context => '-exists:2001::abe0' },
        '~exists:30a9:a37::ff0f/96' =>
            { code => 'E_UNEXPECTED_IPADDR', context => '~exists:30a9:a37::ff0f/96' },
        '+exists:mail.example.com/23' =>
            { code => 'E_UNEXPECTED_BITMASK', context => '+exists:mail.example.com/23' },
        '~exists/18' =>
            { code => 'E_UNEXPECTED_BITMASK', context => '~exists/18' },
        '?exists' =>
            { code => 'E_DOMAIN_EXPECTED', context => '?exists' },
        '%exists' =>
            { code => 'E_SYNTAX', context => '<*>%exists' },
    );

    while ( my ( $case, $result ) = splice @positive, 0, 2 ) {
        describe "positive for '$case'" => sub {

            it "should return correct result" => sub {
                cmp_deeply(
                    $vars{parser}->parse( $case ),
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
                $vars{parser}->parse( $case );
            };

            it "should return correct error" => sub {
                cmp_deeply(
                    $vars{parser}->error,
                    { %{ $result }, text => ignore() }
                );
            };
        };
    }
};

runtests unless caller;
