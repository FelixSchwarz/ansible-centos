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

my $_spam_report = 'Action: no action
Symbol: MIME_GOOD(-0.10)
Symbol: R_SPF_ALLOW(-1.50)
Symbol: R_DKIM_ALLOW(-1.10)
Symbol: BAYES_HAM(-0.90)
Symbol: DMARC_POLICY_ALLOW(-0.50)
Symbol: URIBL_BLOCKED(0.00)
Message: (SPF): spf allow
Message-ID: 51ee44a3-a4c7-0c21-1666-a62b8dd154f7@schwarz-online.org';

#print assemble_spam_symbol_list($_spam_report);
#print "\n"
