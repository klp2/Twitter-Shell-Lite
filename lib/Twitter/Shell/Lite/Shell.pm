# $Id: /mirror/perl/Twitter-Shell/trunk/lib/Twitter/Shell/Shell.pm 7104 2007-05-08T15:04:37.108325Z daisuke  $
#
# Copyright (c) 2007 Daisuke Maki <daisuke@endeworks.jp>
# All rights reserved.

package Twitter::Shell::Lite::Shell;
use strict;
use warnings;
use base qw(Term::Shell);

sub context    { shift->_elem('context', @_) }
sub prompt_str { shift->_elem('prompt_str', @_) }
sub tag_str    { shift->_elem('tag_str',    @_) }
sub order      { shift->_elem('order',      @_) }
sub limit      { shift->_elem('limit',      @_) }

sub _elem
{
    my $self = shift;
    my $name = shift;
    my $value = $self->{$name};
    if (@_) {
        $self->{$name} = shift;
    }
    return $value;
}

sub _twitter_cmd
{
    my $self = shift;
    my $cmd  = shift;
    my $c    = $self->context;
    my $method = "api_$cmd";
    my $ret    = $c->$method(@_);

    if ($ret) {
        print "$cmd ok\n\n";
    } else {
        print "Command $cmd failed :(\n\n";
    }
    return $ret;
}

sub run_update
{
    my $self = shift;
    my $text = "@_";
    $text =~ s/^\s+//;
    $text =~ s/\s+$//;
    if ($text) {
        my $len = length $text;
        if($len < 140) {
            my $tag = $self->tag_str;
            $text .= " " if ($text =~ /\W/);
            $text .= $tag   if(length "$text$tag" <= 140);
        } elsif($len > 140) {
            print "message too long: $len/140\n\n";
            return;
        }
    }
    $self->_twitter_cmd('update', $text);
}
sub smry_update { "post a message" }
sub help_update {
    <<'END';
Posts a message (upto 140 characters).
END
}

# help
*run_say = \&run_update;
sub smry_say { "alias to 'update'" }
*help_say = \&help_update;

sub run_friends
{
    my $self = shift;
    my $ret  = $self->_twitter_cmd('friends');

    if ($ret) {
        foreach my $friend (@$ret) {
            printf( "[%s] %s\n", $friend->{screen_name}, $friend->{status}{text});
        }
    }
}
sub smry_friends { "display friends' status" }
sub help_friends {
    <<'END';
Displays the most recent status messages from each of your friends.
END
}

sub run_friends_timeline
{
    my $self = shift;
    my $ret  = $self->_twitter_cmd('friends_timeline');

    if ($ret) {
        my $limit = defined @_ ? shift : $self->limit;
        $self->_print_timeline($limit,$ret);
    }
}

sub smry_friends_timeline { "display friends' status as a timeline" }
sub help_friends_timeline {
    <<'END';
Displays the most recent status messages within your friends timeline.
END
}

*run_ft = \&run_friends_timeline;
sub smry_ft { "alias to friends_timeline" }
*help_ft = \&help_friends_timeline;

sub run_public_timeline
{
    my $self = shift;
    my $ret  = $self->_twitter_cmd('public_timeline');

    if ($ret) {
        my $limit = defined @_ ? shift : $self->limit;
        $self->_print_timeline($limit,$ret);
    }
}

sub smry_public_timeline { "display public status as a timeline" }
sub help_public_timeline {
    <<'END';
Displays the most recent status messages within the public timeline.
END
}

*run_pt = \&run_public_timeline;
sub smry_pt { "alias to public_timeline" }
*help_pt = \&help_public_timeline;

sub run_followers
{
    my $self = shift;
    my $ret  = $self->_twitter_cmd('followers');

    if ($ret) {
        foreach my $rec (@$ret) {
            printf( "[%s] %s\n", $rec->{screen_name}, $rec->{status}{text});
        }
    }
}
sub smry_followers { "display followers' status" }
sub help_followers {
    <<'END';
Displays the most recent status messages from each of your followers.
END
}
 
