(ql:quickload '(cl-irc split-sequence cl-ppcre))
(defpackage :rms9000
  (:use :common-lisp :irc :split-sequence :cl-ppcre)
  (:export :proselytize))
(in-package :rms9000)


(defvar *pasta* "I would like to interject for a moment. What you're refering to as Linux, is in fact, GNU/Linux, or as I've recently taken to calling it, GNU plus Linux. Linux is not an operating system unto itself, but rather another free component of a fully functioning GNU system made useful by the GNU corelibs, shell utilities and vital system components comprising a full OS as defined by POSIX.")

(defvar *config* '((server . "irc.gnu.org")
		   (nick . "RMS900x")
		   (channel . "#chan_here")))

(defmacro cvar (trait)
  `(cdr (assoc ',trait *config*)))

(defvar *connection* (connect :nickname (cvar nick)
			      :server (cvar server)))

(defun msg-hook (msg)
  (let ((user (source msg))
	(args (split-sequence #\space (cadr (arguments msg)))))
    (if (remove nil (mapcar #'(lambda (x) (scan "(L|l)(inu|uni|ooni)x" x)) args))
	(progn
	  (sleep 10)
	  (privmsg *connection* (cvar channel) (format nil "~a: ~a" user *pasta*))))))



(defun proselytize ()
  (join *connection* (cvar channel))
  (add-hook *connection* 'irc::irc-privmsg-message 'msg-hook)
  (read-message-loop *connection*))
