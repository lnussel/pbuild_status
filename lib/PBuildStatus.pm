package PBuildStatus;
use Mojo::Base 'Mojolicious', -signatures;
use Mojo::File qw/path/;

# This method will run once at server start
sub startup ($self) {

  # Load configuration from config file
  my $config = $self->plugin('NotYAMLConfig', file => path->sibling("pbuild_status.yml"));

  # Configure the application
  $self->secrets($config->{secrets});

  # Router
  my $r = $self->routes;

  # Normal route to controller
  $r->get('/')->to('Status#status');
}

1;
