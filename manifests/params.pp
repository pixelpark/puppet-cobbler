# @summary Defines default values for variables inside whole cobbler class
#
# @author Anton Baranov <email:abaranov@linuxfoundation.org>
class cobbler::params {
  $ensure                 = 'present'
  $package                = [
    'cobbler',
    'syslinux',
    'syslinux-tftpboot',
  ]
  $package_ensure         = 'installed'
  $service                = 'cobblerd'
  $service_ensure         = 'running'
  $service_enable         = true
  $config_path            = '/etc/cobbler'
  $config_file            = 'settings'
  $config_modules         = 'modules.conf'
  # Default config you have just after cobbler is installed
  # Just load yaml as cobbler use yaml format for $config_file
  $default_cobbler_config = {
    'allow_duplicate_hostnames'             => 0,
    'allow_duplicate_ips'                   => 0,
    'allow_duplicate_macs'                  => 0,
    'allow_dynamic_settings'                => 0,
    'anamon_enabled'                        => 0,
    'authn_pam_service'                     => 'login',
    'auth_token_expiration'                 => 3600,
    'build_reporting_enabled'               => 0,
    'build_reporting_sender'                => '',
    'build_reporting_email'                 => ['root@localhost'],
    'build_reporting_smtp_server'           => 'localhost',
    'build_reporting_subject'               => '',
    'build_reporting_ignorelist'            => [],
    'cheetah_import_whitelist'              => ['random', 're', 'time'],
    'createrepo_flags'                      => '-c cache -s sha',
    # lint:ignore:80chars
    'default_kickstart'                     => '/var/lib/cobbler/kickstarts/default.ks',
    # lint:endignore
    'default_name_servers'                  => [],
    'default_ownership'                     => ['admin'],
    # lint:ignore:80chars
    'default_password_crypted'              => '$1$mF86/UHC$WvcIcX2t6crBz2onWxyac.',
    # lint:endignore
    'default_template_type'                 => 'cheetah',
    'default_virt_bridge'                   => 'xenbr0',
    'default_virt_file_size'                => 5,
    'default_virt_ram'                      => 512,
    'default_virt_type'                     => 'xenpv',
    'enable_gpxe'                           => 0,
    'enable_menu'                           => 1,
    'func_auto_setup'                       => 0,
    'func_master'                           => 'overlord.example.org',
    'http_port'                             => 80,
    'kernel_options'                        => {
      'ksdevice' => 'bootif',
      'lang'     => '',
      'text'     => '',
    },
    'kernel_options_s390x'                  => {
      'RUNKS'        => 1,
      'ramdisk_size' => 40000,
      'root'         => '/dev/ram0',
      'ro'           => '' ,
      'ip'           => false,
      'vnc'          => '',
    },
    'ldap_server'                           => 'ldap.example.com',
    'ldap_base_dn'                          => 'DC=example,DC=com',
    'ldap_port'                             => 389,
    'ldap_tls'                              => 1,
    'ldap_anonymous_bind'                   => 1,
    'ldap_search_bind_dn'                   => '',
    'ldap_search_passwd'                    => '',
    'ldap_search_prefix'                    => 'uid=',
    'ldap_tls_cacertfile'                   => '',
    'ldap_tls_keyfile'                      => '',
    'ldap_tls_certfile'                     => '',
    'mgmt_classes'                          => [],
    'mgmt_parameters'                       => {
      'from_cobbler' => 1,
    },
    'puppet_auto_setup'                     => 0,
    'sign_puppet_certs_automatically'       => 0,
    'puppetca_path'                         => '/usr/bin/puppet',
    'remove_old_puppet_certs_automatically' => 0,
    'manage_dhcp'                           => 0,
    'manage_dns'                            => 0,
    'bind_chroot_path'                      => '',
    'bind_master'                           => '127.0.0.1',
    'manage_tftpd'                          => 1,
    'manage_rsync'                          => 0,
    'manage_forward_zones'                  => [],
    'manage_reverse_zones'                  => [],
    'next_server'                           => '127.0.0.1',
    'power_management_default_type'         => 'ipmitool',
    'power_template_dir'                    => '/etc/cobbler/power',
    'pxe_just_once'                         => 1,
    'pxe_template_dir'                      => '/etc/cobbler/pxe',
    'consoles'                              => '/var/consoles',
    'redhat_management_type'                => 'off',
    'redhat_management_server'              => 'xmlrpc.rhn.redhat.com',
    'redhat_management_key'                 => '',
    'redhat_management_permissive'          => 0,
    'register_new_installs'                 => 0,
    'reposync_flags'                        => '-l -n -d',
    'restart_dns'                           => 1,
    'restart_dhcp'                          => 1,
    'run_install_triggers'                  => 1,
    'scm_track_enabled'                     => 0,
    'scm_track_mode'                        => 'git',
    'server'                                => '127.0.0.1',
    'client_use_localhost'                  => 0,
    'client_use_https'                      => 0,
    'snippetsdir'                           => '/var/lib/cobbler/snippets',
    'template_remote_kickstarts'            => 0,
    'virt_auto_boot'                        => 1,
    'webdir'                                => '/var/www/cobbler',
    'xmlrpc_port'                           => 25151,
    'yum_post_install_mirror'               => 1,
    'yum_distro_priority'                   => 1,
    'yumdownloader_flags'                   => '--resolve',
    'serializer_pretty_json'                => 0,
    'replicate_rsync_options'               => '-avzH',
    'replicate_repo_rsync_options'          => '-avzH',
    'always_write_dhcp_entries'             => 0,
    'proxy_url_ext'                         => '',
    'proxy_url_int'                         => '',
  }
  # Default configuration for cobbler modules
  $default_modules_config = {
    'authentication' => { 'module' => 'authn_configfile' },
    'authorization'  => { 'module' => 'authz_allowall' },
    'dns'            => { 'module' => 'manage_bind' },
    'dhcp'           => { 'module' => 'manage_isc' },
    'tftpd'          => { 'module' => 'manage_in_tftpd' },
  }
}
