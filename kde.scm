(define-module (kde)
  #:use-module (gnu packages gnome)
  #:use-module (gnu packages kde-graphics)
  #:use-module (gnu packages kde-internet)
  #:use-module (gnu packages kde-multimedia)
  #:use-module (gnu packages kde-pim)
  #:use-module (gnu packages kde-plasma)
  #:use-module (gnu packages kde-systemtools)
  #:use-module (gnu packages kde-utils)
  #:use-module (gnu packages lxqt)
  #:use-module (packages dexy-themes)
  #:export (%kde-system-packages))

;; KDE-specific system packages. To switch back to KDE from Sway in
;; configuration.scm:
;;   1. Replace (inherit asahi-sway-os) with (inherit asahi-plasma-os)
;;   2. Replace %sway-os-packages with (operating-system-packages asahi-plasma-os)
;;   3. Replace (append %sway-packages ...) with (append %kde-system-packages ...)
;;   4. In guix-home-config.scm: swap %sway-services for %kde-services
;;   5. In home/shell.scm: uncomment the kbuildsycoca6 line in sysconf
(define-public %kde-system-packages
  (list
   ;; file management
   dolphin
   ;; image viewing
   gwenview
   ;; document viewing
   okular
   papers
   ;; video
   haruna
   ;; KDE PIM suite
   kmail
   korganizer
   merkuro
   kaddressbook
   kaccounts-integration
   kaccounts-providers
   kalarm
   ;; messaging / feeds
   neochat
   konversation
   kget
   akregator
   ;; KDE tools
   ark
   kate
   kfind
   filelight
   kdegraphics-thumbnailers
   plasma-browser-integration
   ;; audio
   pavucontrol-qt
   ;; theming
   dexy-plasma-themes))