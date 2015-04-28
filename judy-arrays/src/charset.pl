#!/usr/bin/env perl

use common::sense;

use Judy::L qw<First Get Next Set>;

binmode(STDOUT, ":utf8");

my $charset;

sub process_line
{
    my $line = shift;

    for my $char (split '', $line)
    {
        Set($charset, ord($char), Get($charset, ord($char)) + 1);
    }
}

sub print_result
{
    my (undef, $value, $char) = First($charset, 0);

    while (defined $char)
    {
        say chr($char) . ": $value";
        (undef, $value, $char) = Next($charset, $char);
    }
}

for my $line (<>)
{
    process_line($line);
}

print_result();
