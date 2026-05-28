(define-module (packages newsflash)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix build-system meson)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (gnu packages glib)
  #:use-module (gnu packages gnome)
  #:use-module (gnu packages gtk)
  #:use-module (gnu packages freedesktop)
  #:use-module (gnu packages gettext)
  #:use-module (gnu packages pkg-config)
  #:use-module (gnu packages rust)
  #:use-module (gnu packages tls)
  #:use-module (gnu packages gstreamer)
  #:use-module (gnu packages llvm)
  #:use-module (gnu packages webkit)
  #:use-module (gnu packages linux)
  #:use-module (packages clapper))

(define-public newsflash
  (package
    (name "newsflash")
    (version "5.1.0")
    (source
      (origin
        (method url-fetch)
        (uri (string-append
               "https://gitlab.com/api/v4/projects/8320003/packages/generic/"
               "newsflash/" version "/newsflash-" version ".tar.xz"))
        (sha256
          (base32 "1rvfd2lp2pvvwq1nmwskf88k2f3fwb2y8b68dqfwnxrnsq3k0w3b"))))
    (build-system meson-build-system)
    (native-inputs
      (list pkg-config
            `(,glib "bin")
            `(,gtk "bin")
            gnu-gettext
            desktop-file-utils
            rust
            clang
            blueprint-compiler))
    (inputs
      (list glib
            gtk
            libadwaita
            openssl
            webkitgtk
            clapper
            gtksourceview
            gstreamer
            gst-plugins-base
            libseccomp))
    (arguments
      `(#:configure-flags '("-Dprofile=default")
        #:phases
        (modify-phases %standard-phases
          (add-after 'unpack 'reduce-cargo-jobs
            (lambda _
              (substitute* "src/meson.build"
                (("'--jobs', '16'") "'--jobs', '4'"))))
          (add-after 'unpack 'fix-cargo-config
            (lambda _
              (let ((source-dir (getcwd)))
                (delete-file ".cargo/config")
                (call-with-output-file ".cargo/config.toml"
                  (lambda (port)
                    (format port "[source.crates-io]~%replace-with = \"vendored-sources\"~%~%")
                    (format port "[source.\"git+https://gitlab.com/news-flash/html2gtk.git#2bf569896435c57bfe999009fd6d72381b8c7abb\"]~%replace-with = \"vendored-sources\"~%~%")
                    (format port "[source.\"git+https://gitlab.com/news-flash/news_flash.git#ffb97389c0d7512e82b6382b87cd10cf68168e5a\"]~%replace-with = \"vendored-sources\"~%~%")
                    (format port "[source.vendored-sources]~%directory = \"~a/vendor\"~%" source-dir))))))
          (add-after 'fix-cargo-config 'patch-cargo-features
            (lambda _
              (substitute* "Cargo.toml"
                (("features = \\[\"v2_88\"\\]") "features = [\"v2_86\"]")
                (("features = \\[\"v1_9\"\\]") "features = [\"v1_8\"]"))
              (substitute* "vendor/html2gtk/Cargo.toml"
                (("\"v5_18\"") "\"v5_16\""))
              (call-with-output-file "vendor/html2gtk/.cargo-checksum.json"
                (lambda (port)
                  (display "{\"files\":{}}" port)))))
          (add-before 'patch-source-shebangs 'protect-vendor
            (lambda _
              (rename-file "vendor" "../vendor-preserved")))
          (add-after 'patch-source-shebangs 'restore-vendor
            (lambda _
              (rename-file "../vendor-preserved" "vendor")))
          (add-after 'configure 'fix-cargo-home
            (lambda* (#:key inputs #:allow-other-keys)
              (setenv "CC" "gcc")
              (let* ((build-dir (getcwd))
                     (cargo-home (string-append build-dir "/cargo-home"))
                     (vendor-dir (string-append build-dir "/../newsflash-5.1.0/vendor"))
                     (openssl-dir (assoc-ref inputs "openssl")))
                (mkdir-p cargo-home)
                (call-with-output-file (string-append cargo-home "/config.toml")
                  (lambda (port)
                    (format port "[source.crates-io]~%replace-with = \"vendored-sources\"~%~%")
                    (format port "[source.\"git+https://gitlab.com/news-flash/html2gtk.git#2bf569896435c57bfe999009fd6d72381b8c7abb\"]~%git = \"https://gitlab.com/news-flash/html2gtk.git\"~%replace-with = \"vendored-sources\"~%~%")
                    (format port "[source.\"git+https://gitlab.com/news-flash/news_flash.git#ffb97389c0d7512e82b6382b87cd10cf68168e5a\"]~%git = \"https://gitlab.com/news-flash/news_flash.git\"~%replace-with = \"vendored-sources\"~%~%")
                    (format port "[source.vendored-sources]~%directory = \"~a\"~%" vendor-dir)))
                (setenv "CARGO_HOME" cargo-home)
                (setenv "OPENSSL_DIR" openssl-dir)
                (setenv "OPENSSL_LIB_DIR" (string-append openssl-dir "/lib"))
                (setenv "OPENSSL_INCLUDE_DIR" (string-append openssl-dir "/include"))
                (setenv "LIBCLANG_PATH" (string-append (assoc-ref inputs "clang") "/lib"))
                (let* ((clapper-dir (assoc-ref inputs "clapper"))
                       (gstreamer-dir (assoc-ref inputs "gstreamer"))
                       (gst-plugins-base-dir (assoc-ref inputs "gst-plugins-base")))
                  (setenv "GI_TYPELIB_PATH"
                          (string-append clapper-dir "/lib/girepository-1.0"
                                         ":" gstreamer-dir "/lib/girepository-1.0"
                                         ":" gst-plugins-base-dir "/lib/girepository-1.0"))
                  (setenv "LD_LIBRARY_PATH"
                          (string-append clapper-dir "/lib"
                                         ":" gstreamer-dir "/lib"
                                         ":" gst-plugins-base-dir "/lib"
                                         (let ((existing (getenv "LD_LIBRARY_PATH")))
                                           (if existing (string-append ":" existing) "")))))))))))
    (synopsis "Modern feed reader for GNOME")
    (description
      "NewsFlash is a program designed to complement an already existing
web-based RSS reader account.")
    (home-page "https://gitlab.com/news-flash/news_flash_gtk")
    (license license:gpl3+)))

newsflash
