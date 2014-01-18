class mailserver {

    package { [
        'exim4',
        'exim4-base',
        'exim4-config',
        'exim4-daemon-light' ]:
        ensure => absent,
    }

    $packages = [ 'postfix', 'sasl2-bin', 'libsasl2-modules', 'dovecot-core', 'dovecot-imapd' ]
    package { $packages: ensure => installed }

    service { 'postfix':
        ensure     => running,
        enable     => true,
        hasrestart => true,
        hasstatus  => false,
        require    => Package['postfix'],
    }

}
