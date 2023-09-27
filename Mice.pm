package Lang::Mice;

use strict;
use warnings;
use utf8;
use Regexp::Grammars;

our $VERSION = '5.137';

sub new {
    my ($class) = @_;
    return bless {}, $class;
}

sub PP::Lang::X {
    my ($class) = @_;

    my $code = '
        use strict;
        use warnings;
        use utf8;

        use feature qw(signatures);
        no warnings "experimental::signatures";
        no warnings "experimental::smartmatch";
        use Hash::Merge;

        use Tie::IxHash;

        my %pp = ();
        tie %pp, "Tie::IxHash";
        my $hash = \%pp;

        sub def( $variable) {
            return defined($variable);
        }

        sub not( $boolOperand) {
            my $not = ! $boolOperand;
            return $not;
        }

        sub arrayElement( $array, $element) {
            if( $element ~~ @{$array} ) {
                return 1;
            } else {
                return 0;
            }
        }
        sub stringSplit($expr, $string) {
            my @array = split($expr, $string);
            return \@array;
        }

        sub stringJoin($expr, $array) {
            my $string = join($expr, @{$array});
            return $string;
        }

        sub arrayDelete( $array, $element) {
            delete($array->[$element]);
        }

        sub hashDelete( $hash, $element) {
            delete($hash->{$element});
        }

        sub arrayReverse( $array) {
            my @reversedArray = reverse(@{$array});
            return \@reversedArray;
        }

        sub arrayJoin( $separator, $array) {
            my @array = @{$array};
            return join($separator, $array);
        }

        sub arraySort( $array) {
            my @array = @{$array};
            my @sortedArray = sort(@array);
            return \@sortedArray;
        }

        sub arrayUnshift( $array, $element) {
            unshift(@{$array}, $element);
        }

        sub arrayShift( $array) {
            return shift(@{$array});
        }

        sub arrayPush( $array, $element) {
            push(@{$array}, $element);
        }

        sub arrayPop( $array) {
            return pop(@{$array});
        }

        sub stringConcat( $textOne, $textTwo) {
            return $textOne . $textTwo;
        }

        sub arrayLength( $array) {
            my @newArray = @{$array};
            return $#newArray;
        }

        sub arrayMerge( $arrayOne, $arrayTwo) {
            my @newArray = ( @{$arrayOne}, @{$arrayTwo} );
            return \@newArray;
        }

        sub hashElement( $hash, $element) {
            my %hashMap  = %{$hash};
            if( exists $hashMap{$element} ) {
                return 1;
            } else {
                return 0;
            }
        }

        sub hashKeys( $hash) {
            my @keys = keys(%{$hash});
            return \@keys;
        }

        sub hashMerge( $hashOne, $hashTwo) {
            my $mergedHash = merge($hashOne, $hashTwo);
            return $mergedHash;
        }

        sub readFile( $fileName) {
            my $fileContent;
            open(my $fh, "<:encoding(UTF-8)", $fileName) or die "Cannot open the $fileName file";
            {
                local $/;
                $fileContent = <$fh>;
            }
            close($fh);
            return $fileContent;
        }

        sub writeFile( $fileName, $fileContent) {
            open(my $fh, ">:encoding(UTF-8)", $fileName) or die "Cannot open the $fileName file";
            print $fh $fileContent;
            close($fh);
        }

        ';

    for my $element ( @{$class->{FunctionOrEmbed}} ) {
        $code .= $element->X();
    }

    $code .= 'main();';
    return $code;
}

sub PP::FunctionOrEmbed::X {
    my ($class) = @_;

    return (       $class->{DefineFunction}
                      || $class->{DefineEmbed} )->X();
}

sub PP::DefineFunction::X {
    my ($class) = @_;

    my $code = "";
    for my $element ( @{ $class->{Function}} ) {
        $code .= $element->X();
    }

    return $code;

}

sub PP::DefineEmbed::X {
    my ($class) = @_;

    my $code = "";
    for my $element ( @{ $class->{EmbedBlock}} ) {
        $code .= $element->X();
    }

    return $code;
}


sub PP::Function::X {
    my ($class) = @_;

    my $functionName = $class->{FunctionName}->X();
    my $functionParamList = $class->{FunctionParamList}->X();
    my $codeBlock = $class->{CodeBlock}->X($functionName);

    my $function = "\n sub " . $functionName . $functionParamList . $codeBlock;
    return $function;
}

sub PP::FunctionName::X {
    my ($class, $className) = @_;

    my $functionName = $class->{''};
    return $functionName;
}

sub PP::FunctionParamList::X {
    my ($class, $className) = @_;

    my @params = (       $class->{EmptyParamList}
                      || $class->{FunctionParams} )->X();

    my $functionParamList;
    $functionParamList = '( ';

    if($#params >= 0) {
        foreach my $param (@params) {
            if( $param eq "" ) {} else {
                $functionParamList .= "\$" . $param . ",";
            }
        }
        if( substr($functionParamList, -1) eq "," ) {
            chop($functionParamList);
        }
    }
    else {
        chop($functionParamList);
    }
    $functionParamList .= ")";

    return $functionParamList;
}

sub PP::CodeBlock::X {
    my ($class, $className, $functionName) = @_;
    my $blocks = $class->{Blocks}->X($functionName);
    my $codeBlock = "{\n" . $blocks . "\n}";
    return $codeBlock;
}

sub PP::EmptyParamList::X {
    my ($class, $className) = @_;
    return $class->{''};
}

sub PP::FunctionParams::X {
    my ($class, $className) = @_;
    my @functionParams;

    for my $element ( @{ $class->{Arg}} ) {
        push @functionParams, $element->X();
    }

    return @functionParams;
}

sub PP::Arg::X {
    my ($class, $className) = @_;
    return $class->{''};
}

