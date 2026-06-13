(define-module (packages prebuilt)
  #:use-module (guix packages)
  #:use-module (guix build-system trivial)
  #:use-module (guix gexp)
  #:use-module (gnu packages base)
  #:use-module (gnu packages compression)
  #:export (make-prebuilt-binary))

(define* (make-prebuilt-binary name version source synopsis description home-page license
                               #:key (strip-components? #t))
  (package
   (name name)
   (version version)
   (source source)
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
                                            (if #$strip-components?
                                                (invoke "tar" "--strip-components=1" "-xf" source)
                                                (invoke "tar" "-xf" source))
                                            (copy-file #$name (string-append bin "/" #$name))
                                            (chmod (string-append bin "/" #$name) #o755)))))))
   (synopsis synopsis)
   (description description)
   (home-page home-page)
   (license license)))
