UNAME := $(shell uname)
CWD := $(shell pwd)
ifeq ($(UNAME),$(filter $(UNAME),Linux Darwin))
	ifeq ($(UNAME),$(filter $(UNAME),Darwin))
		# TODO: Check for iOS build flags.
		OS=osx
	else
		OS=linux
	endif
	CXXFLAGS += -std=c++11
else
	OS=windows
endif

program_VERSION := $(shell node -pe "require('./package.json').version")

libgit2_CFLAGS := $(shell pkg-config --cflags --static libgit2)
libgit2_LDFLAGS := $(shell pkg-config --libs libgit2)

libcurl_CFLAGS := $(shell curl-config --cflags)
libcurl_LDFLAGS := $(shell curl-config --libs)

CXXFLAGS += $(libgit2_CFLAGS) $(libcurl_CFLAGS) -DASTRO_CLI_VERSION="\"$(program_VERSION)\""
LDFLAGS += $(libgit2_LDFLAGS) $(libcurl_LDFLAGS) -all_load

INCLUDE_DIRS := $(CWD)/src $(CWD)/deps $(CWD)/../astro/include
LIBRARY_DIRS :=
LIBRARIES :=

SRC_DIRS := $(CWD)/src $(CWD)/tests

program_NAME := astro
program_SRCS := $(shell find $(CWD)/src -type f -name '*.cpp')
program_OBJS := ${program_SRCS:.cpp=.o}
program_DEPS := ${program_OBJS:.o=.dep}

test_NAME := astro-tests
test_SRCS := $(shell find $(CWD)/tests -type f -name '*.cpp')
test_OBJS := ${test_SRCS:.cpp=.o}
test_DEPS := ${test_OBJS:.o=.dep}

CXXFLAGS += -g -O0

ifeq ($(OS),$(filter $(OS),osx ios))
	CXXFLAGS += -stdlib=libc++
	LDFLAGS +=
endif

CXXFLAGS += $(foreach includedir,$(INCLUDE_DIRS),-I$(includedir))
LDFLAGS += $(foreach libdir,$(LIBRARY_DIRS),-L$(libdir))
LDFLAGS += $(foreach lib,$(LIBRARIES),-l$(lib))

.PHONY: all clean distclean

all: generate_linter_flags $(program_NAME) $(test_NAME)

-include $(program_DEPS)

%.o: %.cpp
	$(CXX) $(CXXFLAGS) -x c++ -MM -MT $@ -MF $(patsubst %.o,%.dep,$@) $<
	$(CXX) $(CXXFLAGS) -x c++ -c -o $@ $<

%.o: %.mm
	$(CXX) $(CXXFLAGS) -x objective-c++ -MM -MT $@ -MF $(patsubst %.o,%.dep,$@) $<
	$(CXX) $(CXXFLAGS) -x objective-c++ -c -o $@ $<

$(program_NAME): $(program_OBJS)
	$(LINK.cc) $(program_OBJS) -o $(program_NAME)

$(test_NAME): $(test_OBJS)
	$(LINK.cc) $(test_OBJS) -o $(test_NAME)

generate_linter_flags: Makefile
	echo "$(CXXFLAGS)" | tr ' ' '\n' > .linter-clang-flags

clean:
	@- $(RM) $(program_NAME)
	@- $(RM) $(test_NAME)
	@- $(RM) $(shell find ${SRC_DIRS} -type f -name '*.o')
	@- $(RM) $(shell find ${SRC_DIRS} -type f -name '*.dep')

distclean: clean
