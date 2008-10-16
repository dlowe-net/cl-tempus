(in-package #:tempus.tests)

(in-suite (defsuite (tempus.obj :in test)))

(deftest objs-containing-objs ()
  (with-mock-objects ((obj-a "obj-a")
                      (obj-b "obj-b"))
    (tempus::obj-to-obj obj-a obj-b)
    (is (equal (list obj-a) (tempus::contains-of obj-b)))
    (is (equal (tempus::in-obj-of obj-a) obj-b))
    (tempus::obj-from-obj obj-a)
    (is (null (tempus::contains-of obj-b)))
    (is (null (tempus::in-obj-of obj-a)))))

(deftest can-carry-items ()
  (with-mock-players (alice)
    (setf (tempus::dex-of (tempus::aff-abils-of alice)) 11)
    (setf (tempus::level-of alice) 40)
    (is (= 12 (tempus::can-carry-items alice)))
    (tempus::affect-modify alice 0 0 tempus::+aff2-telekinesis+ 2 t)
    (is (= 22 (tempus::can-carry-items alice)))
    (setf (tempus::level-of alice) 55)
    (is (> (tempus::can-carry-items alice) 10000))))

(deftest can-carry-weight ()
  (with-mock-players (alice)
    (setf (tempus::str-of (tempus::aff-abils-of alice)) 1)
    (is (= 10 (tempus::can-carry-weight alice)))
    (setf (tempus::str-of (tempus::aff-abils-of alice)) 12)
    (is (= 140 (tempus::can-carry-weight alice)))))

(deftest affect-modify ()
  (with-mock-players (alice)
    (tempus::affect-modify alice tempus::+apply-wis+ 2 0 0 t)
    (is (eql (tempus::wis-of alice) 13))
    (tempus::affect-modify alice tempus::+apply-wis+ 2 0 0 nil)
    (is (eql (tempus::wis-of alice) 11))
    (tempus::affect-modify alice 0 0 tempus::+aff-glowlight+ 1 t)
    (is (logtest (tempus::aff-flags-of alice) tempus::+aff-glowlight+))
    (tempus::affect-modify alice 0 0 tempus::+aff-glowlight+ 1 nil)
    (is (not (logtest (tempus::aff-flags-of alice) tempus::+aff-glowlight+)))))

(deftest obj-equip ()
  (with-mock-players (alice)
    (with-mock-objects ((obj "a magic ring"))
      ;; Make the object give glowlight and wis+2
      (setf (aref (tempus::bitvector-of obj) 0) tempus::+aff-glowlight+)
      (setf (tempus::location-of (aref (tempus::affected-of obj) 0)) tempus::+apply-wis+)
      (setf (tempus::modifier-of (aref (tempus::affected-of obj) 0)) 2)
      (setf (tempus::wis-of (tempus::real-abils-of alice)) 10)
      (setf (tempus::wis-of (tempus::aff-abils-of alice)) 10)
      (tempus::equip-char alice obj tempus::+wear-body+ :worn)
      (is (eql alice (tempus::worn-by-of obj)))
      (is (eql tempus::+wear-body+ (tempus::worn-on-of obj)))
      (is (eql 12 (tempus::wis-of (tempus::aff-abils-of alice))))
      (is (logtest (tempus::aff-flags-of alice) tempus::+aff-glowlight+)))))

(deftest obj-unequip ()
  (with-mock-players (alice)
    (with-mock-objects ((obj "a magic ring"))
      ;; Make the object give glowlight and wis+2
      (setf (aref (tempus::bitvector-of obj) 0) tempus::+aff-glowlight+)
      (setf (tempus::location-of (aref (tempus::affected-of obj) 0)) tempus::+apply-wis+)
      (setf (tempus::modifier-of (aref (tempus::affected-of obj) 0)) 2)
      (setf (tempus::wis-of (tempus::real-abils-of alice)) 10)
      (setf (tempus::wis-of (tempus::aff-abils-of alice)) 10)
      (tempus::equip-char alice obj tempus::+wear-body+ :worn)
      (tempus::unequip-char alice tempus::+wear-body+ :worn nil)
      (is (eql nil (tempus::worn-by-of obj)))
      (is (eql -1 (tempus::worn-on-of obj)))
      (is (eql 10 (tempus::wis-of (tempus::aff-abils-of alice))))
      (is (not (logtest (tempus::aff-flags-of alice) tempus::+aff-glowlight+))))))

(deftest obj-implant ()
  (with-mock-players (alice)
    (with-mock-objects ((obj "a magic ring"))
      ;; Make the object give glowlight and wis+2
      (setf (tempus::kind-of obj) tempus::+item-armor+)
      (setf (tempus::wear-flags-of obj) (logior tempus::+item-wear-body+
                                                tempus::+item-wear-take+))
      (setf (tempus::extra2-flags-of obj) tempus::+item2-implant+)
      (setf (aref (tempus::bitvector-of obj) 0) tempus::+aff-glowlight+)
      (setf (tempus::location-of (aref (tempus::affected-of obj) 0)) tempus::+apply-wis+)
      (setf (tempus::modifier-of (aref (tempus::affected-of obj) 0)) 2)
      (setf (tempus::wis-of (tempus::real-abils-of alice)) 10)
      (setf (tempus::wis-of (tempus::aff-abils-of alice)) 10)
      (tempus::equip-char alice obj tempus::+wear-body+ :implant)
      (is (eql alice (tempus::worn-by-of obj)))
      (is (eql tempus::+wear-body+ (tempus::worn-on-of obj)))
      (is (eql 12 (tempus::wis-of (tempus::aff-abils-of alice))))
      (is (logtest (tempus::aff-flags-of alice) tempus::+aff-glowlight+)))))

(deftest affect-total ()
  (with-mock-players (alice)
    (with-mock-objects ((equip "a magic ring")
                        (implant "an internal booster"))
      ;; Set up alice
      (setf (tempus::max-hitp-of alice) 100)
      (setf (tempus::max-mana-of alice) 100)
      (setf (tempus::max-move-of alice) 100)
      ;; Set up equipment
      (setf (tempus::location-of (aref (tempus::affected-of equip) 0)) tempus::+apply-hit+)
      (setf (tempus::modifier-of (aref (tempus::affected-of equip) 0)) 20)
      ;; Set up implant
      (setf (tempus::extra2-flags-of implant) tempus::+item2-implant+)
      (setf (tempus::location-of (aref (tempus::affected-of implant) 0)) tempus::+apply-mana+)
      (setf (tempus::modifier-of (aref (tempus::affected-of implant) 0)) 20)
      (tempus::equip-char alice equip tempus::+wear-body+ :worn)
      (is (eql 120 (tempus::max-hitp-of alice)))
      (tempus::equip-char alice implant tempus::+wear-body+ :implant)
      (is (eql 120 (tempus::max-mana-of alice)))
      (tempus::affect-total alice)
      (is (eql 120 (tempus::max-hitp-of alice)))
      (is (eql 120 (tempus::max-mana-of alice))))))



(defmacro object-command-test (&body body)
  `(with-mock-players (alice bob)
     (with-mock-objects ((armor-1 "some plate armor")
                         (armor-2 "some plate armor")
                         (chest "a treasure chest"))
       (setf (tempus::sex-of alice) 'tempus::female)
       (setf (tempus::wear-flags-of armor-1) (logior
                                              tempus::+item-wear-take+
                                              tempus::+item-wear-body+))
       (setf (tempus::wear-flags-of armor-2) (logior
                                              tempus::+item-wear-take+
                                              tempus::+item-wear-body+))
       (macrolet ((do-cmd (command-str)
                    `(tempus::interpret-command alice ,command-str))
                  (self-emit-is (emit-str)
                    `(is (equal ,emit-str (char-output alice))))
                  (other-emit-is (emit-str)
                    `(is (equal ,emit-str (char-output bob)))))
         ,@body))))

