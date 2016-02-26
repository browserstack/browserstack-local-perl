package Test::Local;

use Test::More;
use base 'Test::Class';
use TryCatch;

use BrowserStack::Local;

sub make_fixture : Test(setup) {
  my $local = BrowserStack::Local::new;
  shift->{local} = $local;
}

sub test_check_pid : Test {
  my $local = shift->{local};
  $local->start(%args);
  cmp_ok $local->{pid}, ">", 0;
}

sub test_is_running : Test(2) {
  my $local = shift->{local};
  cmp_ok $local->isRunning, "==", 0;
  $local->start(%args);
  cmp_ok $local->isRunning, "==", 1;
}

sub test_multiple_binary : Test {
  my $local = shift->{local};
  $local->start(%args);
  my $local2 = BrowserStack::Local::new;
  try {
    $local2->start(%args);
  }
  catch ($err) {
    cmp_ok $local2->isRunning, "==", 0;
  }
}

sub test_enable_verbose : Test {
  my $local = shift->{local};
  my %args = (
    "v" => 1, "onlyCommand" => 1
  );

  $local->start(%args);
  like($local->command(), '/-vvv/i', 'matches -vvv');
}

sub test_set_folder : Test(2) {
  my $local = shift->{local};
  my %args = (
    "f" => '/var/html', "onlyCommand" => 1
  );

  $local->start(%args);
  like($local->command(), '/-f/i', 'matches -f');
  like($local->command(), '/\/var\/html/i', 'matches /var/html');
}

sub test_enable_force : Test {
  my $local = shift->{local};
  my %args = (
    "force" => 1, "onlyCommand" => 1
  );

  $local->start(%args);
  like($local->command(), '/-force/i', 'matches -force');
}

sub test_enable_only : Test {
  my $local = shift->{local};
  my %args = (
    "only" => 1, "onlyCommand" => 1
  );

  $local->start(%args);
  like($local->command(), '/-only/i', 'matches -only');
}

sub test_enable_only_automate : Test {
  my $local = shift->{local};
  my %args = (
    "onlyAutomate" => 1, "onlyCommand" => 1
  );

  $local->start(%args);
  like($local->command(), '/-onlyAutomate/i', 'matches -onlyAutomate');
}

sub test_enable_force_local : Test {
  my $local = shift->{local};
  my %args = (
    "forcelocal" => 1, "onlyCommand" => 1
  );

  $local->start(%args);
  like($local->command(), '/-forcelocal/i', 'matches -forcelocal');
}

sub test_set_local_identifier : Test {
  my $local = shift->{local};
  my %args = (
    "localIdentifier" => "abcdef", "onlyCommand" => 1
  );

  $local->start(%args);
  like($local->command(), '/-localIdentifier abcdef/i', 'matches -localIdentifier abcdef');
}

sub test_set_proxy : Test(4) {
  my $local = shift->{local};
  my %args = (
    "proxyHost" => "localhost", 
    "proxyPort" => 8080,
    "proxyUser" => "user",
    "proxyPass" => "pass",
    "onlyCommand" => 1
  );

  $local->start(%args);
  like($local->command(), '/-proxyHost localhost/i', 'matches -proxyHost localhost');
  like($local->command(), '/-proxyPort 8080/i', 'matches -proxyPort 8080');
  like($local->command(), '/-proxyUser user/i', 'matches -proxyUser user');
  like($local->command(), '/-proxyPass pass/i', 'matches -proxyPass pass');
}

sub test_set_hosts : Test {
  my $local = shift->{local};
  my %args = (
    "hosts" => "localhost,8000,0", "onlyCommand" => 1
  );

  $local->start(%args);
  like($local->command(), '/localhost,8000,0/i', 'matches localhost,8000,0');
}

sub teardown : Test(teardown) {
  my $local = shift->{local};
  $local->stop();
  diag("array = (@$array) after test(s)");
}

1;
