#!/usr/bin/perl

use strict;
use File::Spec::Functions;
use Getopt::Long qw(:config no_auto_abbrev bundling);
use Pod::Usage;

my $chdman = 'chdman';
my $help;
my $man;
my $dry;

GetOptions(
  'h|help|?' => \$help,
  'man' => \$man,
  'n|dry-run' => \$dry,
);
if ($help) { pod2usage(1); }
if ($man) { pod2usage(-exitval => 0, -verbose => 2); }

sub is_valid_input {
  shift =~ m/\.(cue|iso|)$/i;
}

sub process_file {
  my $input = shift;
  if (! -f $input) {
    say { *STDERR } "File does not exist: $input";
  } elsif (is_valid_input($input)) {
    my $output = $input =~ s/\.[^.]+$/.chd/r;
    if (-e $output) {
      say { *STDOUT } "File already exists: $output";
    } else {
      my @args = ($chdman, "createcd", "--input", $input, "--output", $output);
      if ($dry) {
        local $, = ' ';
        say { *STDOUT } @args;
      } else {
        system(@args);
      }
    }
  } else {
    say { *STDERR } "Skipping unknown input: $input"
  }
}

sub process_dir {
  my $dir = shift;
  if (opendir(my $dh, $dir)) {
    for (readdir $dh) {
      my $file = catfile($dir, $_);
      if (-f $file && is_valid_input($file)) {
        process_file($file);
      }
    } 
    closedir $dh;
  } else {
    say { *STDERR } "Could not open directory: $dir";
  }
}

if (@ARGV) {
  for my $path (@ARGV) {
    if (-d $path) {
      process_dir($path);
    } else {
      process_file($path);
    }
  }
} else {
  process_dir('.');
}

__END__

=head1 NAME

B<cue2chd> - convert CUE/BIN or ISO to CHD

=head1 SYNOPSIS

cue2chd [options] [path ...]

=head1 OPTIONS

=over 4

=item B<-h>, B<--help>, B<-?>

Print usage message and exit.

=item B<--man>

Print manual and exit.

=item B<-n>, B<--dry-run>

Print the commands that would be executed, but do not execute them.

=back

=head1 DESCRIPTION

This program converts either CUE/BIN or ISO files to CHD files using B<chdman>.

When converting CUE/BIN files, only the CUE file should be specified.

=cut
