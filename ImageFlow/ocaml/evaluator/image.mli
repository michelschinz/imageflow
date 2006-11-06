type t

val empty : t

val of_ifimage : [ `IFImage ] Objc.objc -> t
val of_cgimage : [ `CGImage ] Corefoundation.cftyperef -> t
val of_ciimage : [ `CIImage ] Objc.objc -> t
val mask_of_ciimage : [ `CIImage ] Objc.objc -> t

val to_ifimage : t -> [ `IFImage ] Objc.objc
val to_ciimage : t -> [ `CIImage ] Objc.objc

val is_locked : t -> bool
val extent : t -> Rect.t
val byte_size : t -> int

val to_string : t -> string

