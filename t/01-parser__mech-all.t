use Test::Spec;
use Validate::SPF::Parser;

spec_helper 'mechanism.pl';

my $mech = 'all';

describe "Validate::SPF::Parser [$mech]" => sub {
    share my %vars;

    before all => sub {
        $vars{parser} = Validate::SPF::Parser->new;
        $vars{mech} = $mech;
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
        '?All' =>
            { qualifier => '?' },
    );

    my @negative = (
        # TODO
        # 'all/24' =>
        #     { code => 'E_UNEXPECTED_BITMASK', context => 'all/24' },
        # '?all/32' =>
        #     { code => 'E_UNEXPECTED_BITMASK', context => '?all/32' },
        '%all' =>
            { code => 'E_SYNTAX', context => '<*>%all' },
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
