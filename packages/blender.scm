(define-module (packages blender)
  #:use-module (guix packages)
  #:use-module (guix gexp)
  #:use-module (guix utils)
  #:use-module (gnu packages graphics)
  #:use-module (gnu packages freedesktop)
  #:use-module (gnu packages xdisorg))

(define-public blender-wayland
  (package
    (inherit blender)
    ;; Keep upstream name so the store path matches and profiles don't conflict.
    (name "blender")
    (inputs
      (modify-inputs (package-inputs blender)
        (append wayland wayland-protocols libxkbcommon)))
    (arguments
      (substitute-keyword-arguments (package-arguments blender)
        ((#:configure-flags flags)
         #~(append #$flags (list "-DWITH_GHOST_WAYLAND=ON")))))))
