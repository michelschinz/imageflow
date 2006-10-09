type t

val make: int -> t
val store: t -> Expr.t -> Image.t -> unit
val lookup: t -> Expr.t -> Expr.t
