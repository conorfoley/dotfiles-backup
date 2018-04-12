(define-key evil-insert-state-map (kbd "C-a") 'beginning-of-line)
(define-key evil-insert-state-map (kbd "C-d") 'evil-delete-char)
(define-key evil-insert-state-map (kbd "C-e") 'end-of-line)
(define-key evil-insert-state-map (kbd "C-h") 'left-char)
(define-key evil-insert-state-map (kbd "C-j") 'next-line)
(define-key evil-insert-state-map (kbd "C-k") 'previous-line)
(define-key evil-insert-state-map (kbd "C-l") 'right-char)

(global-set-key (kbd "C-S-j") 'drag-stuff-down)
(global-set-key (kbd "C-S-k") 'drag-stuff-up)

(global-set-key (kbd "C-H-M-S-h") 'windmove-left)
(global-set-key (kbd "C-H-M-S-j") 'windmove-down)
(global-set-key (kbd "C-H-M-S-k") 'windmove-up)
(global-set-key (kbd "C-H-M-S-l") 'windmove-right)

(global-set-key (kbd "C-H-M-S-s") 'split-window-right-and-focus)
(global-set-key (kbd "C-H-M-S-v") 'split-window-below-and-focus)
(global-set-key (kbd "C-H-M-S-w") 'delete-window)

(global-set-key (kbd "H-w") 'delete-frame)
(global-set-key (kbd "C-H-M-:") 'eshell)
