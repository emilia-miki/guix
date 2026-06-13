(define-module (packages ollama)
  #:use-module (ollama-bin)
  #:use-module (guix packages)
  #:use-module (guix download))

(define-public ollama-linux-arm64
  (package
   (inherit ollama-linux-amd64)
   (name "ollama-linux-arm64")
   (source
    (origin
     (method url-fetch)
     (uri (string-append
           "https://github.com/ollama/ollama/releases/download/v"
           (package-version ollama-linux-amd64)
           "/ollama-linux-arm64.tgz"))
     (sha256
      (base32 "1kg0kd1ig7ljp6r2rf5kk40my97829wxpjsxv63bwvwdb0cgk5kv"))))
   (supported-systems (list "aarch64-linux"))))
