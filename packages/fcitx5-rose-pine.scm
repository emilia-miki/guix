(define-module (packages fcitx5-rose-pine)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix build-system copy)
  #:use-module ((guix licenses) #:prefix license:))

(define-public fcitx5-rose-pine
  (package
    (name "fcitx5-rose-pine")
    (version "0-unstable-2024-03-01")
    (source
      (origin
        (method url-fetch)
        (uri "https://github.com/rose-pine/fcitx5/archive/148de09929c2e2f948376bb23bc25d72006403bc.tar.gz")
        (sha256
          (base32 "1rnjgwl1j6pzn0jky0byd767nmkqn22f1sy0z2ijl9141c4x7lgd"))))
    (build-system copy-build-system)
    (arguments
      `(#:install-plan
        '(("." "share/fcitx5/themes"
           #:include-regexp ("rose-pine.*")))))
    (synopsis "Rosé Pine theme for Fcitx5")
    (description
      "Rosé Pine color theme for the Fcitx5 input method framework.")
    (home-page "https://github.com/rose-pine/fcitx5")
    (license license:expat)))
