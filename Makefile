TOP_DIR = ../..
include $(TOP_DIR)/tools/Makefile.common

DEPLOY_RUNTIME ?= /kb/runtime
TARGET ?= /kb/deployment

APP_SERVICE = app_service

SRC_PERL = $(wildcard scripts/*.pl)
BIN_PERL = $(addprefix $(BIN_DIR)/,$(basename $(notdir $(SRC_PERL))))
DEPLOY_PERL = $(addprefix $(TARGET)/bin/,$(basename $(notdir $(SRC_PERL))))

SRC_SERVICE_PERL = $(wildcard service-scripts/*.pl)
BIN_SERVICE_PERL = $(addprefix $(BIN_DIR)/,$(basename $(notdir $(SRC_SERVICE_PERL))))
DEPLOY_SERVICE_PERL = $(addprefix $(SERVICE_DIR)/bin/,$(basename $(notdir $(SRC_SERVICE_PERL))))

CLIENT_TESTS = $(wildcard t/client-tests/*.t)
SERVER_TESTS = $(wildcard t/server-tests/*.t)
PROD_TESTS = $(wildcard t/prod-tests/*.t)

LOVAN_PERL = $(wildcard Viral_Annotation/*.pl)
LOVAN_BIN = $(addprefix $(BIN_DIR)/,$(notdir $(LOVAN_PERL)))
LOVAN_DEPLOY = $(addprefix $(TARGET)/bin/,$(notdir $(LOVAN_PERL)))

STARMAN_WORKERS = 8
STARMAN_MAX_REQUESTS = 100

TPAGE_ARGS = --define kb_top=$(TARGET) --define kb_runtime=$(DEPLOY_RUNTIME) --define kb_service_name=$(SERVICE) \
	--define kb_service_port=$(SERVICE_PORT) --define kb_service_dir=$(SERVICE_DIR) \
	--define kb_sphinx_port=$(SPHINX_PORT) --define kb_sphinx_host=$(SPHINX_HOST) \
	--define kb_starman_workers=$(STARMAN_WORKERS) \
	--define kb_starman_max_requests=$(STARMAN_MAX_REQUESTS)

SOURCE_REPO = https://github.com/olsonanl/jdavis_lovan
#SOURCE_REPO = https://github.com/jimdavis1/Viral_Annotation
REPO_DIR = Viral_Annotation

all: pull-repo bin

pull-repo: $(REPO_DIR)
	rm -rf $(REPO_DIR)
	git clone --depth 1 $(SOURCE_REPO) $(REPO_DIR)

bin: $(BIN_PERL) $(BIN_SERVICE_PERL) $(LOVAN_BIN)

$(BIN_DIR)/%: Viral_Annotation/% $(TOP_DIR)/user-env.sh
	$(WRAP_PERL_SCRIPT) '$$KB_TOP/modules/$(CURRENT_DIR)/$<' $@


deploy: deploy-all
deploy-all: deploy-client 
deploy-client: deploy-libs deploy-scripts deploy-docs

deploy-service: deploy-libs deploy-scripts deploy-service-scripts deploy-specs

deploy-dir:
	if [ ! -d $(SERVICE_DIR) ] ; then mkdir $(SERVICE_DIR) ; fi
	if [ ! -d $(SERVICE_DIR)/bin ] ; then mkdir $(SERVICE_DIR)/bin ; fi

deploy-docs: 


clean:


$(BIN_DIR)/%: service-scripts/%.pl $(TOP_DIR)/user-env.sh
	$(WRAP_PERL_SCRIPT) '$$KB_TOP/modules/$(CURRENT_DIR)/$<' $@

$(BIN_DIR)/%: service-scripts/%.py $(TOP_DIR)/user-env.sh
	$(WRAP_PYTHON_SCRIPT) '$$KB_TOP/modules/$(CURRENT_DIR)/$<' $@

include $(TOP_DIR)/tools/Makefile.common.rules
