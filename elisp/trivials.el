
(defcustom triv-octopress-workdir (expand-file-name "~/work/pumpkinsugar")
  "An Octopress checkout which Emacs tries to step in")

(defun triv-octopress-new-post (title)
  (interactive "MTitle: ")
  (let ((command-str (format "bash -l -c 'source $HOME/.rvm/scripts/rvm && rvm use 1.9.2 > /dev/null && cd %s && rake new_post[\"%s\"]'" 
			    triv-octopress-workdir title))
	(command-result) (filename))
    (progn
      (message command-str)
      (setq command-result (shell-command-to-string command-str))
      (setq filename (concat triv-octopress-workdir "/" 
			     (replace-regexp-in-string "\\(Creating new post: \\)\\|\n" "" command-result)))
      (find-file filename)
      )))

(provide 'trivials)