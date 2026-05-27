(define-module (packages claude-code)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix build-system gnu)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (gnu packages base)
  #:use-module (gnu packages elf)
)

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
    (build-system gnu-build-system)
    (inputs
      (list glibc))
    (native-inputs
      (list patchelf))

    (arguments
      `(#:validate-runpath? #f
        #:strip-binaries? #f
        #:phases
        (modify-phases %standard-phases
          (delete 'configure)
          (delete 'build)
          (delete 'check)
          (replace 'install
            (lambda* (#:key inputs outputs #:allow-other-keys)
              (let* ((out     (assoc-ref outputs "out"))
                     (bin     (string-append out "/bin"))
                     (libexec (string-append out "/libexec/claude-code"))
                     (binary  (string-append libexec "/claude"))
                     (wrapper (string-append bin "/claude"))
                     (glibc   (assoc-ref inputs "glibc"))
                     (interp  (string-append glibc "/lib/ld-linux-aarch64.so.1")))
                (mkdir-p libexec)
                (mkdir-p bin)
                (copy-file "claude" binary)
                (chmod binary #o755)
                (invoke "patchelf" "--set-interpreter" interp binary)
                (call-with-output-file wrapper
                  (lambda (port)
                    (format port "#!/bin/sh\n")
                    (format port "export LD_LIBRARY_PATH=~a/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}\n"
                            glibc)
                    (format port "exec ~a \"$@\"\n" binary)))
                (chmod wrapper #o755)))))))
    (synopsis "Claude Code CLI by Anthropic")
    (description
      "Use Claude, Anthropic's AI assistant, right from your terminal.
Claude can understand your codebase, edit files, run terminal commands,
and handle entire workflows.")
    (home-page "https://github.com/anthropics/claude-code")
    (license (license:non-copyleft
               "https://code.claude.com/docs/en/legal-and-compliance"
               "Proprietary — © Anthropic PBC. All rights reserved."))))

claude-code