sub PP::Blocks::X {
    my ($class, $className, $functionName) = @_;
    my @blocks;

    for my $element ( @{$class->{Block}} ) {
        push @blocks, $element->X($functionName);
    }

    my $blocks = join("\n", @blocks);
    return $blocks;
}

sub PP::Block::X {
    my ($class, $className, $functionName) = @_;

    my $block = (      $class->{IfElse}
                    || $class->{While}
                    || $class->{ForEach}
                    || $class->{ArrayEach}
                    || $class->{HashEach}
                    || $class->{EmbedBlock}
                    || $class->{Statement}
                    || $class->{NonSyntax} )->X($functionName);
    return $block;
}

sub PP::NonSyntax::X {
    my ($class, $className, $functionName) = @_;
    my $nonSyntax = $class->{''};

    my @nonSyntax = split(" ", $nonSyntax);
    $nonSyntax = $nonSyntax[0];

    print "SyntaxError", "\n";
    print "===========", "\n";

    if(defined $functionName) {
    	print "FunctionName: ", $functionName, "\n";
    }

    die "Error: $nonSyntax \n";
}

sub PP::EmbedBlock::X {
    my ($class, $className) = @_;

    my $embedBlock = $class->{EmbedCodeBlock}->X();
    return $embedBlock;
}

sub PP::EmbedCodeBlock::X {
    my ($class, $className) = @_;

    my $embedCode = $class->{EmbeddedCode}->X();
    return $embedCode;
}

sub PP::EmbeddedCode::X {
    my ($class, $className) = @_;

    my $embedCode = $class->{''};
    return $embedCode;
}

sub PP::While::X {
    my ($class, $className) = @_;

    my $boolExpression = $class->{BoolExpression}->X();
    my $codeBlock = $class->{CodeBlock}->X();

    my $while = "\n while ( " . $boolExpression . " ) " . $codeBlock;
    return $while;
}

sub PP::ForEach::X {
    my ($class, $className) = @_;

    my $forEachVariableName = $class->{VariableName}->X();
    my @forRange = $class->{ForRange}->X();
    my $codeBlock = $class->{CodeBlock}->X();

    my $forEach = "\n foreach my " . $forEachVariableName . " ( " . $forRange[0]
                  . " ... " . $forRange[1] . " ) " . $codeBlock;

    return $forEach;
}

sub PP::ForEachVariableName::X {
    my ($class, $className) = @_;

    my $variableName = $class->{VariableName}->X();
    return $variableName;
}

sub PP::ArrayEach::X {
    my ($class, $className) = @_;

    my $variableName = $class->{VariableName}->X();
    my $arrayEachVariableName = $class->{ArrayEachVariableName}->X();
    my $arrayEachNumber = $class->{ArrayEachNumber}->X();
    my $codeBlock = $class->{CodeBlock}->X();

    my @codeBlock = split(" ", $codeBlock);
    shift(@codeBlock);
    $codeBlock = join(" ", @codeBlock);

    my $arrayEachCodeBlock = "my " . $arrayEachVariableName . " = " . $variableName . "->[" . $arrayEachNumber . "];\n" . $codeBlock;
    my $arrayEach = "\n for my " . $arrayEachNumber . "( 0 ... " . "arrayLength(" . $variableName . ") ) {\n" . $arrayEachCodeBlock;

    return $arrayEach;
}

sub PP::ArrayEachVariableName::X {
    my ($class, $className) = @_;

    my $variableName = $class->{VariableName}->X();
    return $variableName;
}

sub PP::ArrayEachNumber::X {
    my ($class, $className) = @_;

    my $variableName = $class->{VariableName}->X();
    return $variableName;
}

sub PP::HashEach::X {
    my ($class, $className) = @_;

    my $variableName = $class->{VariableName}->X();
    my $hashEachKey = $class->{HashEachKey}->X();
    my $hashEachValue = $class->{HashEachValue}->X();
    my $codeBlock = $class->{CodeBlock}->X();

    my $hashEach = "\n keys %{" . $variableName . "};\n while(my (" . $hashEachKey
                   . ", " . $hashEachValue . ") = each %{ " . $variableName . " }) " . $codeBlock;

    return $hashEach;
}

sub PP::HashEachKey::X {
    my ($class, $className) = @_;

    my $hashEachKey = $class->{VariableName}->X();
    return $hashEachKey;
}

sub PP::HashEachValue::X {
    my ($class, $className) = @_;

    my $hashEachValue = $class->{VariableName}->X();
    return $hashEachValue;
}

sub PP::ForRange::X {
    my ($class, $className) = @_;

    my $lowerRange = $class->{LowerRange}->X();
    my $upperRange = $class->{UpperRange}->X();

    my @forRange = ($lowerRange, $upperRange);
    return @forRange;
}

sub PP::LowerRange::X {
    my ($class, $className) = @_;

    my $number = (     $class->{Number}
                    || $class->{String}
                    || $class->{VariableName}
                    || $class->{ArrayElement}
                    || $class->{HashElement}
                    || $class->{FunctionReturn} )->X();

    return $number;
}

sub PP::UpperRange::X {
    my ($class, $className) = @_;

    my $number = (     $class->{Number}
                    || $class->{String}
                    || $class->{VariableName}
                    || $class->{ArrayElement}
                    || $class->{HashElement}
                    || $class->{FunctionReturn} )->X();

    return $number;
}

sub PP::IfElse::X {
    my ($class, $className) = @_;
    my $if = $class->{If}->X();

    my $elsif;
    my $else;

    if( exists $class->{ElsIf} ) {
        $elsif = $class->{ElsIf}->X();
    }
    if( exists $class->{Else} ) {
        $else = $class->{Else}->X();
    }

    my $ifElseIf;
    if (defined $elsif) {
        $ifElseIf = $if . $elsif . $else;
        return $ifElseIf;
    }
    if (defined $else) {
        $ifElseIf = $if . $else;
        return $ifElseIf;
    }

    $ifElseIf = $if;
    return $ifElseIf;
}

