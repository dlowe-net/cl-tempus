(in-package #:tempus.tests)

(in-suite* #:tempus.comm :in :tempus)

(test say
  (with-mock-players (alice bob eva)
    (tempus::interpret-command alice "say foo bar")
    (is (equal "&BYou say, &c'foo bar'&n~%" (char-output alice)))
    (is (equal "&BAlice says, &c'foo bar'&n~%" (char-output bob)))
    (is (equal "&BAlice says, &c'foo bar'&n~%" (char-output eva)))
    (clear-mock-buffers alice bob eva)

    (tempus::interpret-command alice "'foo bar")
    (is (equal "&BYou say, &c'foo bar'&n~%" (char-output alice)))
    (is (equal "&BAlice says, &c'foo bar'&n~%" (char-output bob)))
    (is (equal "&BAlice says, &c'foo bar'&n~%" (char-output eva)))
    (clear-mock-buffers alice bob eva)

    (tempus::interpret-command alice "' foo bar")
    (is (equal "&BYou say, &c'foo bar'&n~%" (char-output alice)))
    (is (equal "&BAlice says, &c'foo bar'&n~%" (char-output bob)))
    (is (equal "&BAlice says, &c'foo bar'&n~%" (char-output eva)))))

(test say-with-escapes
  (with-mock-players (alice)
    (tempus::interpret-command alice "' $ is a dollar sign")
    (is (equal "&BYou say, &c'$ is a dollar sign'&n~%" (char-output alice)))
    (clear-mock-buffers alice)
    (tempus::interpret-command alice "' & is an ampersand")
    (is (equal "&BYou say, &c'& is an ampersand'&n~%" (char-output alice)))
    (clear-mock-buffers alice)
    (tempus::interpret-command alice "' \\ is a backslash")
    (is (equal "&BYou say, &c'\\ is a backslash'&n~%" (char-output alice)))
    (clear-mock-buffers alice)
    (tempus::interpret-command alice "' ] is a right bracket")
    (is (equal "&BYou say, &c'] is a right bracket'&n~%" (char-output alice)))))

(test sayto
  (with-mock-players (alice bob eva)
    (clear-mock-buffers alice bob eva)
    (tempus::interpret-command alice ">bob foo bar")
    (is (equal "&BYou say to Bob, &c'foo bar'&n~%" (char-output alice)))
    (is (equal "&BAlice says to you, &c'foo bar'&n~%" (char-output bob)))
    (is (equal "&BAlice says to Bob, &c'foo bar'&n~%" (char-output eva)))
    (clear-mock-buffers alice bob eva)))

(test gossip
  (with-mock-players (alice bob)
    (setf (tempus::level-of alice) 10)
    (tempus::interpret-command alice "gossip I did it my way")
    (is (equal "&gYou gossip, &n'I did it my way'~%" (char-output alice)))
    (is (equal "&gAlice gossips, &n'I did it my way'~%" (char-output bob)))

    (clear-mock-buffers alice bob)
    (tempus::interpret-command alice "gossip")
    (is (equal "Yes, gossip, fine, gossip we must, but WHAT???~%"
               (char-output alice)))
    (is (equal "" (char-output bob)))))
