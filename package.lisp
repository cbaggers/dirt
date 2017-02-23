;;;; package.lisp

(defpackage #:dirt
  (:use #:cl)
  (:export :load-image-to-c-array
           :load-image-to-texture
           :save-as-image))
