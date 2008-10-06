(in-package #:tempus.tests)

(in-suite (defsuite (tempus.move :in test)))

(deftest basic-movement ()
  (with-mock-players (alice bob)
    (let ((orig-room (tempus::in-room-of alice)))
      (setf (tempus::bitp (tempus::prefs-of alice) tempus::+pref-autoexit+) t)
      (tempus::interpret-command alice "e")
      (is (eql (tempus::to-room-of
                (aref (tempus::dir-option-of orig-room) tempus::+east+))
               (tempus::number-of (tempus::in-room-of alice))))
      (is (search "East Goddess Street" (char-output alice)))
      (is (search "[ Exits: n e s w u ]" (char-output alice)))
      (is (search "The broad tree-lined avenue leads east"
                       (char-output alice)))
      (is (or (string= (char-output bob) "Alice walks east.~%")
              (string= (char-output bob) "Alice strolls east.~%")
              (string= (char-output bob) "Alice departs eastward.~%")
              (string= (char-output bob) "Alice leaves east.~%")))

      (clear-mock-buffers alice bob)

      (tempus::interpret-command alice "w")
      (is (eql (tempus::in-room-of alice) orig-room))
      (is (search "Holy Square" (char-output alice)))
      (is (or (string= (char-output bob) "Alice walks in from the east.~%")
              (string= (char-output bob) "Alice strolls in from the east.~%")
              (string= (char-output bob) "Alice has arrived from the east.~%")
              (char-output bob))))))

(deftest movement-with-brief ()
  (with-mock-players (alice)
    (setf (tempus::bitp (tempus::prefs-of alice) tempus::+pref-brief+) t)
    (tempus::interpret-command alice "e")
    (is (search "East Goddess Street" (char-output alice)))
    (is (null (search "The broad tree-lined avenue leads east"
                      (char-output alice))))))

(deftest standing ()
  (with-mock-players (alice)
    (setf (tempus::position-of alice) tempus::+pos-sitting+)
    (tempus::interpret-command alice "stand")
    (is (= (tempus::position-of alice) tempus::+pos-standing+))
    (is (string= (char-output alice) "You clamber to your feet.~%"))

    (clear-mock-buffers alice)
    (setf (tempus::position-of alice) tempus::+pos-resting+)
    (tempus::interpret-command alice "stand")
    (is (= (tempus::position-of alice) tempus::+pos-standing+))
    (is (string= (char-output alice) "You stop resting, and clamber onto your feet.~%"))

    (clear-mock-buffers alice)
    (setf (tempus::position-of alice) tempus::+pos-sleeping+)
    (tempus::interpret-command alice "stand")
    (is (= (tempus::position-of alice) tempus::+pos-standing+))
    (is (string= (char-output alice) "You wake up, and stagger to your feet.~%"))
    (clear-mock-buffers alice)
    (setf (tempus::position-of alice) tempus::+pos-standing+)
    (tempus::interpret-command alice "stand")
    (is (= (tempus::position-of alice) tempus::+pos-standing+))
    (is (string= (char-output alice) "You are already standing.~%"))

    (clear-mock-buffers alice)
    (setf (tempus::position-of alice) tempus::+pos-fighting+)
    (tempus::interpret-command alice "stand")
    (is (= (tempus::position-of alice) tempus::+pos-fighting+))
    (is (string= (char-output alice) "You are already standing.~%"))

    (clear-mock-buffers alice)
    (setf (tempus::position-of alice) tempus::+pos-flying+)
    (tempus::interpret-command alice "stand")
    (is (= (tempus::position-of alice) tempus::+pos-standing+))
    (is (string= (char-output alice) "You settle lightly to the ground.~%"))))

(deftest resting ()
  (with-mock-players (alice)
    (setf (tempus::position-of alice) tempus::+pos-sitting+)
    (tempus::interpret-command alice "rest")
    (is (= (tempus::position-of alice) tempus::+pos-resting+))
    (is (string= (char-output alice) "You lay back and rest your tired bones.~%"))

    (clear-mock-buffers alice)
    (setf (tempus::position-of alice) tempus::+pos-resting+)
    (tempus::interpret-command alice "rest")
    (is (= (tempus::position-of alice) tempus::+pos-resting+))
    (is (string= (char-output alice) "You are already resting.~%"))

    (clear-mock-buffers alice)
    (setf (tempus::position-of alice) tempus::+pos-sleeping+)
    (tempus::interpret-command alice "rest")
    (is (= (tempus::position-of alice) tempus::+pos-sleeping+))
    (is (string= (char-output alice) "You have to wake up first.~%"))
    (clear-mock-buffers alice)
    (setf (tempus::position-of alice) tempus::+pos-standing+)
    (tempus::interpret-command alice "rest")
    (is (= (tempus::position-of alice) tempus::+pos-resting+))
    (is (string= (char-output alice) "You sit down and lay back into a relaxed position.~%"))

    (clear-mock-buffers alice)
    (setf (tempus::position-of alice) tempus::+pos-fighting+)
    (tempus::interpret-command alice "rest")
    (is (= (tempus::position-of alice) tempus::+pos-fighting+))
    (is (string= (char-output alice) "Rest while fighting?  Are you MAD?~%"))

    (clear-mock-buffers alice)
    (setf (tempus::position-of alice) tempus::+pos-flying+)
    (tempus::interpret-command alice "rest")
    (is (= (tempus::position-of alice) tempus::+pos-flying+))
    (is (string= (char-output alice) "You better not try that while flying.~%"))))

(deftest sleeping ()
  (with-mock-players (alice)
    (setf (tempus::position-of alice) tempus::+pos-sitting+)
    (tempus::interpret-command alice "sleep")
    (is (= tempus::+pos-sleeping+ (tempus::position-of alice)))
    (is (string= (char-output alice) "You go to sleep.~%"))

    (clear-mock-buffers alice)
    (setf (tempus::position-of alice) tempus::+pos-sleeping+)
    (tempus::interpret-command alice "sleep")
    (is (= (tempus::position-of alice) tempus::+pos-sleeping+))
    (is (string= (char-output alice) "You are already sound asleep.~%"))

    (clear-mock-buffers alice)
    (setf (tempus::position-of alice) tempus::+pos-standing+)
    (setf (tempus::aff-flags-of alice) (logior (tempus::aff-flags-of alice)
                                               tempus::+aff-adrenaline+))
    (tempus::interpret-command alice "sleep")
    (is (= (tempus::position-of alice) tempus::+pos-standing+))
    (is (string= (char-output alice) "You can't seem to relax.~%"))
    (setf (tempus::aff-flags-of alice) 0)

    (clear-mock-buffers alice)
    (setf (tempus::position-of alice) tempus::+pos-standing+)
    (setf (tempus::aff2-flags-of alice) (logior (tempus::aff2-flags-of alice)
                                                tempus::+aff2-berserk+))
    (tempus::interpret-command alice "sleep")
    (is (= (tempus::position-of alice) tempus::+pos-standing+))
    (is (string= (char-output alice) "What, sleep while in a berserk rage??~%"))
    (setf (tempus::aff2-flags-of alice) 0)

    (clear-mock-buffers alice)
    (setf (tempus::position-of alice) tempus::+pos-standing+)
    (tempus::interpret-command alice "sleep")
    (is (= (tempus::position-of alice) tempus::+pos-sleeping+))
    (is (string= (char-output alice) "You go to sleep.~%"))

    (clear-mock-buffers alice)
    (setf (tempus::position-of alice) tempus::+pos-fighting+)
    (tempus::interpret-command alice "sleep")
    (is (= (tempus::position-of alice) tempus::+pos-fighting+))
    (is (string= (char-output alice) "Sleep while fighting?  Are you MAD?~%"))

    (clear-mock-buffers alice)
    (setf (tempus::position-of alice) tempus::+pos-flying+)
    (tempus::interpret-command alice "sleep")
    (is (= (tempus::position-of alice) tempus::+pos-flying+))
    (is (string= (char-output alice) "That's a really bad idea while flying!~%"))))

(deftest waking ()
  (with-mock-players (alice)
    (setf (tempus::position-of alice) tempus::+pos-sleeping+)
    (tempus::interpret-command alice "wake")
    (is (= (tempus::position-of alice) tempus::+pos-sitting+))
    (is (string= (char-output alice) "You awaken, and sit up.~%"))

    (clear-mock-buffers alice)
    (setf (tempus::position-of alice) tempus::+pos-sitting+)
    (tempus::interpret-command alice "wake")
    (is (= (tempus::position-of alice) tempus::+pos-sitting+))
    (is (string= (char-output alice) "You are already awake...~%"))

    (clear-mock-buffers alice)
    (setf (tempus::position-of alice) tempus::+pos-sleeping+)
    (setf (tempus::aff3-flags-of alice) (logior (tempus::aff3-flags-of alice)
                                                tempus::+aff3-stasis+))
    (tempus::interpret-command alice "wake")
    (is (= (tempus::position-of alice) tempus::+pos-sitting+))
    (is (string= (char-output alice) "Reactivating processes...~%"))))

(deftest goto-command ()
  (with-mock-players (alice bob)
    (tempus::interpret-command alice "goto 3001")
    (is (= 3001 (tempus::number-of (tempus::in-room-of alice))))
    (tempus::interpret-command alice "goto bob")
    (is (= (tempus::number-of (tempus::in-room-of bob))
           (tempus::number-of (tempus::in-room-of alice))))))
