(in-package #:tempus.tests)

(in-suite (defsuite (tempus.wizard :in test)))

(deftest echo/normal/displays-to-room ()
  (with-mock-players (alice bob chuck)
    (setf (tempus::level-of alice) 51)
    (setf (tempus::level-of bob) 49)
    (setf (tempus::level-of chuck) 52)
    (tempus::interpret-command alice "echo testing")
    (is (equal "Testing~%" (char-output alice)))
    (is (equal "Testing~%" (char-output bob)))
    (is (equal "[Alice] testing~%" (char-output chuck)))))

(deftest send/normal/sends-to-char ()
  (with-mock-players (alice bob)
    (tempus::interpret-command alice "send .bob testing")
    (is (equal "You send 'testing' to Bob.~%" (char-output alice)))
    (is (equal "Testing~%" (char-output bob)))))

(deftest at/normal/performs-command-in-target-room ()
  (with-mock-players (alice bob)
    (tempus::char-from-room alice)
    (tempus::char-to-room alice (tempus::real-room 3001))
    (tempus::interpret-command alice "at 3013 say hi")
    (is (equal "&BYou say, &c'hi'&n~%" (char-output alice)))
    (is (equal "&BAlice says, &c'hi'&n~%" (char-output bob)))))

(deftest goto/numeric-target/changes-room ()
  (with-mock-players (alice bob)
    (tempus::char-from-room alice)
    (tempus::char-to-room alice (tempus::real-room 3001))
    (tempus::interpret-command alice "goto 3013")
    (is (= 3013 (tempus::number-of (tempus::in-room-of alice))))
    (is (equal "Alice appears with an ear-splitting bang.~%" (char-output bob)))))

(deftest goto/char-target/changes-room ()
  (with-mock-players (alice bob)
    (tempus::char-from-room alice)
    (tempus::char-to-room alice (tempus::real-room 3001))
    (tempus::interpret-command alice "goto .bob")
    (is (= 3013 (tempus::number-of (tempus::in-room-of alice))))
    (is (equal "Alice appears with an ear-splitting bang.~%" (char-output bob)))))

(deftest goto/following-imm/imm-in-same-room ()
  (with-mock-players (alice bob)
    (setf (tempus::level-of bob) 51)
    (tempus::add-follower bob alice)
    (clear-mock-buffers bob alice)
    (tempus::interpret-command alice "goto 3001")
    (is (= 3001 (tempus::number-of (tempus::in-room-of alice))))
    (is (= 3001 (tempus::number-of (tempus::in-room-of bob))))
    (is (search "Bob appears with an ear-splitting bang.~%" (char-output alice)))
    (is (search "Alice disappears in a puff of smoke.~%" (char-output bob)))))

(deftest distance/valid-rooms/returns-distance ()
  (with-mock-players (alice bob)
    (tempus::interpret-command alice "distance 24800")
    (is (equal "Room 24800 is 40 steps away.~%" (char-output alice)))))

(deftest distance/no-connection/returns-error ()
  (with-mock-players (alice bob)
    (tempus::interpret-command alice "distance 43000")
    (is (equal "There is no valid path to room 43000.~%" (char-output alice)))))

(deftest transport/normal/moves-target ()
  (with-mock-players (alice bob)
    (tempus::char-from-room alice)
    (tempus::char-to-room alice (tempus::real-room 3001))
    (with-captured-log log
        (tempus::do-transport-targets alice ".bob")
      (is (= 3001 (tempus::number-of (tempus::in-room-of bob))))
      (is (equal "Bob arrives from a puff of smoke.~%" (char-output alice)))
      (is (equal "Alice has transported you!~%" (char-output bob)))
      (is (search "Alice has transported Bob" log)))))

(deftest transport/no-such-target/error-message ()
  (with-mock-players (alice)
    (tempus::do-transport-targets alice ".zyzygy")
    (is (equal "You can't detect any '.zyzygy'~%" (char-output alice)))))

(deftest teleport/normal/moves-target ()
  (with-mock-players (alice bob)
    (with-captured-log log
        (tempus::do-teleport-name-to-target alice ".bob" "3001")
      (is (= 3001 (tempus::number-of (tempus::in-room-of bob))))
      (is (equal "Okay.~%Bob disappears in a puff of smoke.~%" (char-output alice)))
      (is (search "Alice has teleported you!~%" (char-output bob)))
      (is (search "Alice has teleported Bob" log)))))

(deftest vnum-mob/normal/lists-mobs ()
  (with-mock-players (alice)
    (tempus::do-vnum-mobiles-name alice "puff dragon")
    (is (equal "  1. &g[&n    1&g] &yPuff&n~%" (char-output alice)))))

(deftest vnum-mob/not-found/error-message ()
  (with-mock-players (alice)
    (tempus::do-vnum-mobiles-name alice "zyzygy")
    (is (equal "No mobiles by that name.~%" (char-output alice)))))

(deftest vnum-obj/normal/lists-objs ()
  (with-mock-players (alice)
    (tempus::do-vnum-objects-name alice "mixed potion")
    (is (equal "  1. &g[&n   15&g] &ga mixed potion&n~%"
                (char-output alice)))))

(deftest vnum-obj/not-found/error-message ()
  (with-mock-players (alice)
    (tempus::do-vnum-objects-name alice "zyzygy")
    (is (equal "No objects by that name.~%" (char-output alice)))))

(deftest force-command ()
  (with-mock-players (alice bob)
    (function-trace-bind ((calls tempus::interpret-command))
        (tempus::interpret-command alice "force bob to inventory")
      (is (equal "You got it.~%" (char-output alice)))
      (is (= (length calls) 2))
      (is (eql (first (first calls)) bob))
      (is (equal (second (first calls)) "inventory")))))