(define-module (packages dexy-themes)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix build-system copy))

(define-public dexy-plasma-themes
  (package
    (name "dexy-plasma-themes")
    (version "13.6")
    (source
      (origin
        (method url-fetch)
        (uri "https://github.com/L4ki/Dexy-Plasma-Themes/archive/44d6136c7381de3033dc09cebb45c0bb5dbd75f4.tar.gz")
        (sha256
          (base32
            "0hp706v9dp0jh4pad8izf5jjvwh72q8g2649xapxjzh7krvk9nsw"))))
    (build-system copy-build-system)
    (arguments
      `(#:install-plan
        '(("Dexy-Color-Icons/Dexy-Color-Dark-Icons" "share/icons/")
          ("Dexy Window Decorations/Dexy-Blur-Dark-Color-Aurorae-6" "share/aurorae/themes/")
          ("Dexy Window Decorations/Dexy-Dark-Color-Aurorae-6" "share/aurorae/themes/")
          ("Dexy Plasma Themes/Dexy-Color-Plasma" "share/plasma/desktoptheme/")
          ("Dexy ColorSchemes/DexyColorDarkModerateCyan.colors" "share/color-schemes/"))))
    (home-page "https://github.com/L4ki/Dexy-Plasma-Themes")
    (synopsis "Dexy theme suite for KDE Plasma")
    (description "Icon theme, window decorations, plasma desktop theme, and color
schemes for KDE Plasma by L4ki.")
    (license license:gpl3+)))
