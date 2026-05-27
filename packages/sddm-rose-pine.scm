(define-module (packages sddm-rose-pine)
  #:use-module (guix packages)
  #:use-module (guix build-system trivial)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (gnu packages display-managers))

(define-public sddm-rose-pine-theme
  (package
    (inherit where-is-my-sddm-theme)
    (name "sddm-rose-pine-theme")
    (build-system trivial-build-system)
    (arguments
      `(#:modules ((guix build utils))
        #:builder
        (begin
          (use-modules (guix build utils))
          (let* ((out (assoc-ref %outputs "out"))
                 (theme-dir (string-append out "/share/sddm/themes/rose-pine")))
            (mkdir-p theme-dir)
            (copy-recursively
              (string-append (assoc-ref %build-inputs "source")
                             "/where_is_my_sddm_theme")
              theme-dir)
            (let ((conf (string-append theme-dir "/theme.conf")))
              (chmod conf #o644))
            (call-with-output-file (string-append theme-dir "/theme.conf")
              (lambda (port)
                (display
                  "[General]\nbackgroundFill=#191724\nbasicTextColor=#e0def4\npasswordInputBackground=#26233a\npasswordTextColor=#e0def4\npasswordCursorColor=#c4a7e7\npasswordInputRadius=8\nfont=monospace\n"
                  port)))))))
    (synopsis "Rosé Pine theme for SDDM")
    (description
      "A Rosé Pine color theme for SDDM based on where-is-my-sddm-theme,
with a dark background and rose-pine color palette.")
    (license license:gpl3+)))

sddm-rose-pine-theme
