#!/usr/bin/perlT
push (@INC,'pwd');
use BrowserStack::Local;

my %args = (
        "v" => 1
        );

$driver = BrowserStack::Local::new;
print $driver->isRunning();
$driver->start(%args);
print $driver->isRunning();
$driver->stop();
print $driver->isRunning();


