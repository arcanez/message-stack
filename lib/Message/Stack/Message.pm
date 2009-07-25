package Message::Stack::Message;
use Moose;

has id => (
    is => 'rw',
    isa => 'Maybe[Str]'
);

has level => (
    is => 'rw',
    isa => 'Maybe[Str]'
);

has scope => (
    is => 'rw',
    isa => 'Maybe[Str]'
);

has subject => (
    is => 'rw',
    isa => 'Maybe[Str]'
);

has text => (
    is => 'rw',
    isa => 'Maybe[Str]'
);

__PACKAGE__->meta->make_immutable;

no Moose;
1;

__END__

=head1 NAME

Message::Stack::Message - A Message

=head1 SYNOPSIS

  my $stack = Message::Stack->new;

  $stack->add_to_messages(
    Message::Stack::Message->new(
        id => 'I18NName',
        level => 'error',
        scope => 'loginform'
        subject => 'username',
        text => 'You forgot a password'
    )
  );

=head1 DESCRIPTION

The Message object formalizes the messages that are added to the stack.

=head1 AUTHOR

Cory G Watson, C<< <gphat at cpan.org> >>

=head1 COPYRIGHT & LICENSE

Copyright 2009 Cory G Watson, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.
