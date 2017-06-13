#!/usr/bin/env perl
use strict;
use English;
$OFS="\t";
$ORS="\n";
my $prefix = shift;
open(GFF, "$prefix.gff") || die $!;
open(COL, "$prefix.collinearity") || die $!;
my %gene2loc;
while (<GFF>) {
    next if /^#/;
    chomp;
    my ($chr, $gene, $start, $stop) = split /\t/;
    $gene2loc{$gene} = [$chr, $start, $stop];
}

my ($b1_chr, $b1_start, $b1_stop, $b2_chr, $b2_start, $b2_stop, $orientation, $score, $alignment_block);
my @ks;
while (<COL>) {
    chomp;
    #TODO: add threshold criteria for acceptance
    if (/^## Alignment (\d+)(: score=([0-9.]+) e_value=([-0-9e.]+) N=(\d+) \S+ (plus|minus))?/) {
        if (defined $b1_start) {
            @ks = sort {$a <=> $b} @ks;
            my $median_ks;
            if (@ks) {
                $median_ks = $ks[$#ks/2];
            }
            
            my $name="${alignment_block}::$b1_chr:$b1_start-$b1_stop|$b2_chr:$b2_start-$b2_stop";
            print $b1_chr, "mcscanx", "syntenic_region", $b1_start, $b1_stop, $score, ($orientation eq "plus" ? "+" : "-"), ".", "ID=$name;Name=$name;Target=$b2_chr $b2_start $b2_stop".(defined $median_ks ? ";median_Ks=$median_ks" : "");
            $name="${alignment_block}::$b2_chr:$b2_start-$b2_stop|$b1_chr:$b1_start-$b1_stop";
            print $b2_chr, "mcscanx", "syntenic_region", $b2_start, $b2_stop, $score, ($orientation eq "plus" ? "+" : "-"), ".", "ID=$name;Name=$name;Target=$b1_chr $b1_start $b1_stop".(defined $median_ks ? ";median_Ks=$median_ks" : "");
        }
        $alignment_block = $1;
        $score = $4;
        $orientation = $5;
        $b1_chr = undef;
        $b1_start = undef;
        $b1_stop = undef;
        $b2_chr = undef;
        $b2_start = undef;
        $b2_stop = undef;
        @ks = ();
    }
    elsif (!/^#/) {
        my (undef, $gene1, $gene2, $match_evalue, $ka, $ks) = split /\t/;
        my ($g1_chr, $g1_start, $g1_stop) = @{$gene2loc{$gene1}};
        $b1_chr = $g1_chr;
        if (! defined $b1_start || $g1_start < $b1_start) {
            $b1_start = $g1_start;
        }
        if (! defined $b1_stop || $g1_stop > $b1_stop) {
            $b1_stop = $g1_stop;
        }
        my ($g2_chr, $g2_start, $g2_stop) = @{$gene2loc{$gene2}};
        $b2_chr = $g2_chr;
        if (! defined $b2_start || $g2_start < $b2_start) {
            $b2_start = $g2_start;
        }
        if (! defined $b2_stop || $g2_stop > $b2_stop) {
            $b2_stop = $g2_stop;
        }
        if (defined $ks) {
            push @ks, $ks;
        }
    }
}
