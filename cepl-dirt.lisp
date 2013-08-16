;;;; cepl-dirt.lisp

(in-package #:cepl-dirt)

(defun check-formats (format)
  (if (find format '(:rgba :rgb))
      t
      (error "Format must be either :rgb, :rgba or :auto~%Given ~s" format)))

(defun get-element-type (format)
  (case format
    (:rgb :ubyte-vec3)
    (:rgba :ubyte-vec4)))

(defun load-image (filepath &optional (format :rgba))
  "Load image from disk to c-array"
  (when (check-formats format)
    (destructuring-bind (pointer width height channels) 
        (cl-soil:load-image filepath format)
      (values (cgl:make-c-array-from-pointer (list width height) 
                                             (get-element-type format)
                                             pointer)
              channels))))

(defun load-image-to-texture (filepath &optional texture (format :rgba))
  (let ((data (load-image filepath format)))
    (unwind-protect 
         (cond ((typep texture 'null) (cgl:make-texture :initial-contents data))
               ((typep texture 'cgl:gl-texture) (cgl:gl-push 
                                                 (cgl:texref texture) data))
               ((typep texture 'cgl:gpu-array-t) (cgl:gl-push texture data)))
      (cgl:free-c-array data))))
