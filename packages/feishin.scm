(define-module (packages feishin)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix build-system trivial)
  #:use-module (guix gexp)
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
    (version "1.12.0")
    (source
      (origin
        (method url-fetch)
        (uri (string-append
               "https://github.com/jeffvli/feishin/releases/download/v"
               version "/Feishin-linux-arm64.tar.xz"))
        (sha256
          (base32 "1smq1d1hljpxlgwppy7mjnbqr8k8v59l749sy6zdgsfqda7wm3ra"))))
    (build-system trivial-build-system)
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
    (native-inputs (list patchelf tar xz))
    (arguments
      (list #:modules '((guix build utils))
            #:builder
            #~(begin
                (use-modules (guix build utils))
                (define (elf? path)
                  (let ((s (lstat path)))
                    (and (eq? 'regular (stat:type s))
                         (let* ((port (open-file path "rb"))
                                (b0 (get-u8 port))
                                (b1 (get-u8 port))
                                (b2 (get-u8 port))
                                (b3 (get-u8 port)))
                           (close-port port)
                           (and (not (eof-object? b0))
                                (not (eof-object? b1))
                                (not (eof-object? b2))
                                (not (eof-object? b3))
                                (= b0 #x7f) (= b1 #x45)
                                (= b2 #x4c) (= b3 #x46))))))
                (setenv "PATH" (string-append
                                (assoc-ref %build-inputs "tar") "/bin:"
                                (assoc-ref %build-inputs "xz") "/bin:"
                                (assoc-ref %build-inputs "patchelf") "/bin"))
                (let* ((source   (assoc-ref %build-inputs "source"))
                       (out      (assoc-ref %outputs "out"))
                       (bin      (string-append out "/bin"))
                       (lib      (string-append out "/lib/feishin"))
                       (interp   (string-append
                                   (assoc-ref %build-inputs "glibc")
                                   "/lib/ld-linux-aarch64.so.1"))
                       (lib-dirs
                         (cons* lib
                                (string-append (assoc-ref %build-inputs "nss") "/lib/nss")
                                (map (lambda (pkg)
                                       (string-append (assoc-ref %build-inputs pkg) "/lib"))
                                     '("glibc" "gcc" "glib" "dbus" "gtk+" "pango"
                                       "cairo" "at-spi2-core" "nspr" "libx11"
                                       "libxcomposite" "libxdamage" "libxext"
                                       "libxfixes" "libxrandr" "libxcb"
                                       "libxkbcommon" "libdrm" "expat" "alsa-lib"
                                       "cups" "pulseaudio" "pciutils" "eudev"
                                       "mesa"))))
                       (rpath    (string-join lib-dirs ":")))
                  (mkdir-p lib)
                  (mkdir-p bin)
                  (invoke "tar" "--strip-components=1" "-xf" source "-C" lib)
                  (for-each
                    (lambda (file)
                      (invoke "patchelf" "--set-rpath" rpath file))
                    (filter elf? (find-files lib)))
                  (for-each
                    (lambda (exe)
                      (when (file-exists? exe)
                        (invoke "patchelf" "--set-interpreter" interp exe)))
                    (list (string-append lib "/feishin")
                          (string-append lib "/chrome-sandbox")
                          (string-append lib "/chrome_crashpad_handler")))
                  (for-each
                    (lambda (size)
                      (let* ((icon-dir (string-append out "/share/icons/hicolor/"
                                                      size "x" size "/apps"))
                             (src      (string-append lib "/resources/assets/icons/"
                                                      size "x" size ".png")))
                        (mkdir-p icon-dir)
                        (copy-file src (string-append icon-dir "/feishin.png"))))
                    '("32" "64" "128" "256" "512" "1024"))
                  (let ((apps (string-append out "/share/applications")))
                    (mkdir-p apps)
                    (call-with-output-file (string-append apps "/feishin.desktop")
                      (lambda (port)
                        (format port "[Desktop Entry]~%")
                        (format port "Name=Feishin~%")
                        (format port "Comment=Modern self-hosted music player~%")
                        (format port "Exec=feishin~%")
                        (format port "Icon=feishin~%")
                        (format port "Terminal=false~%")
                        (format port "Type=Application~%")
                        (format port "Categories=Audio;Music;AudioVideo;~%"))))
                  (call-with-output-file (string-append bin "/feishin")
                    (lambda (port)
                      (format port "#!/bin/sh\nexec ~a/feishin \"$@\"\n" lib)))
                  (chmod (string-append bin "/feishin") #o755)))))
    (synopsis "Modern self-hosted music player")
    (description
      "Full-featured Jellyfin, Navidrome, and OpenSubsonic compatible desktop music player.")
    (home-page "https://github.com/jeffvli/feishin")
    (license license:gpl3)))
