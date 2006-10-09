open Objc
open Corefoundation

type t = [ `IFImage ] objc

let empty =
  Ifimage.emptyImage()

let of_ifimage ifimage =
  ifimage

let of_cgimage cgimage =
  Ifimage.imageWithCGImage cgimage

let of_ciimage ciimage =
  Ifimage.imageWithCIImage ciimage

let to_ifimage i =
  i

let to_ciimage i =
  Ifimage.imageCI i

let is_locked i =
  Ifimage.isLocked i

let extent i =
  let e = Ifimage.extent i in
  Rect.make e.(0) e.(1) e.(2) e.(3)

let byte_size i =
  (* TODO take depth into account *)
  let e = extent i in
  4 * int_of_float ((Rect.width e) *. (Rect.height e))

let to_string i = "<image " ^ (Rect.to_string (extent i)) ^ ">"
