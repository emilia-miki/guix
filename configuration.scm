  (use-modules (asahi guix systems sway) (gnu) (srfi srfi-1) (guix packages) (btv tailscale) (gnu packages librewolf) (gnu packages chromium) (gnu packages) (gnu packages text-editors) (gnu packages wm) (gnu packages tmux) (gnu packages image) (gnu packages fcitx5) (gnu packages xdisorg) (gnu packages music) (gnu packages nushell) (gnu packages vpn) (gnu packages dns) (asahi guix packages linux) (gnu packages fonts) (gnu packages linux) (gnu services desktop) (gnu packages pulseaudio) (gnu packages racket) (gnu packages shellutils) (gnu packages admin) (gnu packages readline) (gnu packages audio) (gnu packages rust-apps) (gnu packages video) (gnu packages compression) (gnu packages autotools) (gnu packages cmake) (gnu packages llvm) (gnu packages firmware) (gnu packages pdf) (gnu packages games) (gnu packages kde-systemtools) (gnu packages gnome) (gnu packages vnc) (gnu packages networking) (gnu packages bittorrent) (gnu packages graphics) (gnu packages gimp) (gnu packages kde-graphics) (gnu packages education) (gnu packages version-control))

  (operating-system
    (inherit asahi-sway-os)
    (timezone "Europe/Kyiv")
    (users (cons* (user-account
                    (name "miki")
                    (group "users")
                    (supplementary-groups '("wheel" "audio" "video" "input" "netdev"))
                    (home-directory "/home/miki"))
                   %base-user-accounts))
    (services (cons*  (service tailscale-service-type)
                      (service bluetooth-service-type)
                      (operating-system-user-services asahi-sway-os)))
    (packages (cons*  librewolf
                      (specification->package "ungoogled-chromium-wayland")
                      wmenu ;; temporary, replace with wofi?
                      git
                      bluez
                      pavucontrol
                      racket
                      direnv
                      tree
                      rlwrap
                      cava
                      tree
                      hyperfine
                      ffmpeg
                      yt-dlp
                      unzip
                      libtool
                      cmake
                      clang
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
                      qmk

                      swayidle
                      zathura

                      ;; GUI software
                      moonlight-qt
                      dolphin
                      drawing
                      (@ (gnu packages gnome-circle) polari)
                      remmina
                      wireshark
                      vlc
                      mpv
                      qbittorrent
                      obs
                      papers
                      audacity
                      blender
                      gimp
                      ;; krita
                      klavaro

                      font-awesome
                      font-nerd-fira-code
                      font-google-noto          ;; noto-fonts
                      font-google-noto-sans-cjk ;; noto-fonts-cjk-sans
                      font-google-noto-serif-cjk ;; noto-fonts-cjk-serif
                      font-google-noto-emoji    ;; noto-fonts-color-emoji
                      font-dejavu               ;; dejavu_fonts
                      font-gnu-unifont              ;; unifont
                      font-ipa                  ;; ipafont
                      font-ipa-ex               ;; kochi-substitute equivalent
                      font-bitstream-vera       ;; ttf_bitstream_vera
                      ;; carlito, source-code-pro — check guix names
                      openvpn
                      openresolv
                      helix
                      waybar
                      tmux
                      nushell
                      grim
                      slurp
                      mako
                      fcitx5
                      wl-clipboard
                      playerctl
                      tailscale
                      (remove (lambda (p)
                        (equal? "kitty" (package-name p)))
                      (operating-system-packages asahi-sway-os))))
    (file-systems (cons* (file-system
                           (device (uuid "848E-1AEE" 'fat32))
                           (mount-point "/boot/efi")
                           (needed-for-boot? #t)
                           (type "vfat"))
                         (file-system
                           (device (file-system-label "asahi-guix-root"))
                           (mount-point "/")
                           (needed-for-boot? #t)
                           (type "btrfs"))
                         %base-file-systems)))
