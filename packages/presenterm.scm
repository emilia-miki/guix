(define-module (packages presenterm)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix build-system trivial)
  #:use-module (guix gexp)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (gnu packages base)
  #:use-module (gnu packages compression))

(define-public presenterm
  (package
    (name "presenterm")
    (version "0.16.1")
    (source
      (origin
        (method url-fetch)
        (uri (string-append
               "https://github.com/mfontanini/presenterm/releases/download/v"
               version "/presenterm-" version "-aarch64-unknown-linux-musl.tar.gz"))
        (sha256
          (base32 "1hv43h07kc200ingmm481pbqnx0j351lznlxmix5hqcxc123fg60"))))
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
                       (bin    (string-append out "/bin")))
                  (let ((tmp "/tmp/src"))
                    (mkdir-p bin)
                    (mkdir-p tmp)
                    (with-directory-excursion tmp
                      (invoke "tar" "--strip-components=1" "-xf" source)
                      (copy-file "presenterm" (string-append bin "/presenterm"))
                      (chmod (string-append bin "/presenterm") #o755)))))))
    (synopsis "Terminal slideshow presenter")
    (description
      "presenterm renders Markdown-based slideshows in the terminal, with
syntax highlighting, images via Kitty/sixel protocols, and slide transitions.")
    (home-page "https://github.com/mfontanini/presenterm")
    (license license:bsd-2)))
