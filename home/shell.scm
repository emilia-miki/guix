(define-module (home shell)
  #:use-module (gnu home services)
  #:use-module (gnu services)
  #:use-module (guix gexp)
  #:export (%shell-services))

(define-public %shell-services
  (list
    (simple-service 'shell-bash-config
      home-files-service-type
      `((".bash_profile"
         ,(plain-file "bash_profile"
            "# Guix Home sets up the user environment and starts the shepherd daemon
[ -f ~/.profile ] && . ~/.profile

# Source .bashrc for interactive login shells
[ -f ~/.bashrc ] && . ~/.bashrc

# Auto-start Sway on first TTY at login
if [ -z \"$WAYLAND_DISPLAY\" ] && [ \"$(tty)\" = \"/dev/tty1\" ]; then
  exec sway
fi
"))
        (".bashrc"
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
))))
