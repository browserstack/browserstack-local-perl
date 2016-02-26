#!/usr/bin/perlT
push (@INC,'pwd');
use BrowserStack::Local;

my %args = (
  "v" => 1
);

my $local = BrowserStack::Local::new;
print $local->isRunning();
print "Starting";
$local->start(%args);
print "Started";
print $local->isRunning();

print "Stopping";
$local->stop();
print "Stopped";
print $local->isRunning();

