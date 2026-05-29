(define-module (packages audacity)
  #:use-module (guix packages)
  #:use-module (guix build-system trivial)
  #:use-module (guix gexp)
  #:use-module (gnu packages audio)
  #:use-module (gnu packages bash))

(define-public audacity-wayland
  (package
    (inherit audacity)
    ;; Keep upstream name so the store path matches and profiles don't conflict.
    (name "audacity")
    (build-system trivial-build-system)
    (source #f)
    (inputs (list audacity bash-minimal))
    (native-inputs '())
    (arguments
      (list #:modules '((guix build utils) (guix build union))
            #:builder
            #~(begin
                (use-modules (guix build utils) (guix build union))
                (let* ((src  (assoc-ref %build-inputs "audacity"))
                       (bash (assoc-ref %build-inputs "bash-minimal"))
                       (out  (assoc-ref %outputs "out")))
                  (union-build out (list src) #:create-all-directories? #t)
                  ;; Replace bin/audacity symlink with a wrapper that forces the
                  ;; Wayland backend regardless of what the caller set.
                  (let ((wrapper (string-append out "/bin/audacity")))
                    (delete-file wrapper)
                    (call-with-output-file wrapper
                      (lambda (port)
                        (format port "#!~a/bin/bash\nexport GDK_BACKEND=wayland,x11\nexec ~a \"$@\"\n"
                                bash
                                (string-append src "/bin/audacity"))))
                    (chmod wrapper #o755))
                  ;; Also fix the desktop file (belt and suspenders).
                  (let ((desktop (string-append out "/share/applications/audacity.desktop")))
                    (delete-file desktop)
                    (copy-file (string-append src "/share/applications/audacity.desktop")
                               desktop)
                    (substitute* desktop
                      (("GDK_BACKEND=x11")
                       "GDK_BACKEND=wayland,x11")))))))))
