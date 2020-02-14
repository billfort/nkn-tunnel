.DEFAULT_GOAL:=local_or_with_proxy

USE_PROXY=GOPROXY=https://goproxy.io
BUILD=go build -ldflags "-s -w"
BUILD_DIR=build
BIN_DIR=$(GOOS)-$(GOARCH)
BIN_NAME=nkn-tunnel
MAIN=bin/main.go

.PHONY: local
local:
	$(BUILD) -o $(BIN_NAME) $(MAIN)

.PHONY: local_with_proxy
local_with_proxy:
	$(USE_PROXY) $(BUILD) -o $(BIN_NAME) $(MAIN)

.PHONY: local_or_with_proxy
local_or_with_proxy:
	${MAKE} local || ${MAKE} local_with_proxy

.PHONY: build
build:
	mkdir -p $(BUILD_DIR)/$(BIN_DIR)
	GOOS=$(GOOS) GOARCH=$(GOARCH) $(BUILD) -o $(BUILD_DIR)/$(BIN_DIR)/$(BIN_NAME)$(EXT) $(MAIN)
	${MAKE} zip

.PHONY: tar
tar:
	cd $(BUILD_DIR) && rm -f $(BIN_DIR).tar.gz && tar --exclude ".DS_Store" --exclude "__MACOSX" -czvf $(BIN_DIR).tar.gz $(BIN_DIR)

.PHONY: zip
zip:
	cd $(BUILD_DIR) && rm -f $(BIN_DIR).zip && zip --exclude "*.DS_Store*" --exclude "*__MACOSX*" -r $(BIN_DIR).zip $(BIN_DIR)

.PHONY: all
all:
	${MAKE} build GOOS=darwin GOARCH=amd64
	${MAKE} build GOOS=linux GOARCH=amd64
	${MAKE} build GOOS=windows GOARCH=amd64 EXT=.exe