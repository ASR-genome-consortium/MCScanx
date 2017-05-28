#!/usr/bin/env perl
use strict;
use English;
$OFS="\t";
$ORS="\n";
while (<>) {
    chomp;
    my @data = split /\t/;
    if ($data[2] eq "gene") {
        my ($gene) = ($data[8] =~ /Name=([^;]+)/);
        if (! defined $gene) {
            my ($gene) = ($data[8] =~ /ID=([^;]+)/);
        }
        print $data[0], $gene, $data[3], $data[4];
    }
}
