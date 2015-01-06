use Test::Spec;
use Validate::SPF::Parser;

my $mech = 'mx';

describe "Validate::SPF::Parser [$mech]" => sub {
    share my %vars;

    before all => sub {
        $vars{parser} = Validate::SPF::Parser->new;
        $vars{mech} = $mech;
    };

    my @positive = (
        'mx' =>
            { qualifier => '+', domain => '@' },
        '?mx' =>
            { qualifier => '?', domain => '@' },
        '-mx' =>
            { qualifier => '-', domain => '@' },
        '~mx' =>
            { qualifier => '~', domain => '@' },
        '+mx' =>
            { qualifier => '+', domain => '@' },
        '-mx/25' =>
            { qualifier => '-', domain => '@', bitmask => '25' },
        'mx:mail.example.com' =>
            { qualifier => '+', domain => 'mail.example.com' },
        '-mx:www.example.com' =>
            { qualifier => '-', domain => 'www.example.com' },
        '~mx:example.net' =>
            { qualifier => '~', domain => 'example.net' },
        'mx:foo.com/26' =>
            { qualifier => '+', domain => 'foo.com', bitmask => '26' },
        '?mx:bar.com/8' =>
            { qualifier => '?', domain => 'bar.com', bitmask => '8' },
    );

    my @negative = (
        'mx:10.17.1.0' =>
            { code => 'E_UNEXPECTED_IPADDR', context => 'mx:10.17.1.0' },
        '?mx:172.16.23.0/26' =>
            { code => 'E_UNEXPECTED_IPADDR', context => '?mx:172.16.23.0/26' },
        '-mx:2001::abe0' =>
            { code => 'E_UNEXPECTED_IPADDR', context => '-mx:2001::abe0' },
        '~mx:30a9:a37::ff0f/96' =>
            { code => 'E_UNEXPECTED_IPADDR', context => '~mx:30a9:a37::ff0f/96' },
        '%mx' =>
            { code => 'E_SYNTAX', context => '<*>%mx' },
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
