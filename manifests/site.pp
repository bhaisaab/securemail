import "modules"
import "nodes"

# global defaults
Exec { path => "/usr/bin:/usr/sbin/:/bin:/sbin:/usr/local/bin" }

Package {
    provider => $operatingsystem ? {
        debian => aptitude,
        ubuntu => aptitude,
        redhat => yum,
        fedora => yum,
        centos => yum,
    }
}


