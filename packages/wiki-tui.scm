(define-module (packages wiki-tui)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix build-system gnu)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (gnu packages base)
  #:use-module (gnu packages elf)
  #:use-module (gnu packages gcc)
  #:use-module (gnu packages tls))

(define-public wiki-tui
  (package
    (name "wiki-tui")
    (version "0.9.2")
    (source
      (origin
        (method url-fetch)
        (uri "https://github.com/Builditluc/wiki-tui/releases/download/v0.9.2/wiki-tui-linux.tar.gz")
        (sha256
          (base32 "0ny00jllqjvymdrvihzd9dz462kfa2ymirm6ic1k3j3wxfni81wa"))))
    (build-system gnu-build-system)
    (inputs
      (list glibc `(,gcc "lib") openssl))
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
                     (binary  (string-append bin "/wiki-tui"))
                     (glibc   (assoc-ref inputs "glibc"))
                     (gcc-lib (assoc-ref inputs "gcc"))
                     (ssl     (assoc-ref inputs "openssl"))
                     (interp  (string-append glibc "/lib/ld-linux-aarch64.so.1"))
                     (rpath   (string-join (list (string-append glibc "/lib")
                                                 (string-append gcc-lib "/lib")
                                                 (string-append ssl "/lib"))
                                           ":")))
                (mkdir-p bin)
                (copy-file "wiki-tui" binary)
                (invoke "patchelf" "--set-interpreter" interp binary)
                (invoke "patchelf" "--set-rpath" rpath binary)))))))
    (synopsis "Browse Wikipedia from the terminal")
    (description
      "wiki-tui is a simple and easy to use Wikipedia text user interface.")
    (home-page "https://github.com/Builditluc/wiki-tui")
    (license license:expat)))

wiki-tui
