val remove_first : 'a -> 'a list -> 'a list
val union : 'a list -> 'a list -> 'a list
val concat_map : ('a -> 'b list) -> 'a list -> 'b list
val cartesian_product : 'a list list -> 'a list list
val drop : int -> 'a list -> 'a list
val take : int -> 'a list -> 'a list
val index : ('a -> bool) -> 'a list -> int
val first : 'a list -> 'a
val last : 'a list -> 'a
