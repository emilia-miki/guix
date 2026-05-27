(define-module (packages yazi)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix build-system gnu)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (gnu packages base)
  #:use-module (gnu packages compression)
  #:use-module (gnu packages elf)
  #:use-module (gnu packages gcc))

(define-public yazi
  (package
    (name "yazi")
    (version "26.5.6")
    (source
      (origin
        (method url-fetch)
        (uri "https://github.com/sxyazi/yazi/releases/download/v26.5.6/yazi-aarch64-unknown-linux-gnu.zip")
        (sha256
          (base32 "1qg1533ia0wvi76iif1mk2lpkcyh9cdll3zx0djwgi3z3sb0g2y3"))))
    (build-system gnu-build-system)
    (inputs
      (list glibc `(,gcc "lib")))
    (native-inputs
      (list patchelf unzip))
    (arguments
      `(#:validate-runpath? #f
        #:strip-binaries? #f
        #:phases
        (modify-phases %standard-phases
          (delete 'configure)
          (delete 'build)
          (delete 'check)
          (replace 'install
            (lambda* (#:key inputs outputs #:allow-other-keys)
              (let* ((out     (assoc-ref outputs "out"))
                     (bin     (string-append out "/bin"))
                     (binary  (string-append bin "/yazi"))
                     (glibc   (assoc-ref inputs "glibc"))
                     (gcc-lib (assoc-ref inputs "gcc"))
                     (interp  (string-append glibc "/lib/ld-linux-aarch64.so.1"))
                     (rpath   (string-join (list (string-append glibc "/lib")
                                                 (string-append gcc-lib "/lib"))
                                           ":")))
                (mkdir-p bin)
                (copy-file "yazi" binary)
                (invoke "patchelf" "--set-interpreter" interp binary)
                (invoke "patchelf" "--set-rpath" rpath binary)))))))
    (synopsis "Terminal file manager")
    (description
      "Yazi is a blazing fast terminal file manager written in Rust,
based on async I/O.")
    (home-page "https://github.com/sxyazi/yazi")
    (license license:expat)))

yazi
