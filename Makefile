all:

REPO=repo
SESSION=output

# Docker
DOCKER_REPOSITORY=microsoft/dotnet-buildtools-prereqs
DOCKER_TAG=ubuntu-14.04-cross-0cd4667-20172211042239
DOCKER_IMAGE_NAME=$(DOCKER_REPOSITORY):$(DOCKER_TAG)
DOCKER_ENV=-e ROOTFS_DIR=/crossrootfs/arm
DOCKER_WORKING_DIR=/opt/code
DOCKER_RUN_OPTS=--rm $(DOCKER_ENV) $(DOCKER_IMAGE_NAME)

# Common
change_ownership_to_uid:
	docker run -v $(DIR):$(DOCKER_WORKING_DIR) -w $(DOCKER_WORKING_DIR) $(DOCKER_RUN_OPTS) \
    chown $( id -u ${USER} ):$( id -u ${USER} ) . -R

# CoreCLR
CLR_URL=http://github.com/dotnet/coreclr.git

CLR_OPTS+=skipgenerateversion

CLR_CMAKE_OPTS+=cmakeargs -DFEATURE_GDBJIT=TRUE

CLR_DBG_OPTS=debug
CLR_CHK_OPTS=checked
CLR_REL_OPTS=release

coreclr_debug_cross_build:
	docker run -v $(CLR_DIR):$(DOCKER_WORKING_DIR) -w $(DOCKER_WORKING_DIR) $(DOCKER_RUN_OPTS) \
	./build.sh cross arm $(CLR_DBG_OPTS) $(CLR_CMAKE_OPTS) $(CLANG_TAG)

coreclr_checked_cross_build:
	docker run -v $(CLR_DIR):$(DOCKER_WORKING_DIR) -w $(DOCKER_WORKING_DIR) $(DOCKER_RUN_OPTS) \
	./build.sh cross arm $(CLR_CHK_OPTS) $(CLR_CMAKE_OPTS) $(CLANG_TAG)

coreclr_debug_collect:
	./coreclr_collect $(SESSION) $(CLR_DIR) Linux arm Debug

coreclr_checked_collect:
	./coreclr_collect $(SESSION) $(CLR_DIR) Linux arm Checked

# CoreFX
FX_URL=http://github.com/dotnet/corefx.git

FX_NATIVE_OPTS=
FX_MANAGED_OPTS=
FX_EXTRA_OPTS=/p:BinPlaceNETCoreAppPackage=true

FX_DBG_OPTS=-debug
FX_REL_OPTS=-release

corefx_debug_cross_build:
	docker run -v $(FX_DIR):$(DOCKER_WORKING_DIR) -w $(DOCKER_WORKING_DIR) $(DOCKER_RUN_OPTS) \
	./build.sh $(FX_DBG_OPTS) -buildArch=arm -RuntimeOS=ubuntu.14.04-arm -- $(FX_EXTRA_OPTS)

corefx_debug_collect:
	./corefx_collect $(SESSION) $(FX_DIR) Linux arm Debug
