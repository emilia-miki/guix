# my guix system config

i'm a very messy person and my config is very messy. generally here's what is in here:
* Macbook M1 Air system conf (asahi linux)
* overrides/inherits for packages that failed to build on aarch64 (some of them might be unnecessary now)
* overrides/inherits for packages that didn't work on wayland in the default build (also not sure if it could be fixed in a better way)
* some custom packages that are not in guix, non-guix, or other channels i could find (i didn't look too hard)
* sway config with related tools
* GTK/Qt rose-pine theme, rose-pine theme for other software where possible
* Emacs config (with coding config + IRC, RSS, PDF, Djvu)
* Fonts
* minimum set of graphical apps, most things are done via browser/emacs/terminal (i do not like TUI apps but i have some for now). main ones are:
  * dolphin because all other graphical FMs are cringe
  * ark for archives just bc fits well with dolphin
  * foot for terminal
  * chromium for things that don't work super well on firefox or for PWAs (teams)
  * fcitx5 with japanese support
  * feishin for music (i have a navidrome server)
  * moonlight for "better VNC" over LAN
  * remmina for VNC
  * imv, mpv for media
  * preview-app - MacOS-like Preview app for document signing
  * libreoffice, wireshark, OBS, blender, audacity, gimp - self-explanatory
