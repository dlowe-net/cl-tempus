(in-package #:tempus)

(defun exit (ch dir)
  (aref (dir-option-of (in-room-of ch)) dir))

(defun first-word (str)
  (subseq str 0 (min (length str) (position #\space str))))

(defun do-simple-move (ch dir mode need-specials-check)
  (declare (ignore mode need-specials-check))
  (let ((destination (real-room (to-room-of (exit ch dir)))))
    (char-from-room ch)
    (char-to-room ch destination))

  (look-at-room ch (in-room-of ch) nil))

(defun perform-move (ch dir mode need-specials-check)
  (when (or (null ch)
            (null (in-room-of ch))
            (minusp dir)
            (>= dir +num-of-dirs+))
    (return-from perform-move))

  (let ((exit (exit ch dir)))
    (cond
      ((or (null exit)
           (null (to-room-of exit))
           (logtest (exit-info-of exit) +ex-nopass+)
           (and (logtest (exit-info-of exit) (logior +ex-secret+ +ex-hidden+))
                (logtest (exit-info-of exit) +ex-closed+)
                (not (immortalp ch))
                (not (noncorporealp ch))))
       (send-to-char ch "~a~%"
                     (case (random-range 0 5)
                       (0 "Alas, you cannot go that way...")
                       (1 "You don't seem to be able to go that way.")
                       (2 "Sorry, you can't go in that direction!")
                       (3 "There is no way to move in that direction.")
                       (4 "You can't go that way, slick...")
                       (t "You'll have to choose another direction."))))
      ((and (logtest (exit-info-of exit) +ex-closed+)
            (not (noncorporealp ch))
            (immortalp ch))
       (if (keyword-of exit)
           (let ((exit-name (first-word (keyword-of exit))))
             (send-to-char ch "The ~a seem~a to be closed.~%"
                           exit-name
                           (if (and (not (string= exit-name "porticullis"))
                                    (char= (char exit-name (1- (length exit-name)))
                                           #\s))
                               "" "s")))
           (send-to-char ch "It seems to be closed.~%")))
      (t
       (do-simple-move ch dir mode need-specials-check)))))