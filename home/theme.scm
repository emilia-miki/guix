(define-module (home theme)
  #:use-module (gnu home services)
  #:use-module (gnu packages gnome)
  #:use-module (gnu packages kde-frameworks)
  #:use-module (gnu packages qt)
  #:use-module (gnu services)
  #:use-module (guix gexp)
  #:use-module (packages rose-pine-gtk)
  #:use-module (packages rose-pine-kvantum)
  #:export (%theme-services))

(define %gtk-settings
  "\
[Settings]
gtk-application-prefer-dark-theme=1
gtk-theme-name=rose-pine-gtk
gtk-cursor-theme-name=Adwaita
gtk-cursor-theme-size=24
gtk-icon-theme-name=rose-pine-icons
")

(define-public %theme-services
  (list
   (simple-service 'theme-packages
                   home-profile-service-type
                   (list rose-pine-gtk rose-pine-kvantum kvantum dconf))

   (simple-service 'theme-env
                   home-environment-variables-service-type
                   '(("QT_QPA_PLATFORMTHEME"  . "qt6ct")
                     ("QT_PLUGIN_PATH"        . "$HOME/.guix-home/profile/lib:$HOME/.guix-home/profile/lib/qt6/plugins:/run/current-system/profile/lib/qt6/plugins")
                     ("ADW_DEBUG_COLOR_SCHEME" . "prefer-dark")
                     ("XCURSOR_THEME" . "Adwaita")
                     ("XCURSOR_SIZE"  . "24")))

   (simple-service 'gtk-files
                   home-files-service-type
                   `((".config/gtk-3.0/settings.ini"
                      ,(plain-file "gtk-settings.ini" %gtk-settings))
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
                                              (display "\

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

   (simple-service 'desktop-interface-settings
                   home-activation-service-type
                   #~(let ((dconf #$(file-append dconf "/bin/dconf")))
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

   (simple-service 'kde-app-theme-config
                   home-xdg-configuration-files-service-type
                   `(("Kvantum/kvantum.kvconfig"
                      ,(plain-file "kvantum.kvconfig"
                                   "\
[General]
theme=rose-pine-love
respect_DE=false
"))
                     ;; Route XDG Settings portal to gtk so Qt 6.5+ reads color-scheme from dconf.
                     ("xdg-desktop-portal/portals.conf"
                      ,(plain-file "portals.conf"
                                   "\
[preferred]
default=wlr
org.freedesktop.impl.portal.Settings=gtk
org.freedesktop.impl.portal.FileChooser=gtk
"))

                     ("kdeglobals"
                      ,(plain-file "kdeglobals"
                                   "\
[KDE]
widgetStyle=kvantum

[General]
ColorScheme=RosePine

[Icons]
Theme=rose-pine-icons
FallbackTheme=breeze-dark

[Colors:Window]
BackgroundNormal=29,23,31
ForegroundNormal=224,222,244
BackgroundAlternate=30,28,42

[Colors:View]
BackgroundNormal=29,23,31
ForegroundNormal=224,222,244
BackgroundAlternate=30,28,42
ForegroundLink=156,207,216
ForegroundVisited=196,167,231

[Colors:Button]
BackgroundNormal=30,28,42
ForegroundNormal=224,222,244

[Colors:Selection]
BackgroundNormal=64,60,100
ForegroundNormal=224,222,244

[Colors:Tooltip]
BackgroundNormal=30,28,42
ForegroundNormal=224,222,244

[Colors:Header]
BackgroundNormal=29,23,31
ForegroundNormal=224,222,244
"))))

   (simple-service 'qt6ct-conf
                   home-activation-service-type
                   #~(let ((path (string-append (getenv "HOME") "/.config/qt6ct/qt6ct.conf")))
                       (call-with-output-file path
                         (lambda (port)
                           (display "\
[Appearance]
custom_palette=false
icon_theme=rose-pine-icons
standard_dialogs=default
style=kvantum

[Fonts]
fixed=\"Noto Sans,12,-1,5,400,0,0,0,0,0,0,0,0,0,0,1\"
general=\"Noto Sans,12,-1,5,400,0,0,0,0,0,0,0,0,0,0,1\"

[Interface]
activate_item_on_single_click=1
buttonbox_layout=0
cursor_flash_time=1000
dialog_buttons_have_icons=1
double_click_interval=400
gui_effects=@Invalid()
keyboard_scheme=2
menus_have_icons=true
show_shortcuts_in_context_menus=true
stylesheets=@Invalid()
toolbutton_style=4
underline_shortcut=1
wheel_scroll_lines=3

[Troubleshooting]
force_raster_widgets=1
ignored_applications=@Invalid()
" port)))))

   (simple-service 'rebuild-kde-cache
                   home-activation-service-type
                   #~(let ((home (getenv "HOME")))
                       (setenv "XDG_DATA_DIRS"
                               (string-append home "/.guix-home/profile/share"
                                              ":/run/current-system/profile/share"))
                       (system* #$(file-append kservice "/bin/kbuildsycoca6")
                                "--noincremental")))))
