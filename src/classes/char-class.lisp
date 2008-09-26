(in-package #:tempus)

;; 0 - class/race combination not allowed
;; 1 - class/race combination allowed only for secondary class
;; 2 - class/race combination allowed for primary class
(defparameter +race-restrictions+
;;                      MG CL TH WR BR PS PH CY KN RN BD MN VP MR S1 S2 S3
  #2A((#.+race-human+    2  2  2  0  2  2  2  2  2  2  2  2  0  2  0  0  0 )
      (#.+race-elf+      2  2  2  0  0  2  2  2  2  2  2  2  0  2  0  0  0 )
      (#.+race-dwarf+    0  2  2  0  2  1  1  1  2  0  0  0  0  1  0  0  0 )
      (#.+race-half-orc+ 0  0  2  0  2  0  2  2  0  0  0  0  0  2  0  0  0 )
      (#.+race-halfling+ 2  2  2  0  2  1  1  1  2  2  2  2  0  1  0  0  0 )
      (#.+race-tabaxi+   2  2  2  0  2  2  2  2  0  2  0  2  0  2  0  0  0 )
      (#.+race-drow+     2  2  2  0  0  1  1  1  2  2  2  0  0  1  0  0  0 )
      (#.+race-minotaur+ 2  2  0  0  2  0  1  1  0  2  0  0  0  1  0  0  0 )
      (#.+race-orc+      0  0  1  0  2  0  1  2  0  0  0  2  0  2  0  0  0 )))

(defun invalid-char-class (ch obj)
  "Used to determine if a piece of equipment is usable by a particular character class, based on the +ITEM-ANTI-<class>+ bitvectors"
  (cond
    ((and (not (is-npc ch))
          (plusp (owner-id-of (shared-of obj)))
          (/= (owner-id-of (shared-of obj)) (idnum-of ch)))
     nil)
    ((or (and (is-obj-stat obj +item-anti-magic-user+) (is-magic-user ch))
         (and (is-obj-stat obj +item-anti-cleric+) (is-cleric ch))
         (and (is-obj-stat obj +item-anti-warrior+) (is-warrior ch))
         (and (is-obj-stat obj +item-anti-thief+) (is-thief ch))
         (and (is-obj-stat obj +item-anti-barb+) (is-barb ch))
         (and (is-obj-stat obj +item-anti-psychic+) (is-psionic ch))
         (and (is-obj-stat obj +item-anti-physic+) (is-physic ch))
         (and (is-obj-stat obj +item-anti-cyborg+) (is-cyborg ch))
         (and (is-obj-stat obj +item-anti-knight+) (is-knight ch))
         (and (is-obj-stat obj +item-anti-ranger+) (is-ranger ch))
         (and (is-obj-stat obj +item-anti-bard+) (is-bard ch))
         (and (is-obj-stat obj +item-anti-monk+) (is-monk ch))
         (and (is-obj-stat2 obj +item2-anti-merc+) (is-merc ch))
         (and (not (approvedp obj))
              (not (testerp ch))
              (not (immortalp ch))))
     nil)
    ((and (or (not (is-obj-stat3 obj +item3-req-mage+)) (is-mage ch))
          (or (not (is-obj-stat3 obj +item3-req-cleric+)) (is-cleric ch))
          (or (not (is-obj-stat3 obj +item3-req-thief+)) (is-thief ch))
          (or (not (is-obj-stat3 obj +item3-req-warrior+)) (is-warrior ch))
          (or (not (is-obj-stat3 obj +item3-req-barb+)) (is-barb ch))
          (or (not (is-obj-stat3 obj +item3-req-psionic+)) (is-psionic ch))
          (or (not (is-obj-stat3 obj +item3-req-physic+)) (is-physic ch))
          (or (not (is-obj-stat3 obj +item3-req-cyborg+)) (is-cyborg ch))
          (or (not (is-obj-stat3 obj +item3-req-knight+)) (is-knight ch))
          (or (not (is-obj-stat3 obj +item3-req-ranger+)) (is-ranger ch))
          (or (not (is-obj-stat3 obj +item3-req-bard+)) (is-bard ch))
          (or (not (is-obj-stat3 obj +item3-req-monk+)) (is-monk ch))
          (or (not (is-obj-stat3 obj +item3-req-vampire+)) (is-vampire ch))
          (or (not (is-obj-stat3 obj +item3-req-mercenary+)) (is-merc ch))
          (or (not (is-obj-stat3 obj +item3-req-spare1+)) (is-spare1 ch))
          (or (not (is-obj-stat3 obj +item3-req-spare2+)) (is-spare2 ch))
          (or (not (is-obj-stat3 obj +item3-req-spare3+)) (is-spare3 ch)))
     nil)
    (t
     t)))

(defparameter +prac-params+
  #2A(
  ;; MG  CL  TH  WR  BR  PS  PH  CY  KN  RN  BD  MN  VP  MR  S1  S2  S3
	(75  75  70  70  65  75  75  80  75  75  80  75  75  70  70  70  70)
	(25  20  20  20  20  25  20  30  20  25  30  20  15  25  25  25  25)
	(15  15  10  15  10  15  15  15  15  15  15  10  10  10  10  10  10)
	(spl spl skl skl skl trg alt prg spl spl sng zen spl skl skl skl skl)))

(defun learned (ch)
  (if (is-remort ch)
      (+ (max (aref +prac-params+ 0 (min (1- +num-classes+) (char-class-of ch)))
              (aref +prac-params+ 0 (min (1- +num-classes+) (remort-char-class-of ch))))
         (* (remort-gen-of ch) 2))))

(defun gain-skill-proficiency (ch skill)
  (let ((learned (if (or (= skill +skill-read-scrolls+)
                         (= skill +skill-use-wands+))
                     10
                     (learned ch))))
    (when (and
           ;; Mobiles don't learn skills
           (not (is-npc ch))
           ;; You can't gain in a skill that you don't really know
           (or (< (level-of ch) (spell-level skill (char-class-of ch)))
               (and (is-remort ch)
                    (< (level-of ch) (spell-level skill (remort-char-class-of ch)))))
           ;; Check for remort skills too
           (or (zerop (spell-gen skill (char-class-of ch)))
               (< (remort-gen-of ch) (spell-gen skill (char-class-of ch))))
           (>= (skill-of ch skill) (- learned 10))
           (<= (- (skill-of ch skill) (level-of ch)) 66)
           (zerop (random-range 0 (level-of ch))))
      (incf (skill-of ch skill)))))
