use strict;
use utf8;
use warning;
use feature ':5.12';

use BibTeX::Parser;
use IO::File;
use Getopt::Long;

our $texfile="";
our $generateBib=1;
GetOptions(
		   'texfile|file|f'=>\$texfile,
		   'generatebib|g|bib'=>$generateBib,
		   
);


sub entryoutput{
   
}
