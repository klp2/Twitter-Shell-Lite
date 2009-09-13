#!perl

use strict;
use warnings;

use Test::More tests => 73;
use Twitter::Shell::Lite::Shell;

# Twitter::Shell::Lite::Shell help handlers

ok( my $obj = Twitter::Shell::Lite::Shell->new(), "got object" );

foreach my $k ( qw/
    exit
    followers
    friends
    friends_timeline
    ft
    help
    pt
    public_timeline
    say
    update
    quit
    q
/ ){
  for my $m (qw(smry help)) {
    my $j = "${m}_$k";
    my $label = "[$j]";
    SKIP: {
      ok( $obj->can($j), "$label can" ) or skip "'$j' method missing", 2;
      isnt( $obj->$j(), undef, "$label returns something" );
      like( $obj->$j, qr/\w/, "$label returns some text" );
    }
  };
}