sub PP::IfElseIf::X {
    my ($class, $className) = @_;
    my $if = $class->{If}->X();

    my $elsif;
    my $else;

    if( exists $class->{ElsIf} ) {
        $elsif = $class->{ElsIf}->X();
    }
    if( exists $class->{Else} ) {
        $else = $class->{Else}->X();
    }

    my $ifElseIf;
    if (defined $elsif) {
        $ifElseIf = $if . $elsif . $else;
        return $ifElseIf;
    }
    if (defined $else) {
        $ifElseIf = $if . $else;
        return $ifElseIf;
    }

    $ifElseIf = $if;
    return $ifElseIf;
}

sub PP::If::X {
    my ($class, $className) = @_;

    my $boolExpression = $class->{BoolExpression}->X();
    my $codeBlock = $class->{CodeBlock}->X();

    my $if = "\n if ( " . $boolExpression . " ) " . $codeBlock;
    return $if;
}

sub PP::BoolExpression::X {
    my ($class, $className) = @_;
    my @booleanExpressions;

    for my $element ( @{ $class->{BooleanExpression}} ) {
        push @booleanExpressions, $element->X();
    }

    my @boolOperators;

    for my $element (@{ $class->{BoolOperator} }) {
        push @boolOperators, $element->X();
    }

    my $boolExpression = $booleanExpressions[0];
    for my $counter (1 .. $#booleanExpressions) {
        $boolExpression .= $boolOperators[$counter - 1] . " " . $booleanExpressions[$counter];
    }

    return $boolExpression;
}

sub PP::BooleanExpression::X {
    my ($class, $className) = @_;
    my $boolExpression;

    my $boolOperand = $class->{BoolOperands}->X();
    if( exists $class->{BoolOperatorExpression} ) {
        my @boolOperatorExpression = $class->{BoolOperatorExpression}->X();
        $boolExpression = $boolOperand . " "
                          . $boolOperatorExpression[0] . " " . $boolOperatorExpression[1];
        return $boolExpression;
    }

    $boolExpression = $boolOperand;
    return $boolExpression;
}

sub PP::BoolOperatorExpression::X {
    my ($class, $className) = @_;

    my $boolOperator = $class->{BoolOperator}->X();
    my $boolOperand = $class->{BoolOperands}->X();

    my @boolOperatorExpression = ($boolOperator, $boolOperand);
    return @boolOperatorExpression;
}

sub PP::BoolOperator::X {
    my ($class, $className) = @_;
    return (       $class->{GreaterThan}
                || $class->{LessThan}
                || $class->{Equals}
                || $class->{GreaterThanEquals}
                || $class->{LessThanEquals}
                || $class->{StringEquals}
                || $class->{StringNotEquals}
                || $class->{NotEqulas}
                || $class->{LogicalAnd}
                || $class->{LogicalOr}
                || $class->{Percent}
                || $class->{EmbedBlock} )->X();
}

sub PP::BoolOperands::X {
    my ($class, $className) = @_;
    return (       $class->{RealNumber}
                || $class->{String}
                || $class->{ScalarVariable}
                || $class->{ArrayElement}
                || $class->{HashElement}
                || $class->{FunctionReturn}
                || $class->{EmbedBlock} )->X();
}

sub PP::ElsIf::X {
    my ($class, $className) = @_;
    my @elsIfChain;

    for my $element ( @{$class->{ElsIfChain}} ) {
        push @elsIfChain, $element->X();
    }

    my $elsIfChain;
    foreach my $elsIf (@elsIfChain) {
        $elsIfChain .= $elsIf;
    }

    return $elsIfChain;
}

sub PP::ElsIfChain::X {
    my ($class, $className) = @_;
    my $boolExpression = $class->{BoolExpression}->X();
    my $codeBlock = $class->{CodeBlock}->X();

    my $elsIf = "\n elsif ( " . $boolExpression . " ) " . $codeBlock;
    return $elsIf;
}

sub PP::Else::X {
    my ($class, $className) = @_;
    my $codeBlock = $class->{CodeBlock}->X();

    my $else = "\n else " . $codeBlock;
    return $else;
}

sub PP::Statement::X {
    my ($class, $className) = @_;
    return (       $class->{VariableDeclaration}
                || $class->{FunctionCall}
                || $class->{Assignment}
                || $class->{Return}
                || $class->{Last}
                || $class->{Next})->X();
}


sub PP::VariableDeclaration::X {
    my ($class, $className) = @_;
    return (       $class->{ScalarDeclaration}
                || $class->{ArrayDeclaration}
                || $class->{HashDeclaration} )->X();
}

sub PP::ScalarDeclaration::X {
    my ($class, $className) = @_;
    my $variableName = $class->{VariableName}->X();
    my $value = $class->{Value}->X();

    my $scalarDeclaration = "\n my " . $variableName
                            .  " = " . $value . ";\n";
    return $scalarDeclaration;
}

sub PP::VariableName::X {
    my ($class, $className) = @_;
    my $variableName = $class->{''};
    return "\$" . $variableName;
}

sub PP::Value::X {
    my ($class, $className) = @_;
    my $rhs = $class->{RHS}->X();
    return $rhs;
}

sub PP::Number::X {
    my ($class, $className) = @_;
    my $number = $class->{''};
    return $number;
}

sub PP::RealNumber::X {
    my ($class, $className) = @_;
    my $realNumber = $class->{''};
    return $realNumber;
}

sub PP::String::X {
    my ($class, $className) = @_;
    my $stringValue = $class->{StringValue}->X();

    my $string = "\"" . $stringValue . "\"";
}

sub PP::StringValue::X {
    my ($class, $className) = @_;
    my $stringValue = $class->{''};
    return $stringValue;
}

