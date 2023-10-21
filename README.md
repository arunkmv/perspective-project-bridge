# Perspective project.el bridge

Creates a perspective for each project.el project. Based on [persp-mode-projectile-bridge](https://github.com/Bad-ptr/persp-mode-projectile-bridge.el).

## Usage
### Example configuration:
```elisp
 (with-eval-after-load "perspective-project-bridge-autoloads"
   (add-hook 'after-init-hook
			 (lambda ()
				 (perspective-project-bridge-mode 1))
			 t))

```

### With use-package:
```elisp
 (use-package perspective-project-bridge
   :hook
   (perspective-project-bridge-mode . (lambda ()
									   (if perspective-project-bridge-mode
										   (perspective-project-bridge-find-perspectives-for-all-buffers)
										 (perspective-project-bridge-kill-perspectives))))
   (persp-mode . perspective-project-bridge-mode))
```

### Automatic buffer assignment
By adding the following hook, all buffers are automatically assigned a project-specific perspective when ```perspective-project-bridge-mode``` is enabled and all bridge perspectives are killed when the mode is disabled.
```elisp
   (add-hook 'perspective-project-bridge-mode-hook
			 (lambda ()
				 (if perspective-project-bridge-mode
					 (perspective-project-bridge-find-perspectives-for-all-buffers)
				   (perspective-project-bridge-kill-perspectives))))
```
