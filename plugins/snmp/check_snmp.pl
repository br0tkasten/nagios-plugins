#!/usr/bin/perl -tw

use strict;
use warnings;
use lib './libs';
use Getopt::Long qw(:config no_ignore_case);
use Data::Dumper;
use Net::SNMP;

my $verbose   = '';
my $type      = '';
my $mode      = '';
my $host      = '';
my $community = '';


GetOptions (
   'c=s'         => \$community,
	'h'           => \&help,
   'H=s'         => \$host,
   'm=s'         => \$mode,
   't=s'         => \$type,
   'community=s' => \$community,
	'help'        => \&help,
   'host=s'      => \$host,
   'mode=s'      => \$mode,
   'type=s'      => \$type,
);

my $typeMap = {
	'snmpd'  => 'TYPE::SNMPD',
	'cisco'  => 'TYPE::CISCO',
	'huawei' => 'TYPE::HUAWEI'
};

my $modeMap = {
	'cpu'    => \&get_cpu,
	'temp'   => \&get_temp,
	'net'    => \&get_net
};

my $t = $typeMap->{$type};
eval "use $t"; 
my $object = eval { $t->new() };


my $result = eval { $modeMap->{$mode}->() };

sub get_cpu {

}

sub get_temp {

}


sub get_net {
	print "Get Net Data...\n";
	my %params;
	my ($snmp,$error) = Net::SNMP->session(
		-hostname  => $host,
		-community => $community,
		-nonblocking => 0
	);
	my $result = $snmp->get_table(-baseoid => $object->{NET}->{IfTable});
	print Dumper($result);

	return (%params);
}

sub help {
	print qq{
Usage: $0 [...]
	
    -h --help     print help page
    -v --verbose  do some verbose stuff

};

	return(0);
}

exit(0);
