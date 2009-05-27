use Test::More;
use File::Spec;
use POE;

#if ( $^O eq 'MSWin32' ) {
#   eval "require CPAN::YACSmoke";
#   unless ($@) {
#	plan skip_all => "MSWin32 and CPAN::YACSmoke detected";
#   }
#}

plan tests => 12;

require_ok('POE::Component::CPAN::Reporter');

my @path = qw(COMPLETELY MADE UP PATH TO PERL);
unshift @path, 'C:' if $^O eq 'MSWin32';
my $perl = File::Spec->catfile( @path );

my $module = 'F/FU/FUBAR/Fubar-1.00.tar.gz';

my $smoker = POE::Component::CPAN::Reporter->spawn( alias => 'smoker',debug => 0, options => { trace => 0 } );

isa_ok( $smoker, 'POE::Component::CPAN::Reporter' );

POE::Session->create(
	package_states => [
	   'main' => [ qw(_start _stop _results _timeout) ],
	],
);

$poe_kernel->run();
exit 0;

sub _start {
  my ($kernel,$heap) = @_[KERNEL,HEAP];
  $kernel->post( 'smoker', 'submit', 
	{ event => '_results', perl => $perl, module => $module, '_ArBiTrArY' => 12345 } 
  );
  $kernel->delay( '_time_out', 60 );
  undef;
}

sub _stop {
  pass("Hey the poco let go of our refcount");
  $poe_kernel->call( 'smoker', 'shutdown' );
  undef;
}

sub _timeout {
  die "F**k it all went pear-shaped";
  undef;
}

sub _results {
  my $job = $_[ARG0];
  ok( $job->{$_}, "There was a $_" ) for qw(log start_time end_time PID status submitted);
  ok( $job->{module} eq $module, "Module was the same" );
  ok( $job->{_ArBiTrArY} eq '12345', "The Arbitary value can through unchanged" );
  my @stats = $smoker->statistics();
  ok( scalar @stats == 5, 'Right number of stats returned'  );
  $poe_kernel->delay( '_time_out' );
  undef;
}
