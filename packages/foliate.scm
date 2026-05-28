(define-module (packages foliate)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix build-system meson)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (gnu packages glib)
  #:use-module (gnu packages gnome)
  #:use-module (gnu packages gtk)
  #:use-module (gnu packages javascript)
  #:use-module (gnu packages freedesktop)
  #:use-module (gnu packages gettext)
  #:use-module (gnu packages pkg-config)
  #:use-module (gnu packages webkit))

(define-public foliate
  (package
    (name "foliate")
    (version "3.3.0")
    (source
      (origin
        (method url-fetch)
        (uri "https://github.com/johnfactotum/foliate/releases/download/3.3.0/com.github.johnfactotum.Foliate-3.3.0.tar.xz")
        (sha256
          (base32 "0wmn9nf4jhjwkwdh8nlacfzpxdz9vx3p3mi5mxbjwsj26h5crl09"))))
    (build-system meson-build-system)
    (arguments
      `(#:configure-flags '("-Dcheck_runtime_deps=false")
        #:phases
        (modify-phases %standard-phases
          (add-after 'install 'wrap-typelibs
            (lambda* (#:key inputs outputs #:allow-other-keys)
              (let* ((out (assoc-ref outputs "out"))
                     (dirs (let lp ((in inputs) (acc '()))
                             (if (null? in)
                                 (reverse acc)
                                 (let ((d (string-append (cdar in)
                                                         "/lib/girepository-1.0")))
                                   (lp (cdr in)
                                       (if (file-exists? d)
                                           (cons d acc)
                                           acc))))))
                     (gi-path (string-join dirs ":")))
                (wrap-program (string-append out "/bin/foliate")
                  `("GI_TYPELIB_PATH" ":" prefix (,gi-path)))))))))
    (native-inputs
      (list pkg-config glib `(,glib "bin") gnu-gettext `(,gtk "bin") desktop-file-utils))
    (inputs
      (list gjs gtk libadwaita webkitgtk))
    (synopsis "E-book reader for GNOME")
    (description
      "Foliate is a simple and modern GTK e-book viewer written in GJS.")
    (home-page "https://github.com/johnfactotum/foliate")
    (license license:gpl3+)))

foliate
