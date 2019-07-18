package Web::Simple::Roles::Nodes;

use Moo::Role;
use Module::Pluggable::Object;
use Module::Runtime 'use_module';

has 'nodes' =>  (
  is=>'ro',
  lazy=>1,
  required=>1,
  builder=>'_build_nodes');

sub _build_nodes {
  my $self = shift;
  my $class = ref $self;
  my $depth = scalar(split '::', $class);
  my @packages = Module::Pluggable::Object->new(
    require => 1,
    max_depth => $depth + 1,
    search_path => [$class],
  )->plugins;

  my %nodes = map {
    my $package = $_;
    my ($name) = ($package=~/^$class\:\:(.+)$/);
    my $config = $self->config->{$name} || +{};
    $name => {
      package => $package,
      config => $config,
    };
  } @packages;

  return \%nodes;
}

sub find_node_package {
  my ($self, $name) = @_;
  return my $package = $self->nodes->{$name}{package}
    || $self->node_name_not_found($name);
}

sub node_name_not_found {
  my ($self, $name) = @_;
  die "'$name' is not a Web::Machine Resource";
}

sub build_config_for_node {
  my ($self, $name, @args) = @_;
  my @config = (%{$self->nodes->{$name}{config}}, @args, parent=>$self);
  @config = $self->modify_config(@config) if $self->can('modify_config');
  return @config;
}

sub node {
  my ($self, $name, @args) = @_;
  my $package = $self->find_node_package($name);
  my @config = $self->build_config_for_node($name, @args);
  return $package->new(@config)->to_psgi_app;
}

1;