sub PP::ArrayDeclaration::X {
    my ($class, $className) = @_;
    my $variableName = $class->{VariableName}->X();
    my $arrayList = $class->{ArrayList}->X();

    my $arrayDeclaration = "\n my " . $variableName
                           . " = " . $arrayList . ";\n";

    return $arrayDeclaration;
}

sub PP::ArrayList::X {
    my ($class, $className) = @_;
    my $arrayList = "[";
    my @listElements = $class->{ListElements}->X();

    $arrayList .= join(",", @listElements);

    $arrayList .= "]";
    return $arrayList;
}

sub PP::ListElements::X {
    my ($class, $className) = @_;
    my @listElements;

    for my $element ( @{ $class->{ListElement}} ) {
        push @listElements, $element->X();
    }

    return @listElements;
}

sub PP::ListElement::X {
    my ($class, $className) = @_;
    return (       $class->{RealNumber}
                || $class->{String}
                || $class->{ArrayList}
                || $class->{HashRef}
                || $class->{FunctionReturn}
                || $class->{ArrayElement}
                || $class->{HashElement}
                || $class->{VariableName}
                || $class->{EmbedBlock} )->X();
}

sub PP::HashDeclaration::X {
    my ($class, $className) = @_;
    my $variableName = $class->{VariableName}->X();
    my $hashRef = $class->{HashRef}->X();

    my $hashDeclaration = "\n my " . $variableName
                          . " = " . $hashRef . ";\n";
}

sub PP::HashRef::X {
    my ($class, $className) = @_;
    my $hashRef = "{";
    my $keyValuePairs = $class->{KeyValuePairs}->X();
    $hashRef .= $keyValuePairs . "}";
    return $hashRef;
}

sub PP::KeyValuePairs::X {
    my ($class, $className) = @_;
    my @keyValuePairs;

    my $keyValuePairs = "";
    for my $element ( @{ $class->{KeyValue}} ) {
        @keyValuePairs = ();
        push @keyValuePairs, $element->X();
        $keyValuePairs .= $keyValuePairs[0] . " => " . $keyValuePairs[1] . ", ";
    }

    return $keyValuePairs;
}

sub PP::KeyValue::X {
    my ($class, $className) = @_;
    my $pairKey = $class->{PairKey}->X();
    my $pairValue = $class->{PairValue}->X();

    my @keyValue = ($pairKey, $pairValue);
    return @keyValue;
}

sub PP::PairKey::X {
    my ($class, $className) = @_;
    return (       $class->{Number}
                || $class->{String}
                || $class->{StructAccess}
                || $class->{ClassFunctionReturn}
                || $class->{FunctionReturn}
                || $class->{VariableName}
                || $class->{EmbedBlock} )->X();
}

sub PP::PairValue::X {
    my ($class, $className) = @_;
    return (       $class->{RealNumber}
                || $class->{String}
                || $class->{ArrayList}
                || $class->{HashRef}
                || $class->{VariableName}
                || $class->{ArrayElement}
                || $class->{HashElement}
                || $class->{FunctionReturn}
                || $class->{EmbedBlock} )->X();
}

sub PP::FunctionCall::X {
    my ($class, $className) = @_;
    my $functionName = $class->{FunctionName}->X();

    my $functionCall = $functionName . "(" ;

    if(exists $class->{Parameters}) {
        my @parameters = @{$class->{Parameters}->X()};
        $functionCall .= join(",", @parameters);
    }

    $functionCall .= ");";
    return $functionCall;
}

sub PP::Parameters::X {
    my ($class, $className) = @_;
    my @parameters;

    for my $element (@{ $class->{Param} }) {
        push @parameters, $element->X();
    }

    return \@parameters;
}

sub PP::Param::X {
    my ($class, $className) = @_;
    return (       $class->{RealNumber}
                || $class->{String}
                || $class->{VariableName}
                || $class->{ArrayElement}
                || $class->{HashElement}
                || $class->{HashRef}
                || $class->{FunctionReturn}
                || $class->{EmbedBlock}
                || $class->{Calc}
                || $class->{ParamChars} )->X();
}

sub PP::ParamChars::X {
    my ($class, $className) = @_;
    my $paramChars = $class->{ParamCharacters}->X();
    return $paramChars;
}

sub PP::ParamCharacters::X {
    my ($class, $className) = @_;
    my $paramCharacters = $class->{''};
    return $paramCharacters;
}

sub PP::Assignment::X {
    my ($class, $className) = @_;

    return (
                    $class->{ScalarAssignment}
                || $class->{ArrayAssignment}
                || $class->{HashAssignment} )->X();
}


sub PP::ScalarAssignment::X {
    my ($class, $className) = @_;
    my $lhs = $class->{ScalarVariable}->X();
    my $rhs = $class->{RHS}->X();

    my $scalarAssignment = $lhs . " = " . $rhs . ";\n";
    return $scalarAssignment;
}

sub PP::LHS::X {
    my ($class, $className) = @_;
    my $scalarVariable = $class->{ScalarVariable}->X();

    return $scalarVariable;
}

sub PP::ScalarVariable::X {
    my ($class, $className) = @_;

    my $scalarVariable = "\$";
    $scalarVariable .= $class->{''};

    return $scalarVariable;
}

sub PP::RHS::X {
    my ($class, $className) = @_;

    return (       $class->{Number}
                || $class->{RealNumber}
                || $class->{FunctionReturn}
                || $class->{ArrayElement}
                || $class->{HashElement}
                || $class->{ScalarVariable}
                || $class->{Calc}
                || $class->{ArrayList}
                || $class->{HashRef}
                || $class->{String}
                || $class->{ParamChars}
                || $class->{STDIN}
                || $class->{EmbedBlock} )->X();
}


sub PP::STDIN::X {
    my ($class, $className) = @_;
    my $stdin = '<STDIN>';
    return $stdin;
}


