node basenode {
    include base
    include ntp

    class { "ssh":
        allowed_users => "bhaisaab",
    }

    timezone { "server timezone":
        tz => "UTC",
    }

    users::admin { "bhaisaab": }
    locale { "default": }
}

node default inherits basenode {
}

node /^baagi(\.org)?$/ inherits basenode {
    include fail2ban

    class { "dotfiles":
        user => 'bhaisaab',
    }

    class { "mailserver":
        domain => "baagi.org",
        user => "bhaisaab",
        ssl_cert => "/etc/ssl/private/baagi.pem",
        ssl_key => "/etc/ssl/private/baagi.key",
    }
}
