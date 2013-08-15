;;;; cepl-dirt.lisp

(in-package #:cepl-dirt)

(defun load-image ())



(defun load-image (filepath &optional (format :rgba))
  (unless (find format '(:rgba :rgb))
    (error "Format must be either :rgb or :rgba"))
  (let ((result (cl-soil:load-image filepath format)))))
