open Objc

external retain: 'a objc -> 'a objc
    = "NSObject_release"

external release: 'a objc -> unit
    = "NSObject_release"

external retainCount: 'a objc -> int
    = "NSObject_retainCount"

external description: 'a objc -> [`NSString] objc
    = "NSObject_description"

external isEqual: 'a objc -> 'a objc -> bool
    = "NSObject_isEqual"

external hash: 'a objc -> int
    = "NSObject_hash"
