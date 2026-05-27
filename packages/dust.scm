(define-module (packages dust)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix build-system gnu)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (gnu packages base)
  #:use-module (gnu packages elf)
  #:use-module (gnu packages gcc))

(define-public dust
  (package
    (name "dust")
    (version "1.2.4")
    (source
      (origin
        (method url-fetch)
        (uri "https://github.com/bootandy/dust/releases/download/v1.2.4/dust-v1.2.4-aarch64-unknown-linux-gnu.tar.gz")
        (sha256
          (base32 "0v9nbv35yq38a8jf2w09j0xxw0xmc29mqlijn42ab01acrp2j0qr"))))
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
          (delete 'configure)
          (delete 'build)
          (delete 'check)
          (replace 'install
            (lambda* (#:key inputs outputs #:allow-other-keys)
              (let* ((out     (assoc-ref outputs "out"))
                     (bin     (string-append out "/bin"))
                     (binary  (string-append bin "/dust"))
                     (glibc   (assoc-ref inputs "glibc"))
                     (gcc-lib (assoc-ref inputs "gcc"))
                     (interp  (string-append glibc "/lib/ld-linux-aarch64.so.1"))
                     (rpath   (string-join (list (string-append glibc "/lib")
                                                 (string-append gcc-lib "/lib"))
                                           ":")))
                (mkdir-p bin)
                (copy-file "dust" binary)
                (invoke "patchelf" "--set-interpreter" interp binary)
                (invoke "patchelf" "--set-rpath" rpath binary)))))))
    (synopsis "More intuitive version of du")
    (description
      "Dust gives an instant overview of which directories are using disk space.")
    (home-page "https://github.com/bootandy/dust")
    (license license:asl2.0)))

dust