sub PP::FunctionReturn::X {
    my ($class, $className) = @_;
    my $functionName = $class->{FunctionName}->X();

    my $functionReturn = $functionName . "(" ;

    if(exists $class->{Parameters}) {
        my @parameters = @{$class->{Parameters}->X()};
        my $parameters = join(",", @parameters);
        $functionReturn .= $parameters;
    }

    $functionReturn .= ")";
    return $functionReturn;
}

sub PP::ArrayElement::X {
    my ($class, $className) = @_;
    my $arrayName = $class->{ArrayName}->X();
    my @accessList;

    for my $element (@{ $class->{ArrayAccess} }) {
        push @accessList, $element->X();
    }

    my $arrayElement =  "\$" . $arrayName;
    foreach my $element (@accessList) {
        $arrayElement .= $element;
    }

    return $arrayElement;
}

sub PP::ArrayAccess::X {
    my ($class, $className) = @_;

    return (       $class->{ArrayAccessElement}
                || $class->{ArrayAccessHash} )->X();
}

sub PP::ArrayAccessElement::X {
    my ($class, $className) = @_;
    my $arrayKey = $class->{ArrayKey}->X();
    my $arrayAccessElement = "->[" . $arrayKey . "]";
    return $arrayAccessElement;
}

sub PP::ArrayAccessHash::X {
    my ($class, $className) = @_;
    my $hashKey = $class->{HashKey}->X();
    my $arrayAccessHash = "->{" . $hashKey . "}";
    return $arrayAccessHash;
}

sub PP::ArrayKey::X {
    my ($class, $className) = @_;
    return (       $class->{Number}
                || $class->{RealNumber}
                || $class->{ScalarVariable}
                || $class->{ArrayElement}
                || $class->{HashElement}
                || $class->{FunctionReturn} )->X();
}

sub PP::ArrayName::X {
    my ($class, $className) = @_;
    my $arrayName = $class->{''};
    return $arrayName;
}

sub PP::HashElement::X {
    my ($class, $className) = @_;
    my $hashName = $class->{HashName}->X();
    my @accessList;

    for my $element (@{ $class->{HashAccess} }) {
        push @accessList, $element->X();
    }

    my $hashElement = "\$" . $hashName;
    foreach my $element (@accessList) {
        $hashElement .= $element;
    }

    return $hashElement;
}

sub PP::HashAccess::X {
    my ($class, $className) = @_;

    return (       $class->{HashAccessElement}
                || $class->{HashAccessArray} )->X();
}

sub PP::HashAccessElement::X {
    my ($class, $className) = @_;

    my $hashKey = $class->{HashKey}->X();
    my $hashAccessElement = "->{" . $hashKey . "}";
    return $hashAccessElement;
}

sub PP::HashAccessArray::X {
    my ($class, $className) = @_;

    my $arrayKey = $class->{ArrayKey}->X();
    my $hashAccessArray = "->[" . $arrayKey . "]";
    return $hashAccessArray;
}

sub PP::HashName::X {
    my ($class, $className) = @_;
    my $hashName = $class->{''};
    return $hashName;
}

sub PP::HashKey::X {
    my ($class, $className) = @_;
    return (       $class->{String}
                || $class->{Number}
                || $class->{ScalarVariable}
                || $class->{ArrayElement}
                || $class->{HashElement}
                || $class->{FunctionReturn} )->X();
}

sub PP::HashKeyString::X {
    my ($class, $className) = @_;

    my $hashKeyStringValue = "\"";
    $hashKeyStringValue .= $class->{HashKeyStringValue}->X();
    $hashKeyStringValue .= "\"";

    return $hashKeyStringValue;
}

sub PP::HashKeyStringValue::X {
    my ($class, $className) = @_;
    my $hashKeyStringValue = $class->{''};
    return $hashKeyStringValue;
}

sub PP::HashKeyNumber::X {
    my ($class, $className) = @_;
    my $hashKeyNumber = $class->{''};
    return $hashKeyNumber;
}

sub PP::ArrayAssignment::X {
    my ($class, $className) = @_;
    my $arrayElement = $class->{ArrayElement}->X();
    my $rhs = $class->{RHS}->X();

    my $arrayAssignment = $arrayElement . " = " . $rhs . ";\n";
    return $arrayAssignment;
}

sub PP::HashAssignment::X {
    my ($class, $className) = @_;
    my $hashElement = $class->{HashElement}->X();
    my $rhs = $class->{RHS}->X();

    my $hashAssignment = $hashElement . " = " . $rhs . ";\n";
    return $hashAssignment;
}

sub PP::Calc::X {
    my ($class, $className) = @_;
    my $calcExpression = $class->{CalcExpression}->X();
    return $calcExpression;
}

sub PP::CalcExpression::X {
    my ($class, $className) = @_;
    my @calcOperands;
    my @calcOperator;

    for my $element (@{ $class->{CalcOperands} }) {
        push @calcOperands, $element->X();
    }

    for my $element (@{ $class->{CalcOperator} }) {
        push @calcOperator, $element->X();
    }

    my $calcExpression = $calcOperands[0];
    for my $counter (1 .. $#calcOperands) {
        $calcExpression .= $calcOperator[$counter - 1] . " " . $calcOperands[$counter];
    }

    return $calcExpression;
}

sub PP::CalcOperands::X {
    my ($class, $className) = @_;
    return (       $class->{RealNumber}
                || $class->{ScalarVariable}
                || $class->{ArrayElement}
                || $class->{HashElement}
                || $class->{FunctionReturn}
                || $class->{EmbedBlock} )->X();
}

sub PP::CalcOperator::X {
    my ($class, $className) = @_;
    return (       $class->{Plus}
                || $class->{Minus}
                || $class->{Multiply}
                || $class->{Divide}
                || $class->{EmbedBlock} )->X();
}

sub PP::Return::X {
    my ($class, $className) = @_;
    if(exists $class->{RHS}) {
        my $rhs = $class->{RHS}->X();
        my $return = "return " . $rhs . ";\n";
        return $return;
    } else {
        return "return;";
    }
}

