val check : int list list -> Type.t list list -> bool
val verbose_check : int list list -> Type.t list list -> bool
val infer : int -> int list list -> Type.t list list -> Type.t list
val first_valid_configuration :
    int list list -> Type.t list list -> (int * Type.t) list option
