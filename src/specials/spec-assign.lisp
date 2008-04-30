(in-package :tempus)

(defparameter +special-cmd+ 0)          ; special command response
(defparameter +special-tick+ 1)         ; special periodic action
(defparameter +special-death+ 2)        ; special death notification
(defparameter +special-fight+ 3)        ; special fight starting
(defparameter +special-combat+ 4)       ; special in-combat ability
(defparameter +special-enter+ 5)        ; special upon entrance
(defparameter +special-leave+ 6)        ; special upon exit
(defparameter +special-reset+ 7)        ; zone reset

(defvar *spec-list*)

(defun find-spec-index-arg (str)
  (position str *spec-list* :test #'string-equal))

(defun assign-specials (kind config-path retrieval-func setter-func)
  (with-open-file (inf config-path :direction :input)
    (loop for line = (get-line inf)
       while line
       as result = (scan #/^(\d+)\s+([^\s#]+)/ line)
       when result do
       (let* ((vnum (parse-integer (regref result 1)))
              (thing (funcall retrieval-func vnum))
              (index (find-spec-index-arg (regref result 2))))
         (when (and (null thing) (not *mini-mud*))
           (slog "Error in ~a spec file: ~a <~d> does not exist."
                 kind kind vnum))
         (cond
           ((null index)
            (slog "Error in ~a spec file: ptr <~a> does not exist."
                  kind (regref result 2)))
           ((not (logtest (flags-of (aref *spec-list* index)) +spec-mob+))
            (slog "Attempt to assign ptr <~a> to a ~a."
                  (regref result 2) kind))
           (t
            (funcall setter-func thing (func-of (aref *spec-list* index)))))))))

(defun assign-mobiles ()
  (assign-specials "mobile" +spec-file-mob+ #'real-mobile-proto
                   (lambda (mob func)
                     (setf (func-of (shared-of mob)) func))))
(defun assign-objects ()
  (assign-specials "object" +spec-file-obj+ #'real-object-proto
                   (lambda (obj func)
                     (setf (func-of (shared-of obj)) func))))
(defun assign-rooms ()
  (assign-specials "room" +spec-file-rm+ #'real-room
                   (lambda (room func)
                     (setf (func-of room) func))))