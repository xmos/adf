.DEFAULT_GOAL := help

#**************************
# xcore_interpreter targets
#**************************

.PHONY: xcore_interpreters_build
xcore_interpreters_build:
	cd xcore_interpreters/host_library && bash build.sh
	cd xcore_interpreters/xcore_firmware && bash build.sh

.PHONY: xcore_interpreters_unit_test
xcore_interpreters_unit_test:
	cd xcore_interpreters/xcore_interpreters && pytest --junitxml=xcore_interpreters_junit.xml

.PHONY: xcore_interpreters_dist
xcore_interpreters_dist:
	cd xcore_interpreters && bash build_dist.sh

#**************************
# default build and test targets
#**************************

.PHONY: build
build: xcore_interpreters_build

.PHONY: test
test: xcore_interpreters_unit_test

#**************************
# other targets
#**************************

.PHONY: submodule_update
submodule_update:
	git submodule update --init --recursive

.PHONY: clean
clean:
	rm -rf xcore_interpreters/python_bindings/build
	rm -rf xcore_interpreters/xcore_firmware/build

.PHONY: help
help:
	@:  # This silences the "Nothing to be done for 'help'" output
	$(info usage: make [target])
	$(info )
	$(info )
	$(info primary targets:)
	$(info   build                         Build xcore_interpreters)
	$(info   test                          Run all tests (requires xcore_interpreters[test] package))
	$(info   clean                         Clean all build artifacts)
	$(info )
	$(info xcore_interpreter targets:)
	$(info   xcore_interpreters_build      Run xcore_interpreters build)
	$(info   xcore_interpreters_unit_test  Run xcore_interpreters unit tests (requires xcore_interpreters[test] package))
	$(info   xcore_interpreters_dist       Build xcore_interpreters distribution (requires xcore_interpreters[test] package))
	$(info )
