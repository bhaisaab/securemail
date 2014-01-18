define locale($role = $title) {

    $localefile = $role ? {
        default     => 'default.gen',
    }

    # configure locale
    file { "/etc/locale.gen":
        ensure  => present,
        owner   => root,
        group   => root,
        mode    => 644,
        source  => "puppet:///modules/locale/$localefile",
        notify  => Exec["locale-gen"],
    }

    exec { "locale-gen":
        command => "/usr/sbin/locale-gen",
        refreshonly => true,
    }
}
