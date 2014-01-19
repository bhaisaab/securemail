class dotfiles($user = 'bhaisaab') {

    $packages = [ "zsh" ]
    package { $packages: ensure => installed } ->
    exec { "set dotfiles for user":
        path     => "/bin:/usr/bin:/usr/local/bin",
        user     => "$user",
        unless   => "ls /home/${user}/.dotfiles && ls /home/${user}/.oh-my-zsh",
        command  => "git clone git://github.com/bhaisaab/dotfiles.git /home/${user}/.dotfiles \
                     && git clone git://github.com/robbyrussell/oh-my-zsh.git /home/${user}/.oh-my-zsh \
                     && /bin/bash /home/${user}/.dotfiles/install.sh",
        require => User["$user"],
    }
}
