package Validate::SPF::Parser;

# ABSTRACT: SPF v1 parser implementation

####################################################################
#
#    This file was generated using Parse::Yapp version 1.05.
#
#        Don't edit this file, use source file instead.
#
#             ANY CHANGE MADE HERE WILL BE LOST !
#
####################################################################

use strict;
use warnings;

# VERSION
# AUTHORITY

use vars qw ( @ISA );

@ISA = qw( Parse::Yapp::Driver );

#Included Parse/Yapp/Driver.pm file----------------------------------------
{
#
# Module Parse::Yapp::Driver
#
# This module is part of the Parse::Yapp package available on your
# nearest CPAN
#
# Any use of this module in a standalone parser make the included
# text under the same copyright as the Parse::Yapp module itself.
#
# This notice should remain unchanged.
#
# (c) Copyright 1998-2001 Francois Desarmenien, all rights reserved.
# (see the pod text in Parse::Yapp module for use and distribution rights)
#

package Parse::Yapp::Driver;

require 5.004;

use strict;

use vars qw ( $VERSION $COMPATIBLE $FILENAME );

$VERSION = '1.05';
$COMPATIBLE = '0.07';
$FILENAME=__FILE__;

use Carp;

#Known parameters, all starting with YY (leading YY will be discarded)
my(%params)=(YYLEX => 'CODE', 'YYERROR' => 'CODE', YYVERSION => '',
             YYRULES => 'ARRAY', YYSTATES => 'ARRAY', YYDEBUG => '');
#Mandatory parameters
my(@params)=('LEX','RULES','STATES');

sub new {
    my($class)=shift;
    my($errst,$nberr,$token,$value,$check,$dotpos);
    my($self)={ ERROR => \&_Error,
                ERRST => \$errst,
                NBERR => \$nberr,
                TOKEN => \$token,
                VALUE => \$value,
                DOTPOS => \$dotpos,
                STACK => [],
                DEBUG => 0,
                CHECK => \$check };

    _CheckParams( [], \%params, \@_, $self );

        exists($$self{VERSION})
    and $$self{VERSION} < $COMPATIBLE
    and croak "Yapp driver version $VERSION ".
              "incompatible with version $$self{VERSION}:\n".
              "Please recompile parser module.";

        ref($class)
    and $class=ref($class);

    bless($self,$class);
}

sub YYParse {
    my($self)=shift;
    my($retval);

    _CheckParams( \@params, \%params, \@_, $self );

    if($$self{DEBUG}) {
        _DBLoad();
        $retval = eval '$self->_DBParse()';#Do not create stab entry on compile
        $@ and die $@;
    }
    else {
        $retval = $self->_Parse();
    }
    $retval
}

sub YYData {
    my($self)=shift;

        exists($$self{USER})
    or  $$self{USER}={};

    $$self{USER};

}

sub YYErrok {
    my($self)=shift;

    ${$$self{ERRST}}=0;
    undef;
}

sub YYNberr {
    my($self)=shift;

    ${$$self{NBERR}};
}

sub YYRecovering {
    my($self)=shift;

    ${$$self{ERRST}} != 0;
}

sub YYAbort {
    my($self)=shift;

    ${$$self{CHECK}}='ABORT';
    undef;
}

sub YYAccept {
    my($self)=shift;

    ${$$self{CHECK}}='ACCEPT';
    undef;
}

sub YYError {
    my($self)=shift;

    ${$$self{CHECK}}='ERROR';
    undef;
}

sub YYSemval {
    my($self)=shift;
    my($index)= $_[0] - ${$$self{DOTPOS}} - 1;

        $index < 0
    and -$index <= @{$$self{STACK}}
    and return $$self{STACK}[$index][1];

    undef;  #Invalid index
}

sub YYCurtok {
    my($self)=shift;

        @_
    and ${$$self{TOKEN}}=$_[0];
    ${$$self{TOKEN}};
}

sub YYCurval {
    my($self)=shift;

        @_
    and ${$$self{VALUE}}=$_[0];
    ${$$self{VALUE}};
}

sub YYExpect {
    my($self)=shift;

    keys %{$self->{STATES}[$self->{STACK}[-1][0]]{ACTIONS}}
}

sub YYLexer {
    my($self)=shift;

    $$self{LEX};
}


#################
# Private stuff #
#################


sub _CheckParams {
    my($mandatory,$checklist,$inarray,$outhash)=@_;
    my($prm,$value);
    my($prmlst)={};

    while(($prm,$value)=splice(@$inarray,0,2)) {
        $prm=uc($prm);
            exists($$checklist{$prm})
        or  croak("Unknow parameter '$prm'");
            ref($value) eq $$checklist{$prm}
        or  croak("Invalid value for parameter '$prm'");
        $prm=unpack('@2A*',$prm);
        $$outhash{$prm}=$value;
    }
    for (@$mandatory) {
            exists($$outhash{$_})
        or  croak("Missing mandatory parameter '".lc($_)."'");
    }
}

sub _Error {
    print "Parse error.\n";
}

sub _DBLoad {
    {
        no strict 'refs';

            exists(${__PACKAGE__.'::'}{_DBParse})#Already loaded ?
        and return;
    }
    my($fname)=__FILE__;
    my(@drv);
    open(DRV,"<$fname") or die "Report this as a BUG: Cannot open $fname";
    while(<DRV>) {
                    /^\s*sub\s+_Parse\s*{\s*$/ .. /^\s*}\s*#\s*_Parse\s*$/
            and     do {
                    s/^#DBG>//;
                    push(@drv,$_);
            }
    }
    close(DRV);

    $drv[0]=~s/_P/_DBP/;
    eval join('',@drv);
}

#Note that for loading debugging version of the driver,
#this file will be parsed from 'sub _Parse' up to '}#_Parse' inclusive.
#So, DO NOT remove comment at end of sub !!!
sub _Parse {
    my($self)=shift;

    my($rules,$states,$lex,$error)
     = @$self{ 'RULES', 'STATES', 'LEX', 'ERROR' };
    my($errstatus,$nberror,$token,$value,$stack,$check,$dotpos)
     = @$self{ 'ERRST', 'NBERR', 'TOKEN', 'VALUE', 'STACK', 'CHECK', 'DOTPOS' };

#DBG>   my($debug)=$$self{DEBUG};
#DBG>   my($dbgerror)=0;

#DBG>   my($ShowCurToken) = sub {
#DBG>       my($tok)='>';
#DBG>       for (split('',$$token)) {
#DBG>           $tok.=      (ord($_) < 32 or ord($_) > 126)
#DBG>                   ?   sprintf('<%02X>',ord($_))
#DBG>                   :   $_;
#DBG>       }
#DBG>       $tok.='<';
#DBG>   };

    $$errstatus=0;
    $$nberror=0;
    ($$token,$$value)=(undef,undef);
    @$stack=( [ 0, undef ] );
    $$check='';

    while(1) {
        my($actions,$act,$stateno);

        $stateno=$$stack[-1][0];
        $actions=$$states[$stateno];

#DBG>   print STDERR ('-' x 40),"\n";
#DBG>       $debug & 0x2
#DBG>   and print STDERR "In state $stateno:\n";
#DBG>       $debug & 0x08
#DBG>   and print STDERR "Stack:[".
#DBG>                    join(',',map { $$_[0] } @$stack).
#DBG>                    "]\n";


        if  (exists($$actions{ACTIONS})) {

                defined($$token)
            or  do {
                ($$token,$$value)=&$lex($self);
#DBG>               $debug & 0x01
#DBG>           and print STDERR "Need token. Got ".&$ShowCurToken."\n";
            };

            $act=   exists($$actions{ACTIONS}{$$token})
                    ?   $$actions{ACTIONS}{$$token}
                    :   exists($$actions{DEFAULT})
                        ?   $$actions{DEFAULT}
                        :   undef;
        }
        else {
            $act=$$actions{DEFAULT};
#DBG>           $debug & 0x01
#DBG>       and print STDERR "Don't need token.\n";
        }

            defined($act)
        and do {

                $act > 0
            and do {        #shift

#DBG>               $debug & 0x04
#DBG>           and print STDERR "Shift and go to state $act.\n";

                    $$errstatus
                and do {
                    --$$errstatus;

#DBG>                   $debug & 0x10
#DBG>               and $dbgerror
#DBG>               and $$errstatus == 0
#DBG>               and do {
#DBG>                   print STDERR "**End of Error recovery.\n";
#DBG>                   $dbgerror=0;
#DBG>               };
                };


                push(@$stack,[ $act, $$value ]);

                    $$token ne ''   #Don't eat the eof
                and $$token=$$value=undef;
                next;
            };

            #reduce
            my($lhs,$len,$code,@sempar,$semval);
            ($lhs,$len,$code)=@{$$rules[-$act]};

#DBG>           $debug & 0x04
#DBG>       and $act
#DBG>       and print STDERR "Reduce using rule ".-$act." ($lhs,$len): ";

                $act
            or  $self->YYAccept();

            $$dotpos=$len;

                unpack('A1',$lhs) eq '@'    #In line rule
            and do {
                    $lhs =~ /^\@[0-9]+\-([0-9]+)$/
                or  die "In line rule name '$lhs' ill formed: ".
                        "report it as a BUG.\n";
                $$dotpos = $1;
            };

            @sempar =       $$dotpos
                        ?   map { $$_[1] } @$stack[ -$$dotpos .. -1 ]
                        :   ();

            $semval = $code ? &$code( $self, @sempar )
                            : @sempar ? $sempar[0] : undef;

            splice(@$stack,-$len,$len);

                $$check eq 'ACCEPT'
            and do {

#DBG>           $debug & 0x04
#DBG>       and print STDERR "Accept.\n";

                return($semval);
            };

                $$check eq 'ABORT'
            and do {

#DBG>           $debug & 0x04
#DBG>       and print STDERR "Abort.\n";

                return(undef);

            };

#DBG>           $debug & 0x04
#DBG>       and print STDERR "Back to state $$stack[-1][0], then ";

                $$check eq 'ERROR'
            or  do {
#DBG>               $debug & 0x04
#DBG>           and print STDERR
#DBG>                   "go to state $$states[$$stack[-1][0]]{GOTOS}{$lhs}.\n";

#DBG>               $debug & 0x10
#DBG>           and $dbgerror
#DBG>           and $$errstatus == 0
#DBG>           and do {
#DBG>               print STDERR "**End of Error recovery.\n";
#DBG>               $dbgerror=0;
#DBG>           };

                push(@$stack,
                     [ $$states[$$stack[-1][0]]{GOTOS}{$lhs}, $semval ]);
                $$check='';
                next;
            };

#DBG>           $debug & 0x04
#DBG>       and print STDERR "Forced Error recovery.\n";

            $$check='';

        };

        #Error
            $$errstatus
        or   do {

            $$errstatus = 1;
            &$error($self);
                $$errstatus # if 0, then YYErrok has been called
            or  next;       # so continue parsing

#DBG>           $debug & 0x10
#DBG>       and do {
#DBG>           print STDERR "**Entering Error recovery.\n";
#DBG>           ++$dbgerror;
#DBG>       };

            ++$$nberror;

        };

            $$errstatus == 3    #The next token is not valid: discard it
        and do {
                $$token eq ''   # End of input: no hope
            and do {
#DBG>               $debug & 0x10
#DBG>           and print STDERR "**At eof: aborting.\n";
                return(undef);
            };

#DBG>           $debug & 0x10
#DBG>       and print STDERR "**Dicard invalid token ".&$ShowCurToken.".\n";

            $$token=$$value=undef;
        };

        $$errstatus=3;

        while(    @$stack
              and (     not exists($$states[$$stack[-1][0]]{ACTIONS})
                    or  not exists($$states[$$stack[-1][0]]{ACTIONS}{error})
                    or  $$states[$$stack[-1][0]]{ACTIONS}{error} <= 0)) {

#DBG>           $debug & 0x10
#DBG>       and print STDERR "**Pop state $$stack[-1][0].\n";

            pop(@$stack);
        }

            @$stack
        or  do {

#DBG>           $debug & 0x10
#DBG>       and print STDERR "**No state left on stack: aborting.\n";

            return(undef);
        };

        #shift the error token

#DBG>           $debug & 0x10
#DBG>       and print STDERR "**Shift \$error token and go to state ".
#DBG>                        $$states[$$stack[-1][0]]{ACTIONS}{error}.
#DBG>                        ".\n";

        push(@$stack, [ $$states[$$stack[-1][0]]{ACTIONS}{error}, undef ]);

    }

    #never reached
    croak("Error in driver logic. Please, report it as a BUG");

}#_Parse
#DO NOT remove comment

1;

}
#End of include--------------------------------------------------


