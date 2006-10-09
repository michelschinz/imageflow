LOCAL_SRC :=

# Debugging support
LOCAL_SRC += log.ml

# Additional library functions
LOCAL_SRC += marray.ml
LOCAL_SRC += mlist.ml

# Evaluator sources
LOCAL_SRC += point.ml
LOCAL_SRC += color.ml
LOCAL_SRC += interval.ml
LOCAL_SRC += size.ml
LOCAL_SRC += rect.ml
LOCAL_SRC += image.ml
LOCAL_SRC += affinetransform.ml
LOCAL_SRC += coreimage.ml
LOCAL_SRC += expr.ml
LOCAL_SRC += printer.ml
LOCAL_SRC += optimiser.ml
LOCAL_SRC += typechecker.ml
LOCAL_SRC += evaluator.ml
LOCAL_SRC += cache.ml
LOCAL_SRC += optevaluator.ml
LOCAL_SRC += registerer.ml

SRC += $(foreach local_file,$(LOCAL_SRC),evaluator/$(local_file))