(deftest get-command-ok ()
  (with-mock-players (alice bob)
    (with-mock-objects ((obj "some plate armor"))
      (setf (tempus::wear-flags-of obj) tempus::+item-wear-take+)
      (tempus::obj-to-room obj (tempus::in-room-of alice))
      (tempus::interpret-command alice "get armor")
      (is (eql (tempus::carried-by-of obj) alice))
      (is (null (tempus::in-room-of obj)))
      (is (equal (list obj) (tempus::carrying-of alice)))
      (is (equal "You get some plate armor.~%" (char-output alice)))
      (is (equal "Alice gets some plate armor.~%" (char-output bob))))))

(deftest get-all-command ()
  (with-mock-players (alice)
    (with-mock-objects ((armor-1 "some plate armor")
                        (armor-2 "some plate armor")
                        (chest "a treasure chest"))
      (setf (tempus::wear-flags-of armor-1) tempus::+item-wear-take+)
      (setf (tempus::wear-flags-of armor-2) tempus::+item-wear-take+)
      (setf (tempus::wear-flags-of chest) tempus::+item-wear-take+)
      (tempus::obj-to-room armor-1 (tempus::in-room-of alice))
      (tempus::obj-to-room armor-2 (tempus::in-room-of alice))
      (tempus::obj-to-room chest (tempus::in-room-of alice))
      (tempus::interpret-command alice "get all")
      (is (equal "You get a treasure chest.~%You get some plate armor. (x2)~%" (char-output alice)))
      (is (eql alice (tempus::carried-by-of armor-1)))
      (is (eql alice (tempus::carried-by-of armor-2)))
      (is (eql alice (tempus::carried-by-of chest))))))

(deftest get-all-dot-command ()
  (with-mock-players (alice)
    (with-mock-objects ((armor-1 "some plate armor")
                        (armor-2 "some plate armor")
                        (chest "a treasure chest"))
      (setf (tempus::wear-flags-of armor-1) tempus::+item-wear-take+)
      (setf (tempus::wear-flags-of armor-2) tempus::+item-wear-take+)
      (setf (tempus::wear-flags-of chest) tempus::+item-wear-take+)
      (tempus::obj-to-room armor-1 (tempus::in-room-of alice))
      (tempus::obj-to-room armor-2 (tempus::in-room-of alice))
      (tempus::obj-to-room chest (tempus::in-room-of alice))
      (tempus::interpret-command alice "get all.armor")
      (is (equal "You get some plate armor. (x2)~%" (char-output alice)))
      (is (eql alice (tempus::carried-by-of armor-1)))
      (is (eql alice (tempus::carried-by-of armor-2))))))

