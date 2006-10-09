open Objc

external installNewPool: unit -> [`NSAutoreleasePool] objc
    = "NSAutoreleasePool__new"

