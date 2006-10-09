type typ =
    TFun of typ array * typ
  | TList of typ
  | TImage
  | TMask
  | TColor
  | TRect
  | TSize
  | TPoint
  | TString
  | TNum
  | TBool
  | TAction
  | TError
val op_type : string -> typ
val match_types : typ -> typ -> typ
val infer_type : 'a -> Expr.t -> typ
val well_typed : Expr.t -> bool
