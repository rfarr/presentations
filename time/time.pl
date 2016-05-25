#!/usr/bin/env perl

use strict;

use Time::HiRes qw{time};

print time; # 23:59:59.000
print time; # 23:59:59.999
print time; # 23:59:59.000 <-- Time reset one second previous
print time; # 23:59:59.999
print time; # 00:00:00.000
