package Rex::Bootloader::Syslinux;

use Rex -base;
use Rex::Template::TT;

use Term::ANSIColor;

desc 'Setup networking';

task 'install_bootloader', sub {
  my $boot_disk = param_lookup "boot_disk";
  my $syslinux_package = param_lookup "package";
  my $modules = param_lookup "modules", [ 'menu.c32', 'memdisk', 'libcom32.c32', 'libutil.c32' ];

  if ((! $boot_disk) || (! $syslinux_package)) {
    die("Required parameters $boot_disk or $syslinux_package are missing.");
  }

  pkg $syslinux_package, ensure => 'present';
  run "dd bs=440 conv=notrunc count=1 if=/usr/share/syslinux/gptmbr.bin of=$boot_disk";
  file "/boot/extlinux", ensure => "directory";
  run "extlinux --install /boot/extlinux";
  run "ln -snf . /boot/boot";

  foreach my $mod (@$modules) {
    cp "/usr/share/syslinux/$mod", "/boot/extlinux";
  }

};

task 'setup', sub {
  my $config = param_lookup "config";
  # TODO make sure /boot partition is mounted
  file "/boot/extlinux/extlinux.conf",
    content => template("templates/extlinux.conf.tt", config => $config);
};


1;

=pod

=head1 NAME

$::module_name - {{ SHORT DESCRIPTION }}

=head1 DESCRIPTION

{{ LONG DESCRIPTION }}

=head1 USAGE

{{ USAGE DESCRIPTION }}

 include qw/Rex::Gentoo::Install/;

 task yourtask => sub {
    Rex::Gentoo::Install::example();
 };

=head1 TASKS

=over 4

=item example

This is an example Task. This task just output's the uptime of the system.

=back

=cut
