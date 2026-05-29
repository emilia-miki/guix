(define-module (packages sddm-qylock)
  #:use-module (guix packages)
  #:use-module (guix build-system copy)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix download))

(define-public sddm-qylock-enfield
  (package
    (name "sddm-qylock-enfield")
    (version "0.0.0-0.cde4d11")
    (source
      (origin
        (method url-fetch)
        (uri (string-append
               "https://github.com/darkkal44/qylock/archive/"
               "cde4d11e9e3d385620becdc877a0521e40a55e47.tar.gz"))
        (sha256
          (base32 "0jczxzgmp481mv30z092nw9wqa3h9m4kzsnjxnprvjgm7krsq6m3"))))
    (build-system copy-build-system)
    (arguments
      `(#:install-plan
        '(("themes/enfield" "/share/sddm/themes/enfield"))))
    (synopsis "Qylock enfield SDDM theme")
    (description
      "The enfield variant of the qylock SDDM theme collection,
featuring an animated video background with a stylized login interface.")
    (home-page "https://github.com/darkkal44/qylock")
    (license license:gpl3)))
