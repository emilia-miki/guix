(define-module (packages relax-player)
  #:use-module (gnu packages rust-crates)
  #:use-module (gnu packages linux)
  #:use-module (gnu packages tls)
  #:use-module (gnu packages pkg-config)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix build-system cargo)
  #:use-module ((guix licenses) #:prefix license:))

(define-public relax-player
  (package
   (name "relax-player")
   (version "1.1.0")
   (source
    (origin
     (method url-fetch)
     (uri (crate-uri "relax-player" version))
     (file-name (string-append name "-" version ".tar.gz"))
     (sha256
      (base32 "01g16mgi850hygpwskh18gp81zmxbffrzrsb8vn1ag04hnz7jd4c"))))
   (build-system cargo-build-system)
   (inputs (append  (list alsa-lib openssl)
                    (cargo-inputs 'relax-player #:module '(packages rust-crates))))
   (native-inputs
    (list pkg-config))
   (home-page "https://github.com/ebithril/relax-player")
   (synopsis
    "terminal-based relaxation sound player with ambient sounds like rain, thunder, and campfire")
   (description
    "This package provides a terminal-based relaxation sound player with ambient
sounds like rain, thunder, and campfire.")
   (license license:expat)))
