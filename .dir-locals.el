((enh-ruby-mode
  (eval . (setq-local rspec-use-docker-when-possible t))
  (eval . (setq-local rspec-use-spring-when-possible t))
  (eval . (setq-local rspec-docker-command "docker compose exec -it"))
  (eval . (setq-local rspec-docker-container "app"))
  (eval . (setq-local rspec-docker-cwd "/rails/"))
  (eval . (setq-local rspec-docker-file-name "Dockerfile.dev"))
  (eval . (setq-local rspec-primary-source-dirs '("app")))
  (eval . (add-hook 'lsp-managed-mode-hook (lambda () (setq-local flycheck-checker 'ruby-rubocop))))
  (eval . (add-to-list 'lsp-disabled-clients 'ruby-ls))
  (eval . (add-to-list 'lsp-disabled-clients 'rubocop-ls)))
 (js2-mode
  (eval . (add-hook 'lsp-managed-mode-hook
                    (lambda ()
                      (setq-local flycheck-checker 'javascript-eslint))
                      (setq-local flycheck-javascript-eslint-executable
                                  (concat (locate-dominating-file default-directory ".dir-locals.el")
                                          "node_modules/.bin/eslint"))
                      (message "Dir-locals: ESLint setup in %s" major-mode))))
(nil
  (eval . (add-hook 'after-change-major-mode-hook
                    (lambda ()
                      (setq-local lsp-enabled-clients
                                  (append '(ts-ls sql-ls json-ls ruby-lsp-ls) lsp-enabled-clients))
                      (message "Dir-locals: Hook ran in %s" major-mode))
                    nil t))
  (eval . (setq-local my/dap-debug-project-root "/Users/apmiller/dev/tmp/"))))
