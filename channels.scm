(cons* (channel
         (name 'asahi)
         (url "https://codeberg.org/asahi-guix/channel")
         (branch "main")
         (introduction
           (make-channel-introduction
             "3eeb493b037bea44f225c4314c5556aa25aff36c"
             (openpgp-fingerprint
               "D226 A339 D8DF 4481 5DDE  0CA0 3DDA 5252 7D2A C199"))))
       (channel
         (name 'tailscale)
         (url "https://github.com/umanwizard/guix-tailscale")
         (branch "main")
         (introduction
           (make-channel-introduction
             "c72e15e84c4a9d199303aa40a81a95939db0cfee"
             (openpgp-fingerprint
               "9E53 FC33 B832 8C74 5E7B 31F7 0226 C10D 7877 B741"))))
       (channel
         (name 'nonguix)
         (url "https://gitlab.com/nonguix/nonguix")
         (introduction
           (make-channel-introduction
             "897c1a470da759236cc11798f4e0a5f7d4d59fbc"
             (openpgp-fingerprint
               "2A39 3FFF 68F4 EF7A 3D29  12AF 6F51 20A0 22FB B2D5"))))
       (channel
         (name 'sijo)
         (url "https://git.sr.ht/~simendsjo/dotfiles")
         (branch "main")
         (introduction
           (make-channel-introduction
             "c352f7331b1722b2ffb964572c7f7fbec585bd2f"
             (openpgp-fingerprint
               "B0F2 D6C5 2936 95FD 57B5  D255 77BC 6345 B65D 6CFB"))))
       (channel
         (name 'ollama-guix)
         (url "https://codeberg.org/tusharhero/ollama-guix"))
       %default-channels)
