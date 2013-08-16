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
  (%load-image-to-texture filepath texture format))

(defgeneric %load-image-to-texture (filepath texture format))

(defmethod %load-image-to-texture (filepath (texture null) format)
  (let ((data (load-image filepath format)))
    (unwind-protect (cgl:make-texture :initial-contents data)
      (cgl:free-c-array data))))

(defmethod %load-image-to-texture (filepath (texture cgl:gl-texture) format)
  (let ((data (load-image filepath format)))
    (unwind-protect (cgl:gl-push (cgl:texref texture) data)
      (cgl:free-c-array data))))

(defmethod %load-image-to-texture (filepath (texture cgl:gpu-array-t) format)
  (let ((data (load-image filepath format)))
    (unwind-protect (cgl:gl-push texture data)
      (cgl:free-c-array data))))
