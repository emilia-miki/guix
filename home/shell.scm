(define-module (home shell)
  #:use-module (gnu home services)
  #:use-module (gnu services)
  #:use-module (guix gexp)
  #:export (%shell-services))

(define-public %shell-services
  (list
    (simple-service 'shell-bash-config
      home-files-service-type
      `((".bashrc"
         ,(plain-file "bashrc"
            "eval \"$(starship init bash)\"
eval \"$(zoxide init bash)\"
eval \"$(direnv hook bash)\"

export PATH=\"$HOME/.local/bin:$HOME/.cargo/bin:$PATH\"

alias emacs=\"emacsclient -nw\"
alias em=\"emacsclient -nw\"
alias hx=\"emacsclient -nw\"
"))))

    (simple-service 'shell-local-bin
      home-files-service-type
      `((".local/bin/patch-venv-binary"
         ,(computed-file "patch-venv-binary"
            #~(begin
                (call-with-output-file #$output
                  (lambda (port)
                    (display
                      "#!/bin/sh\ninterp=\"/run/current-system/profile/lib/ld-linux-aarch64.so.1\"\nrpath=\"/run/current-system/profile/lib\"\npatchelf --force-rpath --set-rpath \"$rpath\" --set-interpreter \"$interp\" \"$1\"\n"
                      port)))
                (chmod #$output #o755))))))

    (simple-service 'shell-xdg-config
      home-xdg-configuration-files-service-type
      `(("direnv/direnvrc"
         ,(plain-file "direnvrc"
            "use_guix() {
    eval \"$(guix shell --search-paths)\"
}

use_venv() {
    source .venv/bin/activate
}
"))
        ("starship.toml"
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
  guix describe -f channels | save --force $\"($guix)/channels.lock.scm\"
  kbuildsycoca6 --noincremental
}
"))))))