#line 1 "Parser.yp"
#
# Validate::SPF::Parser source file
#
# Author: Anton Gerasimov
#

my ( $input );


=head1 SYNOPSIS

    use Validate::SPF::Parser;

    $parser = Validate::SPF::Parser->new;
    $ast = $parser->parse( 'v=spf1 a include:_spf.example.com ~all' );

    unless ( $ast ) {
        # fail
        print "Error: " . $parser->error->{code} . ": " . $parser->error->{text} . "\n";
    }
    else {
        # ok
        ...
    }

=method new

Creates an instance of SPF parser.

    my $parser = Validate::SPF::Parser->new;

=cut

sub new {
    my( $class ) = shift;

    ref( $class ) and $class = ref( $class );

    my $self =
        $class->SUPER::new(
            yyversion   => '1.05',
            yystates    => [
    {#State 0
        ACTIONS => {
            'PTR' => 6,
            'ALL' => 3,
            'QUALIFER' => 8,
            'VERSION' => 10
        },
        GOTOS => {
            'mechanism' => 1,
            'chunks' => 7,
            'ptr' => 2,
            'version' => 4,
            'chunk' => 11,
            'spf' => 9,
            'all' => 5
        }
    },
    {#State 1
        DEFAULT => -6
    },
    {#State 2
        DEFAULT => -8
    },
    {#State 3
        DEFAULT => -9
    },
    {#State 4
        DEFAULT => -5
    },
    {#State 5
        DEFAULT => -7
    },
    {#State 6
        DEFAULT => -11
    },
    {#State 7
        ACTIONS => {
            'PTR' => 6,
            'ALL' => 3,
            'QUALIFER' => 8,
            'VERSION' => 10
        },
        DEFAULT => -1,
        GOTOS => {
            'mechanism' => 1,
            'ptr' => 2,
            'version' => 4,
            'chunk' => 12,
            'all' => 5
        }
    },
    {#State 8
        ACTIONS => {
            'PTR' => 14,
            'ALL' => 13
        }
    },
    {#State 9
        ACTIONS => {
            '' => 15
        }
    },
    {#State 10
        DEFAULT => -2
    },
    {#State 11
        DEFAULT => -4
    },
    {#State 12
        DEFAULT => -3
    },
    {#State 13
        DEFAULT => -10
    },
    {#State 14
        DEFAULT => -12
    },
    {#State 15
        DEFAULT => 0
    }
],
            yyrules     => [
    [#Rule 0
         '$start', 2, undef
    ],
    [#Rule 1
         'spf', 1,
sub
#line 14 "Parser.yp"
{ $_[1] }
    ],
    [#Rule 2
         'version', 1,
sub
#line 19 "Parser.yp"
{
            $_[1] eq 'v=spf1' and
                return +{ type => 'ver', version => $_[1] };

            $_[0]->YYData->{ERRMSG} = {
                text    => 'Invalid SPF version',
                code    => 'E_INVALID_VERSION',
                context => $_[1],
            };
            $_[0]->YYError;
            undef;
        }
    ],
    [#Rule 3
         'chunks', 2,
sub
#line 35 "Parser.yp"
{ push(@{$_[1]}, $_[2]) if defined $_[2]; $_[1] }
    ],
    [#Rule 4
         'chunks', 1,
sub
#line 37 "Parser.yp"
{ defined $_[1] ? [ $_[1] ] : [ ] }
    ],
    [#Rule 5
         'chunk', 1, undef
    ],
    [#Rule 6
         'chunk', 1, undef
    ],
    [#Rule 7
         'mechanism', 1, undef
    ],
    [#Rule 8
         'mechanism', 1, undef
    ],
    [#Rule 9
         'all', 1,
sub
#line 52 "Parser.yp"
{ +{ type => 'mech', qualifer => '+', mechanism => $_[1] } }
    ],
    [#Rule 10
         'all', 2,
sub
#line 54 "Parser.yp"
{ +{ type => 'mech', qualifer => $_[1], mechanism => $_[2] } }
    ],
    [#Rule 11
         'ptr', 1,
sub
#line 59 "Parser.yp"
{ +{ type => 'mech', qualifer => '+', mechanism => $_[1], domain => '@' } }
    ],
    [#Rule 12
         'ptr', 2,
sub
#line 61 "Parser.yp"
{ +{ type => 'mech', qualifer => $_[1], mechanism => $_[2], domain => '@' } }
    ]
],
            @_
        );

    bless $self, $class;
}

