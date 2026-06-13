(define-module (packages libreoffice)
  #:use-module (guix packages)
  #:use-module (guix gexp)
  #:use-module (guix utils)
  #:use-module (gnu packages libreoffice))

;; LibreOffice with firebird disabled — the upstream build includes
;; --enable-firebird-sdbc which triggers a firebird 3.0 build that crashes
;; with SIGBUS on aarch64 (misaligned atomic operations in fb_atomic.h).
;; Disabling firebird-sdbc drops the embedded Firebird connector for
;; LibreOffice Base, but all other components build and work fine.
(define-public libreoffice-aarch64
  (package
    (inherit libreoffice)
    (name "libreoffice")
    (inputs
      (modify-inputs (package-inputs libreoffice)
        (delete "firebird")))
    (arguments
      (substitute-keyword-arguments (package-arguments libreoffice)
        ((#:configure-flags flags)
         #~(map (lambda (f)
                  (if (string=? f "--enable-firebird-sdbc")
                      "--disable-firebird-sdbc"
                      f))
                #$flags))))))
