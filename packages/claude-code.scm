(define-module (packages claude-code)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix build-system trivial)
  #:use-module (guix gexp)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (gnu packages base)
  #:use-module (gnu packages compression)
  #:use-module (gnu packages elf))

(define-public claude-code
  (package
    (name "claude-code")
    (version "2.1.152")
    (source
      (origin
        (method url-fetch)
        (uri (string-append
               "https://registry.npmjs.org/@anthropic-ai/claude-code-linux-arm64/-/"
               "claude-code-linux-arm64-" version ".tgz"))
        (sha256
          (base32 "133zyvs4y0farvxbxxdvz2sia9jjzrvvv1rripsl9hkym215lkq2"))))
    (build-system trivial-build-system)
    (inputs (list glibc))
    (native-inputs (list patchelf tar gzip))
    (arguments
      (list #:modules '((guix build utils))
            #:builder
            #~(begin
                (use-modules (guix build utils))
                (setenv "PATH" (string-append
                                (assoc-ref %build-inputs "tar") "/bin:"
                                (assoc-ref %build-inputs "gzip") "/bin:"
                                (assoc-ref %build-inputs "patchelf") "/bin"))
                (let* ((source   (assoc-ref %build-inputs "source"))
                       (out      (assoc-ref %outputs "out"))
                       (bin      (string-append out "/bin"))
                       (libexec  (string-append out "/libexec/claude-code"))
                       (binary   (string-append libexec "/claude"))
                       (wrapper  (string-append bin "/claude"))
                       (glibc    (assoc-ref %build-inputs "glibc"))
                       (interp   (string-append glibc "/lib/ld-linux-aarch64.so.1")))
                  (let ((tmp "/tmp/src"))
                    (mkdir-p libexec)
                    (mkdir-p bin)
                    (mkdir-p tmp)
                    (with-directory-excursion tmp
                      (invoke "tar" "--strip-components=1" "-xf" source)
                      (copy-file "claude" binary)))
                  (chmod binary #o755)
                  (invoke "patchelf" "--set-interpreter" interp binary)
                  (call-with-output-file wrapper
                    (lambda (port)
                      (format port "#!/bin/sh\n")
                      (format port "export LD_LIBRARY_PATH=~a/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}\n"
                              glibc)
                      (format port "exec ~a \"$@\"\n" binary)))
                  (chmod wrapper #o755)))))
    (synopsis "Claude Code CLI by Anthropic")
    (description
      "Use Claude, Anthropic's AI assistant, right from your terminal.
Claude can understand your codebase, edit files, run terminal commands,
and handle entire workflows.")
    (home-page "https://github.com/anthropics/claude-code")
    (license (license:non-copyleft
               "https://www.anthropic.com/legal/consumer-terms"
               "Proprietary — © Anthropic PBC. All rights reserved."))))
