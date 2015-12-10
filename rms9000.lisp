(ql:quickload '(cl-irc split-sequence cl-ppcre))
(defpackage :rms9000
  (:use :common-lisp :irc :split-sequence :cl-ppcre)
  (:export :proselytize))
(in-package :rms9000)

(defmacro cvar (trait)
  `(cdr (assoc ',trait *config*)))

(defvar *authorized* '("insert" "some" "nicks"))

(defvar *config* '((server . "irc.xxxxxxxx.net")
		   (nick . "RMSXXXX")
		   (channel . "#xxxxxxxxxx")))

(defparameter *rules* '(("(L|l)(inu|uni|ooni)x" . "I would like to interject for a moment. What you're refering to as Linux, is in fact, GNU/Linux, or as I've recently taken to calling it, GNU plus Linux. Linux is not an operating system unto itself, but rather another free component of a fully functioning GNU system made useful by the GNU corelibs, shell utilities and vital system components comprising a full OS as defined by POSIX.")
			("(F|f)uck" . "FUARRK")
			("(S|s)hit" . "soykaf")
			("(O|o)pen(-|)(S|s)ource" . "I believe you mean Open-Sores")
			("(D|d)(E|e)(S|s)(U|u)" . "desu desu desu desu desu desu desu desu desu desu desu desu desu desu desu desu desu desu desu desu desu desu desu desu desu desu desu desu desu desu desu desu desu desu desu desu desu desu desu desu desu desu desu desu desu desu desu desu desu desu desu")
			("(B|b)(A|a)(C|c)(K|k)(U|u)(P|p)(G|g)(A|a)(T|t)(E|e)" . "I would like to interject for a moment. What you're refering to as Backupgate, is in fact, GNU/Backupgate, or as I've recently taken to calling it, GNU plus Backupgate. Backupgate is not an event unto itself, but rather another free component of a fully functioning GNU event made useful by the GNU corelibs, shell utilities and vital event components comprising a full event as defined by KALYX.")))

(defvar *connection* (connect :nickname (cvar nick)
			      :server (cvar server)))

(defparameter *speak* 't)

(defun converter (temp scale)
  (let ((x nil))
    (labels ((c->f (c) (+ (* 9/5 c) 32))
		     (f->c (f) (* 5/9 (- f 32))))
      (case scale (f (setf x (format nil "~,1fC" (f->c temp))))
	    (c (setf x (format nil "~,1fF" (c->f temp))))))
    x))

(defun temp-func (in)
  (let ((temp (scan-to-strings "^\\d+(F|f|C|c)$" in)))
    (if temp
	(let ((num (scan-to-strings "^\\d+$" in))
	      (scale (scan-to-strings "^[A-z]$" temp)))
	  (cond ((or (equal scale "F") (equal scale "f")) (privmsg *connection* (cvar channel) (converter num 'f)))
		((or (equal scale "C") (equal scale "c")) (privmsg *connection* (cvar channel) (converter num 'c))))))))

(defun msg-hook (msg &aux (args (split-sequence #\space (cadr (arguments msg)))))
  (and (member (source msg) *authorized* :test #'equal)
     (cond ((equal (car args) "%newrule") (if (< (length args) 3)
					     (privmsg *connection* (cvar channel) "You fuarrked up.")
					     (defparameter *rules* (cons (cons (cadr args) (string-trim " "(format nil "~{~a ~}" (cddr args)))) *rules*))))
	   ((equal (car args) "%stop")    (setf *speak* nil))
	   ((equal (car args) "%start")   (setf *speak* 't))
	   ((equal (car args) "%add")     (setf *authorized* (cons (cadr args) *authorized*)))
	   ((equal (car args) "%remove")  (setf *authorized* (remove (cadr args) *authorized* :test #'equal)))
	   ((equal (car args) "%unrule")  (setf *rules* (remove-if (lambda (x) (equal (car x) (cadr args))) *rules*)))))
  (loop for r in *rules*
     do (if (equal (car r) "(L|l)(inu|uni|ooni)x")
	    (if (not (remove nil (mapcar #'(lambda (x) (scan "(G|g)(N|n)(U|u)" x)) args)))
		(if (remove nil (mapcar #'(lambda (x) (scan (car r) x)) args))
		    (if *speak*
			(privmsg *connection* (cvar channel) (cdr r)))))
	    (if (remove nil (mapcar #'(lambda (x) (scan (car r) x)) args))
		(if *speak*
		    (privmsg *connection* (cvar channel) (cdr r))))))
  (if (equal (car args) "%rules")
      (mapc #'(lambda (x) (privmsg *connection* (source msg) (car x))) *rules*)))

(defun proselytize ()
  (join *connection* (cvar channel))
  (add-hook *connection* 'irc::irc-privmsg-message 'msg-hook)
  (read-message-loop *connection*))
