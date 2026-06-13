(define-module (home fcitx5)
  #:use-module (gnu home services)
  #:use-module (gnu packages fcitx5)
  #:use-module (gnu services)
  #:use-module (guix gexp)
  #:use-module (packages fcitx5-rose-pine)
  #:export (%fcitx5-services))

(define %fcitx5-config
  "\
[Hotkey]
EnumerateWithTriggerKeys=True
EnumerateForwardKeys=
EnumerateBackwardKeys=
EnumerateSkipFirst=False
ModifierOnlyKeyTimeout=250

[Hotkey/TriggerKeys]
0=Super+space
1=Zenkaku_Hankaku
2=Hangul

[Hotkey/ActivateKeys]
0=Hangul_Hanja

[Hotkey/DeactivateKeys]
0=Hangul_Romaja

[Hotkey/AltTriggerKeys]
0=Shift_L

[Hotkey/EnumerateGroupForwardKeys]
0=Super+space

[Hotkey/EnumerateGroupBackwardKeys]
0=Shift+Super+space

[Hotkey/PrevPage]
0=Up

[Hotkey/NextPage]
0=Down

[Hotkey/PrevCandidate]
0=Shift+Tab

[Hotkey/NextCandidate]
0=Tab

[Hotkey/TogglePreedit]
0=Control+Alt+P

[Behavior]
ActiveByDefault=False
resetStateWhenFocusIn=No
ShareInputState=All
PreeditEnabledByDefault=True
ShowInputMethodInformation=True
showInputMethodInformationWhenFocusIn=False
CompactInputMethodInformation=False
ShowFirstInputMethodInformation=True
DefaultPageSize=5
OverrideXkbOption=False
CustomXkbOption=
EnabledAddons=
PreloadInputMethod=True
AllowInputMethodForPassword=False
ShowPreeditForPassword=False
AutoSavePeriod=30

[Behavior/DisabledAddons]
0=notificationitem
")

(define %fcitx5-profile
  "\
[Groups/0]
Name=Default
Default Layout=us
DefaultIM=keyboard-ua

[Groups/0/Items/0]
Name=keyboard-us
Layout=

[Groups/0/Items/1]
Name=keyboard-ua
Layout=

[Groups/0/Items/2]
Name=anthy
Layout=

[GroupOrder]
0=Default
")

(define %fcitx5-classicui
  "\
Vertical Candidate List=False
WheelForPaging=True
Font=\"Sans 10\"
MenuFont=\"Sans 10\"
TrayFont=\"Sans Bold 10\"
TrayOutlineColor=#000000
TrayTextColor=#ffffff
PreferTextIcon=False
ShowLayoutNameInIcon=False
UseInputMethodLanguageToDisplayText=True
Theme=rose-pine
DarkTheme=rose-pine
UseDarkTheme=False
UseAccentColor=True
PerScreenDPI=False
ForceWaylandDPI=0
EnableFractionalScale=True
")

(define %fcitx5-hangul
  "\
Keyboard=Dubeolsik
AutoReorder=True
WordCommit=False
HanjaMode=False

[HanjaModeToggleKey]
0=Hangul_Hanja
1=F9

[PrevPage]
0=Up

[NextPage]
0=Down

[PrevCandidate]
0=Shift+Tab

[NextCandidate]
0=Tab
")

(define %fcitx5-clipboard
  "\
[Trigger Key]
")

(define-public %fcitx5-services
  (list
   (simple-service 'fcitx5-packages
                   home-profile-service-type
                   (list fcitx5 fcitx5-gtk fcitx5-gtk4 fcitx5-qt fcitx5-anthy
                         fcitx5-hangul fcitx5-rose-pine fcitx5-configtool))

   (simple-service 'fcitx5-xdg-config
                   home-xdg-configuration-files-service-type
                   `(("fcitx5/config"
                      ,(plain-file "fcitx5-config" %fcitx5-config))
                     ("fcitx5/profile"
                      ,(plain-file "fcitx5-profile" %fcitx5-profile))
                     ("fcitx5/conf/classicui.conf"
                      ,(plain-file "fcitx5-classicui.conf" %fcitx5-classicui))
                     ("fcitx5/conf/hangul.conf"
                      ,(plain-file "fcitx5-hangul.conf" %fcitx5-hangul))
                     ("fcitx5/conf/clipboard.conf"
                      ,(plain-file "fcitx5-clipboard.conf" %fcitx5-clipboard))))))
