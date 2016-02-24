package BrowserStack::Local;

use 5.018002;
#use strict;
#use warnings;
use IO::Socket;
use LWP::Simple;
use File::Temp;
use Config;
use Cwd;

require Exporter;

our @ISA = qw(Exporter);

# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.

# This allows declaration	use BrowserStack::Local ':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.
our %EXPORT_TAGS = ( 'all' => [ qw(
	
) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw(
	
);

our $VERSION = '0.01';

my $handle;
my $binary_path;

my @possiblebinarypaths = ($ENV{HOME} . "/.browserStack", getcwd);

sub new {
    my $self = {
        key => $ENV{'BROWSERSTACK_KEY'},
    };

    
    bless $self;

    $self->{binary_path}="./BrowserStackLocal";
    return $self;
}

sub isRunning {
    my $host = 'localhost';
    my $port = '45691';
    my $socket = IO::Socket::INET->new(PeerAddr => $host , PeerPort => $port , Proto => 'tcp' , Timeout => 1);
    if ($socket){
        return 1;
    }
    else
    {
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
    elsif ($arg_key eq "v") {
        $self->{verbose_flag} = "-v";
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
    foreach (keys %args) {
        $self->add_args($_,$args{$_});
    }
    my $command = $self->command();
    open $handle, "$command |";
    while (my $line = <$handle>) 
     {
        
         chomp $line;
         if ($line eq "Press Ctrl-C to exit")
         {
            last;
         }
         if ($line =~ /Error/) {
             print "$line";
        }
     }
}


sub stop {
    my ($self) = @_;
    close ($handle);
}

sub command {
    my ($self) = @_;
    my $command = "$self->{binary_path} $self->{folder_flag} $self->{folder_flag} $self->{key} $self->{folder_path} $self->{force_local_flag} $self->{local_identifier_flag} $self->{only_flag} $self->{only_automate_flag} $self->{proxy_host} $self->{proxy_port} $self->{proxy_user} $self->{proxy_pass} $self->{force_flag} $self->{verbose_flag} $self->{hosts}";
    $command =~ s/(?<!\w) //g;
    return $command;
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


sub prepare_binary {
    my ($self) = @_;
    my $url = $self->platform_url();
    my $hello = get $url;
    # my $dir = File::Temp->newdir;
    # chdir $dir
    # chdir $olddir
    # foreach (@possiblebinarypaths)
    # {
    #   SubRoutine($_);
    # }
}

1;

__END__
# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

BrowserStack::Local - Perl extension for blah blah blah

=head1 SYNOPSIS

  use BrowserStack::Local;
  blah blah blah

=head1 DESCRIPTION

Stub documentation for BrowserStack::Local, created by h2xs. It looks like the
author of the extension was negligent enough to leave the stub
unedited.

Blah blah blah.

=head2 EXPORT

None by default.



=head1 SEE ALSO

Mention other useful documentation such as the documentation of
related modules or operating system documentation (such as man pages
in UNIX), or any relevant external documentation such as RFCs or
standards.

If you have a mailing list set up for your module, mention it here.

If you have a web site set up for your module, mention it here.

=head1 AUTHOR

Nidhi Makhijani, E<lt>nidhi@apple.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2016 by Nidhi Makhijani

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.18.2 or,
at your option, any later version of Perl 5 you may have available.


=cut
