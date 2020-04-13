((nil . ((eval . (set (make-local-variable 'current-dir)
                      (file-name-directory
                       (let ((d (dir-locals-find-file "./")))
                         (if (stringp d) d (car d))))))
         (eval . (setq docker-tramp-docker-executable
                       (concat current-dir "podman-wrapper"))))))
