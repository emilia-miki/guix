(define-module (packages uutils-coreutils)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix build-system trivial)
  #:use-module (guix gexp)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (gnu packages base)
  #:use-module (gnu packages compression))

(define-public uutils-coreutils
  (package
    (name "uutils-coreutils")
    (version "0.8.0")
    (source
      (origin
        (method url-fetch)
        (uri (string-append
               "https://github.com/uutils/coreutils/releases/download/"
               version "/coreutils-" version "-aarch64-unknown-linux-musl.tar.gz"))
        (sha256
          (base32 "09dprhwdk3jj2jqix15vp5i9zj12fihv0a13mk2yrpl4yw7214p5"))))
    (build-system trivial-build-system)
    (native-inputs (list tar gzip))
    (arguments
      (list #:modules '((guix build utils))
            #:builder
            #~(begin
                (use-modules (guix build utils))
                (setenv "PATH" (string-append
                                (assoc-ref %build-inputs "tar") "/bin:"
                                (assoc-ref %build-inputs "gzip") "/bin"))
                (let* ((source (assoc-ref %build-inputs "source"))
                       (out    (assoc-ref %outputs "out"))
                       (bin    (string-append out "/bin"))
                       (binary (string-append bin "/coreutils")))
                  (let ((tmp "/tmp/src"))
                    (mkdir-p bin)
                    (mkdir-p tmp)
                    (with-directory-excursion tmp
                      (invoke "tar" "--strip-components=1" "-xf" source)
                      (copy-file "coreutils" binary))
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
                        tools)))))))
    (synopsis "Cross-platform Rust reimplementation of GNU coreutils")
    (description
      "uutils coreutils is a cross-platform reimplementation of the GNU
coreutils in Rust, distributed as a single multicall binary.")
    (home-page "https://github.com/uutils/coreutils")
    (license license:expat)))
