(define-module (packages skate)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix build-system trivial)
  #:use-module (guix gexp)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (gnu packages base)
  #:use-module (gnu packages compression))

(define-public skate
  (package
    (name "skate")
    (version "1.0.1")
    (source
      (origin
        (method url-fetch)
        (uri (string-append
               "https://github.com/charmbracelet/skate/releases/download/v"
               version "/skate_" version "_Linux_arm64.tar.gz"))
        (sha256
          (base32 "0994cxq30m4h35275mx34gnaj2wss3viqg17vv0vs86gia6yphs9"))))
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
                      (copy-file "skate" (string-append bin "/skate"))
                      (chmod (string-append bin "/skate") #o755)))))))
    (synopsis "Personal key-value store backed by Charm Cloud")
    (description "A personal key-value store for the command line.")
    (home-page "https://github.com/charmbracelet/skate")
    (license license:expat)))
