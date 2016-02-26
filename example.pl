#!/usr/bin/perlT
push (@INC,'pwd');
use BrowserStack::Local;

my %args = (
        "v" => 1
        );

$driver = BrowserStack::Local::new;
print $driver->isRunning();
print "Starting";
$driver->start(%args);
print "Started";
print $driver->isRunning();
sleep(5);
print "Stopping";
$driver->stop();
print "Stopped";
print $driver->isRunning();


