define users::admin {

    $passwords = {
        'bhaisaab'    => '$6$nPUQh53z$vsAYEHMfp.jBu0N3VTvAieUNUVWro6AOKI1RTGK//Nx1aN/f8B3LPlX.qKHImoAtn2jvRDT/N.Y4y2CYtiVUR/',
    }

    user { $title:
        ensure     => "present",
        managehome => true,
        home       => "/home/$title",
        comment    => "$title",
        shell      => "/bin/bash",
        password   => $passwords["$title"],
        groups     => ["sudo", "adm", "dialout"],
    }

    file { "/home/$title/.ssh/authorized_keys":
        ensure  => present,
        owner   => $title,
        group   => $title,
        mode    => 600,
        require => File["/home/$title/.ssh"],
        source => "puppet:///modules/users/$title.pub",
    }

    file { "/home/$title/.ssh":
        ensure => directory,
        owner => $title,
        group => $title,
        mode => 700,
    }

    file { "/home/$title":
        ensure => directory,
        owner => $title,
        group => $title,
        mode => 700,
    }
}
