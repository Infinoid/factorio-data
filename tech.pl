#!/usr/bin/perl
use strict;
use warnings;
use JSON qw(decode_json);
use YAML qw(Dump);
use IO::All;
use v5.8;

my $d = decode_json(io("technology.json")->all());
my %tech;
foreach my $tech (@$d) {
    $tech{$$tech{name}} = $tech;
    next unless exists($$tech{unit});
    next unless exists($$tech{unit}{ingredients});
    my %hash;
    foreach my $piece (@{$$tech{unit}{ingredients}}) {
        my ($k, $v) = @$piece;
        $hash{$k} = $v;
    }
    $$tech{unit}{ingredients} = \%hash;
}

my $goal = shift;
$goal //= "rocket-silo";
my %needed_techs;
my %needed_ingredients;

sub achieve {
    my $needed = shift;
    return if exists $needed_techs{$needed};
    $needed_techs{$needed} = 1;
    my $tech = $tech{$needed};
    die("no unit") unless exists($$tech{unit});
    die("no ingredients") unless exists($$tech{unit}{ingredients});
    my $research_count = $$tech{unit}{count};
    foreach my $ingredient (keys %{$$tech{unit}{ingredients}}) {
        my $ingredient_count = $$tech{unit}{ingredients}{$ingredient};
        $needed_ingredients{$ingredient} = 0 unless exists $needed_ingredients{$ingredient};
        $needed_ingredients{$ingredient} += $ingredient_count * $research_count;
    }
    return unless exists $$tech{prerequisites};
    foreach my $prerequisite (@{$$tech{prerequisites}}) {
        print("prerequisite $prerequisite\n");
        achieve($prerequisite);
    }
}

achieve($goal);

print(Dump(\%needed_ingredients));
