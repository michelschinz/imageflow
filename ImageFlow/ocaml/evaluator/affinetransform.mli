type t

val components_array : t -> float array
val identity : t
val scale : float -> float -> t
val translation : float -> float -> t
val rotation : float -> t
val invert : t -> t
val concat : t -> t -> t
val transform_point : t -> Point.t -> Point.t
