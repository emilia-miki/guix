(define-module (configuration))

(use-modules
  (asahi guix systems plasma)
  (asahi guix systems sway)
  (asahi guix packages linux)
  (btv tailscale)
  (gnu)
  (gnu packages)
  (gnu packages admin)
  (gnu packages audio)
  (gnu packages autotools)
  (gnu packages bittorrent)
  (gnu packages chromium)
  (gnu packages cmake)
  (gnu packages compression)
  (gnu packages curl)
  (gnu packages dns)
  (gnu packages education)
  (gnu packages fcitx5)
  (gnu packages file)
  (gnu packages firmware)
  (gnu packages fonts)
  (gnu packages freedesktop)
  (gnu packages games)
  (gnu packages gimp)
  (gnu packages gnome)
  (gnu packages graphics)
  (gnu packages image)
  (gnu packages kde-graphics)
  (gnu packages kde-systemtools)
  (gnu packages librewolf)
  (gnu packages linux)
  (gnu packages llvm)
  (gnu packages music)
  (gnu packages networking)
  (gnu packages nushell)
  (gnu packages pdf)
  (gnu packages pulseaudio)
  (gnu packages qt)
  (gnu packages racket)
  (gnu packages readline)
  (gnu packages rust-apps)
  (gnu packages shellutils)
  (gnu packages text-editors)
  (gnu packages tmux)
  (gnu packages version-control)
  (gnu packages video)
  (gnu packages vnc)
  (gnu packages vpn)
  (gnu packages wm)
  (gnu packages xdisorg)
  (gnu packages display-managers)
  (gnu services cups)
  (gnu services desktop)
  (gnu services sddm)
  (gnu system locale)
  (guix packages)
  (packages claude-code)
  (packages dua)
  (packages dust)
  (packages fcitx5-rose-pine)
  (packages feishin)
  (packages foliate)
  (packages glow)
  (packages marksman)
  (packages mprocs)
  (packages clapper)
  (packages newsflash)
  (packages presenterm)
  (packages sddm-qylock)
  (packages skate)
  (packages uutils-coreutils)
  (packages wiki-tui)
  (packages xh)
  (packages yazi)
  (srfi srfi-1))

(operating-system
  ;; (inherit asahi-sway-os)
  (inherit asahi-plasma-os)
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
    (cons* (service tailscale-service-type)
           (service bluetooth-service-type)
           (service cups-service-type)
           (modify-services (operating-system-user-services asahi-plasma-os)
             (sddm-service-type config =>
               (sddm-configuration
                 (inherit config)
                 (theme "enfield"))))))
  (packages
    (cons*
      ;; browsers
      librewolf
      (specification->package "ungoogled-chromium-wayland")

      ;; terminal tools
      file
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
      nushell
      bat
      gitui
      starship
      tokei
      zoxide
      fd
      inotify-tools
      tmux
      helix
      bind:utils

      ;; multimedia
      ffmpeg
      yt-dlp
      cava
      mpv
      vlc
      audacity

      ;; build tools
      unzip
      libtool
      cmake
      clang

      ;; sway / wayland
      wmenu  ;; temporary, replace with wofi?
      swayidle
      swaylock
      waybar
      grim
      slurp
      mako
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
      zathura

      ;; network
      openvpn
      openresolv
      tailscale

      ;; CLI tools
      glow
      skate
      marksman
      yazi
      wiki-tui
      dust
      dua
      uutils-coreutils
      xh
      mprocs
      presenterm

      ;; login
      sddm-qylock-enfield
      qt5compat
      qtmultimedia

      ;; GUI apps
      feishin
      newsflash
      foliate
      moonlight-qt
      dolphin
      drawing
      (@ (gnu packages gnome-circle) polari)
      remmina
      wireshark
      qbittorrent
      obs
      papers
      blender
      gimp
      ;; krita
      klavaro

      ;; languages / runtimes
      racket
      qmk

      ;; system
      bluez
      pavucontrol
      power-profiles-daemon

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

      (remove (lambda (p) (equal? "kitty" (package-name p)))
              (operating-system-packages asahi-sway-os))))
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
             (device (file-system-label "asahi-guix-root")
             (mount-point "/swap")
             (type "btrfs")
             (options "subvol=swap,nodatacow")
             (needed-for-boot? #f)))
           %base-file-systems))
  (swap-devices
    (list (swap-space (target "/swap/swapfile")))))