(deftest get-command-no-take ()
  (with-mock-players (alice)
    (with-mock-objects ((obj "some plate armor"))
      (tempus::obj-to-room obj (tempus::in-room-of alice))
      (tempus::interpret-command alice "get armor")
      (is (eql (tempus::in-room-of obj) (tempus::in-room-of alice)))
      (is (null (tempus::carried-by-of obj)))
      (is (equal "Some plate armor: you can't take that!~%" (char-output alice))))))


(deftest get-command-imm-no-take ()
  (with-mock-players (alice)
    (with-mock-objects ((obj "some plate armor"))
      (setf (tempus::level-of alice) 55)
      (tempus::obj-to-room obj (tempus::in-room-of alice))
      (tempus::interpret-command alice "get armor")
      (is (eql (tempus::carried-by-of obj) alice))
      (is (null (tempus::in-room-of obj)))
      (is (equal "You get some plate armor.~%" (char-output alice))))))

(deftest get-gold ()
  (with-mock-players (alice)
    (with-mock-objects ((obj "a pile of gold"))
      (setf obj (make-mock-object "a pile of gold"))
      (setf (tempus::wear-flags-of obj) tempus::+item-wear-take+)
      (setf (tempus::kind-of obj) tempus::+item-money+)
      (setf (aref (tempus::value-of obj) 0) 12345)
      (setf (aref (tempus::value-of obj) 1) 0)
      (tempus::obj-to-room obj (tempus::in-room-of alice))
      (tempus::interpret-command alice "get gold")
      (is (null (tempus::carrying-of alice)))
      (is (= 12345 (tempus::gold-of alice)))
      (is (equal "You get a pile of gold.~%There were 12345 coins.~%" (char-output alice))))))

(deftest get-cash ()
  (with-mock-players (alice)
    (with-mock-objects ((obj "a pile of cash"))
      (setf (tempus::wear-flags-of obj) tempus::+item-wear-take+)
      (setf (tempus::kind-of obj) tempus::+item-money+)
      (setf (aref (tempus::value-of obj) 0) 12345)
      (setf (aref (tempus::value-of obj) 1) 1)
      (tempus::obj-to-room obj (tempus::in-room-of alice))
      (tempus::interpret-command alice "get cash")
      (is (null (tempus::carrying-of alice)))
      (is (= 12345 (tempus::cash-of alice)))
      (is (equal "You get a pile of cash.~%There were 12345 credits.~%" (char-output alice))))))

(deftest get-from-command ()
  (with-mock-players (alice bob)
    (with-mock-objects ((armor-1 "some plate armor")
                        (chest "a treasure chest"))
      (setf (tempus::wear-flags-of armor-1) tempus::+item-wear-take+)
      (setf (tempus::wear-flags-of chest) tempus::+item-wear-take+)
      (tempus::obj-to-room chest (tempus::in-room-of alice))
      (tempus::obj-to-obj armor-1 chest)
      (tempus::interpret-command alice "get armor from chest")
      (is (equal "You get some plate armor from a treasure chest.~%" (char-output alice)))
      (is (equal "Alice gets some plate armor from a treasure chest.~%" (char-output bob)))
      (is (eql alice (tempus::carried-by-of armor-1))))))

(deftest get-all-from-command ()
  (with-mock-players (alice bob)
    (with-mock-objects ((armor-1 "some plate armor")
                        (armor-2 "some plate armor")
                        (chest "a treasure chest"))
      (setf (tempus::wear-flags-of armor-1) tempus::+item-wear-take+)
      (setf (tempus::wear-flags-of armor-2) tempus::+item-wear-take+)
      (tempus::obj-to-room chest (tempus::in-room-of alice))
      (tempus::obj-to-obj armor-1 chest)
      (tempus::obj-to-obj armor-2 chest)
      (tempus::interpret-command alice "get all.armor from chest")
      (is (equal "You get some plate armor from a treasure chest. (x2)~%" (char-output alice)))
      (is (equal "Alice gets some plate armor from a treasure chest. (x2)~%" (char-output bob)))
      (is (eql alice (tempus::carried-by-of armor-1)))
      (is (eql alice (tempus::carried-by-of armor-2))))))

(deftest get-from-container/all-from-empty-container/failure ()
  (with-mock-players (alice)
    (with-mock-objects ((chest "a treasure chest"))
      (tempus::obj-to-room chest (tempus::in-room-of alice))
      (tempus::get-from-container alice "all" chest)
      (is (equal "You didn't find anything to take in a treasure chest.~%" (char-output alice))))))

