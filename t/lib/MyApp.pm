package MyApp;

use Web::Simple;

with 'Web::Simple::Roles::Nodes';
with 'Web::Simple::Roles::Resources';

sub default_config {
  Node => { a => 1 },
  Resource => {
    Hello => {
      name => 'John',
    }
  }
}

sub dispatch_request {
  my $self = shift;
  '/node' => sub { $self->node('Node', b=>2) },
  '/hello' => sub { $self->resource('Hello', age=>10) },
}
 
__PACKAGE__->run_if_script;
