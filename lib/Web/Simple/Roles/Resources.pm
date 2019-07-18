package Web::Simple::Roles::Resources;

use Moo::Role;
use Module::Pluggable::Object;
use Web::Machine;

has 'resource_namespace' => (
  is=>'ro',
  required=>1,
  lazy=>1, 
  builder=>'_build_resource_namespace');

  sub _default_resource_namespace_part { 'Resource' }

  sub _build_resource_namespace {
    my $package = ref($_[0]);
    my @parts = split('::', $package);
    my $resource_namespace = join('::',
      @parts,
      $_[0]->_default_resource_namespace_part);
    return $resource_namespace;
  }

has 'extra_resource_namespaces' => (
  is=>'ro',
  predicate=>'has_extra_resource_namespaces');

has 'resource_packages' => (
  is=>'ro',
  required=>1,
  lazy=>1,
  builder=>'_build_resource_packages');
  
  sub _build_resource_packages {
    my $self = shift;
    my @search = ref($self->resource_namespace) ?
      @{$self->resource_namespace} :
        ($self->resource_namespace);

    push @search, @{$self->extra_resource_namespaces}
      if $self->has_extra_resource_namespaces;

    my %packages = ();

    foreach my $search(@search) {
      my @packages = Module::Pluggable::Object->new(
        require => 1,
        search_path => $search,
      )->plugins;
      $packages{$search} = \@packages;
    }
    return \%packages;
  }

has 'resource_by_ns' => (
  is=>'ro',
  required=>1,
  lazy=>1,
  builder=>'_build_resource_by_ns');

  sub _build_resource_by_ns {
    my $self = shift;
    my %resource_packages = %{$self->resource_packages};
    my %names = ();
    foreach my $ns (keys %resource_packages) {
      foreach my $package (@{$resource_packages{$ns}}) {
        my ($name) = ($package=~/^$ns\:\:(.+)$/);
        my $config = $self->config->{Resource}{$name} || +{};
        $names{$name} = +{
          package => $package,
          config => $config,
        };
      }
    }
    return \%names;
}

sub find_resource_package {
  my ($self, $name) = @_;
  return my $package = $self->resource_by_ns->{$name}{package}
    || $self->resource_name_not_found($name);
}

sub resource_name_not_found {
  my ($self, $name) = @_;
  die "'$name' is not a Web::Machine Resource";
}

sub build_config_for_resource {
  my ($self, $name, @args) = @_;
  my @config = (%{$self->resource_by_ns->{$name}{config}}, @args, app=>$self);
  @config = $self->modify_config(@config) if $self->can('modify_config');
  return @config;
}

sub build_web_machine {
  my ($self, $package, @config) = @_;
  return Web::Machine->new(resource => $package,  resource_args=>\@config);
}

sub resource {
  my ($self, $name, @args) = @_;
  my $package = $self->find_resource_package($name);
  my @config = $self->build_config_for_resource($name, @args);
  return $self->build_web_machine($package, @config)->to_app;
}

1; 
