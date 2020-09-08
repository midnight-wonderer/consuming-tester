#######################################
# MAKE CONFIGS
#######################################

BASE_PATH := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
BASE_PATH := $(BASE_PATH:/=)


#######################################
# INPUT PATHS
#######################################

SEARCH_EXCLUDES += $(BASE_PATH)
RELATIVE_EXCLUDE_FLAGS = $(foreach EXCLUDE,$(SEARCH_EXCLUDES:$(PWD)%=.%),-not -path "$(EXCLUDE)/*")
C_INCLUDE_PATHS += $(shell (find -L . -type f -name '*.h' $(RELATIVE_EXCLUDE_FLAGS) -exec dirname {} \; 2>/dev/null) | sort | uniq)
ENTRY_SOURCE ?= ./source/main.c
APPLICATION_SOURCES = $(filter-out $(ENTRY_SOURCE), $(shell find -L . -type f -name '*.c' $(RELATIVE_EXCLUDE_FLAGS) 2>/dev/null))


#######################################
# OUTPUT PATHS
#######################################

BUILD_DIR ?= build
CACHE_DIR ?= $(BUILD_DIR)/cache
ENTRY_OBJECT = $(patsubst ./%,%,$(ENTRY_SOURCE:.c=.o))
APPLICATION_OBJECTS = $(filter-out $(ENTRY_OBJECT), $(subst /./,/,$(addprefix $(CACHE_DIR)/, $(APPLICATION_SOURCES:.c=.o))))

$(BUILD_DIR) $(CACHE_DIR):
	mkdir -p $@


#######################################
# BUILD TOOLS
#######################################

CROSS_PREFIX ?=
ifdef GCC_PATH
CC = $(GCC_PATH)/$(CROSS_PREFIX)gcc
AR = $(GCC_PATH)/$(CROSS_PREFIX)ar
else
CC = $(CROSS_PREFIX)gcc
AR = $(CROSS_PREFIX)ar
endif


#######################################
# TARGET
#######################################

DEBUG ?= 1
OPT ?= -Og
# CPU ?= -mcpu=cortex-m3
# MCU = $(CPU) -mthumb


#######################################
# CUSTOMIZATION
#######################################

C_DEFS ?=
C_INCLUDES = $(addprefix -I,$(C_INCLUDE_PATHS))
CFLAGS = $(MCU) $(C_DEFS) $(C_INCLUDES) $(OPT) -Wall -fdata-sections -ffunction-sections
ifeq ($(DEBUG), 1)
CFLAGS += -g -gdwarf-2
endif

# libraries
LIBS =
LIBDIR += $(CACHE_DIR)
LDFLAGS = $(MCU) $(addprefix -L,$(LIBDIR)) $(LIBS) -Wl,--gc-sections


#######################################
# BUILD COMPONENTS
#######################################

$(CACHE_DIR)/$(ENTRY_OBJECT): $(ENTRY_SOURCE)
	mkdir -p $(dir $@) && \
	$(CC) -c $(strip $(CFLAGS)) -Wa,-a,-ad,-alms=$(@:.o=.lst) $< -o $@

$(CACHE_DIR)/%.o: ./%.c | $(CACHE_DIR)
	mkdir -p $(dir $@) && \
	$(CC) -c $(strip $(CFLAGS)) -Wa,-a,-ad,-alms=$(@:.o=.lst) $< -o $@

$(CACHE_DIR)/libapplication.a: $(APPLICATION_OBJECTS)
	$(AR) rcs $@ $^

$(BUILD_DIR)/application.elf: $(CACHE_DIR)/$(ENTRY_OBJECT) $(CACHE_DIR)/libapplication.a
	$(CC) $< $(LDFLAGS) -Wl,-Map=$(@:.elf=.map),--cref $(foreach ARCHIVE,$(filter-out $<,$^),$(shell echo $(ARCHIVE) | sed -E 's/^.*lib([a-z]*)\.a$$/-l\1/')) -o $@
