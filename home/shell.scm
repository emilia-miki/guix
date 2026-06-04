(define-module (home shell)
  #:use-module (gnu home services)
  #:use-module (gnu services)
  #:use-module (guix gexp)
  #:export (%shell-services))

(define-public %shell-services
  (list
    (simple-service 'shell-xdg-config
      home-xdg-configuration-files-service-type
      `(("starship.toml"
         ,(plain-file "starship.toml"
            "[character]\nsuccess_symbol = '[λ](bold green)'\nerror_symbol = '[λ](bold red)'\n"))
        ("nushell/env.nu"
         ,(plain-file "env.nu"
            "# Local bin and Cargo
$env.PATH = ($env.PATH | prepend $\"($env.HOME)/.local/bin\" | prepend $\"($env.HOME)/.cargo/bin\")

# Starship prompt init
mkdir ~/.cache/starship
starship init nu | save -f ~/.cache/starship/init.nu

# Zoxide init
zoxide init nushell | save -f ~/.zoxide.nu
"))
        ("nushell/config.nu"
         ,(plain-file "config.nu"
            "# Starship prompt
use ~/.cache/starship/init.nu

# Zoxide
source ~/.zoxide.nu

alias em = emacsclient -nw

def sysconf [] {
  let guix = $\"($env.HOME)/Projects/guix-system\"
  sudo guix system reconfigure -L $guix $\"($guix)/configuration.scm\"
  guix home reconfigure -L $guix $\"($guix)/guix-home-config.scm\"
  kbuildsycoca6 --noincremental
}
"))))))
