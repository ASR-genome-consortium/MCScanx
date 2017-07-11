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
        $family_assignments{$family}->{$species}->{$gene} = 1;
    }
}

foreach my $family (keys %family_assignments) {
    my @species = keys %{$family_assignments{$family}};
    my @fam_genes;
    foreach my $species (@species) {
        my @species_genes = keys %{$family_assignments{$family}->{$species}};
        if (defined $limit && scalar(@species_genes) > $limit) {
            next;
        }
        else {
            push @fam_genes, @species_genes;
        }
    }
    for (my $i=0; $i < @fam_genes; $i++) {
        for (my $j=$i+1; $j < @fam_genes; $j++) {
            print $fam_genes[$i],"\t",$fam_genes[$j],"\n";
        }
    }
}