sub PP::Last::X {
    my ($class, $className) = @_;
    return "last;";
}

sub PP::Next::X {
    my ($class, $className) = @_;
    return "next;";
}

sub PP::GreaterThan::X {
    my ($class, $className) = @_;
    my $greaterThan = $class->{''};
    return $greaterThan;
}

sub PP::LessThan::X {
    my ($class, $className) = @_;
    my $lessThan = $class->{''};
    return $lessThan;
}

sub PP::Equals::X {
    my ($class, $className) = @_;
    my $equals = $class->{''};
    return $equals;
}

sub PP::Plus::X {
    my ($class, $className) = @_;
    my $plus = $class->{''};
    return $plus;
}

sub PP::Minus::X {
    my ($class, $className) = @_;
    my $minus = $class->{''};
    return $minus;
}

sub PP::Multiply::X {
    my ($class, $className) = @_;
    my $multiply = $class->{''};
    return $multiply;
}

sub PP::Divide::X {
    my ($class, $className) = @_;
    my $divide = $class->{''};
    return $divide;
}

sub PP::Modulus::X {
    my ($class, $className) = @_;
    my $divide = $class->{''};
    return $divide;
}

sub PP::Exponent::X {
    my ($class, $className) = @_;
    my $divide = $class->{''};
    return $divide;
}

sub PP::GreaterThanEquals::X {
    my ($class, $className) = @_;
    my $greaterThanEquals = $class->{''};
    return $greaterThanEquals;
}

sub PP::LessThanEquals::X {
    my ($class, $className) = @_;
    my $lessThanEquals = $class->{''};
    return $lessThanEquals;
}

sub PP::StringEquals::X {
    my ($class, $className) = @_;
    my $stringEquals = $class->{''};
    return $stringEquals;
}

sub PP::Percent::X {
    my ($class, $className) = @_;
    my $percent = $class->{''};
    return $percent;
}

sub PP::StringNotEquals::X {
    my ($class, $className) = @_;
    my $stringNotEquals = $class->{''};
    return $stringNotEquals;
}

sub PP::NotEqulas::X {
    my ($class, $className) = @_;
    my $notEqulas = $class->{''};
    return $notEqulas;
}

sub PP::LogicalAnd::X {
    my ($class, $className) = @_;
    my $logicalAnd = $class->{''};
    return $logicalAnd;
}

sub PP::LogicalOr::X {
    my ($class, $className) = @_;
    my $logicalOr = $class->{''};
    return $logicalOr;
}

sub PP::TokenImplement::X {
    my ($class, $className) = @_;
    my $tokenImplement = $class->{''};
    return $tokenImplement;
}

sub PP::TokenTry::X {
    my ($class, $className) = @_;
    my $tokenTry = $class->{''};
    return $tokenTry;
}

sub PP::TokenCatch::X {
    my ($class, $className) = @_;
    my $tokenCatch = $class->{''};
    return $tokenCatch;
}

sub PP::TokenError::X {
    my ($class, $className) = @_;
    my $tokenError = $class->{''};
    return $tokenError;
}

sub PP::EachSymbol::X {
    my ($class, $className) = @_;
    my $eachSymbol = $class->{''};
    return $eachSymbol;
}

sub PP::LParen::X {
    my ($class, $className) = @_;
    my $lParen = $class->{''};
    return $lParen;
}

sub PP::LParenError::X {
    my ($class, $className) = @_;
    my $lParenError = $class->{''};

    print "SyntaxError", "\n";
    print "===========", "\n";
    die "Missing ( after className '", $className, "', instead found ", $lParenError, "\n";
}

sub PP::LBrace::X {
    my ($class, $className) = @_;
    my $lBrace = $class->{''};
    return $lBrace;
}

sub PP::LBraceError::X {
    my ($class, $className) = @_;
    my $classLBraceError = $class->{''};
    return $classLBraceError;
}

sub PP::RBrace::X {
    my ($class, $className) = @_;
    my $rBrace = $class->{''};
    return $rBrace;
}

sub PP::RBraceError::X {
    my ($class, $className) = @_;
    my $classRBraceError = $class->{''};
    return $classRBraceError;
}

