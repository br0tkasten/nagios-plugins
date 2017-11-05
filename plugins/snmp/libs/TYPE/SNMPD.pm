package TYPE::SNMPD;

require Exporter;
use Net::SNMP;
use Data::Dumper;

our @ISA     = qw(Exporter);
our @EXPORT  = qw(); 
our $VERSION = 1.00; 

my $oidMap = {
	CPU    => { CPU0 => '' },
	TEMP   => { TEMP0 => '' },
	NET    => { 
		IfDescr  => '.1.3.6.1.2.1.2.2.1.2',
		IfInOct  => '.1.3.6.1.2.1.2.2.1.10',
		IfOutOct => '.1.3.6.1.2.1.2.2.1.16',
		IfInErr  => '.1.3.6.1.2.1.2.2.1.14',
		IfOutErr => '.1.3.6.1.2.1.2.2.1.20',
	},
};


sub new {
	my ($class,$p) = @_;
	my $self = bless({},$class);
	$self->{OID}  = $oidMap;

	my ($s,$e) = Net::SNMP->session(
		-hostname  => $p->{host},
		-community => $p->{community}
	);
	die($e) if($e);

	$self->{SNMP} = $s;
	return($self);
}

1;
