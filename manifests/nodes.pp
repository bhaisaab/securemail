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
}
