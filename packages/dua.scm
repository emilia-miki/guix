(define-module (packages dua)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix build-system gnu)
  #:use-module ((guix licenses) #:prefix license:))

(define-public dua
  (package
    (name "dua")
    (version "2.34.0")
    (source
      (origin
        (method url-fetch)
        (uri "https://github.com/Byron/dua-cli/releases/download/v2.34.0/dua-v2.34.0-aarch64-unknown-linux-musl.tar.gz")
        (sha256
          (base32 "14qq5g8j25kdyy6kbfl90029dbwmafhybb30kbyjrw8smbihfynp"))))
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
                (copy-file "dua"
                           (string-append bin "/dua"))
                (chmod (string-append bin "/dua") #o755)))))))
    (synopsis "Interactive disk usage analyzer")
    (description
      "dua (Disk Usage Analyzer) shows disk space used by files and
directories in a fast interactive TUI, allowing navigation and deletion.")
    (home-page "https://github.com/Byron/dua-cli")
    (license license:expat)))

dua
