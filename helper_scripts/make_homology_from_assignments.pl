#!/usr/bin/env perl
use strict;
use Getopt::Long;
my @species;
my $limit;
GetOptions(
    "species=s" => \@species,
    "limit=i" => \$limit,
);
my %species = map {$_ => 1;} @species;

my %family_assignments;
while (<>) {
    chomp;
    my ($gene, $family) = split /\t/;
    my ($species) = ($gene =~ /^([^.]+)/);
    if ($species{$species} || scalar(@species) == 0) {
        $family_assignments{$family}->{$gene} = 1;
    }
}

foreach my $family (keys %family_assignments) {
    my @genes = keys %{$family_assignments{$family}};
    if (defined $limit && scalar(@genes) > $limit) {
        next;
    }
    for (my $i=0; $i < @genes; $i++) {
        for (my $j=1; $j < @genes; $j++) {
            print $genes[$i],"\t",$genes[$j],"\n";
        }
    }
}
