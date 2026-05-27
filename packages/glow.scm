(define-module (packages glow)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix build-system gnu)
  #:use-module ((guix licenses) #:prefix license:))

(define-public glow
  (package
    (name "glow")
    (version "2.1.2")
    (source
      (origin
        (method url-fetch)
        (uri "https://github.com/charmbracelet/glow/releases/download/v2.1.2/glow_2.1.2_Linux_arm64.tar.gz")
        (sha256
          (base32 "1690jnvdpbc4vh2lgs00m4bvzv3w1qlphpcnvc4jkdshrgmsnqyg"))))
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
                (copy-file "glow"
                           (string-append bin "/glow"))
                (chmod (string-append bin "/glow") #o755)))))))
    (synopsis "Markdown reader for the terminal")
    (description "Renders Markdown in the terminal with glamour styles.")
    (home-page "https://github.com/charmbracelet/glow")
    (license license:expat)))

glow
