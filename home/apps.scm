(define-module (home apps)
  #:use-module (guix download)
  #:use-module (guix packages)
  #:use-module (gnu home services)
  #:use-module (gnu home services xdg)
  #:use-module (gnu packages bittorrent)
  #:use-module (gnu packages chromium)
  #:use-module (gnu packages firmware)
  #:use-module (gnu packages freedesktop)
  #:use-module (gnu packages games)
  #:use-module (gnu packages gimp)
  #:use-module (gnu packages gnome)
  #:use-module (gnu packages image-viewers)
  #:use-module (gnu packages kde-systemtools)
  #:use-module (gnu packages kde-utils)
  #:use-module (gnu packages librewolf)
  #:use-module (gnu packages linux)
  #:use-module (gnu packages networking)
  #:use-module (gnu packages package-management)
  #:use-module (gnu packages unicode)
  #:use-module (gnu packages video)
  #:use-module (gnu packages vnc)
  #:use-module (gnu services)
  #:use-module (guix gexp)
  #:use-module (packages blender)
  #:use-module (packages feishin)
  #:use-module (packages libreoffice)
  #:export (%apps-services))

(define %applications-menu
  (origin
   (method url-fetch)
   (uri "https://raw.githubusercontent.com/KDE/plasma-workspace/master/menu/desktop/plasma-applications.menu")
   (file-name "applications.menu")
   (sha256 (base32 "1xibf1p74pi78a4d8w1ng8jqdsx4ib9ra031k3hwk9pg2dfwwnx5"))))

(define-public %apps-services
  (list
   (simple-service 'gui-apps-packages
                   home-profile-service-type
                   (list
                    ;; browsers
                    librewolf ungoogled-chromium/wayland
                    ;; media
                    feishin obs
                    ;; viewers
                    imv
                    ;; file management
                    dolphin ark udiskie
                    ;; office
                    libreoffice-aarch64
                    ;; graphics
                    gimp blender-wayland
                    ;; network/remote
                    wireshark remmina qbittorrent moonlight-qt
                    ;; other
                    flatpak qmk ucd gsettings-desktop-schemas bluez))

   (service home-xdg-mime-applications-service-type
            (home-xdg-mime-applications-configuration
             (desktop-entries
              (list (xdg-desktop-entry
                     (file "chrome-kadndpdhfiaigidpmcgmgabmbcjnjbgn-Teams")
                     (name "Microsoft Teams (PWA)")
                     (type 'application)
                     (config
                      '((exec . "chromium --profile-directory=Teams --app-id=kadndpdhfiaigidpmcgmgabmbcjnjbgn")
                        (icon . "chrome-kadndpdhfiaigidpmcgmgabmbcjnjbgn-Teams")
                        (terminal . #f)
                        (startupwmclass . "crx_kadndpdhfiaigidpmcgmgabmbcjnjbgn"))))))
             (default
               '(
                 ;; Text / code → emacs
                 (text/plain . emacsclient.desktop)
                 (text/csv . emacsclient.desktop)
                 (text/html . emacsclient.desktop)
                 (text/xml . emacsclient.desktop)
                 (text/markdown . emacsclient.desktop)
                 (text/x-org . emacsclient.desktop)
                 (text/x-tex . emacsclient.desktop)
                 (text/x-c . emacsclient.desktop)
                 (text/x-c++ . emacsclient.desktop)
                 (text/x-csrc . emacsclient.desktop)
                 (text/x-c++src . emacsclient.desktop)
                 (text/x-chdr . emacsclient.desktop)
                 (text/x-c++hdr . emacsclient.desktop)
                 (text/x-java . emacsclient.desktop)
                 (text/x-python . emacsclient.desktop)
                 (text/x-python3 . emacsclient.desktop)
                 (text/x-shellscript . emacsclient.desktop)
                 (text/x-lisp . emacsclient.desktop)
                 (text/x-elisp . emacsclient.desktop)
                 (text/english . emacsclient.desktop)
                 (text/x-makefile . emacsclient.desktop)
                 (text/x-moc . emacsclient.desktop)
                 (text/x-pascal . emacsclient.desktop)
                 (text/x-tcl . emacsclient.desktop)
                 (application/x-shellscript . emacsclient.desktop)
                 (application/json . emacsclient.desktop)
                 (application/xml . emacsclient.desktop)
                 (application/xhtml+xml . emacsclient.desktop)
                 (application/x-yaml . emacsclient.desktop)
                 (application/toml . emacsclient.desktop)
                 (x-scheme-handler/org-protocol . emacsclient.desktop)

                 ;; PDF → emacs
                 (application/pdf . emacsclient.desktop)

                 ;; DjVu → emacs
                 (image/vnd.djvu . emacsclient.desktop)

                 ;; Document files → libreoffice
                 (application/vnd.oasis.opendocument.text . libreoffice-writer.desktop)
                 (application/vnd.oasis.opendocument.spreadsheet . libreoffice-calc.desktop)
                 (application/vnd.oasis.opendocument.presentation . libreoffice-impress.desktop)
                 (application/vnd.oasis.opendocument.graphics . libreoffice-draw.desktop)
                 (application/msword . libreoffice-writer.desktop)
                 (application/vnd.openxmlformats-officedocument.wordprocessingml.document . libreoffice-writer.desktop)
                 (application/vnd.ms-excel . libreoffice-calc.desktop)
                 (application/vnd.openxmlformats-officedocument.spreadsheetml.sheet . libreoffice-calc.desktop)
                 (application/vnd.ms-powerpoint . libreoffice-impress.desktop)
                 (application/vnd.openxmlformats-officedocument.presentationml.presentation . libreoffice-impress.desktop)

                 ;; Archives → ark
                 (application/x-tar . org.kde.ark.desktop)
                 (application/x-gtar . org.kde.ark.desktop)
                 (application/x-gzip . org.kde.ark.desktop)
                 (application/x-bzip2 . org.kde.ark.desktop)
                 (application/x-xz . org.kde.ark.desktop)
                 (application/x-zstd . org.kde.ark.desktop)
                 (application/zip . org.kde.ark.desktop)
                 (application/x-7z-compressed . org.kde.ark.desktop)
                 (application/x-rar-compressed . org.kde.ark.desktop)
                 (application/x-rar . org.kde.ark.desktop)
                 (application/x-deb . org.kde.ark.desktop)
                 (application/x-archive . org.kde.ark.desktop)

                 ;; Audio / video → mpv
                 (audio/mpeg . mpv.desktop)
                 (audio/ogg . mpv.desktop)
                 (audio/flac . mpv.desktop)
                 (audio/x-flac . mpv.desktop)
                 (audio/aac . mpv.desktop)
                 (audio/x-wav . mpv.desktop)
                 (audio/x-vorbis+ogg . mpv.desktop)
                 (video/mp4 . mpv.desktop)
                 (video/x-matroska . mpv.desktop)
                 (video/webm . mpv.desktop)
                 (video/x-msvideo . mpv.desktop)
                 (video/x-mpeg . mpv.desktop)
                 (video/ogg . mpv.desktop)

                 ;; Images → imv
                 (image/png . imv.desktop)
                 (image/jpeg . imv.desktop)
                 (image/gif . imv.desktop)
                 (image/webp . imv.desktop)
                 (image/bmp . imv.desktop)
                 (image/svg+xml . imv.desktop)
                 (image/tiff . imv.desktop)
                 (image/x-tga . imv.desktop)
                 (image/x-portable-bitmap . imv.desktop)
                 (image/x-portable-pixmap . imv.desktop)
                 (image/x-exr . imv.desktop)
                 (image/avif . imv.desktop)
                 (image/heif . imv.desktop)


                 ;; PCAP → wireshark
                 (application/vnd.tcpdump.pcap . org.wireshark.Wireshark.desktop)
                 (application/x-pcap . org.wireshark.Wireshark.desktop)
                 (application/pcap . org.wireshark.Wireshark.desktop)

                 ;; 3D models → blender
                 (model/stl . blender.desktop)
                 (model/obj . blender.desktop)
                 (model/3mf . blender.desktop)
                 (model/gltf+json . blender.desktop)
                 (model/gltf-binary . blender.desktop)
                 (application/x-fbx . blender.desktop)

                 ;; Blender projects (.blend) → blender
                 (application/x-blender . blender.desktop)))))

   (simple-service 'applications-menu
                   home-xdg-configuration-files-service-type
                   `(("menus/applications.menu" ,%applications-menu)))))
