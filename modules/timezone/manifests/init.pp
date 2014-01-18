define timezone ($tz = "UTC") {

    package { "tzdata":  ensure => installed }

    $tzfile = $tz ? {
        'UTC'    => 'UTC',
        'IST'    => 'Asia/Kolkata',
        default  => 'UTC',
    }

    file { "/etc/localtime":
        require => Package["tzdata"],
        source  => "file:///usr/share/zoneinfo/$tzfile",
    }
}
