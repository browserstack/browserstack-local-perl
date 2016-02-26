
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
  } else {
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
  elsif ($arg_key eq "binaryPath") {
    $self->{binary_path} = $value;
  }
  elsif ($arg_key eq "logfile") {
    $self->{logfile} = $value;
  }
  elsif ($arg_key eq "v") {
    $self->{verbose_flag} = "-v";
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
  elsif ($arg_key eq "hosts") {
    $self->{hosts} = $value;
  }
  elsif ($arg_key eq "f") {
    $self->{folder_flag} = "-f";
    $self->{folder_path} = $value;
  }   
}


sub start {
  my ($self, %args) = @_;
  system("echo '' > $self->{logfile}");
  foreach (keys %args) {
    $self->add_args($_,$args{$_});
  }

  $self->check_binary();
  my $command = $self->command();
  
  my $pid = $self->{pid} = open($self->{handle}, "-|");
  if (0 == $pid) {
    setpgrp(0, 0);
    exec $command;
    die "exec failed: $!\n";
  }
  else {
    open(my $loghandle, , '<', $self->{logfile});
    while (1) {
      my $line = <$loghandle>;
      chomp $line;
      if ($line  =~ /Press Ctrl-C to exit/) {
        close $loghandle;
        return;
      }
      if ($line =~ /Error/) {
        close $loghandle;
        #throw Exception->new($line);
        die $line;
        return;
      }
      sleep(1);
    }
  }
}

sub stop {
  my ($self) = @_;
  kill -9, $self->{pid};
  close ($self->{handle});
}

sub command {
  my ($self) = @_;
  my $command = "$self->{binary_path} -logFile $self->{logfile} $self->{folder_flag} $self->{folder_flag} $self->{key} $self->{folder_path} $self->{force_local_flag} $self->{local_identifier_flag} $self->{only_flag} $self->{only_automate_flag} $self->{proxy_host} $self->{proxy_port} $self->{proxy_user} $self->{proxy_pass} $self->{force_flag} $self->{verbose_flag} $self->{hosts}";
  $command =~ s/(?<!\w) //g;
  return $command;
}

sub check_binary {
  my @possiblebinarypaths = ($ENV{HOME} . "/.browserstack", getcwd, tempdir( CLEANUP => 1 ));

  my ($self) = @_;
  if (defined $self->{binary_path}) {
    if (-x $self->{binary_path} || -X $self->{binary_path}) {
      return 1;
    }
  }
  else
  {
    for (my $i=0; $i <= 2; $i++) {
      $self->{binary_path} = $possiblebinarypaths[$i] . "/BrowserStackLocal";
      
      if (-x $self->{binary_path} || -X $self->{binary_path}) {
        return 1;
      }
      else
      {
        $self->download_binary();
      }
      if (-x $self->{binary_path} || -X $self->{binary_path}) {
        return 1;}
    }
  }
  return 0;
}

sub platform_url {
  if ($^O =~ "darwin") {
  return "https://s3.amazonaws.com/browserStack/browserstack-local/BrowserStackLocal-darwin-x64";
  }
  elsif ($^O =~ /^Win/) {
  return "https://s3.amazonaws.com/browserStack/browserstack-local/BrowserStackLocal.exe";
  }
  if ($^O =~ "linux") {
  if (Config{'longsize'} == 8) {
    return "https://s3.amazonaws.com/browserStack/browserstack-local/BrowserStackLocal-linux-x64";
  } else {
    return "https://s3.amazonaws.com/browserStack/browserstack-local/BrowserStackLocal-linux-ia32";
  }  
  }
}


sub download_binary {
  my ($self) = @_;
  my $url = $self->platform_url();
  my $url = get $url;
  chmod 0777, $self->{binary_path};
}

1;

__END__
