#!/usr/bin/perl

# This script executes commands that I run routinely to check the system's
# status.

use warnings;
use strict;

# Capture the commands output
my $top = `top -b -n1 | head -n 8`;
my $df_header = `df -TH | head -n 1`;
my $df_footer = `df -TH --total | tail -n 1`;
my $df_body = `df -TH | sed 1d | sort -k6,6n -k4,4h`;
my $logs = `find /home/$ENV{USER} -name "*.log" | xargs ls -l | sed 's#/home/$ENV{USER}#~#'`;
my $ps = `ps ux`;

chomp $df_header;
chomp $df_body;
chomp $logs;

# Truncate each row of ps's and df's output
my @ps = split("\n", $ps);
my $ps_n = -1;
$ps = '';
foreach my $line (@ps) {
    $line = substr($line, 0, 80);
    $ps .= $line . "\n";
    $ps_n++;
}
$ps.="total\t$ps_n";

my @df = split("\n", $df_body);
$df_body = '';
foreach my $line (@df) {
    $line = substr($line, 0, 80);
    $df_body .= $line . "\n";
}
chomp $df_body;

# Get the current time
my $localtime = localtime();

print << "END";
### REPORT ###
$localtime

top:
$top
df:
$df_header
$df_body
$df_footer
ps:
$ps

log files:
$logs
END

exit
