(define-module (home env)
  #:use-module (gnu home services)
  #:use-module (gnu services)
  #:export (%env-services))

(define-public %env-services
  (list
   (simple-service 'env
                   home-environment-variables-service-type
                   '(;; editor
                     ("EDITOR" . "emacsclient -nw")
                     ("VISUAL" . "emacsclient -nw")

                     ;; wayland
                     ("QT_QPA_PLATFORM" . "wayland")
                     ("GDK_BACKEND"     . "wayland,x11")

                     ;; build tools
                     ("ACLOCAL_PATH" . "$HOME/.guix-home/profile/share/aclocal:/run/current-system/profile/share/aclocal")))))
