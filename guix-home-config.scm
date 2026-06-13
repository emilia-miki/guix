(define-module (guix-home-config)
  #:use-module (gnu home)
  #:use-module (gnu home services)
  #:use-module (gnu home services desktop)
  #:use-module (gnu home services gnupg)
  #:use-module (gnu services)
  #:use-module (guix gexp)
  #:use-module (gnu packages gnupg)
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
  #:use-module (home bluetooth)
  #:use-module (packages rose-pine-gtk)
  #:use-module (packages rose-pine-kvantum)
  #:use-module (gnu packages qt)
  #:use-module (gnu home services xdg))

(define %gtk-settings
  "[Settings]\ngtk-application-prefer-dark-theme=1\ngtk-theme-name=rose-pine-gtk\ngtk-cursor-theme-name=Adwaita\ngtk-cursor-theme-size=24\ngtk-icon-theme-name=rose-pine-icons\n")

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

        ;; Emacs packages
        (simple-service 'emacs-packages
                        home-profile-service-type
                        %emacs-packages)

        (simple-service 'theme-packages
          home-profile-service-type
          (list rose-pine-gtk rose-pine-kvantum kvantum qt5ct qt6ct))

        (simple-service 'theme-env
                        home-environment-variables-service-type
                       `(("QT_PLUGIN_PATH" . "$HOME/.guix-home/profile/lib:$HOME/.guix-home/profile/lib/qt6/plugins:/run/current-system/profile/lib/qt6/plugins")))

        (service home-files-service-type
                 `((".config/gtk-3.0/settings.ini"
                    ,(plain-file "gtk-settings.ini" %gtk-settings))
                   (".Xdefaults" ,%default-xdefaults)
                   (".guile" ,%default-dotguile)
                   (".config/gtk-4.0/settings.ini"
                    ,(plain-file "gtk-settings.ini" %gtk-settings))
                   ;; Rose Pine GTK4 CSS extended with CSS custom properties.
                   ;; Libadwaita reads --window-bg-color etc. (CSS custom properties)
                   ;; which respect cascade order (user priority 800 > adwaita's 600).
                   ;; @define-color alone is insufficient because libadwaita overwrites
                   ;; those in load order regardless of priority.
                   (".config/gtk-4.0/gtk.css"
                    ,(computed-file "gtk4.css"
                       #~(begin
                           (use-modules (ice-9 textual-ports))
                           (call-with-output-file #$output
                             (lambda (port)
                               (display
                                 (call-with-input-file
                                   #$(file-append rose-pine-gtk
                                                  "/share/themes/rose-pine-gtk/gtk-4.0/gtk.css")
                                   get-string-all)
                                 port)
                               (display "
/* CSS custom properties for libadwaita — these respect cascade order unlike @define-color */
:root {
  --window-bg-color: #191724;
  --window-fg-color: #e0def4;
  --view-bg-color: #1f1d2e;
  --view-fg-color: #e0def4;
  --headerbar-bg-color: #191724;
  --headerbar-fg-color: #e0def4;
  --headerbar-border-color: #e0def4;
  --headerbar-backdrop-color: #191724;
  --headerbar-shade-color: #191724;
  --headerbar-darker-shade-color: #0d0c14;
  --sidebar-bg-color: #1f1d2e;
  --sidebar-fg-color: #e0def4;
  --sidebar-backdrop-color: #1f1d2e;
  --sidebar-border-color: #26233a;
  --sidebar-shade-color: #191724;
  --secondary-sidebar-bg-color: #26233a;
  --secondary-sidebar-fg-color: #e0def4;
  --secondary-sidebar-backdrop-color: #26233a;
  --secondary-sidebar-border-color: #26233a;
  --secondary-sidebar-shade-color: #1f1d2e;
  --card-bg-color: #26233a;
  --card-fg-color: #e0def4;
  --card-shade-color: #1f1d2e;
  --dialog-bg-color: #26233a;
  --dialog-fg-color: #e0def4;
  --popover-bg-color: #26233a;
  --popover-fg-color: #e0def4;
  --popover-shade-color: #1f1d2e;
  --thumbnail-bg-color: #403d52;
  --thumbnail-fg-color: #e0def4;
  --shade-color: #191724;
  --scrollbar-outline-color: #0d0c14;
  --accent-bg-color: #c4a7e7;
  --accent-fg-color: #191724;
  --accent-color: #c4a7e7;
  --destructive-bg-color: #eb6f92;
  --destructive-fg-color: #191724;
  --destructive-color: #eb6f92;
  --success-bg-color: #9ccfd8;
  --success-fg-color: #191724;
  --success-color: #9ccfd8;
  --warning-bg-color: #f6c177;
  --warning-fg-color: #191724;
  --warning-color: #f6c177;
  --error-bg-color: #eb6f92;
  --error-fg-color: #191724;
  --error-color: #eb6f92;
}
" port))))))))

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

        (simple-service 'rebuild-kde-cache
                        home-activation-service-type
                        #~(system* "/run/current-system/profile/bin/kbuildsycoca6"
                                   "--noincremental"))

        (simple-service 'desktop-interface-settings
                        home-activation-service-type
                        #~(let ((dconf "/run/current-system/profile/bin/dconf"))
                            (system* dconf "write"
                                     "/org/gnome/desktop/interface/gtk-theme"
                                     "'rose-pine-gtk'")
                            (system* dconf "write"
                                     "/org/gnome/desktop/interface/icon-theme"
                                     "'rose-pine-icons'")
                            (system* dconf "write"
                                     "/org/gnome/desktop/interface/color-scheme"
                                     "'prefer-dark'")
                            (system* dconf "write"
                                     "/org/gnome/desktop/interface/cursor-theme"
                                     "'Adwaita'")
                            (system* dconf "write"
                                     "/org/gnome/desktop/interface/cursor-size"
                                     "24")))

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
                   ("nano/nanorc" ,%default-nanorc)
                   ))
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
      %bluetooth-services
      %base-home-services)))
