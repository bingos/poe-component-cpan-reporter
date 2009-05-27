use strict;
use inc::Module::Install;
name 'POE-Component-CPAN-Reporter';
author 'Chris Williams <chris@bingosnet.co.uk>';
license 'perl';
version_from 'lib/POE/Component/CPAN/Reporter.pm';
abstract_from 'lib/POE/Component/CPAN/Reporter.pm';
perl_version '5.006';
author_tests 'xt';
no_index directory => 'xt';
install_script 'bin/minireporter';
build_requires 'Test::More' => 0.47;
build_requires 'File::Spec' => 0;
requires 'Storable' => 0;
requires 'POE' => 1.0002;
requires 'POE::Wheel::Run' => 0;
requires 'POE::Component::SmokeBox::Recent' => 1.00;
if ( $^O eq 'MSWin32' ) {
  requires 'Win32::Process' => 0;
  requires 'Win32::Job' => 0;
}
else {
  eval "require Proc::ProcessTable";
  if ( $@ ) {
    requires 'Proc::ProcessTable' => 0 if 
       prompt( 'Do you want to enable optional Proc::ProcessTable support [y/N]?', 'N' )
	 =~ /^Y/i;
  }
  else {
     warn "You already have optional module Proc::ProcessTable installed, skipping dialogue\n";
  }
}
WriteAll();
