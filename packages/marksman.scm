(define-module (packages marksman)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix build-system trivial)
  #:use-module (guix gexp)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (gnu packages base)
  #:use-module (gnu packages elf)
  #:use-module (gnu packages gcc))

(define-public marksman
  (package
    (name "marksman")
    (version "2026-02-08")
    (source
      (origin
        (method url-fetch)
        (uri (string-append
               "https://github.com/artempyanykh/marksman/releases/download/"
               version "/marksman-linux-arm64"))
        (sha256
          (base32 "1yv2v6pkf4xz4794f7n0j8yigvsjkhdq54bc7s709y7p4x2i53nv"))))
    (build-system trivial-build-system)
    (inputs (list glibc `(,gcc "lib")))
    (native-inputs (list patchelf))
    (arguments
      (list #:modules '((guix build utils))
            #:builder
            #~(begin
                (use-modules (guix build utils))
                (let* ((source  (assoc-ref %build-inputs "source"))
                       (out     (assoc-ref %outputs "out"))
                       (bin     (string-append out "/bin"))
                       (binary  (string-append bin "/marksman"))
                       (glibc   (assoc-ref %build-inputs "glibc"))
                       (gcc-lib (assoc-ref %build-inputs "gcc"))
                       (interp  (string-append glibc "/lib/ld-linux-aarch64.so.1"))
                       (rpath   (string-join (list (string-append glibc "/lib")
                                                   (string-append gcc-lib "/lib"))
                                             ":")))
                  (mkdir-p bin)
                  (copy-file source binary)
                  (chmod binary #o755)
                  (invoke (string-append (assoc-ref %build-inputs "patchelf")
                                         "/bin/patchelf")
                          "--set-interpreter" interp binary)
                  (invoke (string-append (assoc-ref %build-inputs "patchelf")
                                         "/bin/patchelf")
                          "--set-rpath" rpath binary)))))
    (synopsis "Markdown LSP server")
    (description
      "Marksman is a language server for Markdown providing completion,
cross-references, diagnostics, and more.")
    (home-page "https://github.com/artempyanykh/marksman")
    (license license:expat)))
