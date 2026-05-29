(define-module (packages glow)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix build-system trivial)
  #:use-module (guix gexp)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (gnu packages base)
  #:use-module (gnu packages compression))

(define-public glow
  (package
    (name "glow")
    (version "2.1.2")
    (source
      (origin
        (method url-fetch)
        (uri (string-append
               "https://github.com/charmbracelet/glow/releases/download/v"
               version "/glow_" version "_Linux_arm64.tar.gz"))
        (sha256
          (base32 "1690jnvdpbc4vh2lgs00m4bvzv3w1qlphpcnvc4jkdshrgmsnqyg"))))
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
                       (tmp    "/tmp/src"))
                  (mkdir-p bin)
                  (mkdir-p tmp)
                  (with-directory-excursion tmp
                    (invoke "tar" "--strip-components=1" "-xf" source)
                    (copy-file "glow" (string-append bin "/glow"))
                    (chmod (string-append bin "/glow") #o755))))))
    (synopsis "Markdown reader for the terminal")
    (description "Renders Markdown in the terminal with glamour styles.")
    (home-page "https://github.com/charmbracelet/glow")
    (license license:expat)))
