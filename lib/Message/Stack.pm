package Message::Stack;
use Moose;

use Carp qw(croak);
use MooseX::Storage;
use MooseX::Types::Moose qw(HashRef);
use Message::Stack::Message;
use Message::Stack::Types qw(MessageStackMessage);

our $VERSION = '0.15';

with 'MooseX::Storage::Deferred';

has messages => (
    traits => [ 'Array' ],
    is => 'rw',
    isa => 'ArrayRef[Message::Stack::Message]',
    default => sub { [] },
    handles => {
        reset           => 'clear',
        count           => 'count',
        has_messages    => 'count',
        first           => [ get => 0 ],
        first_message   => [ get => 0 ],
        _grep_messages  => 'grep',
        get_message     => 'get',
        last            => [ get => -1 ],
        last_message    => [ get => -1 ],
    }
);

sub add {
    my ($self, $message) = @_;

    return unless defined($message);

    if(is_MessageStackMessage($message)) {
        push(@{ $self->messages }, $message);
    } elsif(is_HashRef($message)) {
        my $mess = Message::Stack::Message->new($message);
        push(@{ $self->messages }, $mess);
    } else {
        croak('Message must be either a Message::Stack::Message or hashref');
    }
}

sub for_id {
    my ($self, $id) = @_;

    return $self->search(sub { $_->id eq $id if $_->has_id });
}

sub for_level {
    my ($self, $level) = @_;

    return $self->search(sub { $_->level eq $level if $_->has_level });
}

sub for_scope {
    my ($self, $scope) = @_;

    return $self->search(sub { $_->scope eq $scope if $_->has_scope });
}

sub for_subject {
    my ($self, $subject) = @_;

    return $self->search(sub { $_->subject eq $subject if $_->has_subject });
}

sub has_id {
    my ($self, $id) = @_;

    return 0 unless $self->has_messages;

    return $self->for_id($id)->count ? 1 : 0;
}

sub has_level {
    my ($self, $level) = @_;

    return 0 unless $self->has_messages;

    return $self->for_level($level)->count ? 1 : 0;
}

sub has_scope {
    my ($self, $scope) = @_;

    return 0 unless $self->has_messages;

    return $self->for_scope($scope)->count ? 1 : 0;
}

sub has_subject {
    my ($self, $subject) = @_;

    return 0 unless $self->has_messages;

    return $self->for_subject($subject)->count ? 1 : 0;
}

sub search {
    my ($self, $coderef) = @_;

    my @messages = $self->_grep_messages($coderef);
    return Message::Stack->new(messages => \@messages);
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

__END__

=head1 NAME

Message::Stack - Deal with a "stack" of messages

=head1 SYNOPSIS

  my $stack = Message::Stack->new;

  $stack->add(Message::Stack::Message->new(
      id        => 'something_happened',
      level     => 'error',
      scope     => 'login_form',
      subject   => 'username',
      text      => 'Something happened!'
  ));
  # Or... for those that want to type less
  $stack->add({
      id        => 'something_else_happened',
      level     => 'error',
      scope     => 'login_form',
      subject   => 'password',
      text      => 'Something else happened!'
  });
  
  ...
  my $errors = $stack->for_level($error);
  # Or
  my $login_form_errors = $stack->for_scope('login_form');
  $login_form_errors->for_id('username');
  print "Username has ".$login_form_errors->count." errors.\n";

=head1 DESCRIPTION

Message::Stack provides a mechanism for storing messages until they can be
consumed.  A stack is used to retain order of occurrence.  Each message may
have a id, level, scope, subject and text.  Consult the documentation for
L<Message::Stack::Message> for an explanation of these attributes.

This is not a logging mechanism.  The original use was to store various errors
or messages that occur during processing for later display in a web
application.  The messages are added via C<add>.

=head1 SERIALIZATION

This module uses L<MooseX::Storage::Deferred> to facilitate easy serialization.
Consult the documentation for L<MooseX::Storage::Deferred> options, but the
gist is:

  my $json = $stack->freeze({ format => 'JSON' });
  ...
  my $stack = Message::Stack->thaw($json, { format => 'JSON' });

=head1 METHODS

=head2 add ($message)

Adds the supplied message to the stack.  C<$message> may be either a
L<Message::Stack::Message> object or a hashref with similar keys.

=head2 count

Returns the number of messages in the stack.

=head2 messages

Returns the full arrayref of messages for this stack.

=head2 first_message

Returns the first message (if there is one, else undef)

=head2 search (CODEREF)

Returns a Message::Stack containing messages that return true when passed
to the coderef argument.

  $stack->search( sub { $_[0]->id eq 'someid' } )

=head2 get_message ($index)

Get the message at the supplied index.

=head2 for_id ($id)

Returns a new Message::Stack containing only the message objects with the
supplied id. If there are no messages for that level then the stack
returned will have no messages.

=head2 for_level ($level)

Returns a new Message::Stack containing only the message objects with the
supplied level. If there are no messages for that level then the stack
returned will have no messages.

=head2 for_scope ($scope)

Returns a new Message::Stack containing only the message objects with the
supplied scope. If there are no messages for that scope then the stack
returned will have no messages.

=head2 for_subject ($subject)

Returns a new Message::Stack containing only the message objects with the
supplied subject. If there are no messages for that subject then the stack
returned will have no messages.

=head2 has_messages

Returns true if there are messages in the stack, else false

=head2 has_id ($id)

Returns true if there are messages with the supplied id.

=head2 has_level ($level)

Returns true if there are messages with the supplied level.

=head2 has_scope ($scope)

Returns true if there are messages with the supplied scope.

=head2 has_subject ($subject)

Returns true if there are messages with the supplied subject.

=head2 last_message

Returns the last message (if there is one, else undef)

=head1 AUTHOR

Cory G Watson, C<< <gphat at cpan.org> >>

=head1 CONTRIBUTORS

Jay Shirley

Stevan Little

Justin Hunter

Jon Wright

Mike Eldridge

=head1 COPYRIGHT & LICENSE

Copyright 2010 Cory G Watson, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.