(deftest get-from-container/non-matching-objects/failure ()
  (with-mock-players (alice)
    (with-mock-objects ((armor-1 "some plate armor")
                        (armor-2 "some plate armor")
                        (chest "a treasure chest"))
      (tempus::obj-to-room chest (tempus::in-room-of alice))
      (tempus::obj-to-obj armor-1 chest)
      (tempus::obj-to-obj armor-2 chest)
      (tempus::get-from-container alice "all.potion" chest)
      (is (equal "You didn't find anything in a treasure chest that looks like a potion.~%" (char-output alice)))
      (clear-mock-buffers alice)
      (tempus::get-from-container alice "all.egg" chest)
      (is (equal "You didn't find anything in a treasure chest that looks like an egg.~%" (char-output alice))))))

(deftest inventory-command ()
  (with-mock-players (alice)
    (with-mock-objects ((obj "some plate armor"))
             (tempus::obj-to-char obj alice)
             (tempus::interpret-command alice "i")
             (is (equal "You are carrying:~%some plate armor~%" (char-output alice))))))

(deftest put-command ()
  (object-command-test
    (tempus::obj-to-char armor-2 alice)
    (tempus::obj-to-char armor-1 alice)
    (tempus::obj-to-room chest (tempus::in-room-of alice))
    (do-cmd "put armor into chest")
    (self-emit-is "You put some plate armor into a treasure chest.~%")
    (other-emit-is "Alice puts some plate armor into a treasure chest.~%")
    (is (eql chest (tempus::in-obj-of armor-1)))))

(deftest put-command-no-container ()
  (object-command-test
    (tempus::obj-to-char armor-2 alice)
    (tempus::obj-to-char armor-1 alice)
    (tempus::obj-to-room chest (tempus::in-room-of alice))
    (do-cmd "put armor")
    (self-emit-is "What do you want to put it in?~%")))

(deftest put-command-numbered ()
  (object-command-test
    (tempus::obj-to-char armor-2 alice)
    (tempus::obj-to-char armor-1 alice)
    (tempus::obj-to-room chest (tempus::in-room-of alice))
    (do-cmd "put 2.armor into chest")
    (self-emit-is "You put some plate armor into a treasure chest.~%")
    (other-emit-is "Alice puts some plate armor into a treasure chest.~%")
   (is (eql chest (tempus::in-obj-of armor-2)))))

(deftest put-command-all ()
  (object-command-test
    (tempus::obj-to-char armor-2 alice)
    (tempus::obj-to-char armor-1 alice)
    (tempus::obj-to-room chest (tempus::in-room-of alice))
    (do-cmd "put all into chest")
    (self-emit-is "You put some plate armor into a treasure chest. (x2)~%")
    (other-emit-is "Alice puts some plate armor into a treasure chest. (x2)~%")
    (is (eql chest (tempus::in-obj-of armor-1)))
    (is (eql chest (tempus::in-obj-of armor-2)))))

(deftest drop-command ()
  (object-command-test
    (tempus::obj-to-char armor-2 alice)
    (tempus::obj-to-char armor-1 alice)
    (do-cmd "drop armor")
    (self-emit-is "You drop some plate armor.~%")
    (other-emit-is "Alice drops some plate armor.~%")
    (is (eql (tempus::in-room-of alice) (tempus::in-room-of armor-1))))

  (object-command-test
    (tempus::obj-to-char armor-2 alice)
    (tempus::obj-to-char armor-1 alice)
    (do-cmd "drop all")
    (self-emit-is "You drop some plate armor. (x2)~%")
    (other-emit-is "Alice drops some plate armor. (x2)~%")
    (is (eql (tempus::in-room-of alice) (tempus::in-room-of armor-1)))
    (is (eql (tempus::in-room-of alice) (tempus::in-room-of armor-2)))))

(deftest drop-command-cursed ()
  (object-command-test
    (tempus::obj-to-char armor-2 alice)
    (tempus::obj-to-char armor-1 alice)
    (setf (tempus::extra-flags-of armor-1)
          (logior (tempus::extra-flags-of armor-1) tempus::+item-nodrop+))
    (do-cmd "drop armor")
    (self-emit-is "You can't drop some plate armor, it must be CURSED!~%")
    (is (eql alice (tempus::carried-by-of armor-1)))
    ;; Check immortal drop
    (clear-mock-buffers alice bob)
    (setf (tempus::level-of alice) 70)
    (do-cmd "drop armor")
    (self-emit-is "You peel some plate armor off your hand...~%You drop some plate armor.~%")
    (is (eql (tempus::in-room-of alice) (tempus::in-room-of armor-1)))))

(deftest wear-command ()
  (object-command-test
    (tempus::obj-to-char armor-2 alice)
    (tempus::obj-to-char armor-1 alice)
    (do-cmd "wear armor")
    (self-emit-is "You wear some plate armor on your body.~%")
    (other-emit-is "Alice wears some plate armor on her body.~%")
    (is (null (tempus::carried-by-of armor-1)))
    (is (not (member armor-1 (tempus::carrying-of alice))))
    (is (eql alice (tempus::worn-by-of armor-1)))
    (is (eql tempus::+wear-body+ (tempus::worn-on-of armor-1)))
    (is (eql armor-1 (aref (tempus::equipment-of alice) tempus::+wear-body+)))
    (clear-mock-buffers alice bob)
    (do-cmd "wear armor")
    (self-emit-is "You're already wearing something on your body.~%")))