sub _print_timeline {
    my ($self,$limit,$ret) = @_;
    my @recs = $self->order =~ /^asc/i ? reverse @$ret : @$ret;
    splice(@recs,0,$limit)  if($limit);
    printf( "[%s] %s\n", $_->{user}{screen_name}, $_->{text})   for(@recs);
}

sub smry_quit { "alias to exit" }
sub help_quit {
    <<'END';
Exits the program.
END
}
sub run_quit {
    my $self = shift;
    $self->stoploop;
}

*run_q = \&run_quit;
*smry_q = \&smry_quit;
*help_q = \&help_quit;


1;

__END__

=head1 NAME

Twitter::Shell::Shell - Provides shell for Twitter::Shell

=head1 METHODS


=head2 Constructor

=over 4

=item * new

=back

=head2 Configuration Methods

=over 4

=item * context

Used internally to reference the current shell for command handlers.

=item * limit

Used by timeline commands to limit the number of messages displayed. The
default setting will display the last 20 messages.

=item * order

Used by timeline commands to order the messages displayed. The default is to
display messages in descending order, with the most recent first and the oldest
last.
 
To reverse this order, set the 'order' as 'ascending' (or 'asc') in your
configuration file. (case insensitive).
 
=item * prompt_str
 
Sets the prompt that will appear on the command line.
 
=item * tag_str
 
Sets the text that will appear at the end of your message.
 
In order to suppress the tag string set the 'tag' option to '.' in your
configuration file.
 
=back
 
=head2 Run Methods
 
The run methods are handlers to run the specific command requested.
 
=head2 Help Methods
 
The help methods are handlers to provide additional information about the named
command when the 'help' command is used, with the name of a command as an
argument.
 
=head2 Summary Methods
 
When the 'help' command is requested, with no additonal arguments, a summary
of the available commands is display, with the text from each specific command
summary method handler.
 
=head2 Followers Methods
 
The followers methods provide the handlers for the 'followers' command.
 
=over 4
 
=item * run_followers

=item * help_followers

=item * smry_followers

=back

=head2 Friends Methods

The friends methods provide the handlers for the 'friends' command.

=over 4

=item * run_friends

=item * help_friends

=item * smry_friends

=back

=head2 Friends Timeline Methods

The friends timeline methods provide the handlers for the 'friends_timeline'
command. Note that the 'ft' is an alias to 'friends_timeline'.

=over 4

=item * run_friends_timeline

=item * help_friends_timeline

=item * smry_friends_timeline

=item * run_ft

=item * help_ft

=item * smry_ft

=back

=head2 Public Timeline Methods

The public timeline methods provide the handlers for the 'public_timeline'
command. Note that the 'pt' is an alias to 'public_timeline'.

=over 4

=item * run_public_timeline

=item * help_public_timeline

=item * smry_public_timeline

=item * run_pt

=item * help_pt

=item * smry_pt

=back

=head2 Update Methods

The update methods provide the handlers for the 'update' command. Note that
'say' is an alias for 'update'.

=over 4

=item * run_update

=item * help_update

=item * smry_update

=item * run_say

=item * help_say

=item * smry_say

=back

=head2 Quit Methods

The quit methods provide the handlers for the 'quit' command. Note that both
'quit' and 'q' are aliases to 'exit'

=over 4

=item * run_quit

=item * help_quit

=item * smry_quit

=item * run_q

=item * help_q

=item * smry_q

=back

=head1 AUTHOR

Twitter::Shell::Shell is Copyright (c) 2007 Daisuke Maki <daisuke@endeworks.jp>
Endeworks Ltd. All rights reserved.

=head1 LICENSE

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

See http://www.perl.com/perl/misc/Artistic.html

