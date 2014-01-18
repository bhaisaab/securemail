class ssh($allowed_users = 'bhaisaab rohit rohityadav') {

    $packages = [ "openssh-client", "openssh-server" ]
    package { $packages: ensure => latest }

    service { "ssh":
        ensure => "running",
        enable => "true",
        hasstatus => true,
        require => Package["openssh-server"],
    }

    file { "/etc/ssh/sshd_config":
        ensure => file,
        notify => Service["ssh"],
        mode => 600,
        owner => "root",
        group => "root",
        content => template("ssh/sshd_config.erb"),
        require => Package["openssh-server"],
    }

    file { "/root/.ssh":
        ensure => directory,
        mode => 700,
        owner => root,
        group => root,
        selrange => s0,
        seltype => home_ssh_t,
        selrole => object_r,
        seluser => system_u,
    }
}
