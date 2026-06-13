(define-module (packages rose-pine-kvantum)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix gexp)
  #:use-module (guix build-system trivial)
  #:use-module (gnu packages base)
  #:use-module (gnu packages compression)
  #:use-module ((guix licenses) #:prefix license:))

(define-public rose-pine-kvantum
  (package
   (name "rose-pine-kvantum")
   (version "0-1.816e338")
   (source
    (origin
     (method url-fetch)
     (uri "https://github.com/rose-pine/kvantum/archive/816e3383d73f44c32423d6b43ce1dc66a528cefd.tar.gz")
     (file-name (string-append name "-" version ".tar.gz"))
     (sha256
      (base32 "032vb6rbml7kxw56sq8y127pmh9pvfdrpa8n2y7q91z0bkx3rm4r"))))
   (build-system trivial-build-system)
   (native-inputs (list tar gzip))
   (arguments
    (list #:builder
          (with-imported-modules '((guix build utils))
                                 #~(begin
                                     (use-modules (guix build utils) (ice-9 ftw) (srfi srfi-1))
                                     (setenv "PATH" (string-append #$tar "/bin:" #$gzip "/bin"))
                                     (let* ((tar-bin (string-append #$tar "/bin/tar"))
                                            (kvdir   (string-append #$output "/share/Kvantum"))
                                            (tmpdir  "/tmp/source"))
                                       (mkdir-p kvdir)
                                       (mkdir-p tmpdir)
                                       (invoke tar-bin "-xzf" #$source "-C" tmpdir "--strip-components=1")
                                       (for-each
                                        (lambda (name)
                                          (invoke tar-bin "-xzf"
                                                  (string-append tmpdir "/dist/" name)
                                                  "-C" kvdir))
                                        (filter (lambda (f) (string-suffix? ".tar.gz" f))
                                                (scandir (string-append tmpdir "/dist")))))))))
   (home-page "https://github.com/rose-pine/kvantum")
   (synopsis "Rosé Pine Kvantum theme")
   (description "Kvantum theme in the Rosé Pine color palette.
All variants (main, moon, dawn) and accent colors are included under
share/Kvantum/rose-pine-{variant}-{accent}/.")
   (license license:expat)))
