(define-module (home sway)
  #:use-module (gnu home services)
  #:use-module (gnu packages gnome)
  #:use-module (gnu services)
  #:use-module (guix gexp)
  #:use-module (home wallpaper)
  #:export (%sway-services))

(define (executable-file name source)
  (computed-file name
    #~(begin
        (copy-file #$source #$output)
        (chmod #$output #o755))))

(define (with-wallpaper name template)
  (computed-file name
    #~(begin
        (use-modules (ice-9 textual-ports) (ice-9 regex))
        (call-with-output-file #$output
          (lambda (port)
            (display
              (regexp-substitute/global #f "@WALLPAPER@"
                (call-with-input-file #$template get-string-all)
                'pre #$%wallpaper 'post)
              port))))))

(define-public %sway-services
  (list
    (simple-service 'sway-packages
      home-profile-service-type
      (list libnotify))

    (simple-service 'sway-env
      home-environment-variables-service-type
      '(("XCURSOR_THEME" . "Adwaita")
        ;; 36 = 24 logical px * 1.5 display scale; GTK3 loads cursors in physical px
        ("XCURSOR_SIZE" . "36")
        ;; gtk3 platform theme reads color-scheme from dconf (prefer-dark), so
        ;; QStyleHints::colorScheme() returns Dark and Breeze renders in dark mode.
        ("QT_QPA_PLATFORMTHEME" . "gtk3")))

    (simple-service 'sway-xdg-config
      home-xdg-configuration-files-service-type
      `(("sway/config"
         ,(with-wallpaper "sway-config" (local-file "files/sway-config")))
        ("waybar/config.jsonc"
         ,(local-file "files/waybar-config.jsonc"))
        ("waybar/style.css"
         ,(local-file "files/waybar-style.css"))
        ("waybar/rose-pine.css"
         ,(local-file "files/waybar-rose-pine.css"))
        ("waybar/power_menu.xml"
         ,(local-file "files/waybar-power_menu.xml"))
        ("waybar/wifimenu"
         ,(executable-file "wifimenu" (local-file "files/waybar-wifimenu")))
        ("waybar/wofi-bluetooth"
         ,(executable-file "wofi-bluetooth" (local-file "files/waybar-wofi-bluetooth")))
        ("mako/config"
         ,(local-file "files/mako-config"))
        ("foot/foot.ini"
         ,(local-file "files/foot.ini"))
        ("swaylock/config"
         ,(with-wallpaper "swaylock-config" (local-file "files/swaylock-config")))

        ;; Route the XDG Settings portal to the gtk backend under Sway so that
        ;; Qt 6.5+ and other apps can read the dark-mode preference from dconf.
        ;; dconf already has org.gnome.desktop.interface.color-scheme = prefer-dark.
        ("xdg-desktop-portal/portals.conf"
         ,(plain-file "portals.conf"
            "[preferred]
default=wlr
org.freedesktop.impl.portal.Settings=gtk
"))

;;         ("qt6ct/qt6ct.conf"
;;          ,(plain-file "qt6ct.conf"
;;             "[Appearance]
;; color_scheme_path=~/.config/qt6ct/colors/dexy-dark.conf
;; custom_palette=true
;; icon_theme=breeze-dark
;; standard_dialogs=default
;; style=Fusion
;; "))

;;         ("qt6ct/colors/dexy-dark.conf"
;;          ,(plain-file "dexy-dark.conf"
;;             ;; Colors derived from Trolltech.conf / KDE kdeglobals dark theme.
;;             ;; Format: #AARRGGBB, roles follow QPalette order:
;;             ;; WindowText, Button, Light, Midlight, Dark, Mid, Text, BrightText,
;;             ;; ButtonText, Base, Window, Shadow, Highlight, HighlightedText,
;;             ;; Link, LinkVisited, AlternateBase, NoRole, ToolTipBase, ToolTipText,
;;             ;; PlaceholderText
;;             "[ColorScheme]
;; active_colors=#ffd3dae3, #ff161925, #ff373f5d, #ff2b3048, #ff0b0c12, #ff131620, #ffd3dae3, #ffffffff, #ffc3c7d1, #ff161925, #ff161925, #ff08090d, #ffa93076, #ffffffff, #fff7bcd4, #ff7cb7ff, #ff141a21, #ff000000, #ff171b28, #ffd3dae3, #ffa6acba
;; disabled_colors=#ff545863, #ff151823, #ffd9dbe6, #ffacb1cb, #ff8b93ba, #ff5e6b9f, #ff545863, #ffffffff, #ff4f525d, #ff151823, #ff151823, #ffacb1cb, #ff151823, #ff545863, #ff604e5e, #ff374d6c, #ff13191f, #ff000000, #ff171b28, #ffd3dae3, #ff454955
;; inactive_colors=#ffd3dae3, #ff161925, #ff373f5d, #ff2b3048, #ff0b0c12, #ff131620, #ffd3dae3, #ffffffff, #ffc3c7d1, #ff161925, #ff161925, #ff08090d, #ff4a1938, #ffd3dae3, #fff7bcd4, #ff7cb7ff, #ff141a21, #ff000000, #ff171b28, #ffd3dae3, #ffa6acba
;; "))
        ))))
