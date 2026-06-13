(define-module (home bluetooth)
  #:use-module (gnu home services)
  #:use-module (gnu home services shepherd)
  #:use-module (gnu packages glib)
  #:use-module (gnu services shepherd)
  #:use-module (guix gexp)
  #:export (%bluetooth-services))

;; When the AVENTHO 100 reconnects it brings up BLE first (for its companion
;; app), which BlueZ treats as a full "Connected" state.  BlueZ does not
;; automatically layer the BR/EDR A2DP profile on top of an existing LE
;; connection, so PipeWire never sees an audio sink.  This watcher monitors
;; D-Bus for the device becoming connected and calls ConnectProfile to force
;; A2DP up every time.

(define %aventho-device-path "/org/bluez/hci0/dev_00_22_BB_7F_11_15")
(define %aventho-a2dp-uuid   "0000110b-0000-1000-8000-00805f9b34fb")

(define aventho-a2dp-watcher
  (program-file "aventho-a2dp-watcher"
    #~(begin
        (use-modules (ice-9 popen) (ice-9 rdelim))

        (define (connect-a2dp!)
          (sleep 1) ; let BlueZ settle after the connection event
          (system* #$(file-append dbus "/bin/dbus-send")
                   "--system"
                   "--dest=org.bluez"
                   #$%aventho-device-path
                   "org.bluez.Device1.ConnectProfile"
                   #$(string-append "string:" %aventho-a2dp-uuid)))

        (let ((port (open-pipe*
                      OPEN_READ
                      #$(file-append dbus "/bin/dbus-monitor")
                      "--system"
                      #$(string-append
                          "type='signal',"
                          "interface='org.freedesktop.DBus.Properties',"
                          "path='" %aventho-device-path "'"))))
          (let loop ((expecting #f))
            (let ((line (read-line port)))
              (unless (eof-object? line)
                (cond
                  ((string-contains line "\"Connected\"")
                   (loop #t))
                  ((and expecting (string-contains line "boolean true"))
                   (connect-a2dp!)
                   (loop #f))
                  ((and expecting (string-contains line "boolean"))
                   (loop #f)) ; Connected=false, ignore
                  (else
                   (loop expecting))))))))))

(define-public %bluetooth-services
  (list
    (simple-service 'aventho-a2dp
      home-shepherd-service-type
      (list
        (shepherd-service
          (provision '(aventho-a2dp))
          (documentation
            "Auto-connect A2DP profile when AVENTHO 100 headphones connect.")
          (start #~(make-forkexec-constructor
                     (list #$aventho-a2dp-watcher)
                     #:log-file (string-append (getenv "HOME")
                                               "/.local/var/log/aventho-a2dp.log")))
          (stop #~(make-kill-destructor))
          (respawn? #t))))))
