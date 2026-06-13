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
        ;; GTK3 multiplies XCURSOR_SIZE by wl_output.scale=2 (integer rounding of 1.5),
        ;; so 18×2=36px matches sway's seat cursor of 24 logical×1.5=36px physical.
        ("XCURSOR_SIZE" . "18")
        ("QT_QPA_PLATFORMTHEME" . "qt6ct")
        ;; Force libadwaita dark mode directly; belt-and-suspenders in case the
        ;; xdg-desktop-portal-gtk Settings backend isn't running yet at app launch.
        ("ADW_DEBUG_COLOR_SCHEME" . "prefer-dark")
        ))

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
        ("sway/wofi-unicode"
         ,(executable-file "wofi-unicode" (local-file "files/wofi-unicode")))
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
org.freedesktop.impl.portal.FileChooser=gtk
"))

        ("Kvantum/kvantum.kvconfig"
         ,(plain-file "kvantum.kvconfig"
            "[General]
theme=rose-pine-love
respect_DE=false
"))
        ))

    (simple-service 'qt6ct-conf
      home-activation-service-type
      #~(let ((path (string-append (getenv "HOME") "/.config/qt6ct/qt6ct.conf")))
          (call-with-output-file path
            (lambda (port)
              (display
                (string-append
                  "[Appearance]\n"
                  "custom_palette=false\n"
                  "icon_theme=rose-pine-icons\n"
                  "standard_dialogs=default\n"
                  "style=kvantum\n"
                  "\n"
                  "[Fonts]\n"
                  "fixed=\"Noto Sans,12,-1,5,400,0,0,0,0,0,0,0,0,0,0,1\"\n"
                  "general=\"Noto Sans,12,-1,5,400,0,0,0,0,0,0,0,0,0,0,1\"\n"
                  "\n"
                  "[Interface]\n"
                  "activate_item_on_single_click=1\n"
                  "buttonbox_layout=0\n"
                  "cursor_flash_time=1000\n"
                  "dialog_buttons_have_icons=1\n"
                  "double_click_interval=400\n"
                  "gui_effects=@Invalid()\n"
                  "keyboard_scheme=2\n"
                  "menus_have_icons=true\n"
                  "show_shortcuts_in_context_menus=true\n"
                  "stylesheets=@Invalid()\n"
                  "toolbutton_style=4\n"
                  "underline_shortcut=1\n"
                  "wheel_scroll_lines=3\n"
                  "\n"
                  "[Troubleshooting]\n"
                  "force_raster_widgets=1\n"
                  "ignored_applications=@Invalid()\n")
                port)))))))

