(define-module (packages wiki-tui)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix build-system trivial)
  #:use-module (guix gexp)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (gnu packages base)
  #:use-module (gnu packages compression)
  #:use-module (gnu packages elf)
  #:use-module (gnu packages gcc)
  #:use-module (gnu packages tls))

(define-public wiki-tui
  (package
    (name "wiki-tui")
    (version "0.9.2")
    (source
      (origin
        (method url-fetch)
        (uri "https://github.com/Builditluc/wiki-tui/releases/download/v0.9.2/wiki-tui-linux.tar.gz")
        (sha256
          (base32 "0ny00jllqjvymdrvihzd9dz462kfa2ymirm6ic1k3j3wxfni81wa"))))
    (build-system trivial-build-system)
    (inputs (list glibc `(,gcc "lib") openssl))
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
                       (binary  (string-append bin "/wiki-tui"))
                       (glibc   (assoc-ref %build-inputs "glibc"))
                       (gcc-lib (assoc-ref %build-inputs "gcc"))
                       (ssl     (assoc-ref %build-inputs "openssl"))
                       (interp  (string-append glibc "/lib/ld-linux-aarch64.so.1"))
                       (rpath   (string-join (list (string-append glibc "/lib")
                                                   (string-append gcc-lib "/lib")
                                                   (string-append ssl "/lib"))
                                             ":")))
                  (let ((tmp "/tmp/src"))
                    (mkdir-p bin)
                    (mkdir-p tmp)
                    (with-directory-excursion tmp
                      (invoke "tar" "-xf" source)
                      (copy-file "wiki-tui" binary)))
                  (chmod binary #o755)
                  (invoke "patchelf" "--set-interpreter" interp binary)
                  (invoke "patchelf" "--set-rpath" rpath binary)))))
    (synopsis "Browse Wikipedia from the terminal")
    (description
      "wiki-tui is a simple and easy to use Wikipedia text user interface.")
    (home-page "https://github.com/Builditluc/wiki-tui")
    (license license:expat)))
