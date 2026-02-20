;;; review-notes.el --- Global review notes workflow -*- lexical-binding: t; -*-

(defvar review-notes-current-file nil
  "Current review file path under ~/.pi/reviews.")

(defun review-notes--dir ()
  (let ((dir (expand-file-name "~/.pi/reviews/")))
    (unless (file-directory-p dir)
      (make-directory dir t))
    dir))

(defun review-notes--files ()
  (sort (directory-files (review-notes--dir) nil "\\.md$") #'string<))

(defun review-notes--pick-or-create ()
  (let* ((files (review-notes--files))
         (choices (append
                   (when review-notes-current-file
                     (list (format "Use current: %s" (file-name-nondirectory review-notes-current-file))))
                   files
                   '("+ Create new review file")))
         (picked (completing-read "Review target: " choices nil t)))
    (cond
     ((string-prefix-p "Use current:" picked)
      review-notes-current-file)
     ((string= picked "+ Create new review file")
      (let* ((name (string-trim (read-string "New review name: ")))
             (name (replace-regexp-in-string "[[:space:]]+" "-" name))
             (full (expand-file-name (concat name ".md") (review-notes--dir))))
        (unless (file-exists-p full)
          (with-temp-file full
            (insert "# Review Notes: " name "\n\n")
            (insert "Created: " (format-time-string "%Y-%m-%d %H:%M:%S") "\n\n")))
        (setq review-notes-current-file full)
        full))
     ((and picked (not (string-empty-p picked)))
      (let ((full (expand-file-name picked (review-notes--dir))))
        (setq review-notes-current-file full)
        full))
     (t nil))))

(defun review-notes--line-range ()
  (if (use-region-p)
      (let* ((beg (region-beginning))
             (end (region-end))
             (l1 (line-number-at-pos beg))
             (l2 (line-number-at-pos (max beg (1- end)))))
        (cons (min l1 l2) (max l1 l2)))
    (let ((l (line-number-at-pos)))
      (cons l l))))

(defun review-notes--selected-text ()
  (if (use-region-p)
      (buffer-substring-no-properties (region-beginning) (region-end))
    (buffer-substring-no-properties (line-beginning-position) (line-end-position))))

(defun review-notes--lang ()
  (or (and buffer-file-name (file-name-extension buffer-file-name)) "text"))

(defun review-notes--relpath ()
  (if buffer-file-name
      (abbreviate-file-name buffer-file-name)
    (buffer-name)))

;;;###autoload
(defun review-start ()
  "Select or create current review file under ~/.pi/reviews."
  (interactive)
  (let ((f (review-notes--pick-or-create)))
    (if f
        (message "Current review: %s" (file-name-nondirectory f))
      (message "No review selected"))))

(defun review-notes--append-snippet (target)
  (let* ((range (review-notes--line-range))
         (start (car range))
         (end (cdr range))
         (text (review-notes--selected-text))
         (comment (read-string "Comment: "))
         (rel (review-notes--relpath))
         (lang (review-notes--lang)))
    (with-temp-buffer
      (insert (format "## %s (lines %d-%d)\n" rel start end))
      (insert (format "Comment: %s\n\n" (if (string-empty-p comment) "(none)" comment)))
      (insert (format "```%s\n" lang))
      (insert text)
      (unless (string-suffix-p "\n" text) (insert "\n"))
      (insert "```\n\n")
      (append-to-file (point-min) (point-max) target))
    (message "Added snippet to %s" (file-name-nondirectory target))))

;;;###autoload
(defun review-add-snippet ()
  "Add current region (or line) + comment to current review.
If no current review is set, prompt once via `review-start'."
  (interactive)
  (unless (and review-notes-current-file (file-exists-p review-notes-current-file))
    (call-interactively #'review-start))
  (unless (and review-notes-current-file (file-exists-p review-notes-current-file))
    (user-error "No current review selected"))
  (review-notes--append-snippet review-notes-current-file))

;;;###autoload
(defun review-open-current ()
  "Open current review file."
  (interactive)
  (if (and review-notes-current-file (file-exists-p review-notes-current-file))
      (find-file review-notes-current-file)
    (call-interactively #'review-start)
    (when review-notes-current-file
      (find-file review-notes-current-file))))

(provide 'review-notes)
