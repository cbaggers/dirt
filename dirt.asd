;;;; dirt.asd

(asdf:defsystem #:dirt
  :serial t
  :description "A front-end for cepl-soil which loads images straight to cepl:c-arrays and cepl:textures"
  :author "Baggers"
  :license "LLGPL"
  :depends-on (#:cepl #:cl-soil)
  :components ((:file "package")
               (:file "dirt")))
