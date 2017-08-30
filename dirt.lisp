;;;; dirt.lisp

(in-package #:dirt)

(defvar *valid-save-image-formats*
  '(:tga :bmp :dds))

(defun load-image-to-c-array (filename &optional (image-format :rgba))
  (let ((filename (if (pathnamep filename)
                      (namestring filename)
                      filename)))
    (multiple-value-bind (ptr width height components actual-components)
        (cl-soil:load-image filename image-format)
      (declare (ignore components))
      (let ((elem-type (nth (1- actual-components)
                            '(nil nil :uint8-vec3 :uint8-vec4))))
        (cepl:make-c-array-from-pointer (list width height) elem-type ptr
                                        :free #'cl-soil:free-image-data)))))

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

(defgeneric save-as-image (texture file-path &optional format)
  ;;
  (:method ((texture cepl:texture) file-path &optional format)
           (cepl:with-c-array-freed (arr (cepl:pull1-g texture))
             (save-as-image arr file-path format)))
  ;;
  (:method ((image cepl:c-array) file-path &optional format)
    (labels ((path->fmt (path)
               (let ((tmp (pathname-type path)))
                 (when tmp (intern (string-upcase tmp) :keyword)))))
      (let* ((path (uiop:ensure-pathname file-path))
             (format (or format (path->fmt path))))
        (assert (member format *valid-save-image-formats*) (format)
                "Dirt: save-as-image can only save in the following formats:~%~a~%~%However the format ~a was requested"
                *valid-save-image-formats* format)
        (destructuring-bind (x y) (cepl:c-array-dimensions image)
          (let* ((elem-type (cepl:c-array-element-type image))
                 (pixel-fmt (cepl:lisp-type->pixel-format elem-type))
                 (component-len (cepl:pixel-format-comp-length pixel-fmt)))
            (cl-soil:save-image file-path format x y component-len
                                (cepl:c-array-pointer image))
            file-path))))))
