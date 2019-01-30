(defun js-set-indent (indent)
  (progn
    (setq js-indent-level indent)
    (setq js2-basic-offset indent)
    (setq json-reformat:indent-width indent)))

(defun js-toggle-indent ()
  (if (equal js2-basic-offset 2)
    (js-set-indent 4)
    (js-set-indent 2)))


(defun local--delete-dups-keep-last (list)
  (reverse (delete-dups (reverse list))))

(defun local--delete-nondirectories (list)
  (remove-if
    (lambda (item)
      (or (equal nil (file-directory-p item))
          (equal "" item)))
    list))

(defun local--path-denormalize (path)
  (replace-regexp-in-string "^~/" user-home-directory path))
(defun local--path-normalize (path)
  (replace-regexp-in-string (concat "^" user-home-directory) "~/" path))

(defun local--add-path (path list)
  (if (file-directory-p path)
    (nconc list (list (local--path-normalize path)))
    list))
(defun local--add-paths (paths list)
  (seq-reduce
    (lambda (list path) (local--add-path path list))
    paths
    list))

(defun local--get-paths ()
  (mapcar 'local--path-denormalize
    (local--delete-nondirectories
      (split-string (getenv "PATH") ":"))))

(defun local--set-paths (paths)
  (setenv "PATH"
    (mapconcat 'identity
      (local--delete-dups-keep-last
        (mapcar 'local--path-normalize paths))
      ":")))

(defun local/add-path (path)
  (local--set-paths
    (local--add-path path
      (local--get-paths))))

(defun local/add-paths (paths)
  (local--set-paths
    (local--add-paths paths
      (local--get-paths))))
