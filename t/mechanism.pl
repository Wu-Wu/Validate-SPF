shared_examples_for "mechanism positive" => sub {
    share my %t;

    it "should return correct result" => sub {
        cmp_deeply(
            $t{parser}->parse( $t{case} ),
            [
                {
                    %{ $t{result} },
                    type => 'mech',
                    mechanism => $t{mech}
                }
            ]
        );
    };
};

shared_examples_for "mechanism negative" => sub {
    share my %y;

    before sub {
        $y{parser}->parse( $y{case} );
    };

    it "should return correct error" => sub {
        cmp_deeply(
            $y{parser}->error,
            { %{ $y{result} }, text => ignore() }
        );
    };
};
