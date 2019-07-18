use Test::Most;
use FindBin;
use HTTP::Request::Common qw(GET POST);
use lib "$FindBin::Bin/lib";
use MyApp;

ok my $app = MyApp->new();
sub run_request { $app->run_test_request(@_); }
 
{
  my $get = run_request(GET 'http://localhost/hello');
  warn $get->content;
}

{
  my $get = run_request(GET 'http://localhost/node');
  warn $get->content;
}

ok 1;

done_testing;
