(define-module (sway)
  #:use-module (asahi guix systems sway)
  #:use-module (gnu packages fonts)
  #:use-module (gnu packages freedesktop)
  #:use-module (gnu packages image)
  #:use-module (gnu packages kde-frameworks)
  #:use-module (gnu packages kde-plasma)
  #:use-module (gnu packages pdf)
  #:use-module (gnu packages polkit)
  #:use-module (gnu packages lxqt)
  #:use-module (gnu packages pulseaudio)
  #:use-module (gnu packages qt)
  #:use-module (gnu packages terminals)
  #:use-module (gnu packages wm)
  #:use-module (gnu packages xdisorg)
  #:use-module (gnu system)
  #:use-module (guix packages)
  #:use-module (packages dexy-themes)
  #:use-module (srfi srfi-1)
  #:export (%sway-packages %sway-os-packages))

;; Sway-specific packages. Add to the packages list in configuration.scm.
(define-public %sway-packages
  (list
   ;; Core compositor & shell
   swayidle swaylock swaybg waybar
   ;; Terminal & launcher
   foot wofi
   ;; Notifications
   mako
   ;; Screenshots
   grim slurp
   ;; Clipboard
   wl-clipboard
   ;; PolicyKit agent
   polkit-gnome
   ;; Portals (screen sharing, file pickers)
   xdg-desktop-portal xdg-desktop-portal-wlr xdg-desktop-portal-gtk
   ;; Theming
   qt5ct qt6ct qtsvg font-nerd-symbols breeze breeze-icons dexy-plasma-themes
   ;; Audio
   pavucontrol-qt
   ;; Document viewer
   zathura))

;; Base packages from asahi-sway-os (kitty excluded).
;; Use as the last argument to cons* in the packages field, replacing
;; (operating-system-packages asahi-plasma-os).
(define-public %sway-os-packages
  (remove (lambda (p) (equal? "kitty" (package-name p)))
          (operating-system-packages asahi-sway-os)))

;; To switch to Sway in configuration.scm:
;;   1. Add (sway) to use-modules
;;   2. Change (inherit asahi-plasma-os) to (inherit asahi-sway-os)
;;   3. Add (append %sway-packages ...) to the packages list
;;   4. Replace (operating-system-packages asahi-plasma-os) with %sway-os-packages
