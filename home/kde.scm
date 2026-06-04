(define-module (home kde)
  #:use-module (gnu home services)
  #:use-module (gnu services)
  #:use-module (guix gexp)
  #:export (%kde-services))

(define-public %kde-services
  (list
    (simple-service 'kde-xdg-config
      home-xdg-configuration-files-service-type
      `(("kwinrc"
         ,(local-file "files/kwinrc"))
        ("kdeglobals"
         ,(local-file "files/kdeglobals"))
        ("kglobalshortcutsrc"
         ,(local-file "files/kglobalshortcutsrc"))
        ("kwinrulesrc"
         ,(local-file "files/kwinrulesrc"))
        ("kxkbrc"
         ,(plain-file "kxkbrc"
            "[Layout]
DisplayNames=
Options=ctrl:hyper_capscontrol
ResetOldOptions=true
VariantList=
LayoutList=us
Use=true
"))
        ("kcminputrc"
         ,(plain-file "kcminputrc"
            "[Libinput][1452][641][Apple SPI Trackpad]
DisableWhileTyping=false
"))
        ("konsolerc"
         ,(plain-file "konsolerc"
            "MenuBar=Disabled

[Desktop Entry]
DefaultProfile=Custom.profile

[General]
ConfigVersion=1

[TabBar]
TabBarVisibility=AlwaysHideTabBar

[UiSettings]
ColorScheme=
"))
        ("powerdevilrc"
         ,(plain-file "powerdevilrc"
            "[AC][Display]
DimDisplayIdleTimeoutSec=-1
DimDisplayWhenIdle=false
TurnOffDisplayIdleTimeoutSec=-1
TurnOffDisplayWhenIdle=false

[AC][SuspendAndShutdown]
AutoSuspendAction=0
LidAction=0

[Battery][Display]
DimDisplayIdleTimeoutSec=-1
DimDisplayWhenIdle=false
TurnOffDisplayIdleTimeoutSec=-1
TurnOffDisplayWhenIdle=false

[Battery][SuspendAndShutdown]
AutoSuspendAction=0
AutoSuspendIdleTimeoutSec=1800
LidAction=0

[LowBattery][Display]
DimDisplayIdleTimeoutSec=-1
DimDisplayWhenIdle=false
TurnOffDisplayIdleTimeoutSec=-1
TurnOffDisplayWhenIdle=false

[LowBattery][SuspendAndShutdown]
AutoSuspendAction=0
LidAction=0
"))
        ("plasma-localerc"
         ,(plain-file "plasma-localerc"
            "[Formats]
LANG=en_DK.UTF-8
LC_MONETARY=en_IE.UTF-8
"))
        ("Trolltech.conf"
         ,(plain-file "Trolltech.conf"
            "[qt]
GUIEffects=none
KDE\\contrast=7
KWinPalette\\activeBackground=#161925
KWinPalette\\activeBlend=#161925
KWinPalette\\activeForeground=#d3dae3
KWinPalette\\activeTitleBtnBg=#161925
KWinPalette\\frame=#161925
KWinPalette\\inactiveBackground=#161925
KWinPalette\\inactiveBlend=#161925
KWinPalette\\inactiveForeground=#a6acba
KWinPalette\\inactiveFrame=#161925
KWinPalette\\inactiveTitleBtnBg=#161925
Palette\\active=#d3dae3, #161925, #373f5d, #2b3048, #0b0c12, #131620, #d3dae3, #ffffff, #c3c7d1, #161925, #161925, #08090d, #a93076, #ffffff, #f7bcd4, #7cb7ff, #141a21, #000000, #171b28, #d3dae3, #a6acba, #a93076
Palette\\disabled=#545863, #151823, #d9dbe6, #acb1cb, #8b93ba, #5e6b9f, #545863, #ffffff, #4f525d, #151823, #151823, #acb1cb, #151823, #545863, #604e5e, #374d6c, #13191f, #000000, #171b28, #d3dae3, #454955, #151823
Palette\\inactive=#d3dae3, #161925, #373f5d, #2b3048, #0b0c12, #131620, #d3dae3, #ffffff, #c3c7d1, #161925, #161925, #08090d, #4a1938, #d3dae3, #f7bcd4, #7cb7ff, #141a21, #000000, #171b28, #d3dae3, #a6acba, #4a1938
font=\"Noto Sans,10,-1,0,400,0,0,0,0,0,0,0,0,0,0,1\"
"))
        ("mimeapps.list"
         ,(plain-file "mimeapps.list"
            "[Added Associations]
application/json=emacsclient.desktop;
application/x-docbook+xml=emacsclient.desktop;
application/x-yaml=emacsclient.desktop;
text/markdown=emacsclient.desktop;
text/plain=emacsclient.desktop;
text/x-cmake=emacsclient.desktop;
x-scheme-handler/http=librewolf.desktop;
x-scheme-handler/https=librewolf.desktop;

[Default Applications]
application/json=emacsclient.desktop;
application/x-docbook+xml=emacsclient.desktop;
application/x-yaml=emacsclient.desktop;
text/markdown=emacsclient.desktop;
text/plain=emacsclient.desktop;
text/x-cmake=emacsclient.desktop;
x-scheme-handler/http=librewolf.desktop;
x-scheme-handler/https=librewolf.desktop;
"))
        ("autostart/emacs.desktop"
         ,(plain-file "emacs-autostart.desktop"
            "[Desktop Entry]
Name=Emacs
Exec=emacs %F
Icon=emacs
Type=Application
Categories=Development;TextEditor;
"))
        ("autostart/feishin.desktop"
         ,(plain-file "feishin-autostart.desktop"
            "[Desktop Entry]
Name=Feishin
Exec=feishin
Icon=feishin
Type=Application
Categories=Audio;Music;AudioVideo;
"))
        ("autostart/librewolf.desktop"
         ,(plain-file "librewolf-autostart.desktop"
            "[Desktop Entry]
Name=LibreWolf
Exec=librewolf %u
Icon=librewolf
Type=Application
Categories=Network;WebBrowser;
"))))

    (simple-service 'kde-home-files
      home-files-service-type
      `((".local/share/konsole/Custom.profile"
         ,(local-file "files/Custom.profile"))
        (".local/share/konsole/Breeze.colorscheme"
         ,(local-file "files/Breeze.colorscheme"))))

    (simple-service 'kde-wallpaper-activation
      home-activation-service-type
      #~(begin
          (use-modules (guix utils) (ice-9 textual-ports))
          (let* ((home     (getenv "HOME"))
                 (wallpaper #$(local-file "files/dark-souls-3-kiln-of-the-first-flame-uhd-4k-wallpaper.jpg"))
                 (panel-template #$(local-file "files/plasma-panel.ini"))
                 (config-dir (string-append home "/.config")))
            (define (write-config name content)
              (call-with-output-file (string-append config-dir "/" name)
                (lambda (port) (display content port))))
            (write-config "kscreenlockerrc"
              (string-append
                "[Daemon]\n"
                "Timeout=15\n"
                "\n"
                "[Greeter][Wallpaper][org.kde.image][General]\n"
                "Image=file://" wallpaper "\n"
                "PreviewImage=file://" wallpaper "\n"))
            (write-config "plasmarc"
              (string-append
                "[Theme]\n"
                "name=Dexy-Color-Plasma\n"
                "\n"
                "[Wallpapers]\n"
                "usersWallpapers=" wallpaper "\n"))
            (write-config "plasma-org.kde.plasma.desktop-appletsrc"
              (string-replace-substring
                (call-with-input-file panel-template get-string-all)
                "@WALLPAPER@"
                (string-append "file://" wallpaper))))))))
