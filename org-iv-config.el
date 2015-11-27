;;; org-iv-config.el --- configure of org-iv

;; This is free and unencumbered software released into the public domain.

;; Author: kuangdash <kuangdash@163.com>
;; Version: 1.0.0
;; URL: https://github.com/kuangdash/org-iv
;; Package-Requires: ((impatient-mode 1.0.0) (org-mode 8.0))

;;; Commentary:

;; org-iv is a tool used to view html generated by org-file
;; immediately. Powered by impatient-mode.

;;; Code:

(defvar org-iv/root (file-name-directory load-file-name)
  "Where the current package loaded.")

(defcustom org-iv/config-alist nil
  "Association list to control ego publishing behavior.

Each element of the alist is a ego 'project.'  The CAR of
each element is a string, uniquely identifying the project.  The
CDR of each element is a well-formed property list with an even
number of elements, alternating keys and values, specifying
parameters for the publishing process.

  \(:property value :property value ... )

Most properties are optional, but some should always be set:


  `:front-html-file'

The path to the html-strings which will be put on front of html file generated by org-mode.
1. Type: string
2. Example: \"~/default/org-iv-front-file.html\"

  `:back-html-file'

The path to the html-strings which will be put on back of html file generated by org-mode.
1. Type: string
2. Example:  \"~/default/org-iv-back-file.html\"

  `:web-resource-dir'

Where to store CSS and JS files
1. Type: string
2. Example: \"~/default\"

  `:web-test-root'

Where we copy the content of web-resource-dir into
1. Type: string
2. Example: \"~/org-iv-test/\"

  `:web-test-port'

1. Type: number
2. Example: 9876
")

(defvar org-iv--current-config-name nil
  "The current org-iv configure")

(defvar org-iv--config-fallback
  `(:front-html-file ,(expand-file-name "default/org-iv-front-file.html" org-iv/root)
    ;; The file put on front of the html generated by org-file.
    :back-html-file ,(expand-file-name "default/org-iv-back-file.html" org-iv/root)
    ;; The file put on back of the html generated by org-file.
    :web-test-root ,(expand-file-name "default" org-iv/root)
    ;; where we copy the content of web-resource-dir into
    :web-test-port 9876)
  "configure org-iv (default)")

(defvar org-iv--front-html-string nil
  "The string of org-iv/front-html-file.")

(defvar org-iv--back-html-string nil
  "The string of org-iv/back-html-file.")

(defun org-iv/add-to-alist (alist-var new-alist)
  "Add NEW-ALIST to the ALIST-VAR.
If an element with the same key as the key of an element of
NEW-ALIST is already present in ALIST-VAR, add the new values to
it; if a matching element is not already present, append the new
element to ALIST-VAR."
  ;; Loop over all elements of NEW-ALIST.
  (while new-alist
    (let* ((new-element (car new-alist))
           ;; Get the element of ALIST-VAR with the same key of the current
           ;; element of NEW-ALIST, if any.
           (old-element (assoc (car new-element) (symbol-value alist-var))))
      (if old-element
          (progn
            (set alist-var (delete old-element (symbol-value alist-var)))
            ;; Append to `old-element' the values of the current element of
            ;; NEW-ALIST.
            (mapc (lambda (elt) (add-to-list 'old-element elt t))
                  (cdr new-element))
            (set alist-var (add-to-list alist-var old-element t)))
        (add-to-list alist-var new-element t)))
    ;; Next element of NEW-ALIST.
    (setq new-alist (cdr new-alist))))

(org-iv/add-to-alist
 'org-iv/config-alist
 `( ,(cons "default" org-iv--config-fallback)))

(defun org-iv--get-config-option (option)
  "The default org-iv config read function,
which can read `option' from `org-iv/config-alist'
if `option' is not found, get fallback value from
`org-iv--config-fallback'."
  (let ((config-plist (cdr (assoc org-iv--current-config-name
                                  org-iv/config-alist))))
    (if (plist-member config-plist option)
        (plist-get config-plist option)
      (plist-get org-iv--config-fallback option))))

(provide 'org-iv-config)
