(define-module (sway)
  #:use-module (asahi guix systems sway)
  #:use-module (gnu packages image)
  #:use-module (gnu packages pdf)
  #:use-module (gnu packages wm)
  #:use-module (gnu system)
  #:use-module (guix packages)
  #:use-module (srfi srfi-1)
  #:export (%sway-packages %sway-os-packages))

;; Sway-specific packages. Add to the packages list in configuration.scm.
(define-public %sway-packages
  (list wmenu swayidle swaylock waybar grim slurp mako zathura))

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
