(define-module (packages dust)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix build-system trivial)
  #:use-module (guix gexp)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (gnu packages base)
  #:use-module (gnu packages compression)
  #:use-module (gnu packages elf)
  #:use-module (gnu packages gcc))

(define-public dust
  (package
    (name "dust")
    (version "1.2.4")
    (source
      (origin
        (method url-fetch)
        (uri (string-append
               "https://github.com/bootandy/dust/releases/download/v"
               version "/dust-v" version "-aarch64-unknown-linux-gnu.tar.gz"))
        (sha256
          (base32 "0v9nbv35yq38a8jf2w09j0xxw0xmc29mqlijn42ab01acrp2j0qr"))))
    (build-system trivial-build-system)
    (inputs (list glibc `(,gcc "lib")))
    (native-inputs (list patchelf tar gzip))
    (arguments
      (list #:modules '((guix build utils))
            #:builder
            #~(begin
                (use-modules (guix build utils))
                (setenv "PATH" (string-append
                                (assoc-ref %build-inputs "tar") "/bin:"
                                (assoc-ref %build-inputs "gzip") "/bin:"
                                (assoc-ref %build-inputs "patchelf") "/bin"))
                (let* ((source  (assoc-ref %build-inputs "source"))
                       (out     (assoc-ref %outputs "out"))
                       (bin     (string-append out "/bin"))
                       (binary  (string-append bin "/dust"))
                       (glibc   (assoc-ref %build-inputs "glibc"))
                       (gcc-lib (assoc-ref %build-inputs "gcc"))
                       (interp  (string-append glibc "/lib/ld-linux-aarch64.so.1"))
                       (rpath   (string-join (list (string-append glibc "/lib")
                                                   (string-append gcc-lib "/lib"))
                                             ":")))
                  (let ((tmp "/tmp/src"))
                    (mkdir-p bin)
                    (mkdir-p tmp)
                    (with-directory-excursion tmp
                      (invoke "tar" "--strip-components=1" "-xf" source)
                      (copy-file "dust" binary)))
                  (chmod binary #o755)
                  (invoke "patchelf" "--set-interpreter" interp binary)
                  (invoke "patchelf" "--set-rpath" rpath binary)))))
    (synopsis "More intuitive version of du")
    (description
      "Dust gives an instant overview of which directories are using disk space.")
    (home-page "https://github.com/bootandy/dust")
    (license license:asl2.0)))
