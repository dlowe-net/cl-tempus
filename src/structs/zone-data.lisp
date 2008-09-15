(in-package :tempus)

(defparameter +zone-autosave+ (ash 1 0))
(defparameter +zone-resetsave+ (ash 1 1))
(defparameter +zone-notifyowner+ (ash 1 2))
(defparameter +zone-locked+ (ash 1 3))
(defparameter +zone-nomagic+ (ash 1 4))
(defparameter +zone-nolaw+ (ash 1 5))
(defparameter +zone-noweather+ (ash 1 6))
(defparameter +zone-nocrime+ (ash 1 7))
(defparameter +zone-frozen+ (ash 1 8))
(defparameter +zone-isolated+ (ash 1 9))
(defparameter +zone-soundproof+ (ash 1 10))
(defparameter +zone-noidle+ (ash 1 11))
(defparameter +zone-fullcontrol+ (ash 1 12))
(defparameter +zone-paused+ (ash 1 13))
(defparameter +zone-evil-ambience+ (ash 1 14))
(defparameter +zone-good-ambience+ (ash 1 15))
(defparameter +zone-norecalc+ (ash 1 16))

(defparameter +zone-search-approved+ (ash 1 19))
(defparameter +zone-mobs-approved+ (ash 1 20))
(defparameter +zone-objs-approved+ (ash 1 21))
(defparameter +zone-rooms-approved+ (ash 1 22))
(defparameter +zone-zcmds-approved+ (ash 1 23))
(defparameter +zone-shops-approved+ (ash 1 24))
(defparameter +zone-mobs-modified+ (ash 1 25))
(defparameter +zone-objs-modified+ (ash 1 26))
(defparameter +zone-rooms-modified+ (ash 1 27))
(defparameter +zone-zone-modified+ (ash 1 28))

(defun zone-flagged (zone bit)
  (logtest (flags-of zone) bit))

(defun zone-approvedp (zone)
  (and (not (zone-flagged zone +zone-mobs-approved+))
       (not (zone-flagged zone +zone-rooms-approved+))
       (not (zone-flagged zone +zone-objs-approved+))
       (not (zone-flagged zone +zone-search-approved+))
       (not (zone-flagged zone +zone-zcmds-approved+))
       (not (zone-flagged zone +zone-shops-approved+))))

(defparameter +plane-prime-1+ 0)
(defparameter +plane-prime-2+ 1)
(defparameter +plane-neverwhere+ 2)
(defparameter +plane-underdark+ 3)
(defparameter +plane-western+ 4)
(defparameter +plane-morbidian+ 5)
(defparameter +max-prime-plane+ 9)
(defparameter +plane-astral+ 10)
(defparameter +plane-hell-1+ 11)
(defparameter +plane-hell-2+ 12)
(defparameter +plane-hell-3+ 13)
(defparameter +plane-hell-4+ 14)
(defparameter +plane-hell-5+ 15)
(defparameter +plane-hell-6+ 16)
(defparameter +plane-hell-7+ 17)
(defparameter +plane-hell-8+ 18)
(defparameter +plane-hell-9+ 19)
(defparameter +plane-ghenna+ 20)
(defparameter +plane-abyss+ 25)
(defparameter +plane-olc+ 39)
(defparameter +plane-olympus+ 40)
(defparameter +plane-costal+ 41)
(defparameter +plane-heaven+ 43)
(defparameter +plane-doom+ 50)
(defparameter +plane-shadow+ 51)
(defparameter +plane-elem-water+ 70)
(defparameter +plane-elem-fire+ 71)
(defparameter +plane-elem-air+ 72)
(defparameter +plane-elem-earth+ 73)
(defparameter +plane-elem-pos+ 74)
(defparameter +plane-elem-neg+ 75)
(defparameter +plane-pelem-magma+ 76)
(defparameter +plane-pelem-ooze+ 77)
(defparameter +plane-pelem-ice+ 78)
(defparameter +plane-pelem-smoke+ 79)
(defparameter +plane-elysium+ 80)

(defparameter +time-timeless+ 0)
(defparameter +time-modrian+ 1)
(defparameter +time-electro+ 2)
(defparameter +time-past+ +time-modrian+)
(defparameter +time-future+ +time-electro+)

(defparameter +zone-no-pk+ 0)
(defparameter +zone-neutral-pk+ 1)
(defparameter +zone-chaotic-pk+ 2)

(defclass reset-com ()
  ((command :accessor command-of :initarg :command :initform nil)
   (if-flag :accessor if-flag-of :initarg :if-flag :initform nil)
   (arg1 :accessor arg1-of :initarg :arg1 :initform nil)
   (arg2 :accessor arg2-of :initarg :arg2 :initform nil)
   (arg3 :accessor arg3-of :initarg :arg3 :initform nil)
   (line :accessor line-of :initarg :line :initform nil)
   (prob :accessor prob-of :initarg :prob :initform nil)))

(defclass weather-data ()
  ((pressure :accessor pressure-of :initarg :pressure :initform nil)
   (change :accessor change-of :initarg :change :initform nil)
   (sky :accessor sky-of :initarg :sky :initform nil)
   (sunlight :accessor sunlight-of :initarg :sunlight :initform nil)
   (moonlight :accessor moonlight-of :initarg :moonlight :initform nil)
   (temp :accessor temp-of :initarg :temp :initform nil)
   (humid :accessor humid-of :initarg :humid :initform nil)))

(defclass zone-data ()
  ((name :accessor name-of :initarg :name :initform nil)
   (lifespan :accessor lifespan-of :initarg :lifespan :initform nil)
   (age :accessor age-of :initarg :age :initform nil)
   (top :accessor top-of :initarg :top :initform nil)
   (respawn-pt :accessor respawn-pt-of :initarg :respawn-pt :initform nil)
   (reset-mode :accessor reset-mode-of :initarg :reset-mode :initform nil)
   (number :accessor number-of :initarg :number :initform nil)
   (time-frame :accessor time-frame-of :initarg :time-frame :initform nil)
   (plane :accessor plane-of :initarg :plane :initform nil)
   (owner-idnum :accessor owner-idnum-of :initarg :owner-idnum :initform nil)
   (co-owner-idnum :accessor co-owner-idnum-of :initarg :co-owner-idnum :initform nil)
   (author :accessor author-of :initarg :author :initform nil)
   (enter-count :accessor enter-count-of :initarg :enter-count :initform nil)
   (flags :accessor flags-of :initarg :flags :initform nil)
   (hour-mod :accessor hour-mod-of :initarg :hour-mod :initform nil)
   (year-mod :accessor year-mod-of :initarg :year-mod :initform nil)
   (lattitude :accessor lattitude-of :initarg :lattitude :initform nil)
   (min-lvl :accessor min-lvl-of :initarg :min-lvl :initform nil)
   (min-gen :accessor min-gen-of :initarg :min-gen :initform nil)
   (max-lvl :accessor max-lvl-of :initarg :max-lvl :initform nil)
   (max-gen :accessor max-gen-of :initarg :max-gen :initform nil)
   (pk-style :accessor pk-style-of :initarg :pk-style :initform nil)
   (public-desc :accessor public-desc-of :initarg :public-desc :initform nil)
   (private-desc :accessor private-desc-of :initarg :private-desc :initform nil)
   (num-players :accessor num-players-of :initarg :num-players :initform 0)
   (idle-time :accessor idle-time-of :initarg :idle-time :initform 0)
   (world :accessor world-of :initarg :world :initform nil)
   (cmds :accessor cmds-of :initarg :cmd :initform nil)
   (weather :accessor weather-of :initarg :weather :initform nil)))

