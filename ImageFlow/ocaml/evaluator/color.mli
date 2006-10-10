type t

val make : float -> float -> float -> float -> t
val components : t -> float * float * float * float
val red : t -> float
val green : t -> float
val blue : t -> float
val alpha : t -> float
val to_string : t -> string
val transparent : t
val cicolor : t -> [ `CIColor ] Objc.objc
