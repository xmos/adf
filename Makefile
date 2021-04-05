CLOBBER_FLAG := '-c'

.DEFAULT_GOAL := help

#**************************
# xcore_interpreter targets
#**************************

.PHONY: xcore_interpreters_build
xcore_interpreters_build:
	cd xcore_interpreters/python_bindings && bash build.sh $(CLOBBER_FLAG)
	cd xcore_interpreters/xcore_firmware && bash build.sh $(CLOBBER_FLAG)

.PHONY: xcore_interpreters_unit_test
xcore_interpreters_unit_test:
	cd xcore_interpreters/xcore_interpreters && pytest --junitxml=xcore_interpreters_junit.xml

.PHONY: xcore_interpreters_dist
xcore_interpreters_dist:
	cd xcore_interpreters && bash build_dist.sh

#**************************
# ALL tests target
#**************************

.PHONY: build
build: xcore_interpreters_build

#**************************
# ALL tests target
#**************************

.PHONY: test
test: xcore_interpreters_unit_test

#**************************
# ci target
#**************************

.PHONY: ci 
ci: CLOBBER_FLAG = '-c'
ci: build \
 test \
 xcore_interpreters_dist

 
#**************************
# development targets
#**************************

.PHONY: submodule_update
submodule_update: 
	git submodule update --init --recursive

.PHONY: _develop
_develop: submodule_update build

.PHONY: develop
develop: CLOBBER_FLAG=''
develop: _develop

.PHONY: clobber
clobber: CLOBBER_FLAG='-c'
clobber: _develop

.PHONY: help
help:
	@:  # This silences the "Nothing to be done for 'help'" output
	$(info usage: make [target])
	$(info )
	$(info )
	$(info primary targets:)
	$(info   build                         Build xcore_interpreters)
	$(info   develop                       Update submodules and build xcore_interpreters)
	$(info   clobber                       Update submodules, then clean and rebuild xcore_interpreters)
	$(info   test                          Run all tests (requires xcore_interpreters[test]))
	$(info   ci                            Run continuous integration build and test (requires xcore_interpreters[test]))
	$(info )
	$(info xcore_interpreter targets:)
	$(info   xcore_interpreters_build      Run xcore_interpreters build)
	$(info   xcore_interpreters_unit_test  Run xcore_interpreters unit tests (requires xcore_interpreters[test]))
	$(info   xcore_interpreters_dist       Build xcore_interpreters distribution (requires xcore_interpreters[test]))
	$(info )
