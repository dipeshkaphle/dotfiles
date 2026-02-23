;;; review-notes.el --- Global review notes workflow -*- lexical-binding: t; -*-

(require 'json)
(require 'cl-lib)

(defvar review-notes-current-file nil
  "Current review file path.")

(defvar review-notes-script
  (let* ((root (or (and (fboundp 'doom-project-root) (doom-project-root))
                   (expand-file-name "~/dotfiles")))
         (candidates
          (list (expand-file-name "scripts/review_notes.py" root)
                (expand-file-name "~/dotfiles/scripts/review_notes.py")
                (expand-file-name "~/.config/scripts/review_notes.py")
                "review_notes.py")))
    (cl-find-if (lambda (f) (or (file-executable-p f) (executable-find f))) candidates))
  "Path to review_notes.py script.")

(defvar review-notes-dir nil
  "Optional directory to store review notes (defaults to ~/.review-notes).")

(defun review-notes--exec-json (args)
  (let* ((base-cmd (list "python3" review-notes-script))
         (full-cmd (if review-notes-dir
                       (append base-cmd (list "--dir" (expand-file-name review-notes-dir)) args)
                     (append base-cmd args)))
         (output (with-output-to-string
                   (with-current-buffer standard-output
                     (apply #'call-process (car full-cmd) nil t nil (cdr full-cmd))))))
    (condition-case nil
        (json-read-from-string output)
      (error nil))))

(defun review-notes--list ()
  (let ((res (review-notes--exec-json '("list"))))
    (append res nil))) ;; Convert vector to list

(defun review-notes--create (name)
  (let* ((res (review-notes--exec-json (list "create" name)))
         (path (cdr (assoc 'path res))))
    path))

(defun review-notes--append-snippet (target)
  (let* ((range (review-notes--line-range))
         (start (car range))
         (end (cdr range))
         (text (review-notes--selected-text))
         (comment (read-string "Comment: "))
         (rel (review-notes--relpath))
         (lang (review-notes--lang)))
    
    (let* ((base-args (list review-notes-script "add" target rel 
                            (number-to-string start) (number-to-string end) 
                            comment lang))
           (args (if review-notes-dir
                     (append (list review-notes-script "--dir" (expand-file-name review-notes-dir) "add" target rel 
                                   (number-to-string start) (number-to-string end) 
                                   comment lang))
                   base-args)))
      (with-temp-buffer
        (insert text)
        (let ((code (apply #'call-process-region (point-min) (point-max) "python3" nil (list t nil) nil args)))
          (goto-char (point-min))
          (unless (zerop code)
            (message "Review Notes Error: %s" (buffer-string))))))
    
    (message "Added snippet to %s" (file-name-nondirectory target))))

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
      (file-relative-name buffer-file-name (doom-project-root))
    (buffer-name)))

(defun review-notes--pick-or-create ()
  (let* ((files (review-notes--list))
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
      (let* ((name (read-string "New review name: "))
             (full (review-notes--create name)))
        (setq review-notes-current-file full)
        full))
     ((and picked (not (string-empty-p picked)))
      ;; The script list returns filenames, we need full path.
      ;; But the script 'add' can take just filename if it's in default dir?
      ;; The python script "add" function checks if it's absolute, else joins with REVIEW_DIR.
      ;; So filename is fine. But for consistency let's store what create returns (full path).
      ;; Wait, 'list' returns filenames. We need to construct path or rely on script.
      ;; Let's rely on script accepting filename. But for UI 'Use current', we might want full path.
      ;; Let's just store the filename if that's what we get, or maybe expand it manually if needed.
      ;; Actually, let's keep it simple: store what we get.
      ;; If we pass filename to "add", python script handles it.
      (setq review-notes-current-file picked)
      picked)
     (t nil))))

;;;###autoload
(defun review-start ()
  "Select or create current review file."
  (interactive)
  (let ((f (review-notes--pick-or-create)))
    (if f
        (message "Current review: %s" (file-name-nondirectory f))
      (message "No review selected"))))

;;;###autoload
(defun review-add-snippet ()
  "Add current region (or line) + comment to current review."
  (interactive)
  (unless (and review-notes-current-file (not (string-empty-p review-notes-current-file)))
    (call-interactively #'review-start))
  (if (and review-notes-current-file (not (string-empty-p review-notes-current-file)))
      (review-notes--append-snippet review-notes-current-file)
    (user-error "No review file selected")))

;;;###autoload
(defun review-open-current ()
  "Open current review file."
  (interactive)
  (unless review-notes-current-file
    (call-interactively #'review-start))
  (if review-notes-current-file
      (find-file (expand-file-name review-notes-current-file "~/.pi/reviews/")) ;; Expand just in case
    (message "No review selected")))

;; Comments Overlay
(defvar-local review-notes-overlays nil)

(defun review-notes--parse (target)
  (let ((res (review-notes--exec-json (list "parse" target))))
    (append res nil)))

;;;###autoload
(defun review-toggle-comments ()
  "Toggle display of review comments from current review file."
  (interactive)
  (if review-notes-overlays
      (progn
        (mapc #'delete-overlay review-notes-overlays)
        (setq review-notes-overlays nil)
        (message "Review comments hidden"))
    
    (unless review-notes-current-file
      (call-interactively #'review-start))
    
    (when review-notes-current-file
      (let* ((comments (review-notes--parse review-notes-current-file))
             (abs-path (buffer-file-name))
             (count 0))
        (dolist (item comments)
          (let ((file (cdr (assoc 'file item)))
                (start (cdr (assoc 'start_line item)))
                (end (cdr (assoc 'end_line item)))
                (comment (cdr (assoc 'comment item))))
            ;; Check if file matches suffix
            (when (and abs-path (string-suffix-p file abs-path))
              (save-excursion
                (goto-char (point-min))
                (forward-line (1- start)) ;; Start of snippet
                (let ((start-pos (point)))
                  (forward-line (- end start -1)) ;; Go to *after* the end line (start of end+1)
                  (let ((end-pos (point)))
                    ;; Highlight the snippet range
                    (let ((ov-hl (make-overlay start-pos (1- end-pos)))) ;; -1 to avoid newline if we want
                      (overlay-put ov-hl 'face 'highlight)
                      (push ov-hl review-notes-overlays))

                    ;; Add comment at the bottom
                    (goto-char (1- end-pos)) ;; Go to end of last line
                    (let* ((indent "    ")
                           (prefix "   ")
                           (wrapped (with-temp-buffer
                                      (insert prefix comment)
                                      (fill-region (point-min) (point-max))
                                      (goto-char (point-min))
                                      (while (re-search-forward "\n" nil t)
                                        (replace-match (concat "\n" indent) nil nil))
                                      (buffer-string)))
                           (ov-comment (make-overlay (line-end-position) (line-end-position))))
                      (overlay-put ov-comment 'after-string 
                                   (concat "\n" 
                                           (propertize (concat indent wrapped) 
                                                       'face 'font-lock-comment-face)))
                      (push ov-comment review-notes-overlays)
                      (setq count (1+ count)))))))))
        (message "Showing %d comments from %s" count (file-name-nondirectory review-notes-current-file))))))

(provide 'review-notes)
