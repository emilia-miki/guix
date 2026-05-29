(define-module (packages dua)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix build-system trivial)
  #:use-module (guix gexp)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (gnu packages base)
  #:use-module (gnu packages compression))

(define-public dua
  (package
    (name "dua")
    (version "2.34.0")
    (source
      (origin
        (method url-fetch)
        (uri (string-append
               "https://github.com/Byron/dua-cli/releases/download/v"
               version "/dua-v" version "-aarch64-unknown-linux-musl.tar.gz"))
        (sha256
          (base32 "14qq5g8j25kdyy6kbfl90029dbwmafhybb30kbyjrw8smbihfynp"))))
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
                      (copy-file "dua" (string-append bin "/dua"))
                      (chmod (string-append bin "/dua") #o755)))))))
    (synopsis "Interactive disk usage analyzer")
    (description
      "dua (Disk Usage Analyzer) shows disk space used by files and
directories in a fast interactive TUI, allowing navigation and deletion.")
    (home-page "https://github.com/Byron/dua-cli")
    (license license:expat)))
