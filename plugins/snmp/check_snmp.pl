#!/usr/bin/perl -w

use strict;
use warnings;
use lib './libs';
use Getopt::Long qw(:config no_ignore_case);
use Data::Dumper;
use Net::SNMP;
use Cache::File;

my $PARAMS = {
	type      => '',
	mode      => '',
	host      => '',
	community => '',
};

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


sub main {
	GetOptions (
		'c|community=s' => \$PARAMS->{community},
		'h|help'        => \&help,
		'H|host=s'      => \$PARAMS->{host},
		'm|mode=s'      => \$PARAMS->{mode},
		't|type=s'      => \$PARAMS->{type},
	);
	my $handler = &initHandler($typeMap->{$PARAMS->{type}}) or die($@);

	my $cache = Cache::File->new(
		cache_root => '/tmp/check_snmp/cache',
		default_expires => '3600 sec'
	) or die($@);
	my $data    = $cache->get($PARAMS->{host}) || {};
	
	my $result  = $modeMap->{$PARAMS->{mode}}->($handler,$data);
	print "result: " . Dumper($result);

	return(1);
}

sub initHandler {
	my ($t) = @_;
	die("no type") unless($t);

	eval "use $t;";
	die($@) if($@);

	my $r = ${t}->new($PARAMS);
	die($@) if($@);

	return($r);
}

sub _net_generate_ifIndex {
	my ($handler,$data) = @_;
	my $r = {};

	my $t = $handler->{SNMP}->get_table(-baseoid => $handler->{OID}->{NET}->{IfDescr});
	foreach my $k (sort keys %$t) {
		if($k =~ /^$handler->{OID}->{NET}->{IfDescr}\.(\d+)/) {
			$r->{$1} = $t->{$k};
		}
	}

	return($r);	
}

sub get_cpu {
	my ($handler,$data) = @_;

}

sub get_temp {
	my ($handler,$data) = @_;

}

sub get_net {
	my ($handler,$data) = @_;
	my $params = {};

	print "Cache: ";
	unless(exists($data->{net_ifIndex})) {
		$data->{net_ifIndex} = &_net_generate_ifIndex($handler) ;
	}

	foreach my $i (sort keys %{$data->{net_ifIndex}}) {
		foreach my $p (sort keys %{$handler->{OID}->{NET}}) {
			my $r = $handler->{SNMP}->get_request(-varbindlist => [ $handler->{OID}->{NET}->{$p} . ".$i" ]);
			($params->{$data->{net_ifIndex}->{$i}}->{$p}) = values %$r;
		}
	}

	return ($params);
}

sub help {
	print qq{
Usage: $0 [...]
	
    -h --help     print help page
    -v --verbose  do some verbose stuff

};

	return(0);
}

&main();
exit(0);
