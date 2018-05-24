platform "aix-6.1-ppc" do |plat|
  plat.servicetype "aix"

  plat.make "gmake"
  plat.tar "/opt/freeware/bin/tar"
  plat.rpmbuild "/usr/bin/rpm"
  plat.patch "/opt/freeware/bin/patch"

  # Basic vanagon operations require mktemp, rsync, coreutils, make, tar and sed so leave this in there
  plat.provision_with "rpm -Uvh --replacepkgs http://osmirror.delivery.puppetlabs.net/AIX_MIRROR/mktemp-1.7-1.aix5.1.ppc.rpm http://osmirror.delivery.puppetlabs.net/AIX_MIRROR/rsync-3.0.6-1.aix5.3.ppc.rpm http://osmirror.delivery.puppetlabs.net/AIX_MIRROR/coreutils-5.2.1-2.aix5.1.ppc.rpm http://osmirror.delivery.puppetlabs.net/AIX_MIRROR/sed-4.1.1-1.aix5.1.ppc.rpm http://osmirror.delivery.puppetlabs.net/AIX_MIRROR/make-3.80-1.aix5.1.ppc.rpm http://osmirror.delivery.puppetlabs.net/AIX_MIRROR/tar-1.22-1.aix6.1.ppc.rpm"

  # We can't rely on yum, and rpm can't download over https on AIX, so curl packages before installing them
  # Order matters here - there is no automatic dependency resolution
  packages = {
    "m4-1.4.17-1.aix6.1.ppc.rpm"          => "https://artifactory.delivery.puppetlabs.net/artifactory/rpm__remote_aix_linux_toolbox/ppc/m4/m4-1.4.17-1.aix6.1.ppc.rpm",
    "zlib-1.2.8-1.aix6.1.ppc.rpm"         => "https://artifactory.delivery.puppetlabs.net/artifactory/rpm__remote_aix_linux_toolbox/ppc/zlib/zlib-1.2.8-1.aix6.1.ppc.rpm",
    "zlib-devel-1.2.8-1.aix6.1.ppc.rpm"   => "https://artifactory.delivery.puppetlabs.net/artifactory/rpm__remote_aix_linux_toolbox/ppc/zlib/zlib-devel-1.2.8-1.aix6.1.ppc.rpm",
    "bzip2-1.0.6-2.aix6.1.ppc.rpm"        => "https://artifactory.delivery.puppetlabs.net/artifactory/rpm__remote_aix_linux_toolbox/ppc/bzip2/bzip2-1.0.6-2.aix6.1.ppc.rpm",
    "libstdcplusplus-6.3.0-1.aix6.1.ppc.rpm" => "https://artifactory.delivery.puppetlabs.net/artifactory/rpm__remote_aix_linux_toolbox/ppc-6.1/gcc/libstdcplusplus-6.3.0-1.aix6.1.ppc.rpm", # for gmp; change version?
    "gmp-6.1.2-1.aix6.1.ppc.rpm"          => "https://artifactory.delivery.puppetlabs.net/artifactory/rpm__remote_aix_linux_toolbox/ppc/gmp/gmp-6.1.2-1.aix6.1.ppc.rpm", # change version?
    "mpfr-3.1.2-3.aix6.1.ppc.rpm"         => "https://artifactory.delivery.puppetlabs.net/artifactory/rpm__remote_aix_linux_toolbox/ppc/mpfr/mpfr-3.1.2-3.aix6.1.ppc.rpm",
    "libmpc-1.0.3-1.aix6.1.ppc.rpm"       => "https://artifactory.delivery.puppetlabs.net/artifactory/rpm__remote_aix_linux_toolbox/ppc/libmpc/libmpc-1.0.3-1.aix6.1.ppc.rpm", # requires mpfr
    "gettext-0.19.8.1-1.aix6.1.ppc.rpm"   => "https://artifactory.delivery.puppetlabs.net/artifactory/rpm__remote_aix_linux_toolbox/ppc/gettext/gettext-0.19.8.1-1.aix6.1.ppc.rpm",
    "ncurses-6.1-1.aix6.1.ppc.rpm"        => "https://artifactory.delivery.puppetlabs.net/artifactory/rpm__remote_aix_linux_toolbox/ppc/ncurses/ncurses-6.1-1.aix6.1.ppc.rpm",
    "info-6.3-1.aix6.1.ppc.rpm"           => "https://artifactory.delivery.puppetlabs.net/artifactory/rpm__remote_aix_linux_toolbox/ppc/texinfo/info-6.3-1.aix6.1.ppc.rpm", # requires gettext (libintl, specifically) and ncurses
    "libgcc-6.3.0-1.aix6.1.ppc.rpm"       => "https://artifactory.delivery.puppetlabs.net/artifactory/rpm__remote_aix_linux_toolbox/ppc-6.1/gcc/libgcc-6.3.0-1.aix6.1.ppc.rpm", # requires info
    "gcc-6.3.0-1.aix6.1.ppc.rpm"          => "https://artifactory.delivery.puppetlabs.net/artifactory/rpm__remote_aix_linux_toolbox/ppc-6.1/gcc/gcc-6.3.0-1.aix6.1.ppc.rpm",
    "libstdcplusplus-devel-6.3.0-1.aix6.1.ppc.rpm" => "https://artifactory.delivery.puppetlabs.net/artifactory/rpm__remote_aix_linux_toolbox/ppc-6.1/gcc/libstdcplusplus-devel-6.3.0-1.aix6.1.ppc.rpm",
    "gcc-cpp-6.3.0-1.aix6.1.ppc.rpm"      => "https://artifactory.delivery.puppetlabs.net/artifactory/rpm__remote_aix_linux_toolbox/ppc-6.1/gcc/gcc-cpp-6.3.0-1.aix6.1.ppc.rpm", # requires libstdc++
    "gcc-cplusplus-6.3.0-1.aix6.1.ppc.rpm" => "https://artifactory.delivery.puppetlabs.net/artifactory/rpm__remote_aix_linux_toolbox/ppc-6.1/gcc/gcc-cplusplus-6.3.0-1.aix6.1.ppc.rpm", # I guess we need both gcc-cpp and gcc-cplusplus
  }

  packages.each do |name, uri|
    plat.provision_with("curl -O #{uri}")
    plat.provision_with("rpm -Uvh --replacepkgs --nodeps #{name}") 
  end

  # We use --force with rpm because the pl-gettext and pl-autoconf
  # packages conflict with a charset.alias file.
  #
  # Until we get those packages to not conflict (or we remove the need
  # for pl-autoconf) we'll need to force the installation
  #                                         Sean P. McD.
  plat.install_build_dependencies_with "rpm -Uvh --replacepkgs --force "
  plat.vmpooler_template "aix-6.1-power"
end
