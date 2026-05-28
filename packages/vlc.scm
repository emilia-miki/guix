(define-module (packages vlc)
  #:use-module (guix packages)
  #:use-module (guix utils)
  #:use-module (gnu packages qt)
  #:use-module (gnu packages video))

(define-public vlc-wayland
  (package
    (inherit vlc)
    (name "vlc")
    (inputs
      (modify-inputs (package-inputs vlc)
        (append qtwayland-5)))))

vlc-wayland
