(define-module (packages clapper)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix build-system meson)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (gnu packages glib)
  #:use-module (gnu packages gtk)
  #:use-module (gnu packages gnome)
  #:use-module (gnu packages gstreamer)
  #:use-module (gnu packages pkg-config))

(define-public clapper
  (package
    (name "clapper")
    (version "0.10.0")
    (source
      (origin
        (method url-fetch)
        (uri "https://github.com/Rafostar/clapper/archive/refs/tags/0.10.0.tar.gz")
        (sha256
          (base32 "0601g0j83c5jg5z31hb6pd2x33hnikl5vpacnipkr9j0wlh0yk1l"))))
    (build-system meson-build-system)
    (native-inputs
      (list pkg-config
            `(,glib "bin")
            gobject-introspection))
    (inputs
      (list glib
            gtk
            libadwaita
            gstreamer
            gst-plugins-base))
    (arguments
      '(#:validate-runpath? #f
        #:configure-flags
        '("-Dclapper=enabled"
          "-Dclapper-gtk=enabled"
          "-Dclapper-app=disabled"
          "-Dintrospection=enabled"
          "-Dvapi=disabled"
          "-Denhancers-loader=disabled"
          "-Ddoc=false")))
    (synopsis "GObject-based media player library with GTK4 integration")
    (description
      "Clapper is a media player library built on top of GStreamer, providing
a clean GObject API with optional GTK4 integration.")
    (home-page "https://github.com/Rafostar/clapper")
    (license (list license:lgpl2.1+ license:gpl3+))))

clapper
