;;;; dirt.lisp

(in-package #:dirt)

(defun load-image-to-c-array (filename)
  (multiple-value-bind (ptr width height components)
      (cl-soil:load-image filename)
    (let ((elem-type (nth (1- components) '(nil nil :uint8-vec3 :uint8-vec4))))
      (cepl:make-c-array-from-pointer (list width height) elem-type ptr))))


(defun load-image-to-texture (filename &optional (image-format :rgba8) mipmap
					 generate-mipmaps)
  (let* ((array (load-image-to-c-array filename))
	 (pixel-format (cepl:lisp-type->pixel-format :uint8-vec4))
	 (texture (cepl:make-texture
		   array
		   :element-type image-format
		   :pixel-format pixel-format
		   :mipmap mipmap
		   :generate-mipmaps generate-mipmaps)))
    (cepl:free-c-array array)
    texture))
