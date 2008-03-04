(in-package :tempus)

(defclass special-search-data ()
  ((command-keys :accessor command-keys-of :initarg :command-keys :initform nil)
   (keywords :accessor keywords-of :initarg :keywords :initform nil)
   (to-vict :accessor to-vict-of :initarg :to-vict :initform nil)
   (to-room :accessor to-room-of :initarg :to-room :initform nil)
   (to-remote :accessor to-remote-of :initarg :to-remote :initform nil)
   (command :accessor command-of :initarg :command :initform nil)
   (flags :accessor flags-of :initarg :flags :initform nil)
   (arg :accessor arg-of :initarg :args :initform (make-array 3))
   (fail-chance :accessor fail-chance-of :initarg :fail-chance :initform nil)))
