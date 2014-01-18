class base {
    $packages = [ "sudo", "htop", "rsync", "tar", "tmux", "vim", "locales" ]
    package { $packages: ensure => installed }

#    file { "/etc/hosts":
#        ensure => file,
#        content => template("base/hosts.erb"),
#    }

#    firewall { '000 allow packets with valid state':
#        state    => ['RELATED', 'ESTABLISHED'],
#        action   => 'accept',
#    }
#    resources { 'firewall':
#        purge    => false,
#    }
}
