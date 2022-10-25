package PBuildStatus::Controller::Status;
use Mojo::Base 'Mojolicious::Controller', -signatures;
use Mojo::File qw/path/;

use PBuild::Result;
use PBuild::Preset;
use Data::Dump qw/pp/;

my @code_order = qw{building broken failed unresolvable blocked scheduled waiting succeeded excluded disabled locked };
my %code_failures = map {$_ => 1} qw{broken failed unresolvable};

# This action will render a template
sub status ($self) {

  my $preset = PBuild::Preset::read_presets(path);
  die unless $preset;

  my $hostarch = (POSIX::uname())[4];
  die("cannot determine hostarch\n") unless $hostarch;

  my $builddir = '_build.'.$preset->{'name'}.'.'.($preset->{'arch'} || $hostarch);

  my $r = PBuild::Util::retrieve("$builddir/.pbuild/_result", 1);

  my $result;
  my %code_pkgs;
  for my $pkg (sort keys %$r) {
	  my $code = $r->{$pkg}->{'code'} || 'unknown';
	  push @{$code_pkgs{$code}}, $pkg;
  }

  my @codes_seen;
  for (@code_order) {
    push @codes_seen, $_ if $code_pkgs{$_};
  }

  @codes_seen = PBuild::Util::unify(@codes_seen, sort keys %code_pkgs);
#  for my $code (@codes_seen) {
#    my $ncode = @{$code_pkgs{$code}};
#    $result .= sprintf "%-10s %d\n", "$code:", $ncode;
#
#    for my $pkg (@{$code_pkgs{$code}}) {
#      $result .= "    $pkg";
#      $result .= ' - '.$r->{$pkg}->{'details'} if $r->{$pkg}->{'details'};
#      $result .= "\n";
#    }
#  }
  # Render template "example/welcome.html.ep" with message
  $self->render(msg => 'pbuild status', result => $r, codes_seen => \@codes_seen, code_pkgs => \%code_pkgs);
}

1;
