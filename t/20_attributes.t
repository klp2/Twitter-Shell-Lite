#!perl

use strict;
use warnings;

use Test::More tests => 34;
use Twitter::Shell::Lite;
use Twitter::Shell::Lite::Shell;

# Twitter::Shell::Lite attributes

ok( my $obj = Twitter::Shell::Lite->new('t/config.yml'), "got object" );

foreach my $k ( qw/
	shell
	config
	twitter
/ ){
  my $label = "[$k]";
  SKIP: {
    ok( $obj->can($k), "$label can" )
	or skip "'$k' attribute missing", 3;
    isnt( $obj->$k(), undef, "$label has default" );
    is( $obj->$k(123), 123, "$label set" );
    is( $obj->$k, 123, "$label get" );
  };
}


# Twitter::Shell::Lite::Shell attributes

ok( $obj = Twitter::Shell::Lite::Shell->new(), "got object" );

foreach my $k ( qw/
	context
	prompt_str
	tag_str
	order
	limit
/ ){
  my $label = "[$k]";
  SKIP: {
    ok( $obj->can($k), "$label can" )
	or skip "'$k' attribute missing", 3;
    is( $obj->$k(), undef, "$label has no default" );
    is( $obj->$k(123), undef, "$label set" );
    is( $obj->$k, 123, "$label get" );
  };
}
