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
  #:use-module (home ssh)
  #:use-module (home work)
  #:use-module (home emacs)
  #:use-module (home fcitx5)
  #:use-module (home wallpaper)
  #:use-module (home sway)
  #:use-module (gnu home services xdg))

(define %gtk-settings
  "[Settings]\ngtk-application-prefer-dark-theme=1\ngtk-cursor-theme-name=Adwaita\ngtk-cursor-theme-size=24\ngtk-icon-theme-name=breeze-dark\n")

(home-environment
  (inherit asahi-home-environment)
  (services
    (append
      (list
        (service home-dbus-service-type)
        (service home-pipewire-service-type)

        ;; Emacs packages
        (simple-service 'emacs-packages
          home-profile-service-type
          %emacs-packages)

        (service home-files-service-type
          `((".config/gtk-3.0/settings.ini"
             ,(plain-file "gtk-settings.ini" %gtk-settings))
            (".Xdefaults" ,%default-xdefaults)
            (".guile" ,%default-dotguile)
            (".config/gtk-4.0/settings.ini"
             ,(plain-file "gtk-settings.ini" %gtk-settings))))

        (simple-service 'pdf-tools-env home-environment-variables-service-type
                        '(("ACLOCAL_PATH" . "$HOME/.guix-home/profile/share/aclocal:/run/current-system/profile/share/aclocal")))

        (simple-service 'emacs-init-symlink
                        home-activation-service-type
                        #~(let* ((home   (getenv "HOME"))
                                 (link   (string-append home "/.config/emacs/init.el"))
                                 (target (string-append home "/Projects/guix-system/home/files/emacs-init.el")))
                            (mkdir-p (string-append home "/.config/emacs"))
                            (when (file-exists? link)
                              (delete-file link))
                            (symlink target link)))

        (service home-xdg-configuration-files-service-type
          `(("gdb/gdbinit" ,%default-gdbinit)
            ("nano/nanorc" ,%default-nanorc)))
        (service home-xdg-user-directories-service-type))

      ;; Desktop environment services — swap to switch:
      ;; Sway: %sway-services  KDE: %kde-services
      %sway-services
      %shell-services
      %tools-services
      %helix-services
      %kde-services
      %fcitx5-services
      %apps-services
      %ssh-services
      %work-services
      %base-home-services)))
