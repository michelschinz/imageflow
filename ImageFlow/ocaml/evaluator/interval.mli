type t

val make : float -> float -> t
val min : t -> float
val max : t -> float
val length : t -> float
val intersects : t -> t -> bool
val intersection : t -> t -> t option
