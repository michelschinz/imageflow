open Corefoundation

external getWidth: [ `CGImage ] cftyperef -> float
    = "_CGImageGetWidth"

external getHeight: [ `CGImage ] cftyperef -> float
    = "_CGImageGetHeight"