(deftest wear-command-failure ()
  (object-command-test
    (tempus::obj-to-char armor-1 alice)
    (setf (tempus::wear-flags-of armor-1) tempus::+item-wear-hold+)
    (do-cmd "wear armor")
    (self-emit-is "You can't wear some plate armor.~%")))

(deftest wear-command-on-pos ()
  (object-command-test
    (tempus::obj-to-char armor-2 alice)
    (tempus::obj-to-char armor-1 alice)
    (do-cmd "wear armor on body")
    (self-emit-is "You wear some plate armor on your body.~%")
    (other-emit-is "Alice wears some plate armor on her body.~%")
    (is (null (tempus::carried-by-of armor-1)))
    (is (not (member armor-1 (tempus::carrying-of alice))))
    (is (eql alice (tempus::worn-by-of armor-1)))
    (is (eql tempus::+wear-body+ (tempus::worn-on-of armor-1)))
    (is (eql armor-1 (aref (tempus::equipment-of alice) tempus::+wear-body+)))
    (clear-mock-buffers alice bob)
    (do-cmd "wear armor on eyes")
    (self-emit-is "You can't wear some plate armor there.~%")))

(deftest wear-command-on-pos-failure ()
  (object-command-test
    (tempus::obj-to-char armor-2 alice)
    (tempus::obj-to-char armor-1 alice)
    (do-cmd "wear all.armor on body")
    (self-emit-is "You can't wear more than one item on a position.~%")
    (clear-mock-buffers alice)
    (do-cmd "wear armor on foo")
    (self-emit-is "'foo'?  What part of your body is THAT?~%")))


(deftest remove-command ()
  (object-command-test
    (tempus::equip-char alice armor-1 tempus::+wear-body+ :worn)
    (do-cmd "remove armor")
    (self-emit-is "You stop using some plate armor.~%")
    (other-emit-is "Alice stops using some plate armor.~%")
    (is (null (tempus::worn-by-of armor-1)))
    (is (equal (list armor-1) (tempus::carrying-of alice)))))

(deftest remove-command-from-pos ()
  (object-command-test
    (tempus::equip-char alice armor-1 tempus::+wear-body+ :worn)
    (do-cmd "remove earring from body")
    (self-emit-is "You aren't wearing an earring there.~%")
    (clear-mock-buffers alice)
    (do-cmd "remove armor from body")
    (self-emit-is "You stop using some plate armor.~%")
    (other-emit-is "Alice stops using some plate armor.~%")
    (is (null (tempus::worn-by-of armor-1)))
    (is (equal (list armor-1) (tempus::carrying-of alice)))
    (clear-mock-buffers alice)
    (do-cmd "remove armor from arms")
    (self-emit-is "You aren't wearing anything there.~%")))

(deftest give-command ()
  (object-command-test
    (tempus::obj-to-char armor-2 alice)
    (tempus::obj-to-char armor-1 alice)
    (do-cmd "give armor to bob")
    (self-emit-is "You give some plate armor to Bob.~%")
    (other-emit-is "Alice gives some plate armor to you.~%")
    (is (equal (list armor-2) (tempus::carrying-of alice)))
    (is (equal (list armor-1) (tempus::carrying-of bob)))
    (clear-mock-buffers alice bob)
    (tempus::obj-from-char armor-1)
    (tempus::obj-to-char armor-1 alice)
    (do-cmd "give all to bob")
    (self-emit-is "You give some plate armor to Bob. (x2)~%")
    (other-emit-is "Alice gives some plate armor to you. (x2)~%")))

(deftest give-money-commands ()
  (with-mock-players (alice bob eva)
    (setf (tempus::gold-of alice) 10000)
    (setf (tempus::cash-of alice) 10000)
    (tempus::interpret-command alice "give 5000 coins to bob")
    (is (equal "You give 5000 coins to Bob.~%" (char-output alice)))
    (is (equal "Alice gives 5000 coins to you.~%" (char-output bob)))
    (is (equal "Alice gives some coins to Bob.~%" (char-output eva)))
    (is (= (tempus::gold-of alice) 5000))
    (is (= (tempus::gold-of bob) 5000))
    (clear-mock-buffers alice bob eva)
    (tempus::interpret-command alice "give 5000 credits to bob")
    (is (equal "You give 5000 credits to Bob.~%" (char-output alice)))
    (is (equal "Alice gives 5000 credits to you.~%" (char-output bob)))
    (is (equal "Alice gives some credits to Bob.~%" (char-output eva)))
    (is (= (tempus::cash-of alice) 5000))
    (is (= (tempus::cash-of bob) 5000))))

(deftest plant-command ()
  (object-command-test
    (tempus::obj-to-char armor-2 alice)
    (tempus::obj-to-char armor-1 alice)
    (do-cmd "plant armor on bob")
    (self-emit-is "You plant some plate armor on Bob.~%")
    (is (or (equal "" (char-output bob))
                 (equal "Alice puts some plate armor in your pocket.~%"
                        (char-output bob))))
    (is (equal (list armor-2) (tempus::carrying-of alice)))
    (is (equal (list armor-1) (tempus::carrying-of bob)))))

