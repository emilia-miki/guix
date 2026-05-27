(define-module (packages presenterm)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix build-system gnu)
  #:use-module ((guix licenses) #:prefix license:))

(define-public presenterm
  (package
    (name "presenterm")
    (version "0.16.1")
    (source
      (origin
        (method url-fetch)
        (uri "https://github.com/mfontanini/presenterm/releases/download/v0.16.1/presenterm-0.16.1-aarch64-unknown-linux-musl.tar.gz")
        (sha256
          (base32 "1hv43h07kc200ingmm481pbqnx0j351lznlxmix5hqcxc123fg60"))))
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
                (copy-file "presenterm"
                           (string-append bin "/presenterm"))
                (chmod (string-append bin "/presenterm") #o755)))))))
    (synopsis "Terminal slideshow presenter")
    (description
      "presenterm renders Markdown-based slideshows in the terminal, with
syntax highlighting, images via Kitty/sixel protocols, and slide transitions.")
    (home-page "https://github.com/mfontanini/presenterm")
    (license license:bsd-2)))

presenterm
