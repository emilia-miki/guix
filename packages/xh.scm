(define-module (packages xh)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix build-system trivial)
  #:use-module (guix gexp)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (gnu packages base)
  #:use-module (gnu packages compression))

(define-public xh
  (package
    (name "xh")
    (version "0.25.3")
    (source
      (origin
        (method url-fetch)
        (uri (string-append
               "https://github.com/ducaale/xh/releases/download/v"
               version "/xh-v" version "-aarch64-unknown-linux-musl.tar.gz"))
        (sha256
          (base32 "11isnmw692b65bb9hhrw4ykx0553w077ac4jv51007i891050bq4"))))
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
                      (copy-file "xh" (string-append bin "/xh"))
                      (chmod (string-append bin "/xh") #o755)))))))
    (synopsis "Friendly HTTP client for the terminal")
    (description
      "xh is a fast, HTTPie-compatible HTTP client written in Rust.
It sends HTTP requests and renders responses with automatic JSON
pretty-printing and syntax highlighting.")
    (home-page "https://github.com/ducaale/xh")
    (license license:expat)))
