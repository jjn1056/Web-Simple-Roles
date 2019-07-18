package MyApp::Resource::Hello;

use Moo;
extends 'Web::Machine::Resource';

has 'age' => (is=>'ro', required=>1);
has 'name' => (is=>'ro', required=>1);
has 'app' => (is=>'ro', required=>1);

sub content_types_provided { [{ 'text/html' => 'to_html' }] }

sub to_html {
  my $self = shift;
    qq{<html>
        <head>
            <title>Hello World Resource</title>
        </head>
        <body>
            <h1>Hello World ${\$self->name}! you are ${\$self->age}</h1>
        </body>
     </html>}
}

1;

