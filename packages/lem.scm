(define-module (packages lem)
  #:use-module (guix packages)
  #:use-module (guix gexp)
  #:use-module (guix utils)
  #:use-module (gnu packages lisp-xyz)
  #:use-module ((gnu packages text-editors) #:select ((lem . upstream-lem))))

(define libffi-aarch64-spec
  (local-file "files/libffi.aarch64-pc-linux-gnu.spec"))

(define sdl-image-aarch64-spec
  (local-file "files/SDL_image.aarch64-pc-linux-gnu.spec"))

(define sdl2-ttf-aarch64-spec
  (local-file "files/SDL2_ttf.aarch64-pc-linux-gnu.spec"))

(define (add-aarch64-spec-phase phases spec dest)
  #~(modify-phases #$phases
      (add-after 'unpack 'add-aarch64-spec
        (lambda _
          (copy-file #$spec #$dest)))))

;; Patched cl-autowrap with the aarch64-pc-linux-gnu libffi spec added.
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

;; Rewriter that replaces sbcl-cl-autowrap everywhere — applied to each
;; patched SDL package so their own cl-autowrap dependency is correct.
(define rewrite-autowrap
  (package-input-rewriting/spec
    `(("sbcl-cl-autowrap" . ,(const sbcl-cl-autowrap-aarch64)))))

(define sbcl-sdl2-image-aarch64
  (let ((base (rewrite-autowrap sbcl-sdl2-image)))
    (package
      (inherit base)
      (arguments
        (substitute-keyword-arguments (package-arguments base)
          ((#:phases phases)
           (add-aarch64-spec-phase
             phases
             sdl-image-aarch64-spec
             "src/spec/SDL_image.aarch64-pc-linux-gnu.spec")))))))

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

(define-public lem
  (let ((rewrite (package-input-rewriting/spec
                   `(("sbcl-cl-autowrap" . ,(const sbcl-cl-autowrap-aarch64))
                     ("sbcl-sdl2-image"  . ,(const sbcl-sdl2-image-aarch64))
                     ("sbcl-sdl2-ttf"    . ,(const sbcl-sdl2-ttf-aarch64))))))
    (rewrite upstream-lem)))
