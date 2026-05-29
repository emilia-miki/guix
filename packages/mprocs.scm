(define-module (packages mprocs)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix build-system trivial)
  #:use-module (guix gexp)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (gnu packages base)
  #:use-module (gnu packages compression))

(define-public mprocs
  (package
    (name "mprocs")
    (version "0.9.3")
    (source
      (origin
        (method url-fetch)
        (uri (string-append
               "https://github.com/pvolok/mprocs/releases/download/v"
               version "/mprocs-" version "-linux-aarch64-musl.tar.gz"))
        (sha256
          (base32 "15qbx44ifvzgvc7pk4yp0a70rhcfwjdpv8mhx8hga8c0i7krvi2d"))))
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
                      (invoke "tar" "-xf" source)
                      (copy-file "mprocs" (string-append bin "/mprocs"))
                      (chmod (string-append bin "/mprocs") #o755)))))))
    (synopsis "TUI for running multiple processes simultaneously")
    (description
      "mprocs runs multiple commands in parallel and shows their output in
split panes within a terminal UI.  Useful for dev workflows that require
multiple processes running at once.")
    (home-page "https://github.com/pvolok/mprocs")
    (license license:expat)))
