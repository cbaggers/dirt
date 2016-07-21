;;;; dirt.lisp

(in-package #:dirt)

(defun load-image-to-c-array (filename &optional (image-format :rgba))
  (let ((filename (if (pathnamep filename)
		      (namestring filename)
		      filename)))
    (multiple-value-bind (ptr width height components actual-components)
	(cl-soil:load-image filename image-format)
      (declare (ignore components))
      (let ((elem-type (nth (1- actual-components)
			    '(nil nil :uint8-vec3 :uint8-vec4))))
	(cepl:make-c-array-from-pointer (list width height) elem-type ptr)))))


(defun load-image-to-texture (filename &optional (image-format :rgba8) mipmap
					 generate-mipmaps)
  (let* ((array (load-image-to-c-array filename :rgba))
	 (texture (cepl:make-texture
		   array
		   :element-type image-format
		   :mipmap mipmap
		   :generate-mipmaps generate-mipmaps)))
    (cepl:free-c-array array)
    texture))
