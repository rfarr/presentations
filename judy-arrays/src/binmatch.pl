use autodie;
use common::sense;
use Readonly;

use Judy::1 qw<Count First Get Last MemUsed Next Prev Set Test>;
use List::Util qw<min>;

Readonly my $BUFFER_SIZE => 64 * 1024;

sub process
{
    my ($fh1, $fh2) = @_;

    my $lhs;
    my $rhs;

    my $index = 0;
    my $judy;

    while(1)
    {
        my $lhs_size = read($fh1, $lhs, $BUFFER_SIZE);
        my $rhs_size = read($fh2, $rhs, $BUFFER_SIZE);

        if (!$lhs_size || !$rhs_size)
        {
            last;
        }

        my $bit = 0;
        my $char = 0;
        for (1..min($lhs_size, $rhs_size) * 8)
        {
            if (vec($lhs, $bit, 1) == vec($rhs, $bit, 1))
            {
                Set($judy, $index);
            }
            $bit++;
            $index++;
        }
    }

    return $judy;
}

sub summarize
{
    my $judy = shift;

    say "Number of common bits: " . Count($judy, 0, -1);
    say "Memory used: " . MemUsed($judy);
}

sub front
{
    my $judy = shift;
    say First($judy, 0);
}

sub end
{
    my $judy = shift;
    say Last($judy, -1);
}

sub range
{
    my ($judy, $start, $end) = @_;

    if ($start < $end)
    {
        my $key = First($judy, $start);
        while (defined $key && $key <= $end)
        {
            say $key;
            $key = Next($judy, $key);
        }
    }
    else
    {
        my $key = Last($judy, $start);
        while (defined $key && $key >= $end)
        {
            say $key;
            $key = Prev($judy, $key);
        }
    }
}

sub test
{
    my ($judy, $index) = @_;

    say Test($judy, $index);
}


my $file1 = shift || die "Need file1";
my $file2 = shift || die "Need file2";

open(my $fh1, "<", $file1);
binmode($fh1);

open(my $fh2,, "<", $file2);
binmode($fh2);

my $judy = process($fh1, $fh2);

while(1)
{
    print "> ";
    my $line = <>;
    chomp $line;

    my ($cmd, @params) = split(' ', $line);

    if ($cmd eq 'exit')
    {
        exit 0;
    }
    elsif ($cmd eq 'summary')
    {
        summarize($judy);
    }
    elsif ($cmd eq 'first')
    {
        front($judy);
    }
    elsif ($cmd eq 'last')
    {
        end($judy);
    }
    elsif ($cmd eq 'range')
    {
        range($judy, @params);
    }
    elsif ($cmd eq 'test')
    {
        test($judy, @params);
    }
    else
    {
        say "Derp";
    }
}
