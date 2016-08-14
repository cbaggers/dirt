;;;; dirt.asd

(asdf:defsystem #:dirt
  :serial t
  :description "A front-end for cl-soil which loads images straight to cepl:c-arrays and cepl:textures"
  :author "Chris Bagley (Baggers) <techsnuffle@gmail.com>"
  :license "BSD 2 Clause"
  :depends-on (#:cepl #:cl-soil)
  :components ((:file "package")
               (:file "dirt")))
