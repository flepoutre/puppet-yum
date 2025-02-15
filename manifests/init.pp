# Class: yum
#
# Manage Yum configuration.
#
# Parameters:
#   [*keepcache*]         - Yum option keepcache
#   [*debuglevel*]        - Yum option debuglevel
#   [*exactarch*]         - Yum option exactarch
#   [*obsoletes*]         - Yum option obsoletes
#   [*gpgcheck*]          - Yum option gpgcheck
#   [*installonly_limit*] - Yum option installonly_limit
#   [*keep_kernel_devel*] - On old kernels purge keep devel packages.
#
# Actions:
#
# Requires:
#   RPM based system
#
# Sample usage:
#   class { 'yum':
#     installonly_limit => 2,
#   }
#
class yum (
  Boolean $keepcache         = $yum::params::keepcache,
  Integer $debuglevel        = $yum::params::debuglevel,
  Boolean $exactarch         = $yum::params::exactarch,
  Boolean $obsoletes         = $yum::params::obsoletes,
  Boolean $gpgcheck          = $yum::params::gpgcheck,
  Integer $installonly_limit = $yum::params::installonly_limit,
  Boolean $keep_kernel_devel = $yum::params::keep_kernel_devel,
) inherits yum::params {
  # configure Yum
  yum::config { 'keepcache':
    ensure => bool2num($keepcache),
  }

  yum::config { 'debuglevel':
    ensure => $debuglevel,
  }

  yum::config { 'exactarch':
    ensure => bool2num($exactarch),
  }

  yum::config { 'obsoletes':
    ensure => bool2num($obsoletes),
  }

  yum::config { 'gpgcheck':
    ensure => bool2num($gpgcheck),
  }

  yum::config { 'installonly_limit':
    ensure => $installonly_limit,
    notify => Exec['package-cleanup_oldkernels'],
  }

  # cleanup old kernels
  ensure_packages(['yum-utils'])

  $_pc_cmd = delete_undef_values([
      '/usr/bin/package-cleanup',
      '--oldkernels',
      "--count=${installonly_limit}",
      '-y',
      $keep_kernel_devel ? {
        true    => '--keepdevel',
        default => undef,
      },
  ])

  exec { 'package-cleanup_oldkernels':
    command     => shellquote($_pc_cmd),
    refreshonly => true,
    require     => Package['yum-utils'],
  }
}
