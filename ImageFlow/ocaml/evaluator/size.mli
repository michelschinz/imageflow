type t

val make : float -> float -> t
val components : t -> float * float
val components_array : t -> float array
val to_string : t -> string
val zero : t
val width : t -> float
val height : t -> float
val scale : t -> float -> t
val grow : t -> float -> float -> t
