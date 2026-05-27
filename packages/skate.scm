(define-module (packages skate)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix build-system gnu)
  #:use-module ((guix licenses) #:prefix license:))

(define-public skate
  (package
    (name "skate")
    (version "1.0.1")
    (source
      (origin
        (method url-fetch)
        (uri "https://github.com/charmbracelet/skate/releases/download/v1.0.1/skate_1.0.1_Linux_arm64.tar.gz")
        (sha256
          (base32 "0994cxq30m4h35275mx34gnaj2wss3viqg17vv0vs86gia6yphs9"))))
    (build-system gnu-build-system)
    (arguments
      `(#:validate-runpath? #f
        #:strip-binaries? #f
        #:phases
        (modify-phases %standard-phases
          (delete 'configure)
          (delete 'build)
          (delete 'check)
          (replace 'install
            (lambda* (#:key outputs #:allow-other-keys)
              (let* ((out (assoc-ref outputs "out"))
                     (bin (string-append out "/bin")))
                (mkdir-p bin)
                (copy-file "skate"
                           (string-append bin "/skate"))
                (chmod (string-append bin "/skate") #o755)))))))
    (synopsis "Personal key-value store backed by Charm Cloud")
    (description "A personal key-value store for the command line.")
    (home-page "https://github.com/charmbracelet/skate")
    (license license:expat)))

skate
