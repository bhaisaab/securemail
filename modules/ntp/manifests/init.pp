class ntp {

    package { 'ntpdate':
        ensure => latest
    }

    package { "ntp":
        ensure => latest,
    }

    service { "ntp":
        ensure => "running"
    }

}
