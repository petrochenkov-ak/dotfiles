all:
	# not works with CR (Carriage Return) end of line
	# use .editorconfig 'end_of_line = lf'
	find ./ignore_parts -type f -name "*.gitignore" -exec cat {} \; -exec echo \; > ignore
	find hooks -type f -exec chmod +x {} +
	find -H ~/git -maxdepth 3 -type d -path "*/.git" -exec rsync -az --delete --mkpath "$(CURDIR)/templates/hooks/" {}/hooks/ \;


