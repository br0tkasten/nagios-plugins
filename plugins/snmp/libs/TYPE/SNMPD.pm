package TYPE::SNMPD;

require Exporter;

our @ISA     = qw(Exporter);
our @EXPORT  = qw(); 
our $VERSION = 1.00; 

my $oidMap = {
	CPU    => { CPU0 => '' },
	TEMP   => { TEMP0 => '' },
	NET    => { 
		IfTable  => '.1.3.6.1.2.1.2',
		IfInOct  => '',
		IfOutOct => '',
		IfInErr  => '',
		IfOutErr => '',
	},
};


sub new {
	my ($class) = @_;
	my $self = bless($oidMap,$class);
	return($self);
}

1;
