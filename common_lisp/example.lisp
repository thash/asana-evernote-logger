#|
exec /usr/local/bin/sbcl --noinform --non-interactive --load "$0" "$@"
|#
;; $ clisp example.lisp
(format t "hey") ;; => STDOUT "hey"
