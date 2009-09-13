use strict;
use inc::Module::Install;

name("Twitter-Shell-Lite");
all_from('lib/Twitter/Shell/Lite.pm');
requires("Class::Accessor::Fast");
requires("Config::Any");
requires("Net::Twitter::Lite");
requires("Term::Shell");

install_script('script/twittershell');

&auto_install;
&WriteAll;
