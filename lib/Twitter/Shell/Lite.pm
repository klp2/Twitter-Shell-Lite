# $Id: /mirror/perl/Twitter-Shell/trunk/lib/Twitter/Shell.pm 7106 2007-05-08T15:08:18.139509Z daisuke  $
#
# Copyright (c) 2007 Daisuke Maki <daiuske@endeworks.jp>
# All rights reserved.

package Twitter::Shell::Lite;
use strict;
use warnings;
use base qw(Class::Accessor::Fast);
use Carp qw(croak);
use Config::Any;
use Net::Twitter::Lite;
use Twitter::Shell::Lite::Shell;

our $VERSION = '0.01';

__PACKAGE__->mk_accessors($_) for qw(shell config twitter);

sub new
{
    my $class = shift;
    my $config = $class->load_config(shift);
    my $self  = $class->SUPER::new();
    $self->config($config);
    $self->setup();
    $self;
}

sub load_config
{
    my $self = shift;
    my $config = shift;

    if ($config && ! ref $config) {
        my $filename = $config;
        # In the future, we may support multiple configs, but for now
        # just load a single file via Config::Any
        my $list = Config::Any->load_files( { files => [ $filename ], use_ext => 1 } );
        ($config) = $list->[0]->{$filename};
    }

    if (! $config) {
        croak("Could not load config");
    }

    if (ref $config ne 'HASH') {
        croak("Twitter::Shell::Lite expectes config that can be decoded to a HASH");
    }

    return $config;
}

sub setup
{
    my $self = shift;
    $self->shell(Twitter::Shell::Lite::Shell->new);
    $self->twitter(Net::Twitter::Lite->new(
        username => $self->config->{username},
        password => $self->config->{password},
    ));

    # in some environments 'Wide Character' warnings are emited where unicode
    # strings are seen in status messages. This suppresses them.
    binmode STDOUT, ":utf8";
}

sub run
{
    my $self = shift;

    my $tag = $self->config->{tag};
    $tag ||= '[from twittershell]';
    $tag   = '' if($tag eq '.');

    my $prompt = $self->config->{prompt};
    $prompt ||= 'twitter>';
    $prompt =~ s/\s*$/ /;


    my $shell = $self->shell;
    $shell->context($self);
    $shell->prompt_str($prompt);
    $shell->tag_str($tag);
    $shell->order(defined $self->config->{order} ? $self->config->{order} : 'descending');
    $shell->limit(defined $self->config->{limit} ? $self->config->{limit} : 0);
    $shell->cmdloop();
}

sub api_update
{
    my $self = shift;
    $self->twitter->update(@_);
}

sub api_friends
{
    my $self = shift;
    $self->twitter->friends();
}

sub api_friends_timeline
{
    my $self = shift;
    $self->twitter->friends_timeline();
}

sub api_public_timeline
{
    my $self = shift;
    $self->twitter->public_timeline();
}

sub api_followers
{
    my $self = shift;
    $self->twitter->followers();
}

1;

__END__

=head1 NAME

Twitter::Shell::Lite - Twitter From Your Shell!

=head1 SYNOPSIS

   twittershell
   twitter> say Just type a message
   update ok

   twitter> friends
   [friend] A message, another message

   twitter> friends_timeline
   [friend] A message, another message

   twitter> ft
   [friend] A message, another message

   twitter> public_timeline
   [friend] A message, another message

   twitter> pt
   [friend] A message, another message

   twitter> followers
   [friend] A message, another message

=head1 DESCRIPTION

Twitter::Shell::Lite gives you access to Twitter from your shell!

Documentation coming soon...

=head1 METHODS

=head2 Constructor

+=over 4

+=item * new

+=back

+=head2 API Methods

+The API methods are used to interface to with the Twitter API.

+=over 4

+= * api_friends

+= * api_friends_timeline

+= * api_public_timeline

+= * api_followers

+= * api_update

+= back

+=head2 Process Methods

+=over 4
+
+=item * load_config
+
+Loads the configuration file. See the 'twittershell' script to see a fuller
+description of the configuration options.
+
+=item * setup
+
+Prepares the interface and internal environment.
+
+=item * run
+
+Starts the command loop shell, and awaits your command.
+
+=back
+
+=head1 SEE ALSO
+
+For further information regarding the commands and configuration, please see
+the 'twittershell' script included with this distribution.
+
+L<Net::Twitter::Lite>,
+L<Term::Shell>
+
+=head1 AUTHOR
+
+Twitter::Shell is Copyright (c) 2007 Daisuke Maki <daisuke@endeworks.jp>
+Endeworks Ltd. All rights reserved.

=head1 LICENSE

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

See http://www.perl.com/perl/misc/Artistic.html

=cut
