(define-module (packages nyxt)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix gexp)
  #:use-module (guix utils)
  #:use-module (gnu packages lisp-xyz)
  #:use-module (nongnu packages electron)
  #:use-module (sijo packages nyxt)
  #:use-module (ice-9 match))

;;; ── aarch64 cl-autowrap / sdl2-ttf spec-file patches ─────────────────────────
;;; cl-autowrap ships pre-generated c2ffi spec files for known triples.
;;; aarch64-pc-linux-gnu is missing for libffi and SDL2_ttf; without it the
;;; build tries to run c2ffi at compile time and fails.

(define libffi-aarch64-spec
  (local-file "files/libffi.aarch64-pc-linux-gnu.spec"))

(define sdl2-ttf-aarch64-spec
  (local-file "files/SDL2_ttf.aarch64-pc-linux-gnu.spec"))

(define (add-aarch64-spec-phase phases spec dest)
  #~(modify-phases #$phases
      (add-after 'unpack 'add-aarch64-spec
        (lambda _
          (copy-file #$spec #$dest)))))

(define sbcl-cl-autowrap-aarch64
  (package
    (inherit sbcl-cl-autowrap)
    (arguments
      (substitute-keyword-arguments (package-arguments sbcl-cl-autowrap)
        ((#:phases phases)
         (add-aarch64-spec-phase
           phases
           libffi-aarch64-spec
           "autowrap-libffi/spec/libffi.aarch64-pc-linux-gnu.spec"))))))

(define rewrite-autowrap
  (package-input-rewriting/spec
    `(("sbcl-cl-autowrap" . ,(const sbcl-cl-autowrap-aarch64)))))

(define sbcl-sdl2-ttf-aarch64
  (let ((base (rewrite-autowrap sbcl-sdl2-ttf)))
    (package
      (inherit base)
      (arguments
        (substitute-keyword-arguments (package-arguments base)
          ((#:phases phases)
           (add-aarch64-spec-phase
             phases
             sdl2-ttf-aarch64-spec
             "src/spec/SDL2_ttf.aarch64-pc-linux-gnu.spec")))))))

;;; ── electron-36 extended with aarch64 ────────────────────────────────────────
;;; The nongnu package already selects the right upstream URL for arm64 via
;;; %current-system, but only carries the x86_64 hash and restricts
;;; supported-systems accordingly.

(define electron-36-aarch64
  (package
    (inherit electron-36)
    (supported-systems '("x86_64-linux" "aarch64-linux"))
    (source
      (origin
        (method url-fetch/zipbomb)
        (uri (string-append
               "https://github.com/electron/electron/releases/download/v"
               (package-version electron-36)
               "/electron-v" (package-version electron-36) "-"
               (match (%current-system)
                 ("aarch64-linux" "linux-arm64")
                 (_ "linux-x64"))
               ".zip"))
        (sha256 (base32
                  (match (%current-system)
                    ("aarch64-linux"
                     "09xbgyjfg0ka4mql6gc2fii89mh8xl6ss2wyqc3vjxi2kw3s7sgp")
                    (_
                     "05l6cab4cq4cy5ajf8gz26h5s65dnvbzgmlc1wr1d0fnxr53dmjj"))))))))

;;; ── nyxt with all aarch64 rewrites ───────────────────────────────────────────

(define-public nyxt
  (package
    (inherit
      ((package-input-rewriting/spec
         `(("sbcl-cl-autowrap" . ,(const sbcl-cl-autowrap-aarch64))
           ("sbcl-sdl2-ttf"    . ,(const sbcl-sdl2-ttf-aarch64))
           ("electron"         . ,(const electron-36-aarch64))))
       nyxt4))
    (supported-systems '("x86_64-linux" "aarch64-linux"))))
