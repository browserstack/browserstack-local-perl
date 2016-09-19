use 5.008008; # NOT 5.8.8 - needed by CPAN testers

use Module::Build;

my $builder = Module::Build
  ->new( module_name => 'BrowserStack::Local'
         , license => 'perl'
         , requires => { perl => '>= 5.18.2' }
	 , dist_abstract => 'Perl bindings for Browserstack Local'
         , dist_version => '1.0.0'
	 , dist_author => 'support@browserstack.com'
#         , create_makefile_pl => 'traditional'
       );

$builder->create_build_script;

