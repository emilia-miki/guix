(define-module (packages uutils-coreutils)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix build-system gnu)
  #:use-module ((guix licenses) #:prefix license:))

(define-public uutils-coreutils
  (package
    (name "uutils-coreutils")
    (version "0.8.0")
    (source
      (origin
        (method url-fetch)
        (uri "https://github.com/uutils/coreutils/releases/download/0.8.0/coreutils-0.8.0-aarch64-unknown-linux-musl.tar.gz")
        (sha256
          (base32 "09dprhwdk3jj2jqix15vp5i9zj12fihv0a13mk2yrpl4yw7214p5"))))
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
                     (bin (string-append out "/bin"))
                     (binary (string-append bin "/coreutils")))
                (mkdir-p bin)
                (copy-file "coreutils" binary)
                (chmod binary #o755)
                (let ((tools (string-split
                              (with-output-to-string
                                (lambda ()
                                  (invoke binary "--list")))
                              #\newline)))
                  (for-each
                   (lambda (tool)
                     (unless (string-null? tool)
                       (symlink "coreutils"
                                (string-append bin "/" tool))))
                   tools))))))))
    (synopsis "Cross-platform Rust reimplementation of GNU coreutils")
    (description
      "uutils coreutils is a cross-platform reimplementation of the GNU
coreutils in Rust, distributed as a single multicall binary.")
    (home-page "https://github.com/uutils/coreutils")
    (license license:expat)))

uutils-coreutils
