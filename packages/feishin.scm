(define-module (packages feishin)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix build-system gnu)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (gnu packages base)
  #:use-module (gnu packages compression)
  #:use-module (gnu packages elf)
  #:use-module (gnu packages gcc)
  #:use-module (gnu packages gl)
  #:use-module (gnu packages glib)
  #:use-module (gnu packages gtk)
  #:use-module (gnu packages nss)
  #:use-module (gnu packages xdisorg)
  #:use-module (gnu packages xorg)
  #:use-module (gnu packages xml)
  #:use-module (gnu packages cups)
  #:use-module (gnu packages pulseaudio)
  #:use-module (gnu packages linux)
  #:use-module (gnu packages pciutils))

(define-public feishin
  (package
    (name "feishin")
    (version "0.12.1")
    (source
      (origin
        (method url-fetch)
        (uri (string-append
               "https://github.com/jeffvli/feishin/releases/download/v"
               version "/Feishin-" version "-linux-arm64.tar.xz"))
        (sha256
          (base32 "1mcxl7gfsq61lfr4mmjalih86c8rpl47bjfhy530c2wjj0l2mlrr"))))
    (build-system gnu-build-system)
    (inputs
      (list glibc
            `(,gcc "lib")
            glib
            dbus
            gtk+
            pango
            cairo
            at-spi2-core
            nss
            nspr
            mesa
            libx11
            libxcomposite
            libxdamage
            libxext
            libxfixes
            libxrandr
            libxcb
            libxkbcommon
            libdrm
            expat
            alsa-lib
            cups
            pulseaudio
            pciutils
            eudev))
    (native-inputs
      (list patchelf))
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
                     (lib-dirs
                       (cons* lib
                              (string-append (assoc-ref inputs "nss") "/lib/nss")
                              (map (lambda (pkg)
                                     (string-append (assoc-ref inputs pkg) "/lib"))
                                   '("glibc" "gcc" "glib" "dbus" "gtk+" "pango"
                                     "cairo" "at-spi2-core" "nspr" "libx11"
                                     "libxcomposite" "libxdamage" "libxext"
                                     "libxfixes" "libxrandr" "libxcb"
                                     "libxkbcommon" "libdrm" "expat" "alsa-lib"
                                     "cups" "pulseaudio" "pciutils" "eudev"
                                     "mesa"))))
                     (rpath (string-join lib-dirs ":")))
                (mkdir-p lib)
                (mkdir-p bin)
                (copy-recursively "." lib)
                ;; patch rpath on all ELF files
                (for-each
                  (lambda (file)
                    (system* "patchelf" "--set-rpath" rpath file))
                  (find-files lib))
                ;; set interpreter on the executables
                (for-each
                  (lambda (exe)
                    (when (file-exists? exe)
                      (system* "patchelf" "--set-interpreter" interp exe)))
                  (list (string-append lib "/feishin")
                        (string-append lib "/chrome-sandbox")
                        (string-append lib "/chrome_crashpad_handler")))
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

feishin