(deftest drink-command ()
  (with-mock-players (alice bob)
    (with-mock-objects ((glass "a glass of water"))
      (setf (tempus::kind-of glass) tempus::+item-drinkcon+)
      (setf (tempus::value-of glass) (coerce '(8 8 0 0) 'vector))
      (tempus::obj-to-char glass alice)
      (setf (tempus::conditions-of alice) (coerce '(0 12 12) 'vector))
      (tempus::interpret-command alice "drink water")
      (is (equal "Your thirst has been quenched.~%" (char-output alice)))
      (is (equal "Alice drinks water from a glass of water.~%"
                 (char-output bob)))
      (destructuring-bind (drunk full thirst)
          (coerce (tempus::conditions-of alice) 'list)
        (is (= drunk 0))
        (is (>= full 13))
        (is (>= thirst 22))))))

(deftest drink-command-poison ()
  (with-mock-players (alice bob)
    (with-mock-objects ((glass "a glass of water"))
      (setf (tempus::kind-of glass) tempus::+item-drinkcon+)
      (setf (tempus::value-of glass) (coerce '(8 8 0 1) 'vector))
      (tempus::obj-to-char glass alice)
      (setf (tempus::conditions-of alice) (coerce '(0 12 12) 'vector))
      (tempus::interpret-command alice "drink water")
      (is (equal "Your thirst has been quenched.~%Oops, it tasted rather strange!~%" (char-output alice)))
      (is (equal "Alice drinks water from a glass of water.~%Alice chokes and utters some strange sounds.~%"
                 (char-output bob)))
      (is (tempus::affected-by-spell alice tempus::+spell-poison+))
      (destructuring-bind (drunk full thirst)
          (coerce (tempus::conditions-of alice) 'list)
        (is (= drunk 0))
        (is (>= full 13))
        (is (>= thirst 22))))))

(deftest eat-command ()
  (with-mock-players (alice bob)
    (with-mock-objects ((sandwich "a tasty sandwich"))
      (tempus::obj-to-char sandwich alice)
      (setf (tempus::kind-of sandwich) tempus::+item-food+)
      (setf (tempus::value-of sandwich) (coerce '(8 0 0 0) 'vector))
      (setf (tempus::conditions-of alice) (coerce '(0 12 12) 'vector))
      (tempus::interpret-command alice "eat sandwich")
      (is (equal "You eat a tasty sandwich.~%" (char-output alice)))
      (is (equal "Alice eats a tasty sandwich.~%" (char-output bob)))
      (destructuring-bind (drunk full thirst)
          (coerce (tempus::conditions-of alice) 'list)
        (is (= drunk 0))
        (is (= full 20))
        (is (= thirst 12))))))

(deftest name-from-drinkcon ()
  (with-mock-objects ((canteen "a canteen of water"))
    (tempus::name-from-drinkcon canteen 0)
    (is (null (search "water" (tempus::aliases-of canteen))))))

(deftest name-to-drinkcon ()
  (with-mock-objects ((canteen "a canteen"))
    (tempus::name-to-drinkcon canteen 0)
    (is (not (null (search "water" (tempus::aliases-of canteen)))))))

(deftest pour-into-command ()
  (with-mock-players (alice bob)
    (with-mock-objects ((canteen "a canteen of water")
                        (glass "a glass"))
      (setf (tempus::kind-of canteen) tempus::+item-drinkcon+)
      (setf (tempus::kind-of glass) tempus::+item-drinkcon+)
      (setf (tempus::value-of canteen) (coerce '(10 10 0 0) 'vector))
      (setf (tempus::value-of glass) (coerce '(5 0 0 0) 'vector))
      (tempus::obj-to-char canteen alice)
      (tempus::obj-to-char glass alice)
      (tempus::interpret-command alice "pour canteen into glass")
      (is (equal "You pour water into a glass.~%" (char-output alice)))
      (is (equal "Alice pours water into a glass.~%" (char-output bob)))
      (is (equal '(10 5 0 0) (coerce (tempus::value-of canteen) 'list)))
      (is (equal '(5 5 0 0) (coerce (tempus::value-of glass) 'list)))
      (is (search "water" (tempus::aliases-of glass))))))

(deftest pour-into-command-emptying-container ()
  (with-mock-players (alice bob)
    (with-mock-objects ((canteen "a canteen of water")
                        (barrel "a barrel"))
      (setf (tempus::kind-of canteen) tempus::+item-drinkcon+)
      (setf (tempus::kind-of barrel) tempus::+item-drinkcon+)
      (setf (tempus::value-of canteen) (coerce '(10 10 0 0) 'vector))
      (setf (tempus::value-of barrel) (coerce '(20 0 0 0) 'vector))
      (tempus::obj-to-char canteen alice)
      (tempus::obj-to-char barrel alice)
      (tempus::interpret-command alice "pour canteen into barrel")
      (is (equal "You pour water into a barrel.~%" (char-output alice)))
      (is (equal "Alice pours water into a barrel.~%" (char-output bob)))
      (is (equal '(10 0 0 0) (coerce (tempus::value-of canteen) 'list)))
      (is (equal '(20 10 0 0) (coerce (tempus::value-of barrel) 'list)))
      (is (null (search "water" (tempus::aliases-of canteen))))
      (is (search "water" (tempus::aliases-of barrel))))))

