(define-module (configuration))

(use-modules
  (srfi srfi-1)
  (asahi guix systems sway)
  (asahi guix packages linux)
  (btv tailscale)
  (gnu)
  (gnu packages)
  (gnu packages admin)
  (gnu packages audio)
  (gnu packages autotools)
  (gnu packages base)
  (gnu packages bittorrent)
  (gnu packages chromium)
  (gnu packages cmake)
  (gnu packages commencement)
  (gnu packages compression)
  (gnu packages curl)
  (gnu packages djvu)
  (gnu packages dns)
  (gnu packages education)
  (gnu packages elf)
  (gnu packages fcitx5)
  (gnu packages file)
  (gnu packages firmware)
  (gnu packages fonts)
  (gnu packages freedesktop)
  (gnu packages games)
  (gnu packages gcc)
  (gnu packages gimp)
  (gnu packages gnome)
  (gnu packages golang)
  (gnu packages golang-apps)
  (gnu packages guile-xyz)
  (gnu packages graphics)
  (gnu packages image)
  (gnu packages kde-graphics)
  (gnu packages kde-internet)
  (gnu packages kde-plasma)
  (gnu packages kde-multimedia)
  (gnu packages kde-pim)
  (gnu packages kde-systemtools)
  (gnu packages kde-utils)
  (gnu packages libreoffice)
  (gnu packages librewolf)
  (gnu packages linux)
  (gnu packages lxqt)
  (gnu packages llvm)
  (gnu packages markup)
  (gnu packages music)
  (gnu packages ncurses)
  (gnu packages networking)
  (gnu packages package-management)
  (gnu packages pdf)
  (gnu packages pkg-config)
  (gnu packages pulseaudio)
  (gnu packages python)
  (gnu packages python-check)
  (gnu packages qt)
  (gnu packages racket)
  (gnu packages readline)
  (gnu packages rust)
  (gnu packages rust-apps)
  (gnu packages shellutils)
  (gnu packages text-editors)
  (gnu packages tmux)
  (gnu packages version-control)
  (gnu packages video)
  (gnu packages unicode)
  (gnu packages vnc)
  (gnu packages vpn)
  (gnu packages xdisorg)
  (gnu packages display-managers)
  (gnu services)
  (gnu services cups)
  (gnu services desktop)
  (gnu services guix)
  (gnu services networking)
  (gnu services sddm)
  (gnu system)
  (gnu packages image-viewers)
  (gnu packages irc)
  (gnu packages syndication)
  (gnu system locale)
  (guix build-system trivial)
  (guix gexp)
  (guix packages)
  (kde)
  (sway)
  (packages audacity)
  (packages blender)
  (packages claude-code)
  (packages libreoffice)
  (packages dexy-themes)
  (packages dua)
  (packages dust)
  (packages fcitx5-rose-pine)
  (packages feishin)
  (packages glow)
  (packages helix)
  (packages marksman)
  (packages mprocs)
  (packages presenterm)
  (packages relax-player)
  (packages skate)
  (packages uutils-coreutils)
  (packages xh)
  (packages yazi)
  (local))

