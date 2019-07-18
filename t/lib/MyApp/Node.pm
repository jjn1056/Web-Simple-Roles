package MyApp::Node;

use Web::Simple;

has ['a','b'] => (is=>'ro', required=>1);

sub dispatch_request {
  my $self = shift;  
  '' => sub {
    return [200, ['Content-Type' => 'text/plain'], ['hello']];
  };
}
 
1;
