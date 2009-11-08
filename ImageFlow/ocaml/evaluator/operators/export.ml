open Objc

external export_action_create: string -> [`CIImage] objc -> float array -> [`IFConstantExpression] objc
    = "export_action_create"

let create_action file_name image export_area =
  Expr.Action (export_action_create
                 file_name
                 (Image.to_ciimage image)
                 (Rect.components_array export_area))
