(define-module (packages vlc)
  #:use-module (guix packages)
  #:use-module (guix utils)
  #:use-module (gnu packages qt)
  #:use-module (gnu packages video))

(define-public vlc-wayland
  (package
    (inherit vlc)
    ;; Keep upstream name so the store path matches and profiles don't conflict.
    (name "vlc")
    (inputs
      (modify-inputs (package-inputs vlc)
        (append qtwayland-5)))))
