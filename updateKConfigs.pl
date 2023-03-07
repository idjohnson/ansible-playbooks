#!/bin/perl
#

my ($combined,$newint,$output,$newLocal,$newRemote,$newPort) = @ARGV;

open(FILEH,"$combined");
@filec = <FILEH>;
close(FILEH);

my $newcad=`cat $newint | grep 'certificate-authority-data' | sed 's/^.*: //'`;
my $clientcertdata=`cat $newint | grep 'client-certificate-data' | sed 's/^.*: //'`;
my $clientkeydata=`cat $newint | grep 'client-key-data' | sed 's/^.*: //'`;

for (my $i = 0; $i < scalar(@filec); $i += 1)
{
	#	print "$i\n";

	#  certificate-authority-data
	if (($filec[$i] =~ /server: https:\/\/73.242.50.46:25460/)||($filec[$i] =~ /server: https:\/\/192.168.1.81:6443/)||($filec[$i] =~ /server: https:\/\/$newRemote:$newPort/)||($filec[$i] =~ /server: https:\/\/$newLocal:6443/))
	{
		#print $filec[($i - 1)];
		$filec[($i - 1)] =~ s/^(.*)data: .*/\1data: /;
		chomp($filec[($i - 1)]);
		#	print $filec[($i - 1)] . $newcad;
	        $filec[($i - 1)] .= $newcad;
		# Now fix the Server IP and Ports if we changed
		if ($filec[$i] =~ /server: https:\/\/192/) {
			$filec[$i] =~ s/https:\/\/.*/https:\/\/$newLocal:6443/;
		} else {
			$filec[$i] =~ s/https:\/\/.*/https:\/\/$newRemote:$newPort/;
		}
	}
	# client cert and key data
	if ($filec[$i] =~ /^- name: mac81/) {
	    $filec[$i+2] =~ s/^(.*)data: .*/\1data: /;
	    chomp($filec[$i+2]);
	    $filec[$i+2] .= $clientcertdata;
	    $filec[$i+3] =~ s/^(.*)data: .*/\1data: /;
	    chomp($filec[$i+3]);
	    $filec[$i+3] .= $clientkeydata;
        }
}

# print updated file
open(FILEO,">$output");
foreach my $line (@filec)
{
   print FILEO $line;
}
close(FILEO);

exit 0;