(define sysconf-script
  (package
    (name "sysconf")
    (version "1.0")
    (source #f)
    (build-system trivial-build-system)
    (arguments
     `(#:modules ((guix build utils))
       #:builder
       (begin
         (use-modules (guix build utils))
         (let ((out (assoc-ref %outputs "out")))
           (mkdir-p (string-append out "/bin"))
           (let ((script (string-append out "/bin/sysconf")))
             (call-with-output-file script
               (lambda (port)
                 (display "#!/bin/sh\n" port)
                 (display "GUIX_DIR=\"$HOME/Projects/guix-system\"\n" port)
                 (display "sudo guix system reconfigure -L \"$GUIX_DIR\" \"$GUIX_DIR/configuration.scm\" && \\\n" port)
                 (display "guix home reconfigure -L \"$GUIX_DIR\" \"$GUIX_DIR/guix-home-config.scm\" && \\\n" port)
                 (display "guix describe -f channels > \"$GUIX_DIR/channels.lock.scm\"\n" port)
                 ;; Uncomment when using KDE:
                 ;; (display " && kbuildsycoca6 --noincremental\n" port)
                 ))
             (chmod script #o755))))))
    (synopsis "System reconfigure script")
    (description "Reconfigures Guix system and home.")
    (license #f)
    (home-page "")))

(define %nm-vpn-tailscale-script
  (let ((src (plain-file "10-vpn-tailscale-route"
               (string-append
                 "#!/bin/sh\n"
                 "[ \"$2\" = \"vpn-up\" ] || exit 0\n"
                 "[ \"$CONNECTION_ID\" = \"" %ovpn-connection-id "\" ] || exit 0\n"
                 "/run/current-system/profile/sbin/ip route add "
                 %thinkcentre-ssh-hostname
                 "/32 dev tailscale0 2>/dev/null || true\n"))))
    (computed-file "10-vpn-tailscale-route"
      #~(begin
          (copy-file #$src #$output)
          (chmod #$output #o755)))))

(operating-system
 (inherit asahi-sway-os)
 ;; Rose Pine main palette for the virtual console, active from boot
 ;; (including the login prompt). Colors 0-7 = normal, 8-15 = bright.
 (kernel-arguments
  (append (operating-system-user-kernel-arguments asahi-sway-os)
          '("vt.default_red=25,38,49,246,156,196,235,224,82,235,49,246,156,196,235,224"
            "vt.default_grn=23,35,116,193,207,167,188,222,79,111,116,193,207,167,188,222"
            "vt.default_blu=36,58,143,119,216,231,186,244,103,146,143,119,216,231,186,244")))
 (timezone "Europe/Kyiv")
 (locale "en_DK.UTF-8")
 (locale-definitions
  (cons* (locale-definition (name "en_DK.UTF-8") (source "en_DK"))
         (locale-definition (name "en_IE.UTF-8") (source "en_IE"))
         %default-locale-definitions))
 (users
  (cons* (user-account
          (name "miki")
          (group "users")
          (supplementary-groups '("wheel" "audio" "video" "input" "netdev"))
          (home-directory "/home/miki"))
         %base-user-accounts))
 (services
  (cons* (extra-special-file
           "/etc/NetworkManager/dispatcher.d/10-vpn-tailscale-route"
           %nm-vpn-tailscale-script)
         (service tailscale-service-type)
         (service bluetooth-service-type
                          (bluetooth-configuration
                           (auto-enable? #t)))
         (service cups-service-type)
         (simple-service 'extra-hosts
                         hosts-service-type
                         %local-hosts)
         (simple-service 'editor-env
                         session-environment-service-type
                         '(("EDITOR" . "emacsclient -nw")
                           ("VISUAL" . "emacsclient -nw")))
         (simple-service 'wayland-env
                         session-environment-service-type
                         '(("QT_QPA_PLATFORM" . "wayland")
                           ("QT_QPA_PLATFORM_PLUGIN_PATH" . "/run/current-system/profile/lib/qt6/plugins/platforms")
                           ("GDK_BACKEND" . "wayland,x11")))
         (modify-services (operating-system-user-services asahi-sway-os)
                          (delete guix-home-service-type)
                          (guix-service-type config =>
                                             (guix-configuration
                                              (inherit config)
                                              (substitute-urls
                                               (append (list "https://substitutes.nonguix.org")
                                                       %default-substitute-urls))
                                              (authorized-keys
                                               (append (list (plain-file "non-guix.pub"
                                                                         "(public-key (ecc (curve Ed25519) (q #C1FD53E5D4CE971933EC50C9F307AE2171A2D3B52C804642A7A35F84F3A4EA98#)))"))
                                                       %default-authorized-guix-keys))))
                          (network-manager-service-type config =>
                                                        (network-manager-configuration
                                                         (inherit config)
                                                         (vpn-plugins (list network-manager-openvpn))))
                          (delete sddm-service-type)
                          ;; ter-124b: Terminus 24px bold — 1.5× the default 16px
                          (console-font-service-type _ =>
                                                     (map (lambda (tty)
                                                            (cons tty (file-append font-terminus
                                                                                   "/share/consolefonts/ter-124b.psf.gz")))
                                                          '("tty1" "tty2" "tty3" "tty4" "tty5" "tty6")))
                          (elogind-service-type config =>
                                               (elogind-configuration
                                                (inherit config)
                                                (handle-lid-switch 'ignore)
                                                (handle-lid-switch-external-power 'ignore)
                                                (handle-suspend-key 'ignore)
                                                (handle-hibernate-key 'ignore))))))
 (packages
  (cons*
   ;; browsers
   librewolf
   ungoogled-chromium/wayland

   ;; terminal tools
   file
   ncurses
   curl
   git
   direnv
   tree
   rlwrap
   claude-code
   hyperfine
   ripgrep
   ripgrep-all
   eza
   bat
   gitui
   starship
   tokei
   zoxide
   fd
   inotify-tools
   tmux
   helix-steel
   (list isc-bind "utils") ;; provides nslookup, dig, host
   rust
   rust-analyzer
   uv
   patchelf
   go
   gopls
   ruff
   python
   relax-player
   xdg-utils
   autoconf
   automake
   gnu-make
   markdown
   sysconf-script
   gcc-toolchain
   pkg-config
   poppler
   libpng
   zlib
   djvulibre
   djview

   ;; multimedia
   ffmpeg
   yt-dlp
   cava
   mpv
   audacity-wayland

   ;; build tools
   zlib
   unzip
   libtool
   cmake
   clang
   typst

   ;; input / wayland
   fcitx5
   fcitx5-gtk
   fcitx5-gtk4
   fcitx5-anthy
   fcitx5-hangul
   fcitx5-rose-pine
   fcitx5-configtool
   xdg-desktop-portal-gtk
   adwaita-icon-theme
   wl-clipboard
   playerctl

   ;; network
   openvpn
   network-manager-openvpn
   openresolv
   tailscale

   ;; CLI tools
   glow
   skate
   marksman
   yazi
   dust
   dua
   uutils-coreutils
   xh
   mprocs
   presenterm

   font-terminus

   ;; KDE apps (kept regardless of desktop)
   dolphin

   ;; GUI apps
   feishin
   imv
   moonlight-qt
   wireshark
   qbittorrent
   qtwayland
   obs
   remmina
   hyprpicker
   ucd
   libreoffice-aarch64
   ark
   gsettings-desktop-schemas
   udiskie
   swappy
   blender-wayland
   gimp
   ;; krita
   flatpak
   qmk
   bluez

   ;; fonts
   font-awesome
   font-nerd-fira-code
   font-google-noto           ;; noto-fonts
   font-google-noto-sans-cjk  ;; noto-fonts-cjk-sans
   font-google-noto-serif-cjk ;; noto-fonts-cjk-serif
   font-google-noto-emoji     ;; noto-fonts-color-emoji
   font-dejavu                ;; dejavu_fonts
   font-gnu-unifont           ;; unifont
   font-ipa                   ;; ipafont
   font-ipa-ex                ;; kochi-substitute equivalent
   font-bitstream-vera        ;; ttf_bitstream_vera
   ;; carlito, source-code-pro — check guix names

   (append %sway-packages
           %sway-os-packages)))
 (file-systems
  (cons* (file-system
          (device (uuid "848E-1AEE" 'fat32))
          (mount-point "/boot/efi")
          (needed-for-boot? #t)
          (type "vfat"))
         (file-system
          (device (file-system-label "asahi-guix-root"))
          (mount-point "/")
          (needed-for-boot? #t)
          (type "btrfs"))
         (file-system
          (device (file-system-label "asahi-guix-root"))
          (mount-point "/swap")
          (type "btrfs")
          (options "subvol=swap,nodatacow")
          (needed-for-boot? #f))
         %base-file-systems))
 (swap-devices
  (list (swap-space (target "/swap/swapfile")))))