(deftest pour-out-parser ()
  (with-mock-players (alice bob)
    (with-mock-objects ((canteen "a canteen"))
      (tempus::obj-to-char canteen alice)
      (function-trace-bind ((calls tempus::perform-pour-out))
          (tempus::interpret-command alice "pour out canteen")
        (is (= 1 (length calls)))
        (is (equal (list alice canteen) (first calls)))))))

(deftest pour-out ()
  (with-mock-players (alice bob)
    (with-mock-objects ((canteen "a canteen"))
      (setf (tempus::aliases-of canteen) "canteen water")
      (setf (tempus::kind-of canteen) tempus::+item-drinkcon+)
      (setf (tempus::value-of canteen) (coerce '(10 10 0 0) 'vector))
      (tempus::obj-to-char canteen alice)
      (tempus::perform-pour-out alice canteen)
      (is (equal "You pour water out of a canteen.~%" (char-output alice)))
      (is (equal "Alice pours water out of a canteen.~%" (char-output bob)))
      (is (equal '(10 0 0 0) (coerce (tempus::value-of canteen) 'list)))
      (is (null (search "water" (tempus::aliases-of canteen)))))))

(deftest wield-command/normal/success ()
  (with-mock-players (alice bob)
    (with-mock-objects ((sword "an elvish sword"))
      (setf (tempus::kind-of sword) tempus::+item-weapon+)
      (tempus::obj-to-char sword alice)
      (setf (tempus::wear-flags-of sword) (logior
                                             tempus::+item-wear-take+
                                             tempus::+item-wear-wield+))
      (tempus::interpret-command alice "wield sword")
      (is (equal "You wield an elvish sword.~%"
                 (char-output alice)))
      (is (equal "Alice wields an elvish sword.~%" (char-output bob)))
      (is (null (tempus::carried-by-of sword)))
      (is (not (member sword (tempus::carrying-of alice))))
      (is (eql alice (tempus::worn-by-of sword)))
      (is (eql tempus::+wear-wield+ (tempus::worn-on-of sword)))
      (is (eql sword (aref (tempus::equipment-of alice) tempus::+wear-wield+))))))

(deftest wield/already-wielding/dual-wield ()
  (with-mock-players (alice)
    (with-mock-objects ((sword-1 "an elvish sword")
                        (sword-2 "an elvish sword"))
      (setf (tempus::kind-of sword-1) tempus::+item-weapon+)
      (setf (tempus::kind-of sword-2) tempus::+item-weapon+)
      (tempus::equip-char alice sword-1 tempus::+wear-wield+ :worn)
      (tempus::obj-to-char sword-2 alice)
      (setf (tempus::wear-flags-of sword-1) (logior
                                             tempus::+item-wear-take+
                                             tempus::+item-wear-wield+))
      (setf (tempus::wear-flags-of sword-2) (logior
                                             tempus::+item-wear-take+
                                             tempus::+item-wear-wield+))
      (tempus::interpret-command alice "wield sword")
      (is (equal "You wield an elvish sword in your off hand.~%" (char-output alice))))))

(deftest wield/already-dual-wielding/failure ()
  (with-mock-players (alice)
    (with-mock-objects ((sword-1 "an elvish sword")
                        (sword-2 "an elvish sword")
                        (sword-3 "an elvish sword"))
      (setf (tempus::kind-of sword-1) tempus::+item-weapon+)
      (setf (tempus::kind-of sword-2) tempus::+item-weapon+)
      (setf (tempus::kind-of sword-3) tempus::+item-weapon+)
      (setf (tempus::wear-flags-of sword-1) (logior
                                             tempus::+item-wear-take+
                                             tempus::+item-wear-wield+))
      (setf (tempus::wear-flags-of sword-2) (logior
                                             tempus::+item-wear-take+
                                             tempus::+item-wear-wield+))
      (setf (tempus::wear-flags-of sword-3) (logior
                                             tempus::+item-wear-take+
                                             tempus::+item-wear-wield+))
      (tempus::equip-char alice sword-1 tempus::+wear-wield+ :worn)
      (tempus::equip-char alice sword-2 tempus::+wear-wield-2+ :worn)
      (tempus::obj-to-char sword-3 alice)
      (tempus::interpret-command alice "wield sword")
      (is (equal "You don't have a hand free to wield it with.~%" (char-output alice))))))