=method parse

Builds an abstract syntax tree (AST) for given text representation of SPF.

    my $ast = $parser->parse( 'v=spf1 ~all' );

Returns an C<undef> if error occured. See L</error> for details.

=method error

Returns last error occured as HashRef.

    $parser->error;

Here is an example

    {
       code    => 'E_SYNTAX',
       text    => 'Syntax error',
       context => 'v=spf1 <*>exclude:foo.example.com  mx ~all',
    }

=for Pod::Coverage _error _lexer

=head1 BUILD PARSER

In cases of C<Parser.yp> was modified you should re-build this module. Ensure you have L<Parse::Yapp>
distribution installed.

In root directory:

    $ yapp -s -m Validate::SPF::Parser -o lib/Validate/SPF/Parser.pm -t Parser.pm.skel Parser.yp

Ensure the C<lib/Validate/SPF/Parser.pm> saved without tab symbols and has unix line endings.

=head1 SEE ALSO

L<Parse::Yapp>

=cut

#line 64 "Parser.yp"


sub parse {
    my ( $self, $text ) = @_;

    $input = $self->YYData->{INPUT} = $text;

    return $self->YYParse( yylex => \&_lexer, yyerror => \&_error );
}

sub error {
    my ( $self ) = @_;
    return $self->{_error};
}

