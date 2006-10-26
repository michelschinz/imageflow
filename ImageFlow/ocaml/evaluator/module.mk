LOCAL_SRC :=

# Debugging support
LOCAL_SRC += log.ml log.mli

# Additional library functions
LOCAL_SRC += marray.ml marray.mli
LOCAL_SRC += mlist.ml mlist.mli

# Evaluator sources
LOCAL_SRC += blendmode.ml blendmode.mli
LOCAL_SRC += point.ml point.mli
LOCAL_SRC += color.ml color.mli
LOCAL_SRC += interval.ml interval.mli
LOCAL_SRC += size.ml size.mli
LOCAL_SRC += rect.ml rect.mli
LOCAL_SRC += image.ml image.mli
LOCAL_SRC += affinetransform.ml affinetransform.mli
LOCAL_SRC += coreimage.ml coreimage.mli
LOCAL_SRC += expr.ml expr.mli
LOCAL_SRC += printer.ml printer.mli
LOCAL_SRC += optimiser.ml optimiser.mli
LOCAL_SRC += evaluator.ml evaluator.mli
LOCAL_SRC += cache.ml cache.mli
LOCAL_SRC += optevaluator.ml optevaluator.mli
LOCAL_SRC += delta.ml delta.mli
LOCAL_SRC += registerer.ml

SRC += $(foreach local_file,$(LOCAL_SRC),evaluator/$(local_file))
