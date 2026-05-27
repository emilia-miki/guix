(define-module (packages feishin)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix build-system gnu)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (gnu packages base)
  #:use-module (gnu packages compression)
  #:use-module (gnu packages elf)
  #:use-module (gnu packages gcc)
  #:use-module (gnu packages glib)
  #:use-module (gnu packages gtk)
  #:use-module (gnu packages nss)
  #:use-module (gnu packages xorg)
  #:use-module (gnu packages cups)
  #:use-module (gnu packages pulseaudio)
  #:use-module (gnu packages linux))

(define-public feishin
  (package
    (name "feishin")
    (version "0.12.1")
    (source
      (origin
        (method url-fetch)
        (uri (string-append
               "https://github.com/jeffvli/feishin/releases/download/v"
               version "/Feishin-" version "-linux-arm64.tar.gz"))
        (sha256
          (base32 "0000000000000000000000000000000000000000000000000000"))))
    (build-system gnu-build-system)
    (inputs
      (list glib
            gtk+
            nss
            libx11
            libxcomposite
            libxdamage
            libxext
            libxfixes
            libxrandr
            alsa-lib
            cups
            pulseaudio
            pciutils
            eudev))
    (native-inputs
      (list patchelf tar))
    (arguments
      `(#:phases
        (modify-phases %standard-phases
          (delete 'configure)
          (delete 'build)
          (delete 'check)
          (replace 'install
            (lambda* (#:key inputs outputs #:allow-other-keys)
              (let* ((out (assoc-ref outputs "out"))
                     (bin (string-append out "/bin"))
                     (lib (string-append out "/lib/feishin"))
                     (interp (string-append
                               (assoc-ref inputs "glibc")
                               "/lib/ld-linux-aarch64.so.1"))
                     (rpath (string-join
                              (map (lambda (pkg)
                                     (string-append (assoc-ref inputs pkg) "/lib"))
                                   '("glib" "gtk+" "nss" "libx11"
                                     "libxcomposite" "libxdamage"
                                     "alsa-lib" "cups" "pulseaudio"))
                              ":")))
                (mkdir-p lib)
                (mkdir-p bin)
                ;; copy all files
                (copy-recursively "." lib)
                ;; patch the main electron binary
                (invoke "patchelf"
                        "--set-interpreter" interp
                        "--set-rpath" rpath
                        (string-append lib "/feishin"))
                ;; create wrapper script
                (call-with-output-file (string-append bin "/feishin")
                  (lambda (port)
                    (format port "#!/bin/sh\nexec ~a/feishin \"$@\"\n" lib)))
                (chmod (string-append bin "/feishin") #o755)))))))
    (synopsis "Modern self-hosted music player")
    (description
      "Full-featured Jellyfin, Navidrome, and OpenSubsonic compatible desktop music player.")
    (home-page "https://github.com/jeffvli/feishin")
    (license license:gpl3)))