my $parser = qr {
    <nocontext:>
    # <debug: on>

    <Lang>
    <objrule:  PP::Lang>                               <[FunctionOrEmbed]>+
    <objrule:  PP::FunctionOrEmbed>                    <DefineFunction> | <DefineEmbed>
    <objrule:  PP::DefineFunction>                     <[Function]>+
    <objrule:  PP::DefineEmbed>                        <[EmbedBlock]>+

    <objrule:  PP::Function>                           <TokenFunction> <FunctionName> <LParen> <FunctionParamList> <RParen> <CodeBlock>
    <objtoken: PP::FunctionName>                       [A-Za-z_]+?

    <objrule:  PP::FunctionParamList>                  <EmptyParamList> | <FunctionParams>
    <objtoken: PP::EmptyParamList>                     .{0}
    <objrule:  PP::FunctionParams>                     <[Arg]>+ % <Comma>
    <objrule:  PP::Arg>                                [a-zA-Z]+?

    <objrule:  PP::CodeBlock>                          <LBrace> <Blocks> <RBrace>
    <objrule:  PP::Blocks>                             <[Block]>+
    <objrule:  PP::Block>                              <IfElse> | <While> | <ForEach> | <ArrayEach> | <HashEach> | <EmbedBlock> | <Statement> | <NonSyntax>

    <objtoken: PP::NonSyntax>                          \b.*\b

    <objrule:  PP::EmbedBlock>                         <TokenEmbedBlock> <EmbedCodeBlock>
    <objrule:  PP::EmbedCodeBlock>                     <EmbedBegin> <EmbeddedCode> <EmbedEnd>
    <objrule:  PP::EmbedBegin>                         <LParen>\?
    <objrule:  PP::EmbedEnd>                           \?<RParen>
    <objrule:  PP::EmbeddedCode>                       (?<=\(\?)\s*.*?\s*(?=\?\))

    <objrule:  PP::While>                              <TokenWhile> <LParen> <BoolExpression> <RParen> <CodeBlock>

    <objrule:  PP::ForEach>                            <TokenForeach> <LParen> <ForRange> <RParen> <EachSymbol> <LParen> <VariableName> <RParen> <CodeBlock>

    <objrule:  PP::ArrayEach>                          <TokenArrayEach> <LParen> <VariableName> <RParen> <EachSymbol> <LParen> <ArrayEachVariableName> <Comma> <ArrayEachNumber> <RParen> <CodeBlock>
    <objrule:  PP::ArrayEachVariableName>              <VariableName>
    <objrule:  PP::ArrayEachNumber>                    <VariableName>

    <objrule:  PP::HashEach>                           <TokenHashEach> <LParen> <VariableName> <RParen> <EachSymbol> <LParen> <HashEachKey> <Comma> <HashEachValue> <RParen> <CodeBlock>
    <objrule:  PP::HashEachKey>                        <VariableName>
    <objrule:  PP::HashEachValue>                      <VariableName>

    <objrule:  PP::ForRange>                           <LowerRange> <Dot><Dot> <UpperRange>
    <objrule:  PP::LowerRange>                         <String> | <Number> | <VariableName> | <ArrayElement> | <HashElement> | <FunctionReturn>
    <objrule:  PP::UpperRange>                         <String> | <Number> | <VariableName> | <ArrayElement> | <HashElement> | <FunctionReturn>

    <objrule:  PP::IfElse>                             <If> <ElsIf>? <Else>?
    <objrule:  PP::If>                                 <TokenIf> <LParen> <BoolExpression> <RParen> <CodeBlock>

    <objrule:  PP::BoolExpression>                     <[BooleanExpression]>+ % <[BoolOperator]>
    <objrule:  PP::BooleanExpression>                  <BoolOperands> <BoolOperatorExpression>?
    <objrule:  PP::BoolOperatorExpression>             <BoolOperator> <BoolOperands>

    <objrule:  PP::BoolOperands>                       <RealNumber> | <String> | <ScalarVariable> | <ArrayElement> | <HashElement>
                                                        | <FunctionReturn> | <EmbedBlock>

    <objrule:  PP::BoolOperator>                       <GreaterThan> | <LessThan> | <Equals> | <GreaterThanEquals> | <LessThanEquals> | <Percent>
                                                        | <StringEquals> | <StringNotEquals> | <NotEqulas> | <LogicalAnd> | <LogicalOr> | <EmbedBlock>

    <objrule:  PP::ElsIf>                              <[ElsIfChain]>+
    <objrule:  PP::ElsIfChain>                         <TokenElsIf> <LParen> <BoolExpression> <RParen> <CodeBlock>
    <objrule:  PP::Else>                               <TokenElse> <CodeBlock>

    <objrule:  PP::Statement>                          <VariableDeclaration> | <FunctionCall>
                                                        | <Assignment> | <Return> | <Last> | <Next>

    <objrule:  PP::VariableDeclaration>                <ArrayDeclaration> | <HashDeclaration> | <ScalarDeclaration>

    <objrule:  PP::ScalarDeclaration>                  <Var> <VariableName> <Equal> <Value> <SemiColon>
    <objtoken: PP::VariableName>                       [a-zA-Z_]+?
    <objrule:  PP::Value>                              <RHS>
    <objtoken: PP::Number>                             -?[0-9]+
    <objtoken: PP::RealNumber>                         [-]?[0-9]+\.?[0-9]+|[0-9]+
    <objrule:  PP::String>                             <Quote> <StringValue> <Quote>
    <objtoken: PP::StringValue>                        (?<=")\s*.*?\s*(?=")

    <objrule:  PP::ArrayDeclaration>                   <Var> <VariableName> <Equal> <ArrayList> <SemiColon>
    <objrule:  PP::ArrayList>                          <LBracket> <ListElements> <RBracket>
    <objrule:  PP::ListElements>                       .{0} | <[ListElement]>+ % <Comma>

    <objrule:  PP::ListElement>                        <RealNumber> | <String>  | <FunctionReturn>
                                                        | <ArrayElement> | <HashElement> | <ArrayList> | <HashRef> | <VariableName> | <EmbedBlock>

    <objrule:  PP::HashDeclaration>                    <Var> <VariableName> <Equal> <HashRef> <SemiColon>
    <objrule:  PP::HashRef>                            <LBrace> <KeyValuePairs> <RBrace>
    <objrule:  PP::KeyValuePairs>                      .{0} | <[KeyValue]>+ % <Comma>
    <objrule:  PP::KeyValue>                           <PairKey> <Colon> <PairValue>

    <objrule:  PP::PairKey>                            <Number> | <String> | <FunctionReturn> | <VariableName> | <EmbedBlock>
                                                        | <ArrayElement> | <HashElement>

    <objrule:  PP::PairValue>                          <RealNumber> | <String> | <FunctionReturn>
                                                        | <ArrayElement> | <HashElement> | <ArrayList> | <HashRef>
                                                        | <VariableName>  | <EmbedBlock>

    <objrule:  PP::FunctionCall>                       <FunctionName> <LParen> <Parameters>? <RParen> <SemiColon>
    <objrule:  PP::Parameters>                         <[Param]>+ % <Comma>
    <objrule:  PP::Param>                              <RealNumber> | <String>  | <VariableName> | <ArrayElement> | <HashElement>
                                                        | <HashRef> | <FunctionReturn> | <EmbedBlock> | <Calc> | <ParamChars>

    <objrule:  PP::ParamChars>                         <SingleQuote> <ParamCharacters> <SingleQuote>
    <objtoken: PP::ParamCharacters>                    [A-Za-z]+?

    <objrule:  PP::Assignment>                         <ScalarAssignment> | <ArrayAssignment> | <HashAssignment>

    <objrule:  PP::ScalarAssignment>                   <ScalarVariable> <Equal> <RHS> <SemiColon>
    <objtoken: PP::ScalarVariable>                     [a-zA-Z_]+

    <objrule:  PP::RHS>                                <Number> | <RealNumber> | <FunctionReturn> | <ArrayElement> | <HashElement>
                                                        | <ScalarVariable> | <Calc> | <ArrayList> | <HashRef> | <ParamChars>
                                                        | <String> | <STDIN> | <EmbedBlock>

    <objrule:  PP::FunctionReturn>                     <FunctionName> <LParen> <Parameters>? <RParen>

    <objrule:  PP::ArrayElement>                       <ArrayName> <[ArrayAccess]>+
    <objrule:  PP::ArrayAccess>                        <ArrayAccessElement> | <ArrayAccessHash>
    <objrule:  PP::ArrayAccessElement>                 <LBracket> <ArrayKey> <RBracket>
    <objrule:  PP::ArrayAccessHash>                    <LBrace> <HashKey> <RBrace>

    <objrule:  PP::ArrayKey>                           <Number> | <RealNumber> | <ScalarVariable> | <ArrayElement> | <HashElement> | <FunctionReturn>
    <objrule:  PP::ArrayName>                          [a-zA-Z]+?

    <objrule:  PP::HashElement>                        <HashName> <[HashAccess]>+
    <objrule:  PP::HashAccess>                         <HashAccessElement> | <HashAccessArray>
    <objrule:  PP::HashAccessElement>                  <LBrace> <HashKey> <RBrace>
    <objrule:  PP::HashAccessArray>                    <LBracket> <ArrayKey> <RBracket>
    <objrule:  PP::HashName>                           [a-zA-Z]+?
    <objrule:  PP::HashKey>                            <String> | <Number> | <ScalarVariable> | <ArrayElement> | <HashElement> | <FunctionReturn>

    <objrule:  PP::STDIN>                              <LessThan> <TokenSTDIN> <GreaterThan>

    <objtoken: PP::HashKeyStringValue>                 [a-zA-Z]+?

    <objrule:  PP::ArrayAssignment>                    <ArrayElement> <Equal> <RHS> <SemiColon>
    <objrule:  PP::HashAssignment>                     <HashElement> <Equal> <RHS> <SemiColon>

    <objrule:  PP::Calc>                               <CalcExpression>
    <objrule:  PP::CalcExpression>                     <[CalcOperands]>+ % <[CalcOperator]>
    <objrule:  PP::CalcOperands>                       <RealNumber> | <ScalarVariable> | <ArrayElement> | <HashElement> | <FunctionReturn> | <EmbedBlock>

    <objrule:  PP::CalcOperator>                       <Plus> | <Minus> | <Multiply> | <Divide> | <Modulus> | <Exponent> | <EmbedBlock>

    <objrule:  PP::Return>                             <TokenReturn> <RHS>? <SemiColon>
    <objrule:  PP::Last>                               <TokenLast> <SemiColon>
    <objrule:  PP::Next>                               <TokenNext> <SemiColon>

    <objtoken: PP::Var>                                my
    <objtoken: PP::TokenReturn>                        return
    <objtoken: PP::TokenNext>                          next
    <objtoken: PP::TokenLast>                          last
    <objtoken: PP::TokenElse>                          else
    <objtoken: PP::TokenElsIf>                         elsif
    <objtoken: PP::TokenIf>                            if
    <objtoken: PP::TokenForeach>                       forEach
    <objtoken: PP::TokenWhile>                         while
    <objtoken: PP::TokenFunction>                      sub
    <objtoken: PP::TokenEmbedBlock>                    emb
    <objtoken: PP::TokenSTDIN>                         STDIN
    <objtoken: PP::TokenArrayEach>                     arrayEach
    <objtoken: PP::TokenHashEach>                      hashEach

    <objtoken: PP::Percent>			                       \%
    <objtoken: PP::EachSymbol>                         =\>
    <objtoken: PP::Modulus>                            \%
    <objtoken: PP::Exponent>                           \*\*
    <objtoken: PP::LogicalAnd>                         \&\&
    <objtoken: PP::LogicalOr>                          \|\|
    <objtoken: PP::NotEqulas>                          \!=
    <objtoken: PP::StringNotEquals>                    ne
    <objtoken: PP::StringEquals>                       eq
    <objtoken: PP::LessThanEquals>                     \<=
    <objtoken: PP::GreaterThanEquals>                  \>=
    <objtoken: PP::GreaterThan>                        \>
    <objtoken: PP::LessThan>                           \<
    <objtoken: PP::Equals>                             ==
    <objtoken: PP::Plus>                               \+
    <objtoken: PP::Minus>                              \-
    <objtoken: PP::Multiply>                           \*
    <objtoken: PP::Divide>                             \/
    <objtoken: PP::Quote>                              "
    <objtoken: PP::SingleQuote>                        '
    <objtoken: PP::SemiColon>                          ;
    <objtoken: PP::Colon>                              :
    <objtoken: PP::Dot>                                \.
    <objtoken: PP::Equal>                              =
    <objtoken: PP::Comma>                              ,
    <objtoken: PP::LParen>                             \(
    <objtoken: PP::RParen>                             \)
    <objtoken: PP::LBrace>                             \{
    <objtoken: PP::RBrace>                             \}
    <objtoken: PP::LBracket>                           \[
    <objtoken: PP::RBracket>                           \]
}xms;

sub parse {
    my ($class, $program) = @_;
    if($program =~ $parser) {
        my $code = $/{Lang}->X();
        return $code;
    } else {
        my $notMatch = "print 'Error';";
        return $notMatch;
    }
}

1;
