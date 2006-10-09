type t

val make : float -> float -> float -> float -> t
val zero : t
val infinite : t
val x_min : t -> float
val x_max : t -> float
val y_min : t -> float
val y_max : t -> float
val width : t -> float
val height : t -> float
val components : t -> float * float * float * float
val components_array : t -> float array
val to_string : t -> string
val translate : t -> float -> float -> t
val scale : t -> float -> t
val outset : t -> float -> float -> t
val inset : t -> float -> float -> t
val union : t -> t -> t
val intersects : t -> t -> bool
val intersection : t -> t -> t
