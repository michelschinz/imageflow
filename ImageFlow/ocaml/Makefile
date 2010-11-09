MODULES := bridge evaluator/operators evaluator

SRC := # nothing
include $(foreach module,$(MODULES),$(module)/module.mk)

CAML_SRC := $(filter %.ml,$(SRC))
CAML_INT := $(filter %.mli,$(SRC))

CAML_CMXS := $(CAML_SRC:.ml=.cmx)
CAML_OBJS := $(CAML_SRC:.ml=.o)
CAML_CMIS := $(CAML_INT:.mli=.cmi) $(CAML_SRC:.ml=.cmi)

CAML_CODE_OBJ := caml-code.o

DEPENDENCY_FILES := \
  $(C_SRC:.c=_c.d) $(CAML_SRC:.ml=_ml.d) $(CAML_INT:.mli=_mli.d)

# All OCaml objects, sorted according to dependencies
CAML_SORTED_CMXS :=
CAML_SORTED_CMXS += evaluator/log.cmx
CAML_SORTED_CMXS += evaluator/marray.cmx
CAML_SORTED_CMXS += evaluator/mlist.cmx
CAML_SORTED_CMXS += evaluator/blendmode.cmx
CAML_SORTED_CMXS += evaluator/point.cmx
CAML_SORTED_CMXS += evaluator/color.cmx
CAML_SORTED_CMXS += evaluator/interval.cmx
CAML_SORTED_CMXS += evaluator/size.cmx
CAML_SORTED_CMXS += evaluator/rect.cmx
CAML_SORTED_CMXS += evaluator/image.cmx
CAML_SORTED_CMXS += evaluator/affinetransform.cmx
CAML_SORTED_CMXS += evaluator/coreimage.cmx
CAML_SORTED_CMXS += evaluator/operators/export.cmx
CAML_SORTED_CMXS += evaluator/operators/paint.cmx
CAML_SORTED_CMXS += evaluator/operators/save.cmx
CAML_SORTED_CMXS += evaluator/primitives.cmx
CAML_SORTED_CMXS += evaluator/expr.cmx
CAML_SORTED_CMXS += evaluator/type.cmx
CAML_SORTED_CMXS += evaluator/typechecker.cmx
CAML_SORTED_CMXS += evaluator/printer.cmx
CAML_SORTED_CMXS += evaluator/optimiser.cmx
CAML_SORTED_CMXS += evaluator/cache.cmx
CAML_SORTED_CMXS += evaluator/evaluator.cmx
CAML_SORTED_CMXS += evaluator/optevaluator.cmx
CAML_SORTED_CMXS += evaluator/delta.cmx
CAML_SORTED_CMXS += evaluator/registerer.cmx

CAML_INCLUDE_FLAGS := $(foreach module,$(MODULES),-I $(module)) -I ..
CAML_FLAGS := -g -w A $(CAML_INCLUDE_FLAGS)

# Commands
OCAMLOPT := ocamlopt.opt
OCAMLDEP := ocamldep.opt
LIBTOOL := libtool

LIBEVAL := libevaluator.a

.PHONY: all clean

all: $(LIBEVAL)

$(CAML_CODE_OBJ): $(CAML_CMXS)
	$(OCAMLOPT) -output-obj -g -o $@ bigarray.cmxa $(CAML_SORTED_CMXS)

$(LIBEVAL): $(CAML_CODE_OBJ)
	$(LIBTOOL) -static -o $@ $^

clean:
	$(RM) $(LIBEVAL) $(CAML_CODE_OBJ)
	$(RM) $(CAML_CMXS) $(CAML_CMIS) $(CAML_OBJS) $(DEPENDENCY_FILES)

ifneq ($(MAKECMDGOALS),clean)
-include $(DEPENDENCY_FILES)
endif

# Rules for OCaml files
%.cmx: %.ml
	$(OCAMLOPT) -c $(CAML_FLAGS) $<

%.cmi: %.mli
	$(OCAMLOPT) -c $(CAML_FLAGS) $<

# Rules for dependency files
%_mli.d: %.mli
	$(OCAMLDEP) -native $(CAML_INCLUDE_FLAGS) $^ > $@

%_ml.d: %.ml
	$(OCAMLDEP) -native $(CAML_INCLUDE_FLAGS) $^ > $@
