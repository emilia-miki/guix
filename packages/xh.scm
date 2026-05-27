(define-module (packages xh)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix build-system gnu)
  #:use-module ((guix licenses) #:prefix license:))

(define-public xh
  (package
    (name "xh")
    (version "0.25.3")
    (source
      (origin
        (method url-fetch)
        (uri "https://github.com/ducaale/xh/releases/download/v0.25.3/xh-v0.25.3-aarch64-unknown-linux-musl.tar.gz")
        (sha256
          (base32 "11isnmw692b65bb9hhrw4ykx0553w077ac4jv51007i891050bq4"))))
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
                (copy-file "xh"
                           (string-append bin "/xh"))
                (chmod (string-append bin "/xh") #o755)))))))
    (synopsis "Friendly HTTP client for the terminal")
    (description
      "xh is a fast, HTTPie-compatible HTTP client written in Rust.
It sends HTTP requests and renders responses with automatic JSON
pretty-printing and syntax highlighting.")
    (home-page "https://github.com/ducaale/xh")
    (license license:expat)))

xh
