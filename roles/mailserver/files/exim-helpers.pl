#!/usr/bin/perl

use strict;

my $INCLUDE_SCORES = 1;

# Exim's "$spam_report" variable is not that useful when
# using rspamd (see below for an example.
# This function returns a list very similar to rspamc's
# X-Spam-Symbols header.
sub assemble_spam_symbol_list {
    my ($spam_report) = @_;
    my @symbols;
    my @lines = split /\n/, $spam_report;
    foreach my $line (@lines) {
        if ($line =~ m/Symbol:\s*(\S.*?)\((\-?\d+\.\d+)\)/i) {
            if ($2 == 0) {
                # ignore rules without any weight
            } elsif ($INCLUDE_SCORES) {
                push @symbols, "$1($2)";
            } else {
                push @symbols, $1;
            }
        }
    }

    # avoid extremly long lines, instead return multi-line header
    my $MAX_LINE_LENGTH = 78;
    my $symbol_header = '';
    my $current_line = '';

    my $cur_token;
    my $is_first_symbol = 1;
    foreach my $symbol (@symbols) {
        if ( ! $is_first_symbol) {
            $current_line .= ', ';
        }
        if (length($current_line) + length($symbol) > $MAX_LINE_LENGTH) {
            $symbol_header .= (length($symbol_header)) ? "\n".$current_line : $current_line;
            # multi-line header starts with some space
            $current_line = '    ';
        }
        $current_line .= $symbol;
        $is_first_symbol = 0;
    }

    if (length($current_line) > 0) {
        # add an extra newline if we have a multi-line header already
        $symbol_header .= (length($symbol_header)) ? "\n".$current_line : $current_line;
    }
    return $symbol_header;
}

my $_spam_report = 'Action: no action
Symbol: MIME_GOOD(-0.10)
Symbol: R_SPF_ALLOW(-1.50)
Symbol: R_DKIM_ALLOW(-1.10)
Symbol: BAYES_HAM(-0.90)
Symbol: DMARC_POLICY_ALLOW(-0.50)
Symbol: URIBL_BLOCKED(0.00)
Symbol: HFILTER_HOSTNAME_UNKNOWN(2.50)
Symbol: DATE_IN_PAST(1.00)
Symbol: MISSING_TO(2.00)
Symbol: FORGED_MUA_OUTLOOK(3.00)
Symbol: SEM_URIBL_FRESH15(3.00)
Symbol: R_NO_SPACE_IN_FROM(1.00)
Symbol: RDNS_NONE(1.00)
Symbol: HFILTER_HELO_5(3.00)
Message: (SPF): spf allow
Message-ID: 51ee44a3-a4c7-0c21-1666-a62b8dd154f7@schwarz-online.org';

#print assemble_spam_symbol_list($_spam_report);
#print "\n"

