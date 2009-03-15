(in-package #:tempus.tests)

(in-suite (defsuite (tempus.clan :in test-full)))

(deftest create-and-destroy-clan/normal/clan-created ()
  (let ((clan-id (+ 900 (random 100))))
    (unwind-protect
         (let ((clan (tempus::create-clan clan-id)))
           (is (not (null clan)))
           (is (= (tempus::idnum-of clan) clan-id)))
      (tempus::delete-clan clan-id))
    (is (null (tempus::real-clan clan-id)))))

(deftest add-and-remove-clan-member/with-player/added-and-removed ()
  (with-fixtures ((clan mock-clan)
                  (alice mock-player :fullp t))
    (setf (tempus::plr-bits-of alice) tempus::+plr-clan-leader+)
    (tempus::add-clan-member alice clan)
    (is (= (tempus::clan-of alice) (tempus::idnum-of clan)))
    (is (zerop (logand (tempus::plr-bits-of alice) tempus::+plr-clan-leader+)))
    (is (member (tempus::idnum-of alice) (tempus::members-of clan)
                :key 'tempus::idnum-of))
    (tempus::remove-clan-member alice clan)
    (is (zerop (tempus::clan-of alice)))
    (is (not (member (tempus::idnum-of alice) (tempus::members-of clan)
                     :key 'tempus::idnum-of)))))

(deftest resolve-clan-alias/with-number/returns-clan ()
  (with-fixtures ((clan mock-clan))
    (let ((result (tempus::resolve-clan-alias (write-to-string (tempus::idnum-of clan)))))
      (is (eql clan result)))))

(deftest resolve-clan-alias/with-name/returns-clan ()
  (with-fixtures ((clan mock-clan))
    (let ((result (tempus::resolve-clan-alias (tempus::name-of clan))))
      (is (eql clan result)))))

(deftest send-to-clan/clan-members-receive ()
  (with-fixtures ((clan mock-clan)
                  (alice mock-player :fullp t))
    (tempus::add-clan-member alice clan)
    (clear-mock-buffers alice)
    (tempus::send-to-clan (tempus::idnum-of clan) "Testing.")
    (char-output-is alice "&cTesting.&n~%")))

(deftest char-can-enroll/npc/returns-nil ()
  (with-fixtures ((clan mock-clan)
                  (alice mock-player :fullp t))
    (tempus::add-clan-member alice clan)
    (setf (tempus::plr-bits-of alice) tempus::+plr-clan-leader+)
    (with-fixtures ((mallory mock-mobile))
      (is (null (tempus::char-can-enroll alice mallory clan)))
      (char-output-is alice "You can only enroll player characters.~%"))))

(deftest char-can-enroll/is-charmed/returns-nil ()
  (with-fixtures ((clan mock-clan)
                  (alice mock-player :fullp t)
                  (bob mock-player :fullp t))
    (clear-mock-buffers alice bob)
    (tempus::add-clan-member alice clan)
    (setf (tempus::plr-bits-of alice) tempus::+plr-clan-leader+)
    (setf (tempus::aff-flags-of alice) (logior (tempus::aff-flags-of alice)
                                               tempus::+aff-charm+))
    (is (null (tempus::char-can-enroll alice bob clan)))
    (char-output-is alice "You obviously aren't in your right mind.~%")))

(deftest char-can-enroll/already-in-clan/returns-nil ()
  (with-fixtures ((clan mock-clan)
                  (alice mock-player :fullp t)
                  (bob mock-player :fullp t))
    (clear-mock-buffers alice bob)
    (tempus::add-clan-member alice clan)
    (tempus::add-clan-member bob clan)
    (setf (tempus::plr-bits-of alice) tempus::+plr-clan-leader+)
    (is (null (tempus::char-can-enroll alice bob clan)))
    (char-output-is alice "That person is already in the clan.~%")))

(deftest char-can-enroll/in-other-clan/returns-nil ()
  (with-fixtures ((clan-a mock-clan)
                  (clan-b mock-clan)
                  (alice mock-player :fullp t)
                  (bob mock-player :fullp t))
    (clear-mock-buffers alice bob)
    (tempus::add-clan-member alice clan-a)
    (tempus::add-clan-member bob clan-b)
    (setf (tempus::plr-bits-of alice) tempus::+plr-clan-leader+)
    (is (null (tempus::char-can-enroll alice bob clan-a)))
    (char-output-is alice "You cannot while they are a member of another clan.~%")))

(deftest char-can-enroll/target-is-frozen/returns-nil ()
  (with-fixtures ((clan mock-clan)
                  (alice mock-player :fullp t)
                  (bob mock-player :fullp t))
    (clear-mock-buffers alice bob)
    (tempus::add-clan-member alice clan)
    (setf (tempus::plr-bits-of alice) tempus::+plr-clan-leader+)
    (setf (tempus::plr-bits-of bob) tempus::+plr-frozen+)
    (is (null (tempus::char-can-enroll alice bob clan)))
    (is (equal "They are frozen right now.  Wait until a god has mercy.~%"
               (char-output alice)))))

(deftest char-can-enroll/target-is-low-level/returns-nil ()
  (with-fixtures ((clan mock-clan)
                  (alice mock-player :fullp t)
                  (bob mock-player :fullp t))
    (clear-mock-buffers alice bob)
    (tempus::add-clan-member alice clan)
    (setf (tempus::plr-bits-of alice) tempus::+plr-clan-leader+)
    (is (null (tempus::char-can-enroll alice bob clan)))
    (is (equal (format nil "Players must be level ~d before being inducted into the clan.~~%"
                       tempus::+lvl-can-clan+)
               (char-output alice)))))

(deftest char-can-enroll/char-is-owner/returns-t ()
  (with-fixtures ((clan mock-clan)
                  (alice mock-player :fullp t)
                  (bob mock-player :fullp t))
    (clear-mock-buffers alice bob)
    (tempus::add-clan-member alice clan)
    (setf (tempus::level-of bob) tempus::+lvl-can-clan+)
    (setf (tempus::owner-of clan) (tempus::idnum-of alice))
    (is (tempus::char-can-enroll alice bob clan))
    (char-output-has alice "")))

(deftest char-can-enroll/char-is-not-allowed/returns-nil ()
  (with-fixtures ((clan mock-clan)
                  (alice mock-player :fullp t)
                  (bob mock-player :fullp t))
    (clear-mock-buffers alice bob)
    (tempus::add-clan-member alice clan)
    (setf (tempus::level-of bob) tempus::+lvl-can-clan+)
    (is (null (tempus::char-can-enroll alice bob clan)))
    (char-output-is alice "You are not a leader of the clan!~%")))

(deftest char-can-dismiss/char-is-self/returns-nil ()
  (with-fixtures ((clan mock-clan)
                  (alice mock-player :fullp t))
    (tempus::add-clan-member alice clan)
    (is (null (tempus::char-can-dismiss alice alice clan)))
    (char-output-is alice "Try resigning if you want to leave the clan.~%")))

(deftest char-can-dismiss/is-charmed/returns-nil ()
  (with-fixtures ((clan mock-clan)
                  (alice mock-player :fullp t)
                  (bob mock-player :fullp t))
    (clear-mock-buffers alice bob)
    (tempus::add-clan-member alice clan)
    (tempus::add-clan-member bob clan)
    (setf (tempus::plr-bits-of alice) tempus::+plr-clan-leader+)
    (setf (tempus::aff-flags-of alice) (logior (tempus::aff-flags-of alice)
                                               tempus::+aff-charm+))
    (is (null (tempus::char-can-dismiss alice bob clan)))
    (char-output-is alice "You obviously aren't quite in your right mind.~%")))

(deftest char-can-dismiss/char-not-in-clan/returns-nil ()
  (with-fixtures ((clan mock-clan)
                  (alice mock-player)
                  (bob mock-player))
    (clear-mock-buffers alice bob)
    (is (null (tempus::char-can-dismiss alice bob clan)))
    (char-output-is alice "Try joining a clan first.~%")))

(deftest char-can-dismiss/target-not-in-clan/returns-nil ()
  (with-fixtures ((clan mock-clan)
                  (alice mock-player :fullp t)
                  (bob mock-player :fullp t))
    (clear-mock-buffers alice bob)
    (tempus::add-clan-member alice clan)
    (is (null (tempus::char-can-dismiss alice bob clan)))
    (char-output-is alice "Umm, why don't you check the clan list, okay?~%")))

(deftest char-can-dismiss/char-owns-clan/returns-t ()
  (with-fixtures ((clan mock-clan)
                  (alice mock-player :fullp t)
                  (bob mock-player :fullp t))
    (clear-mock-buffers alice bob)
    (tempus::add-clan-member alice clan)
    (tempus::add-clan-member bob clan)
    (setf (tempus::owner-of clan) (tempus::idnum-of alice))
    (is (tempus::char-can-dismiss alice bob clan))
    (char-output-has alice "")))

(deftest char-can-dismiss/char-not-leader/returns-t ()
  (with-fixtures ((clan mock-clan)
                  (alice mock-player :fullp t)
                  (bob mock-player :fullp t))
    (clear-mock-buffers alice bob)
    (tempus::add-clan-member alice clan)
    (tempus::add-clan-member bob clan)
    (is (null (tempus::char-can-dismiss alice bob clan)))
    (char-output-is alice "You are not a leader of the clan!~%")))

(deftest char-can-dismiss/char-doesnt-have-rank/returns-nil ()
  (with-fixtures ((clan mock-clan)
                  (alice mock-player :fullp t)
                  (bob mock-player :fullp t))
    (clear-mock-buffers alice bob)
    (tempus::add-clan-member alice clan)
    (setf (tempus::plr-bits-of alice) tempus::+plr-clan-leader+)
    (tempus::add-clan-member bob clan)
    (is (null (tempus::char-can-dismiss alice bob clan)))
    (char-output-is alice "You don't have the rank for that.~%")))

(deftest char-can-dismiss/target-is-leader/returns-nil ()
  (with-fixtures ((clan mock-clan)
                  (alice mock-player :fullp t)
                  (bob mock-player :fullp t))
    (clear-mock-buffers alice bob)
    (tempus::add-clan-member alice clan)
    (setf (tempus::plr-bits-of alice) tempus::+plr-clan-leader+)
    (incf (tempus::rank-of (find (tempus::idnum-of alice) (tempus::members-of clan)
                                 :key 'tempus::idnum-of)))

    (tempus::add-clan-member bob clan)
    (setf (tempus::plr-bits-of bob) tempus::+plr-clan-leader+)
    (is (null (tempus::char-can-dismiss alice bob clan)))
    (char-output-is alice "You cannot dismiss co-leaders.~%")))

(deftest char-can-dismiss/char-is-leader-with-rank/returns-t ()
  (with-fixtures ((clan mock-clan)
                  (alice mock-player :fullp t)
                  (bob mock-player :fullp t))
    (clear-mock-buffers alice bob)
    (tempus::add-clan-member alice clan)
    (setf (tempus::plr-bits-of alice) tempus::+plr-clan-leader+)
    (incf (tempus::rank-of (find (tempus::idnum-of alice) (tempus::members-of clan)
                                 :key 'tempus::idnum-of)))

    (tempus::add-clan-member bob clan)
    (is (tempus::char-can-dismiss alice bob clan))))

(deftest perform-clanlist/not-full-clanlist/shows-partial-clanlist ()
  (with-fixtures ((clan mock-clan)
                  (alice mock-player :fullp t))
    (tempus::add-clan-member alice clan)
    (tempus::perform-clanlist alice clan nil)
    (char-output-has alice "Members of clan Clan :~%")
    (char-output-has alice "&g[&n 1 &mMage&g] &n&gAlice the member")))

(deftest perform-show-clan/shows-clan ()
  (with-fixtures ((clan mock-clan)
                  (alice mock-player))
    (tempus::perform-show-clan alice clan)
    (char-output-has alice "CLAN ~d" (tempus::idnum-of clan))))

(deftest perform-list-clans/lists-clans ()
  (with-fixtures ((clan mock-clan)
                  (alice mock-player))
    (tempus::perform-list-clans alice clan)
    (char-output-has alice " ~3d - &cClan" (tempus::idnum-of clan))))

(deftest clan-house-can-enter/non-clan-room/returns-t ()
  (with-fixtures ((alice mock-player))
    (is (tempus::clan-house-can-enter alice (tempus::real-room 101)))))

(deftest clan-house-can-enter/in-clan/returns-t ()
  (with-fixtures ((clan mock-clan)
                  (alice mock-player :fullp t))
    (let ((room (tempus::real-room 101)))
      (tempus::add-clan-member alice clan)
      (tempus::add-clan-room room clan)
      (is (tempus::clan-house-can-enter alice room))
      (tempus::remove-clan-room room clan))))

(deftest clan-house-can-enter/not-in-clan/returns-nil ()
  (with-fixtures ((clan mock-clan)
                  (alice mock-player :fullp t))
    (let ((room (tempus::real-room 101)))
      (tempus::add-clan-room room clan)
      (is (null (tempus::clan-house-can-enter alice room)))
      (tempus::remove-clan-room room clan))))
