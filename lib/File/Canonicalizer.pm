package File::Canonicalizer;

use 5.006;
use strict;
use warnings FATAL => 'all';

require Exporter;
our @ISA = qw(Exporter);
our @EXPORT = qw(file_canonicalizer);

use Carp;
our $VERSION = '0.01';

sub file_canonicalizer {
   my ( $inp_file                                       # 1
      , $out_file                                       # 2
      , $remove_comments_started_with_RE                # 3
      , $replace_adjacent_tabs_and_spaces_with_1_space  # 4
      , $replace_adjacent_slashes_with_single_slash     # 5
      , $remove_white_char_from_line_edges              # 6
      , $remove_empty_lines                             # 7
      , $convert_to_lowercased                          # 8
      , $remove_leading_zeroes                          # 9
      , $sort_lines                                     #10
      , $replaced_substring                             #11
      , $replacing_substring                            #12
      ) = @_ ;

   my %lines ;
   my $INP;
   my $OUT;

   unless ($inp_file) { $inp_file = '&STDIN'; } 
   open ($INP, "<$inp_file") || croak "Error: Can't open file \"$inp_file\" for read: $!"; 
   unless ($out_file) { $out_file = '&STDOUT'; } 
   open ($OUT, ">$out_file") || croak "Error: Can't open file \"$out_file\" for write: $!" ;

   while (<$INP>)
   {
     if ($remove_comments_started_with_RE) { s/$remove_comments_started_with_RE.+$//; }
     if (defined $replacing_substring) { s/$replaced_substring/$replacing_substring/g; }
     if ($replace_adjacent_tabs_and_spaces_with_1_space) { s/[ \t]+/ /g; }
     if ($replace_adjacent_slashes_with_single_slash) { s#/+#/#g; }
     if ($remove_empty_lines) { (/^\s*$/) && next; }
     if ($remove_white_char_from_line_edges) { s/(^[ \t]*|[ \t]*$)//g; }
     if ($convert_to_lowercased) { $_ = lc; }
     if ($remove_leading_zeroes) { s/(\W)0+(\d)/$1$2/g; }
     if ($sort_lines) { $lines{$_} = undef; next; }
     print $OUT "$_" || croak "Error: Can't write to $out_file: $!";
   }

   if ($sort_lines)
   {
      for (sort keys %lines)
      {  print $OUT "$_" || croak "Error: Can't write to $out_file: $!"; }
   }

   close $OUT; 
   close $INP;
}  #  end of 'sub file_canonicalizer'

1;

__END__

=head1 NAME

File::Canonicalizer - ASCII file canonicalizer

=head1 SYNOPSIS

   use File::Canonicalizer;

   file_canonicalizer ('input_file','canonical_output_file', '',3,4,5,6,7,8,9,10);

=head1 DESCRIPTION

Sometimes files must be compared semantically, that is their contents, not their forms
are to be compared.
Following two files have different forms, but contain identical information:

file_A

   First name -        Barack   # and Hussein

   Last name  -        Obama

   Birth Date -        1961/8/4

   Profession -        President 


file_B

   last name : Obama
   first name: Barack
   profession: president   # not sure

   Birth Date: 1961/08/04

Some differences between forms of these files are:
 - arbitrary line order
 - arbitrary character cases
 - arbitrary leading zeroes for numbers
 - arbitrary amounts of white characters
 - arbitrary comments
 - arbitrary empty lines
 - field separators

Usage of file_canonicalizer allows to unify both these files, so that 
they can be compared with each other.

=head1 SUBROUTINES

=head2 file_canonicalizer

   file_canonicalizer ( <input_file>                                   # 1 default is STDIN
                      , <output_file>                                  # 2 default is STDOUT 
                      , remove_comments_started_with_<regular_expres>  # 3 if empty, ignore comments
                      , 'replace_adjacent_tabs_and_spaces_with_1_space'# 4
                      , 'replace_adjacent_slashes_with_single_slash'   # 5
                      , 'remove_white_char_from_line_edges'            # 6
                      , 'remove_empty_lines'                           # 7
                      , 'convert_to_lowercased'                        # 8
                      , 'remove_leading_zeroes_in_numbers'             # 9
                      , 'sort_lines'                                   #10
                      , <replaced_substring>                           #11
                      , <replacing_substring>                          #12
   );

All parameters, beginning with the 3rd, are interpreted as boolean values
true or false. A corresponding action will be executed only if its parameter value is true.
This means, that each of literals between apostrophes '' can be shortened to
single arbitrary character or digit 1-9.

List of parameters can be shortened, that is any amount of last parameters can be skipped.
In this case the actions, corresponding skipped parameters, will not be executed.

=head1 EXAMPLES

Read from STDIN, write to STDOUT and remove all strings, beginning with '#' :

   file_canonicalizer ('','','#');

Create canonicalized cron table (on UNIX/Linux) in any of equivalent examples:

   file_canonicalizer('path/cron_table','/tmp/cron_table.canonic','#',4,5,'e','empty_lin','',9,'sort');
   file_canonicalizer('path/cron_table','/tmp/cron_table.canonic','#',4,5, 6,    7,       '',9, 10);
   file_canonicalizer('path/cron_table','/tmp/cron_table.canonic','#',1,1, 1,    1,       '',1, 1);

Canonicalization of file 'file_A' and 'file_B':

   file_canonicalizer('file_A','file_A.c','#',1,5,1,1,1,1,10,'\-',':');
   file_canonicalizer('file_B','file_B.c','#',1,5,1,1,1,1,10);

creates two identical files 'file_A.c' and 'file_B.c':

   birth date : 1961/8/4
   first name : barack
   last name : obama
   profession : president

=cut

=head1 AUTHOR

Mart E. Rivilis,  rivilism@cpan.org

=head1 BUGS

Please report any bugs or feature requests to bug-file-canonicalizer@rt.cpan.org, or through
the web interface at http://rt.cpan.org/NoAuth/ReportBug.html?Queue=File-Canonicalizer.
I will be notified, and then you'll automatically be notified of progress on your bug
as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

   perldoc File::Canonicalizer

You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

 http://rt.cpan.org/NoAuth/Bugs.html?Dist=File-Canonicalizer

=item * AnnoCPAN: Annotated CPAN documentation

 http://annocpan.org/dist/File-Canonicalizer

=item * CPAN Ratings

 http://cpanratings.perl.org/d/File-Canonicalizer

=item * Search CPAN

 http://search.cpan.org/dist/File-Canonicalizer/

=back

=head1 LICENSE AND COPYRIGHT

Copyright 2013 Mart E. Rivilis.

This program is free software; you can redistribute it and/or modify it
under the terms of the the Artistic License (2.0). You may obtain a
copy of the full license at:

=cut
