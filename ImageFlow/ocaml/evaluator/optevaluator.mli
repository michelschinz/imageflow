val eval: Cache.t -> Expr.t -> Expr.t
val eval_extent: Cache.t -> Expr.t -> Rect.t option
val eval_as_image: Cache.t -> Expr.t -> Expr.t
val eval_as_masked_image: Cache.t -> Expr.t -> Rect.t -> Expr.t

val verbose_eval: Cache.t -> Expr.t -> Expr.t
