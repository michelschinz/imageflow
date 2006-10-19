open Objc

external numberWithDouble : float -> [ `NSNumber ] objc
    = "NSNumber__numberWithDouble"

external numberWithInt : int -> [ `NSNumber ] objc
    = "NSNumber__numberWithInt"
