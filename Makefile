SHELL:=/bin/bash

AZURETRE_HOME?="AzureTRE"

THIS_MAKEFILE_FULLPATH := $(abspath $(lastword $(MAKEFILE_LIST)))
THIS_MAKEFILE_DIR := $(dir $(THIS_MAKEFILE_FULLPATH))

include $(AZURETRE_HOME)/Makefile

# Add your make commands down here

workspace_service_bundle_custom:
	$(MAKE) bundle-build bundle-publish bundle-register \
	DIR="${THIS_MAKEFILE_DIR}/templates/workspace_services/${BUNDLE}" BUNDLE_TYPE=workspace_service

user_resource_bundle_custom:
	$(MAKE) bundle-build bundle-publish bundle-register \
	DIR="${THIS_MAKEFILE_DIR}templates/workspace_services/${WORKSPACE_SERVICE}/user_resources/${BUNDLE}" BUNDLE_TYPE=user_resource WORKSPACE_SERVICE_NAME=tre-service-${WORKSPACE_SERVICE}
