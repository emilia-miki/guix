(define-module (guix-home-config)
  #:use-module (gnu home)
  #:use-module (gnu home services)
  #:use-module (gnu home services desktop)
  #:use-module (gnu services)
  #:use-module (guix gexp)
  #:use-module (gnu system shadow)
  #:use-module (asahi guix home config)
  #:use-module (asahi guix home services sound)
  #:use-module (home shell)
  #:use-module (home tools)
  #:use-module (home helix)
  #:use-module (home kde)
  #:use-module (home apps)
  #:use-module (home ssh))

(define %gtk-settings
  "[Settings]\ngtk-application-prefer-dark-theme=1\ngtk-cursor-theme-name=Adwaita\ngtk-cursor-theme-size=24\n")

(home-environment
  (inherit asahi-home-environment)
  (services
    (append
      (list
        (service home-dbus-service-type)
        (service home-pipewire-service-type)

        (service home-files-service-type
          `((".config/gtk-3.0/settings.ini"
             ,(plain-file "gtk-settings.ini" %gtk-settings))
            (".Xdefaults" ,%default-xdefaults)
            (".guile" ,%default-dotguile)
            (".config/gtk-4.0/settings.ini"
             ,(plain-file "gtk-settings.ini" %gtk-settings))))

        (service home-xdg-configuration-files-service-type
          `(("gdb/gdbinit" ,%default-gdbinit)
            ("nano/nanorc" ,%default-nanorc))))

      %shell-services
      %tools-services
      %helix-services
      %kde-services
      %apps-services
      %ssh-services
      %base-home-services)))
