use Test::Spec;
use Validate::SPF::Parser;

spec_helper 'mechanism.pl';

my $mech = 'a';

describe "Validate::SPF::Parser [$mech]" => sub {
    share my %vars;

    before all => sub {
        $vars{parser} = Validate::SPF::Parser->new;
        $vars{mech} = $mech;
    };

    my @positive = (
        'a' =>
            { qualifier => '+', domain => '@' },
        '?a' =>
            { qualifier => '?', domain => '@' },
        '-a' =>
            { qualifier => '-', domain => '@' },
        '~a' =>
            { qualifier => '~', domain => '@' },
        '+a' =>
            { qualifier => '+', domain => '@' },
        '-a/25' =>
            { qualifier => '-', domain => '@', bitmask => '25' },
        'a:mail.example.com' =>
            { qualifier => '+', domain => 'mail.example.com' },
        '-a:www.example.com' =>
            { qualifier => '-', domain => 'www.example.com' },
        '~a:example.net' =>
            { qualifier => '~', domain => 'example.net' },
        'a:foo.com/26' =>
            { qualifier => '+', domain => 'foo.com', bitmask => '26' },
        '?a:bar.com/8' =>
            { qualifier => '?', domain => 'bar.com', bitmask => '8' },
    );

    my @negative = (
        'a:10.17.1.0' =>
            { code => 'E_UNEXPECTED_IPADDR', context => 'a:10.17.1.0' },
        '?a:172.16.23.0/26' =>
            { code => 'E_UNEXPECTED_IPADDR', context => '?a:172.16.23.0/26' },
        '-a:2001::abe0' =>
            { code => 'E_UNEXPECTED_IPADDR', context => '-a:2001::abe0' },
        '~a:30a9:a37::ff0f/96' =>
            { code => 'E_UNEXPECTED_IPADDR', context => '~a:30a9:a37::ff0f/96' },
        '%a' =>
            { code => 'E_SYNTAX', context => '<*>%a' },
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
