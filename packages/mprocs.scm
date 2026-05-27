(define-module (packages mprocs)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix build-system gnu)
  #:use-module ((guix licenses) #:prefix license:))

(define-public mprocs
  (package
    (name "mprocs")
    (version "0.9.3")
    (source
      (origin
        (method url-fetch)
        (uri "https://github.com/pvolok/mprocs/releases/download/v0.9.3/mprocs-0.9.3-linux-aarch64-musl.tar.gz")
        (sha256
          (base32 "15qbx44ifvzgvc7pk4yp0a70rhcfwjdpv8mhx8hga8c0i7krvi2d"))))
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
                (copy-file "mprocs"
                           (string-append bin "/mprocs"))
                (chmod (string-append bin "/mprocs") #o755)))))))
    (synopsis "TUI for running multiple processes simultaneously")
    (description
      "mprocs runs multiple commands in parallel and shows their output in
split panes within a terminal UI.  Useful for dev workflows that require
multiple processes running at once.")
    (home-page "https://github.com/pvolok/mprocs")
    (license license:expat)))

mprocs
