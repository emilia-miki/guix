(define-module (packages audacity)
  #:use-module (guix packages)
  #:use-module (guix utils)
  #:use-module (guix gexp)
  #:use-module (gnu packages audio))

(define-public audacity-wayland
  (package
    (inherit audacity)
    ;; Keep upstream name so the store path matches and profiles don't conflict.
    (name "audacity")
    (arguments
      (substitute-keyword-arguments (package-arguments audacity)
        ((#:phases phases)
         #~(modify-phases #$phases
             (add-after 'install 'force-wayland
               (lambda* (#:key outputs #:allow-other-keys)
                 (substitute* (string-append (assoc-ref outputs "out")
                                             "/share/applications/audacity.desktop")
                   (("GDK_BACKEND=x11")
                    "GDK_BACKEND=wayland"))))))))))