(deftest perform-hold/holding-object/success ()
  (with-mock-players (alice bob)
    (with-mock-objects ((wand "a scarred wand"))
      (setf (tempus::kind-of wand) tempus::+item-wand+)
      (tempus::obj-to-char wand alice)
      (setf (tempus::wear-flags-of wand) (logior
                                             tempus::+item-wear-take+
                                             tempus::+item-wear-hold+))
      (tempus::perform-hold alice wand)
      (is (equal "You grab a scarred wand.~%"
                 (char-output alice)))
      (is (equal "Alice grabs a scarred wand.~%" (char-output bob)))
      (is (null (tempus::carried-by-of wand)))
      (is (not (member wand (tempus::carrying-of alice))))
      (is (eql alice (tempus::worn-by-of wand)))
      (is (eql tempus::+wear-hold+ (tempus::worn-on-of wand)))
      (is (eql wand (aref (tempus::equipment-of alice) tempus::+wear-hold+))))))

(deftest perform-hold-light/normal/success ()
  (with-mock-players (alice bob)
    (with-mock-objects ((torch "a torch"))
      (setf (tempus::kind-of torch) tempus::+item-light+)
      (setf (aref (tempus::value-of torch) 2) 10)
      (tempus::obj-to-char torch alice)
      (setf (tempus::wear-flags-of torch) (logior
                                             tempus::+item-wear-take+
                                             tempus::+item-wear-hold+))
      (tempus::perform-hold-light alice torch)
      (is (equal "You light a torch and hold it.~%"
                 (char-output alice)))
      (is (equal "Alice lights a torch and holds it.~%" (char-output bob)))
      (is (null (tempus::carried-by-of torch)))
      (is (not (member torch (tempus::carrying-of alice))))
      (is (eql alice (tempus::worn-by-of torch)))
      (is (eql tempus::+wear-light+ (tempus::worn-on-of torch)))
      (is (eql torch (aref (tempus::equipment-of alice) tempus::+wear-light+))))))

(deftest perform-hold-light/burned-out/failure ()
  (with-mock-players (alice bob)
    (with-mock-objects ((torch "a torch"))
      (setf (tempus::kind-of torch) tempus::+item-light+)
      (setf (aref (tempus::value-of torch) 2) 0)
      (tempus::obj-to-char torch alice)
      (setf (tempus::wear-flags-of torch) (logior
                                             tempus::+item-wear-take+
                                             tempus::+item-wear-hold+))
      (tempus::perform-hold-light alice torch)
      (is (equal "A torch is no longer usable as a light.~%"
                 (char-output alice)))
      (is (eql alice (tempus::carried-by-of torch)))
      (is (eql torch (first (tempus::carrying-of alice)))))))

(deftest perform-attach/normal-scuba/success ()
  (with-mock-players (alice bob)
    (with-mock-objects ((mask "a scuba mask")
                        (tank "a scuba tank"))
      (setf (tempus::kind-of mask) tempus::+item-scuba-mask+)
      (setf (tempus::kind-of tank) tempus::+item-scuba-tank+)
      (tempus::obj-to-char mask alice)
      (tempus::obj-to-char tank alice)
      (setf (tempus::wear-flags-of mask) (logior
                                             tempus::+item-wear-take+
                                             tempus::+item-wear-face+))
      (setf (tempus::wear-flags-of tank) (logior
                                             tempus::+item-wear-take+
                                             tempus::+item-wear-back+))
      (tempus::perform-attach alice mask tank)
      (is (equal "You attach a scuba mask to a scuba tank.~%"
                 (char-output alice)))
      (is (equal "Alice attaches a scuba mask to a scuba tank.~%"
                 (char-output bob)))
      (is (eql tank (tempus::aux-obj-of mask)))
      (is (eql mask (tempus::aux-obj-of tank))))))

(deftest perform-attach/normal-bomb/success ()
  (with-mock-players (alice bob)
    (with-mock-objects ((fuse "a fuse")
                        (bomb "a bomb"))
      (setf (tempus::kind-of fuse) tempus::+item-fuse+)
      (setf (tempus::kind-of bomb) tempus::+item-bomb+)
      (tempus::obj-to-char fuse alice)
      (tempus::obj-to-char bomb alice)
      (tempus::perform-attach alice fuse bomb)
      (is (equal "You attach a fuse to a bomb.~%"
                 (char-output alice)))
      (is (equal "Alice attaches a fuse to a bomb.~%"
                 (char-output bob)))
      (is (equal (list fuse)
                 (tempus::contains-of bomb))))))

(deftest perform-detach/normal-scuba/success ()
  (with-mock-players (alice bob)
    (with-mock-objects ((mask "a scuba mask")
                        (tank "a scuba tank"))
      (setf (tempus::kind-of mask) tempus::+item-scuba-mask+)
      (setf (tempus::kind-of tank) tempus::+item-scuba-tank+)
      (setf (tempus::aux-obj-of mask) tank)
      (setf (tempus::aux-obj-of tank) mask)
      (tempus::obj-to-char mask alice)
      (tempus::obj-to-char tank alice)
      (tempus::perform-detach alice mask tank)
      (is (equal "You detach a scuba mask from a scuba tank.~%"
                 (char-output alice)))
      (is (equal "Alice detaches a scuba mask from a scuba tank.~%"
                 (char-output bob)))
      (is (null (tempus::aux-obj-of mask)))
      (is (null (tempus::aux-obj-of tank))))))