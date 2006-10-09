type t
val make : float -> float -> t
val components : t -> float * float
val components_array : t -> float array
val to_string : t -> string
val zero : t
val x : t -> float
val y : t -> float
val translate : t -> float -> float -> t
val scale : t -> float -> t
