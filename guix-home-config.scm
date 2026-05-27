(define-module (guix-home-config)
  #:use-module (gnu home)
  #:use-module (gnu home services)
  #:use-module (gnu home services shells)
  #:use-module (gnu home services desktop)
  #:use-module (gnu services)
  #:use-module (guix gexp)
  #:use-module (gnu system shadow)
  #:use-module (asahi guix home services sound))

(define home-config
  (home-environment
    (services
      (append
        (list
          ;; Uncomment the shell you wish to use for your user:
          ;(service home-bash-service-type)
          ;(service home-fish-service-type)
          ;(service home-zsh-service-type)
          (service home-dbus-service-type)
          (service home-pipewire-service-type)

          (simple-service 'environment-vars
            home-environment-variables-service-type
            '(("QT_STYLE_OVERRIDE" . "Adwaita-Dark")
              ("GTK_THEME" . "Adwaita:dark")
              ("GTK_IM_MODULE" . "fcitx")
              ("QT_IM_MODULE" . "fcitx")
              ("XMODIFIERS" . "@im=fcitx")
              ("SDL_IM_MODULE" . "fcitx")))

          (service home-files-service-type
            `((".config/gtk-3.0/settings.ini"
               ,(plain-file "gtk-settings.ini"
                  "[Settings]\ngtk-application-prefer-dark-theme=1\n"))
              (".Xdefaults" ,%default-xdefaults)
              (".guile" ,%default-dotguile)
              (".config/gtk-4.0/settings.ini"
               ,(plain-file "gtk-settings.ini"
                  "[Settings]\ngtk-application-prefer-dark-theme=1\n"))
              (".config/starship.toml"
               ,(plain-file "starship.toml"
                  "[character]\nsuccess_symbol = '[λ](bold green)'\nerror_symbol = '[λ](bold red)'\n"))
              (".config/nushell/env.nu"
               ,(plain-file "env.nu"
                  "\
# Cargo
$env.PATH = ($env.PATH | append $\"($env.HOME)/.cargo/bin\")

# Starship prompt init
mkdir ~/.cache/starship
starship init nu | save -f ~/.cache/starship/init.nu

# Zoxide init
zoxide init nushell | save -f ~/.zoxide.nu
"))
              (".config/nushell/config.nu"
               ,(plain-file "config.nu"
                  "\
# Starship prompt
use ~/.cache/starship/init.nu

# Zoxide
source ~/.zoxide.nu
"))))

          (service home-xdg-configuration-files-service-type
           `(("gdb/gdbinit" ,%default-gdbinit)
             ("nano/nanorc" ,%default-nanorc))))

        %base-home-services))))

home-config