sub _error {
    my ( $self ) = @_;

    exists $self->YYData->{ERRMSG} && do {
        $self->{_error} = $self->YYData->{ERRMSG};
        delete $self->YYData->{ERRMSG};
        return;
    };

    substr( $input, index( $input, $self->YYCurval ), 0, '<*>' );

    $self->{_error} = {
        text    => 'Syntax error',
        code    => 'E_SYNTAX',
        context => $input,
    };
}

sub _lexer {
    my ( $parser ) = @_;

    $parser->YYData->{INPUT} =~ s/^\s*//;

    for ( $parser->YYData->{INPUT} ) {
        # printf( "[debug] %s\n", $_ );

        s/^(v\=spf\d)\b//i          and return ( 'VERSION', $1 );

        s/^(\/)\b//i                and return ( 'SLASH', '/' );
        s/^(\:)\b//i                and return ( 'COLON', ':' );
        s/^(\=)\b//i                and return ( 'ASSIGN', '=' );

        # qualifers
        s/^([-~\+\?])\b//i          and return ( 'QUALIFER', $1 );

        # mechanisms
        s/^(all)\b//i               and return ( 'ALL', $1 );
        s/^(ptr)\b//i               and return ( 'PTR', $1 );
        s/^(a)\b//i                 and return ( 'PTR', $1 );
        s/^(mx)\b//i                and return ( 'UNKNOWN', $1 );
        s/^(ip4)\b//i               and return ( 'UNKNOWN', $1 );
        s/^(ip6)\b//i               and return ( 'UNKNOWN', $1 );
        s/^(exists)\b//i            and return ( 'UNKNOWN', $1 );
        s/^(include)\b//i           and return ( 'UNKNOWN', $1 );

        # garbage
        s/^(.+)\b//i                and return ( 'UNKNOWN', $1 );
    }

    # EOF
    return ( '', undef );
}

1;
