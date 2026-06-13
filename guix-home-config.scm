(define-module (guix-home-config)
  #:use-module (gnu home)
  #:use-module (gnu home services)
  #:use-module (gnu home services desktop)
  #:use-module (gnu home services gnupg)
  #:use-module (gnu home services xdg)
  #:use-module (gnu packages gnupg)
  #:use-module (gnu services)
  #:use-module (gnu system shadow)
  #:use-module (guix gexp)
  #:use-module (asahi guix home config)
  #:use-module (asahi guix home services sound)
  #:use-module (home apps)
  #:use-module (home bluetooth)
  #:use-module (home emacs)
  #:use-module (home env)
  #:use-module (home fcitx5)
  #:use-module (home helix)
  #:use-module (home shell)
  #:use-module (home ssh)
  #:use-module (home sway)
  #:use-module (home theme)
  #:use-module (home tools)
  #:use-module (home wallpaper))

(home-environment
 (inherit asahi-home-environment)
 (services
  (append
   (list
    (service home-dbus-service-type)
    (service home-gpg-agent-service-type
             (home-gpg-agent-configuration
              (ssh-support? #t)
              (pinentry-program
               (file-append pinentry-qt "/bin/pinentry-qt"))))
    (service home-pipewire-service-type)

    (simple-service 'dotfiles
                    home-files-service-type
                    `((".Xdefaults" ,%default-xdefaults)
                      (".guile"     ,%default-dotguile)))

    (simple-service 'channels-scm-symlink
                    home-activation-service-type
                    #~(let* ((home   (getenv "HOME"))
                             (link   (string-append home "/.config/guix/channels.scm"))
                             (target (string-append home "/Projects/guix-system/channels.scm")))
                        (when (file-exists? link)
                          (delete-file link))
                        (symlink target link)))

    (service home-xdg-configuration-files-service-type
             `(("gdb/gdbinit" ,%default-gdbinit)
               ("nano/nanorc" ,%default-nanorc)))
    (service home-xdg-user-directories-service-type))

   %sway-services
   %env-services
   %theme-services
   %shell-services
   %emacs-services
   %tools-services
   %helix-services
   %fcitx5-services
   %apps-services
   %ssh-services
   %bluetooth-services
   %base-home-services)))
