class mailserver($domain='baagi.org', $user='bhaisaab',
                 $ssl_cert='/etc/ssl/private/baagi.pem', $ssl_key='/etc/ssl/private/baagi.key') {

    package { [
        'sendmail',
        'exim4',
        'exim4-base',
        'exim4-config',
        'exim4-daemon-light' ]:
        ensure => absent,
    }

    $packages = [ 'postfix', 'sasl2-bin', 'libsasl2-modules', 'dovecot-core', 'dovecot-imapd',
                  'opendkim', 'opendkim-tools', 'spamass-milter', 'spamassassin' ]
    package { $packages: ensure => installed }

    file { "/etc/postfix/main.cf":
        ensure => file,
        notify => Service["postfix"],
        mode => 644,
        owner => root,
        group => root,
        content => template("mailserver/postfixmain.cf.erb"),
        require => Package["postfix"],
    } ->
    file { "/etc/postfix/master.cf":
        ensure => file,
        notify => Service["postfix"],
        mode => 644,
        owner => root,
        group => root,
        content => template("mailserver/postfixmaster.cf.erb"),
        require => Package["postfix"],
    } ->
    exec { "root-alias-proxy":
        path     => "/bin:/usr/bin:/usr/local/bin",
        user     => root,
        unless   => "cat /etc/aliases | grep root:",
        command  => "echo root: ${user} >> /etc/aliases && /usr/bin/newaliases",
    }

    file { "/etc/dovecot/dovecot.conf":
        ensure => file,
        notify => Service["dovecot"],
        mode => 644,
        owner => root,
        group => root,
        content => template("mailserver/dovecot.conf.erb"),
        require => Package["dovecot-core"],
    }

    file { "/etc/opendkim.conf":
        ensure => file,
        notify => Service["opendkim"],
        mode => 644,
        owner => root,
        group => root,
        content => template("mailserver/opendkim.conf.erb"),
        require => Package["opendkim"],
    }

    # Generate dkim key
    exec { "opendkim-genkey":
        path     => "/bin:/usr/bin:/usr/local/bin",
        user     => root,
        unless   => "ls /etc/opendkim/mail.private",
        command  => "mkdir -p /etc/opendkim && cd /etc/opendkim && \
                     opendkim-genkey -r -h rsa-sha256 -d ${domain} -s mail && \
                     chown opendkim:opendkim * && chmod u=rw,go-rwx * && cat mail.txt",
        require => Package["opendkim"],
    }

    # Enable opendkim service
    exec { "opendkim-enable":
        path     => "/bin:/usr/bin:/usr/local/bin",
        notify => Service["opendkim"],
        user     => root,
        unless   => "cat /etc/default/opendkim | grep ^SOCKET=",
        command  => 'echo SOCKET=\"inet:12345@localhost\" > /etc/default/opendkim',
        require => Package["opendkim"],
    }

    # Enable spamass-milter service
    exec { "spamass-milter-enable":
        path     => "/bin:/usr/bin:/usr/local/bin",
        notify => Service["spamass-milter"],
        user     => root,
        unless   => "cat /etc/default/spamass-milter | grep ^OPTIONS | grep '\-I'",
        command  => 'echo OPTIONS=\"-u spamass-milter -i 127.0.0.1 -m -r -1 -I\" > /etc/default/spamass-milter',
        require => Package["spamass-milter"],
    }

    file { "/etc/default/spamassassin":
        ensure => file,
        notify => Service["spamassassin"],
        mode => 644,
        owner => root,
        group => root,
        content => template("mailserver/spamassassin.erb"),
        require => Package["spamassassin"],
    }

    service { 'postfix':
        ensure     => running,
        enable     => true,
        hasrestart => true,
        hasstatus  => false,
        require    => Package['postfix'],
    }

    service { 'dovecot':
        ensure     => running,
        enable     => true,
        hasrestart => true,
        require    => Package['dovecot-core'],
    }

    service { 'opendkim':
        ensure     => running,
        enable     => true,
        hasrestart => false,
        hasstatus  => false,
        require    => Package['opendkim'],
    }

    service { 'spamass-milter':
        ensure     => running,
        enable     => true,
        require    => Package['spamass-milter'],
    }

    service { 'spamassassin':
        ensure     => running,
        enable     => true,
        require    => Package['spamassassin'],
    }
}
