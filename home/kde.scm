;; KDE home services. To switch back to KDE from Sway:
;;   1. In guix-home-config.scm: replace %sway-services with %kde-services
;;   2. See kde.scm (root) for the system-level checklist.
(define-module (home kde)
  #:use-module (gnu home services)
  #:use-module (gnu services)
  #:use-module (guix gexp)
  #:export (%kde-services))

(define-public %kde-services
  (list
    (simple-service 'kde-xdg-config
      home-xdg-configuration-files-service-type
      `(("kdeglobals"
         ,(plain-file "kdeglobals"
            "[KDE]
widgetStyle=kvantum

[General]
ColorScheme=RosePine

[Icons]
Theme=rose-pine-icons
FallbackTheme=breeze-dark

[Colors:Window]
BackgroundNormal=29,23,31
ForegroundNormal=224,222,244
BackgroundAlternate=30,28,42

[Colors:View]
BackgroundNormal=29,23,31
ForegroundNormal=224,222,244
BackgroundAlternate=30,28,42
ForegroundLink=156,207,216
ForegroundVisited=196,167,231

[Colors:Button]
BackgroundNormal=30,28,42
ForegroundNormal=224,222,244

[Colors:Selection]
BackgroundNormal=64,60,100
ForegroundNormal=224,222,244

[Colors:Tooltip]
BackgroundNormal=30,28,42
ForegroundNormal=224,222,244

[Colors:Header]
BackgroundNormal=29,23,31
ForegroundNormal=224,222,244
"))
        ("mimeapps.list"
         ,(plain-file "mimeapps.list"
            "[Default Applications]
x-scheme-handler/http=librewolf.desktop;
x-scheme-handler/https=librewolf.desktop;
application/pdf=emacsclient.desktop;
text/plain=emacsclient.desktop;
text/markdown=emacsclient.desktop;
text/x-cmake=emacsclient.desktop;
application/json=emacsclient.desktop;
application/x-yaml=emacsclient.desktop;
application/x-docbook+xml=emacsclient.desktop;
image/jpeg=imv.desktop;
image/png=imv.desktop;
image/gif=imv.desktop;
image/svg+xml=imv.desktop;
image/tiff=imv.desktop;
image/webp=imv.desktop;
image/heif=imv.desktop;
image/avif=imv.desktop;
image/jxl=imv.desktop;
image/x-farbfeld=imv.desktop;
video/mp4=mpv.desktop;
video/webm=mpv.desktop;
video/x-matroska=mpv.desktop;
video/mpeg=mpv.desktop;
video/ogg=mpv.desktop;
video/avi=mpv.desktop;
video/x-msvideo=mpv.desktop;
video/quicktime=mpv.desktop;
video/3gpp=mpv.desktop;
audio/mpeg=mpv.desktop;
audio/flac=mpv.desktop;
audio/ogg=mpv.desktop;
audio/wav=mpv.desktop;
audio/mp4=mpv.desktop;
audio/x-matroska=mpv.desktop;
audio/webm=mpv.desktop;
audio/opus=mpv.desktop;
application/zip=org.kde.ark.desktop;
application/x-tar=org.kde.ark.desktop;
application/gzip=org.kde.ark.desktop;
application/x-bzip2=org.kde.ark.desktop;
application/x-xz=org.kde.ark.desktop;
application/x-7z-compressed=org.kde.ark.desktop;
application/x-rar=org.kde.ark.desktop;
application/zstd=org.kde.ark.desktop;
application/x-compressed-tar=org.kde.ark.desktop;
application/vnd.oasis.opendocument.text=libreoffice-writer.desktop;
application/msword=libreoffice-writer.desktop;
application/vnd.openxmlformats-officedocument.wordprocessingml.document=libreoffice-writer.desktop;
application/vnd.oasis.opendocument.spreadsheet=libreoffice-calc.desktop;
application/vnd.ms-excel=libreoffice-calc.desktop;
application/vnd.openxmlformats-officedocument.spreadsheetml.sheet=libreoffice-calc.desktop;
application/vnd.oasis.opendocument.presentation=libreoffice-impress.desktop;
application/vnd.ms-powerpoint=libreoffice-impress.desktop;
application/vnd.openxmlformats-officedocument.presentationml.presentation=libreoffice-impress.desktop;
"))
        ))))
