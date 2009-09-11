val eval : Cache.t -> Expr.t list -> Expr.t -> Expr.t
exception EvalError of Expr.t
