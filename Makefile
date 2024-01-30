CHECK := $(shell command -v yq 2> /dev/null)

install : files/register.yaml
ifndef CHECK
	$(error "yq is required but could not be executed")
endif
	src/install.sh

save : files/register.yaml
ifndef CHECK
	$(error "yq is required but could not be executed")
endif
	src/save.sh

clean:
	rm -R -- files/*/
