open Objc

external stringWithUTF8String: string -> [`NSString] objc
    = "NSString__stringWithUTF8String"

external utf8String: [`NSString] objc -> string
    = "NSString_UTF8String"

