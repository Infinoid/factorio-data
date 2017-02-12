#!/usr/bin/perl
use strict;
use warnings;
use JSON qw(decode_json);
use YAML qw(Dump);
use IO::All;
use v5.8;

my $d = decode_json(io("recipe.json")->all());
my %recipe;
foreach my $recipe (@$d) {
    $recipe{$$recipe{name}} = $recipe;
    next unless exists($$recipe{ingredients});
    next unless ref($$recipe{ingredients}) eq "ARRAY";
    my %hash;
    foreach my $piece (@{$$recipe{ingredients}}) {
        if(ref($piece) eq "HASH") {
            my ($k, $v) = ($$piece{name}, $$piece{amount});
            $hash{$k} = $v;
        }
        elsif(ref($piece) eq "ARRAY") {
            my ($k, $v) = @$piece;
            $hash{$k} = $v;
        }
        else {
            die "I dunno how to handle an ingredient-piece of type " . ref($piece);
        }
    }
    $$recipe{ingredients} = \%hash;
}

my $goal = shift;
$goal //= "processing-unit";
my $quantity = shift;
$quantity //= 1;
my %needed_ingredients; # key = item type, value = number produced per second
my %needed_factories;   # key = item type, value = number of factories producing it

sub achieve {
    my ($needed, $quantity) = @_;
    $needed_ingredients{$needed} = 0 unless exists $needed_ingredients{$needed};
    $needed_ingredients{$needed} += $quantity;
    my $recipe = $recipe{$needed};
    return unless exists($$recipe{ingredients});
    foreach my $ingredient (keys %{$$recipe{ingredients}}) {
        if($ingredient eq "type") {
            die("recipe for $needed has ingredient $ingredient\n");
        }
        my $ingredient_count = $$recipe{ingredients}{$ingredient};
        achieve($ingredient, $quantity*$ingredient_count);
    }
}

achieve($goal, $quantity);

foreach my $item (keys %needed_ingredients) {
    my $prod_count = $needed_ingredients{$item};
    my $recipe = $recipe{$item};
    my $seconds_per_prod = 0.5;
    $seconds_per_prod = $$recipe{energy_required} if exists $$recipe{energy_required};
    $needed_factories{$item} = $seconds_per_prod * $prod_count;
}

print "Production (items produced per second):\n";
print(Dump(\%needed_ingredients));
print "Factories (factories per item):\n";
print(Dump(\%needed_factories));
