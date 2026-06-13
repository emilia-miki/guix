(define-module (packages rose-pine-gtk)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix gexp)
  #:use-module (guix build-system copy)
  #:use-module (guix utils)
  #:use-module ((guix licenses) #:prefix license:))

(define-public rose-pine-gtk
  (package
   (name "rose-pine-gtk")
   (version "0-1.3a11f84")
   (source
    (origin
     (method url-fetch)
     (uri "https://github.com/rose-pine/gtk/archive/3a11f84e11685aacaa749deea1e9f02872b99fdf.tar.gz")
     (file-name (string-append name "-" version ".tar.gz"))
     (sha256
      (base32 "1sdlcncz36qqmncb3xa0fpqbsynn3w1cv32xx3rv7cwhiyknm1p7"))))
   (build-system copy-build-system)
   (arguments
    (list #:install-plan
          #~'(("gtk3/rose-pine-gtk"           "share/themes/rose-pine-gtk")
              ("gtk3/rose-pine-moon-gtk"      "share/themes/rose-pine-moon-gtk")
              ("gtk3/rose-pine-dawn-gtk"      "share/themes/rose-pine-dawn-gtk")
              ("gtk4/rose-pine.css"           "share/themes/rose-pine-gtk/gtk-4.0/gtk.css")
              ("gtk4/rose-pine-moon.css"      "share/themes/rose-pine-moon-gtk/gtk-4.0/gtk.css")
              ("gtk4/rose-pine-dawn.css"      "share/themes/rose-pine-dawn-gtk/gtk-4.0/gtk.css")
              ("icons/rose-pine-icons"        "share/icons/rose-pine-icons")
              ("icons/rose-pine-moon-icons"   "share/icons/rose-pine-moon-icons")
              ("icons/rose-pine-dawn-icons"   "share/icons/rose-pine-dawn-icons"))
          #:phases
          #~(modify-phases %standard-phases
                           ;; The theme's fallback is breeze (light), which has dark icon fills.
                           ;; Switch to breeze-dark so missing icons fall back to light-coloured variants.
                           (add-after 'install 'fix-icon-fallback
                                      (lambda* (#:key outputs #:allow-other-keys)
                                        (let ((out (assoc-ref outputs "out")))
                                          (for-each
                                           (lambda (theme)
                                             (substitute* (string-append out "/share/icons/" theme "/index.theme")
                                                          (("Inherits=breeze,") "Inherits=breeze-dark,")))
                                           '("rose-pine-icons" "rose-pine-moon-icons" "rose-pine-dawn-icons")))))
                           ;; gtk-dark.css imports dist/gtk-dark.css which accidentally has light colors.
                           ;; Overwrite with an import of dist/gtk.css — the actual dark theme.
                           (add-after 'fix-icon-fallback 'fix-gtk-dark-css
                                      (lambda* (#:key outputs #:allow-other-keys)
                                        (let ((out (assoc-ref outputs "out")))
                                          (for-each
                                           (lambda (ver resource-prefix)
                                             (let ((f (string-append out "/share/themes/rose-pine-gtk/"
                                                                     ver "/gtk-dark.css")))
                                               (when (file-exists? f)
                                                 (call-with-output-file f
                                                   (lambda (port)
                                                     (display
                                                      (string-append "@import url(\"resource:///"
                                                                     resource-prefix
                                                                     "/dist/gtk.css\");\n")
                                                      port))))))
                                           '("gtk-3.0"  "gtk-3.20")
                                           '("org/numixproject/gtk" "org/numixproject/gtk-3.20"))))))))
   (home-page "https://github.com/rose-pine/gtk")
   (synopsis "Rosé Pine GTK theme")
   (description "GTK 2/3/4 theme in the Rosé Pine color palette.
Variants: rose-pine-gtk (main), rose-pine-moon-gtk, rose-pine-dawn-gtk.")
   (license license:expat)))
