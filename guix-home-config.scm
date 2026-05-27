;; This is a sample Guix Home configuration which can help setup your
;; home directory in the same declarative manner as Guix System.
;; For more information, see the Home Configuration section of the manual.
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

          (simple-service 'dark-theme
            home-environment-variables-service-type
            '(("QT_STYLE_OVERRIDE" . "Adwaita-Dark")
            ("GTK_THEME" . "Adwaita:dark")))

          (service home-files-service-type
            `((".config/gtk-3.0/settings.ini"
               ,(plain-file "gtk-settings.ini"
                  "[Settings]\ngtk-application-prefer-dark-theme=1\n"))
              (".Xdefaults" ,%default-xdefaults)
              (".guile" ,%default-dotguile)
              (".config/gtk-4.0/settings.ini"
               ,(plain-file "gtk-settings.ini"
                  "[Settings]\ngtk-application-prefer-dark-theme=1\n"))))

          (service home-xdg-configuration-files-service-type
           `(("gdb/gdbinit" ,%default-gdbinit)
             ("nano/nanorc" ,%default-nanorc))))

        %base-home-services))))

home-config
