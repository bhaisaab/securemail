class fail2ban {
    package { "fail2ban":
        ensure => installed
    }

    file { "/etc/default/fail2ban":
        ensure  => present,
        owner   => root,
        group   => root,
        mode    => 644,
        source => "puppet:///modules/fail2ban/fail2ban-default",
        require => Package["fail2ban"],
        notify => Service["fail2ban"],
    }

    file { "/etc/fail2ban/jail.local":
        ensure  => present,
        owner   => root,
        group   => root,
        mode    => 644,
        source => "puppet:///modules/fail2ban/jail.local",
        require => Package["fail2ban"],
        notify => Service["fail2ban"],
    }

    service { "fail2ban":
        ensure => "running"
    }
}
