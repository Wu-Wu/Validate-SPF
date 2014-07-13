use Test::Spec;
use Validate::SPF::Parser;

describe "Validate::SPF::Parser [version]" => sub {
    share my %vars;

    before all => sub {
        $vars{parser} = Validate::SPF::Parser->new;
    };

    my @positive = (
        'v=spf1' =>
            { version => 'v=spf1' },
    );

    my @negative = (
        'v=spf2' =>
            { code => 'E_INVALID_VERSION', context => 'v=spf2' },
        'v=SPF1' =>
            { code => 'E_INVALID_VERSION', context => 'v=SPF1' },
        'v=spf-foo' =>
            { code => 'E_SYNTAX', context => '<*>v=spf-foo' },
    );

    while ( my ( $case, $result ) = splice @positive, 0, 2 ) {
        describe "positive for '$case'" => sub {
            it "should return correct result" => sub {
                cmp_deeply(
                    $vars{parser}->parse( $case ),
                    [
                        {
                            %$result,
                            type => 'ver'
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
                    { %$result, text => ignore() }
                );
            };
        };
    }
};

runtests unless caller;
