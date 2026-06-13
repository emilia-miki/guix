(define-module (home sway)
  #:use-module (gnu home services)
  #:use-module (gnu packages freedesktop)
  #:use-module (gnu packages fonts)
  #:use-module (gnu packages gnome)
  #:use-module (gnu packages image)
  #:use-module (gnu packages kde-frameworks)
  #:use-module (gnu packages kde-plasma)
  #:use-module (gnu packages lxqt)
  #:use-module (gnu packages music)
  #:use-module (gnu packages polkit)
  #:use-module (gnu packages qt)
  #:use-module (gnu packages terminals)
  #:use-module (gnu packages wm)
  #:use-module (gnu packages xdisorg)
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
                   (list
                    ;; Core compositor & shell
                    swayidle swaylock swaybg waybar
                    ;; Terminal & launcher
                    foot wofi
                    ;; Notifications
                    mako
                    ;; Screenshots & annotation
                    grim slurp swappy
                    ;; Clipboard
                    wl-clipboard
                    ;; PolicyKit agent
                    polkit-gnome
                    ;; Portals (screen sharing, file pickers)
                    xdg-desktop-portal xdg-desktop-portal-wlr xdg-desktop-portal-gtk
                    ;; Audio
                    pavucontrol-qt
                    ;; Notifications library
                    libnotify
                    ;; Qt theming
                    qtsvg font-nerd-symbols breeze breeze-icons qt5ct qt6ct
                    ;; Cursor & media keys
                    adwaita-icon-theme playerctl
                    ;; Color picker
                    hyprpicker
                    ;; Fonts
                    font-awesome
                    font-nerd-fira-code
                    font-google-noto
                    font-google-noto-sans-cjk
                    font-google-noto-serif-cjk
                    font-google-noto-emoji
                    font-dejavu
                    font-gnu-unifont
                    font-ipa
                    font-ipa-ex
                    font-bitstream-vera))

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
                      ,(with-wallpaper "swaylock-config" (local-file "files/swaylock-config")))))))

