(define-module (packages marksman)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix build-system gnu)
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
        (uri "https://github.com/artempyanykh/marksman/releases/download/2026-02-08/marksman-linux-arm64")
        (sha256
          (base32 "1yv2v6pkf4xz4794f7n0j8yigvsjkhdq54bc7s709y7p4x2i53nv"))))
    (build-system gnu-build-system)
    (inputs
      (list glibc `(,gcc "lib")))
    (native-inputs
      (list patchelf))
    (arguments
      `(#:validate-runpath? #f
        #:strip-binaries? #f
        #:phases
        (modify-phases %standard-phases
          (replace 'unpack
            (lambda* (#:key source #:allow-other-keys)
              (copy-file source "marksman")
              (chmod "marksman" #o755)))
          (delete 'configure)
          (delete 'build)
          (delete 'check)
          (replace 'install
            (lambda* (#:key inputs outputs #:allow-other-keys)
              (let* ((out     (assoc-ref outputs "out"))
                     (bin     (string-append out "/bin"))
                     (binary  (string-append bin "/marksman"))
                     (glibc   (assoc-ref inputs "glibc"))
                     (gcc-lib (assoc-ref inputs "gcc"))
                     (interp  (string-append glibc "/lib/ld-linux-aarch64.so.1"))
                     (rpath   (string-join (list (string-append glibc "/lib")
                                                 (string-append gcc-lib "/lib"))
                                           ":")))
                (mkdir-p bin)
                (copy-file "marksman" binary)
                (invoke "patchelf" "--set-interpreter" interp binary)
                (invoke "patchelf" "--set-rpath" rpath binary)))))))
    (synopsis "Markdown LSP server")
    (description
      "Marksman is a language server for Markdown providing completion,
cross-references, diagnostics, and more.")
    (home-page "https://github.com/artempyanykh/marksman")
    (license license:expat)))

marksman
