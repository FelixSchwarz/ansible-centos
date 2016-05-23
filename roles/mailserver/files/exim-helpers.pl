#!/usr/bin/perl

use strict;

my $INCLUDE_SCORES = 0;

# Exim's "$spam_report" variable is not that useful when
# using rspamd (see below for an example.
# This function returns a list very similar to rspamc's
# X-Spam-Symbols header.
sub assemble_spam_symbol_list {
    my ($spam_report) = @_;
    my @symbols;
    my @lines = split /\n/, $spam_report;
    foreach my $line (@lines) {
        if ($line =~ m/Symbol:\s*(\w.*?)\((\d+\.\d+)\)/i) {
            if ($INCLUDE_SCORES) {
                push @symbols, "$1($2)";
            } else {
                push @symbols, $1;
            }
        }
    }
    return join(', ', @symbols);
}

my $spam_report = "Action: add header
 Symbol: HFILTER_HELO_IP_A(1.00)
 Symbol: ONCE_RECEIVED(0.10)
Symbol: R_SPF_FAIL(1.00)
Symbol: BROKEN_HEADERS(1.00)
Symbol: HFILTER_HELO_NORES_A_OR_MX(0.30)
Symbol: MISSING_DATE(1.00)
Symbol: MISSING_MID(2.50)
Symbol: MIME_GOOD(-0.10)
Message: (SPF): spf fail
Message-ID: undef";

#print assemble_spam_symbol_list($spam_report);
#print "\n"
