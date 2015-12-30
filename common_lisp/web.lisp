;; quicklisp
(let ((quicklisp-init (merge-pathnames "quicklisp/setup.lisp"
                                       (user-homedir-pathname))))
  (when (probe-file quicklisp-init)
    (load quicklisp-init)))

;; https://twitter.com/nitro_idiot/status/612084253010980864
(ql:quickload "drakma" :silent t)
(ql:quickload "cl-json" :silent t)

(setf drakma:*drakma-default-external-format* :utf-8)

;; これをしないと JSON response が文字列として解釈されない
(pushnew '("application" . "json") drakma:*text-content-types* :test #'equal)


;; (format t (drakma:http-request "http://lisp.org/"))
;; (drakma:http-request "https://app.asana.com/api/1.0/users/me")

;; (defparameter *a* (drakma:http-request "https://app.asana.com/api/1.0/users/me" :additional-headers (list (cons "Authorization" "Bearer <<api_key>>"))))

;; make str to concatenate strings
;; (defun (str ))

(defun asana (endpoint)
  (let ((raw (drakma:http-request (concatenate 'string "https://app.asana.com/api/1.0" endpoint)
                                  :additional-headers '(("Authorization" . "Bearer <<api_key>>")))))
    (cdr (assoc :DATA (json:decode-json-from-string raw)))))

;; (print (asana "/users/me"))
;; (print (asana "/workspaces"))

;; ;; タスク一覧
;; (print (asana "/tasks?workspace=<<workspace_id>>&assignee=me"))

;; ;; 完了タスク一覧 + 未完了タスク
;; completed_since, which returns all "incomplete or completed since X" tasks.
;; http://stackoverflow.com/questions/25613230/asana-api-how-to-get-incomplete-tasks-only
;; (print (asana "/tasks?workspace=<<workspace_id>>&assignee=me&completed_since=2015-10-20T00:00:00.000Z"))

;; ;; 未完了タスク一覧
;; (print (asana "/tasks?workspace=<<workspace_id>>&assignee=me&completed_since=now"))

;; ;; 完了タスク一覧, のみ
;; (defparameter *result* (set-difference (asana "/tasks?workspace=<<workspace_id>>&assignee=me&completed_since=2010-01-01T00:00:00.000Z")
;;                                        (asana "/tasks?workspace=<<workspace_id>>&assignee=me&completed_since=now")
;;                                        :test 'equal))
;;
;; (print (length *result*))
;; (print *result*)
;; (print (subseq *result* 0 10))
;; (print `(subseq *result* ,(- (length *result*) 10) ,(- (length *result*) 1)))
;; (print (subseq *result* (- (length *result*) 10) (- (length *result*) 1)))

