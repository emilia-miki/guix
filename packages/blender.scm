(define-module (packages blender)
  #:use-module (guix packages)
  #:use-module (guix gexp)
  #:use-module (guix utils)
  #:use-module (guix git-download)
  #:use-module (gnu packages graphics)
  #:use-module (gnu packages freedesktop)
  #:use-module (gnu packages image)
  #:use-module (gnu packages xdisorg))

; libheif 1.22.2 changed get_plane's stride parameter in a way that
; openimageio 2.5.x doesn't support yet; pin to the last compatible version.
(define libheif-1.19.7
  (package
    (inherit libheif)
    (version "1.19.7")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
               (url "https://github.com/strukturag/libheif")
               (commit "v1.19.7")))
        (file-name (git-file-name "libheif" "1.19.7"))
        (sha256
          (base32 "0n6pqmxa9cj9z54rcjqyb2gcp5h260x977zgwws47ddmx80blyhm"))))))

(define-public blender-wayland
  (let* ((rewrite (package-input-rewriting/spec
                    `(("libheif" . ,(const libheif-1.19.7)))))
         (blender* (rewrite blender)))
    (package
      (inherit blender*)
      ;; Keep upstream name so the store path matches and profiles don't conflict.
      (name "blender")
      (inputs
        (modify-inputs (package-inputs blender*)
          (append wayland wayland-protocols libxkbcommon)))
      (arguments
        (substitute-keyword-arguments (package-arguments blender*)
          ((#:configure-flags flags)
           #~(append #$flags (list "-DWITH_GHOST_WAYLAND=ON" "-DWITH_GHOST_X11=OFF"))))))))
