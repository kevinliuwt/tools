#! /usr/bin/perl

use strict;
use warnings;
use Getopt::Long;
use Data::Dumper;

my $remote_host = undef;
my $remote_path = undef;
my @lines = "";

sub sync_files_usage
{
	print "This tool helps SCP your local modified files(git tracked) to remote machine:\n";
	print "-----------------------------------------------------------------------------\n";
	print "Pre-conditions:\n";
	print "ssh setup to allow none passwd ssh copy\n";
	print "Usage:\n";
	print "sync_files.pl -h|host=remote_host -p|path=remote_path\n";
}

#process the options
my $num_arg = scalar(@ARGV);
if ($num_arg != 1) {
    sync_files_usage();
    exit -1;
}else{
    GetOptions(
	    #"host|h:s"      	=> \$remote_host,
        "path|p:s"       	=> \$remote_path,
    );
};

if (!defined $remote_host) {
	$remote_host = "10.102.161.213";
}

#prepare modified file list
my @origlines = qx/git status/;

#my @lines = grep(/modified:/, @origlines);
foreach (@origlines) {
	if (/modified:/) {
		push @lines, $_;
	}
	if (/new file:/) {
		push @lines, $_;
	}
}

shift @lines;
chomp(@lines);
foreach (@lines) {
	if (/modified:(\s*)(.+)/) {
		$_ = $2;
	}
	if (/new file:(\s*)(.+)/) {
		$_ = $2;
	}
}

#verification
#print Dumper(\@lines);

#scp to the remote m/c
foreach (@lines) {
	if (/(.+)\/.*$/) {
		#print "$_\n";
		#print "$1\n";
		print "$_\n";
		qx/scp $_ lab002\@$remote_host:$remote_path$1/;
		print "Done\n";
	}
}

exit;
