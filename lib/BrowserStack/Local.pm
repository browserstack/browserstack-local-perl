
package BrowserStack::Local;

use 5.018002;
#use strict;
#use warnings;
use IO::Socket;
use LWP::Simple;
use File::Temp;
use Config;
use Cwd;
use File::Temp qw(tempdir);
use File::Path qw(make_path);
use JSON::Parse qw(parse_json);

require Exporter;

our @ISA = qw(Exporter);

our %EXPORT_TAGS = ( 'all' => [ qw(
  
) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw(
  
);

{ my $ofh = select STDOUT;
  $| = 1;
  select $ofh;
}

our $VERSION = '0.01';

my $handle;
my $binary_path;
my $pid;

sub new {
  my $self = {
    key => $ENV{'BROWSERSTACK_ACCESS_KEY'},
  };
  
  bless $self;
  $self->{logfile} = getcwd . "/local.log";
  $self->{userargs} = [];
  $self->{opcode} = "start";
  return $self;
}

sub isRunning {
  my ($self) = @_;
  if (defined $self->{pid}) {
    my $exists = kill 0, $self->{pid};
    if ($exists) { 
      return 1;
    }
    return 0;
  } 
  else {
    return 0;
  }
}

sub add_args {
  my ($self,@arguments) = @_;    
  my $arg_key = $arguments[0];
  my $value = $arguments[1];
  if ($arg_key eq "key") {
    $self->{key} = $value;
  }
  elsif ($arg_key eq "binarypath") {
    $self->{binary_path} = $value;
  }
  elsif ($arg_key eq "logfile") {
    $self->{logfile} = $value;
  }
  elsif ($arg_key eq "v") {
    $self->{verbose_flag} = "-vvv";
  }
  elsif ($arg_key eq "force") {
    $self->{force_flag} = "-force";
  }
  elsif ($arg_key eq "only") {
    $self->{only_flag} = "-only";
  }
  elsif ($arg_key eq "onlyAutomate") {
    $self->{only_automate_flag} = "-onlyAutomate";
  }
  elsif ($arg_key eq "forcelocal") {
    $self->{force_local_flag} = "-forcelocal";
  }
  elsif ($arg_key eq "localIdentifier") {
    $self->{local_identifier_flag} = "-localIdentifier $value";
  }
  elsif ($arg_key eq "proxyHost") {
    $self->{proxy_host} = "-proxyHost $value";
  }
  elsif ($arg_key eq "proxyPort") {
    $self->{proxy_port} = "-proxyPort $value";
  }
  elsif ($arg_key eq "proxyUser") {
    $self->{proxy_user} = "-proxyUser $value";
  }
  elsif ($arg_key eq "proxyPass") {
    $self->{proxy_pass} = "-proxyPass $value";
  }
  elsif ($arg_key eq "forceproxy") {
    $self->{force_proxy_flag} = "-forceproxy";
  }
  elsif ($arg_key eq "hosts") {
    $self->{hosts} = $value;
  }
  elsif ($arg_key eq "f") {
    $self->{folder_flag} = "-f";
    $self->{folder_path} = $value;
  }
  elsif ($value eq 1) {
    push ((@{$self->{userargs}}), "-$arg_key");
  }
  else {
    push ((@{$self->{userargs}}), "-$arg_key '$value'");
  }
}


sub start {
  my ($self, %args) = @_;
  system("echo '' > $self->{logfile}");
  foreach (keys %args) {
    $self->add_args($_,$args{$_});
  }

  return if exists $args{'onlyCommand'};

  $self->get_binary_path();
  $self->{opcode} = "start";
  my $command = $self->command();
  
  my $out = `$command`;
  my $data = parse_json ($out);

  if ($data->{state} != "connected"){
    die $data->{message}->{message};
  }
  else {
    $self->{pid} = $data->{pid};
  }
}

sub stop {
  my ($self) = @_;
  if(0 == $self->isRunning()) { 
    return;
  }
  $self->{opcode} = "stop";
  my $command = $self->command();
  my $out = `$command`;
}

sub command {
  my ($self) = @_;
  my $userargs = join(' ', (@{$self->{userargs}}));
  my $command = "$self->{binary_path} -d $self->{opcode} -logFile $self->{logfile} $self->{folder_flag} $self->{folder_flag} $self->{key} $self->{folder_path} $self->{force_local_flag} $self->{local_identifier_flag} $self->{only_flag} $self->{only_automate_flag} $self->{proxy_host} $self->{proxy_port} $self->{proxy_user} $self->{proxy_pass} $self->{force_proxy_flag} $self->{force_flag} $self->{verbose_flag} $self->{hosts} $userargs 2>&1";
  $command =~ s/(?<!\w) //g;
  return $command;
}

sub get_binary_path {
  my ($self) = @_;
  my $path = $self->get_available_path();

  $self->{binary_path} = $path . "/BrowserStackLocal";   
  if (-x $self->{binary_path} || -X $self->{binary_path}) {
    return 1;
  } 
  else {
    $self->download_binary();
  }
}

sub get_available_path {
  if ($^O =~ /Win/){
    $ENV{HOME} = $ENV{USERPROFILE};
  }
  my @possiblebinarypaths = ($ENV{HOME} . "/.browserstack", getcwd, tempdir( CLEANUP => 1 ));

  my ($self) = @_;
  for (my $i=0; $i <= 2; $i++) {
    my $path = $possiblebinarypaths[$i];
    
    if (-x $path || -X $path || make_path($path)) {
      return $path;
    }
  }
  die "Error trying to download BrowserStack Local binary";
}

sub platform_url {
  if ($^O =~ "darwin") {
    return "http://s3.amazonaws.com/bstack-local-prod/BrowserStackLocal-darwin-x64";
  }
  elsif ($^O =~ /^Win/) {
    return "http://s3.amazonaws.com/bstack-local-prod/BrowserStackLocal.exe";
  }
  if ($^O =~ "linux") {
    if ($Config{longsize} == 8) {
      return "http://s3.amazonaws.com/bstack-local-prod/BrowserStackLocal-linux-x64";
    } 
    else {
      return "http://s3.amazonaws.com/bstack-local-prod/BrowserStackLocal-linux-ia32";
    }  
  }
}

sub download_binary {
  my ($self) = @_;
  my $url = $self->platform_url();
  getstore($url, $self->{binary_path});
  chmod 0777, $self->{binary_path};
}

1;

__END__
