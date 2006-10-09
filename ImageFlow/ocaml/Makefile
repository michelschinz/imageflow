MODULES := bridge evaluator/operators evaluator

SRC := # nothing
include $(foreach module,$(MODULES),$(module)/module.mk)

CAML_SRC := $(filter %.ml,$(SRC))
CAML_INT := $(filter %.mli,$(SRC))
C_SRC := $(filter %.c,$(SRC))
OBJC_SRC := $(filter %.m,$(SRC))

CAML_OBJS := $(CAML_SRC:.ml=.cmo)
CAML_CINT := $(CAML_INT:.mli=.cmi) $(CAML_SRC:.ml=.cmi)
C_OBJS := $(C_SRC:.c=.o) $(OBJC_SRC:.m=.o)

CAML_CODE_OBJ := caml-code.o
C_OBJS += $(CAML_CODE_OBJ)

CAML_STD_LIB := \
	$(shell ocamlc -config | grep '^standard_library:' | cut -d ' ' -f 2)

DEPENDENCY_FILES := \
	$(C_SRC:.c=_c.d) $(CAML_SRC:.ml=_ml.d) $(CAML_INT:.mli=_mli.d)

INCLUDE_FLAGS := $(foreach module,$(MODULES),-I $(module)) -I ..
CFLAGS += -Wall -g $(INCLUDE_FLAGS) -I $(CAML_STD_LIB)
CAML_INCLUDE_FLAGS := $(INCLUDE_FLAGS)
CAMLFLAGS := -g -dtypes -w A $(CAML_INCLUDE_FLAGS)

# Commands
OCAMLC := ocamlc
OCAMLDEP := ocamldep
OCAMLMKLIB = ocamlmklib
OCAMLMKTOP := ocamlmktop
LIBTOOL := libtool
GREP := grep
WC := wc

LIBEVAL := libevaluator.a
TOPLEVEL := caml-imageflow

.PHONY: all clean grep todo wc

all: $(LIBEVAL)

$(CAML_CODE_OBJ): $(CAML_OBJS)
	$(OCAMLC) -output-obj -g -o $@ $^

$(LIBEVAL): $(C_OBJS)
	$(LIBTOOL) -static -o $@ $^

$(TOPLEVEL): $(filter-out $(CAML_CODE_OBJ),$(C_OBJS)) $(CAML_OBJS)
	$(OCAMLMKTOP) -o $@ -custom $^ \
	-ccopt "-lobjc -framework ApplicationServices" \
	-ccopt "-framework QuartzCore -framework Foundation"

clean:
	$(RM) $(C_OBJS) $(CAML_OBJS) $(CAML_CINT) $(DEPENDENCY_FILES) \
	$(CAML_SRC:.ml=.annot) $(LIBEVAL) $(TOPLEVEL)

grep:
ifdef ARGS
	@$(GREP) $(ARGS) $(SRC)
else
	@echo "Please define variable ARGS before using 'grep' target"
endif

todo:
	@$(GREP) -F TODO $(SRC)

wc:
	@$(WC) $(SRC)

ifneq ($(MAKECMDGOALS),clean)
-include $(DEPENDENCY_FILES)
endif

# Rules for OCaml files
%.cmo: %.ml
	$(OCAMLC) -c $(CAMLFLAGS) $<

%.cmi: %.mli
	$(OCAMLC) -c $(CAMLFLAGS) $<

# Rules for dependency files
%_mli.d: %.mli
	$(OCAMLDEP) $(CAML_INCLUDE_FLAGS) $^ > $@

%_ml.d: %.ml
	$(OCAMLDEP) $(CAML_INCLUDE_FLAGS) $^ > $@

%_c.d: %.c
	$(CC) $(CFLAGS) -M $^ -MF $@
