(in-package #:tempus.tests)

(defsuite (tempus.net :in test))
(in-suite tempus.net)

(deftest prompts ()
  (with-fixtures ((alice mock-player))
    ;; Odd compact level must be set
    (setf (tempus::compact-level-of (tempus::account-of alice)) 1)
    ;; Must not already need prompt
    (setf (tempus::need-prompt-p (tempus::link-of alice)) nil)
    ;; Autoprompt must be on
    (setf (tempus::bitp (tempus::prefs-of alice) tempus::+pref-autoprompt+) t)
    ;; Trigger possible bug
    (tempus::cxn-write (tempus::link-of alice) "foo~%")
    (is (string= (char-output alice) "~%foo~%"))))
