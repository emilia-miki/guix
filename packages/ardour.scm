(define-module (packages ardour)
  #:use-module (gnu packages audio)
  #:use-module (gnu packages base)
  #:use-module (guix packages)
  #:use-module (guix gexp)
  #:use-module (guix utils))

;; On non-x86 systems qm-dsp uses general/Makefile.inc, which guards Thread.h
;; behind USE_PTHREADS but never defines it.  Apply the fix via a source
;; snippet so it's baked into the source derivation and can't be missed.
(define-public qm-dsp
  (package
    (inherit (@ (gnu packages audio) qm-dsp))
    (source
     (origin
       (inherit (package-source (@ (gnu packages audio) qm-dsp)))
       (snippet
        (with-imported-modules '((guix build utils))
          #~(begin
              (use-modules (guix build utils))
              (substitute* "build/general/Makefile.inc"
                ;; Add USE_PTHREADS and -fPIC. USE_PTHREADS is required by
                ;; thread/Thread.h on non-Win32. -fPIC is required on aarch64
                ;; because libqm-dsp.a is linked into Ardour's shared libraries.
                (("\\$\\(CXXFLAGS\\) -I\\.")
                 "$(CXXFLAGS) -DUSE_PTHREADS -fPIC -I.")
                ;; Add bundled include/ path so hmm/hmm.c finds clapack.h.
                ;; (x86 Makefiles use -Ibuild/linux/amd64 instead.)
                (("\\$\\(CFLAGS\\) -I\\.")
                 "$(CFLAGS) -DUSE_PTHREADS -fPIC -Iinclude -I.")))))))))

(define-public ardour
  (package
    (inherit (@ (gnu packages audio) ardour))
    (inputs
     (modify-inputs (package-inputs (@ (gnu packages audio) ardour))
       (replace "qm-dsp" qm-dsp)))))
