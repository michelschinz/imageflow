open Expr

(* Type checker *)

type typ =
  | TFun of (typ array) * typ
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

let op_type = function
    "blend" -> TFun([|TImage; TImage; TString|], TImage)
  | "constant-color" -> TFun([|TColor|], TImage)
  | "crop" -> TFun([|TImage; TRect|], TImage)
  | "crop-overlay" -> TFun([|TImage; TRect|], TImage)
  | "empty" -> TFun([||], TImage)
  | "gaussian-blur" -> TFun([|TImage; TNum|], TImage)
  | "invert" -> TFun([|TImage|], TImage)
  | "load" -> TFun([|TString|], TImage)
  | "mask" -> TFun([|TImage; TMask|], TImage)
  | "mask-overlay" -> TFun([|TImage; TMask|], TImage)
  | "opacity" -> TFun([|TImage; TNum|], TImage)
  | "paint" -> TFun([|TImage; (TList TPoint)|], TImage)
  | "print" -> TFun([|TImage|], TAction)
  | "resample" -> TFun([|TImage; TNum|], TImage)
  | "save" -> TFun([|TImage|], TAction)
  | "threshold" -> TFun([|TImage; TNum|], TImage)
  | "translate" -> TFun([|TImage; TPoint|], TImage)
  | op -> failwith ("internal error: unknown operator " ^ op)

let match_types t1 t2 =
  if t1 = t2 then t1 else TError

let rec infer_type env = function
    Op(op, args) ->
      let TFun(formal_types, ret_type) = op_type op
      and actual_types = Array.map (infer_type env) args in
      if Array.length actual_types = Array.length formal_types then
        let matched_types =
          List.map2
            match_types
            (Array.to_list formal_types)
            (Array.to_list actual_types) in
        if List.mem TError matched_types then TError else ret_type
      else
        TError
  | Array _ -> TError                      (* TODO *)
  | Image _ -> TImage
  | Mask _ -> TMask
  | Color _ -> TColor
  | Rect _ -> TRect
  | Size _ -> TSize
  | Point _ -> TPoint
  | String _ -> TString
  | Num _ -> TNum
  | Bool _ -> TBool
  | Action _ -> TAction
  | Error _ -> TError

let well_typed expr = match infer_type 0 expr with
  TError -> false
| _ -> true

(* let valid_candidates expr candidates = *)
(*   let rec product = function *)
(*       [] -> [[]] *)
(*     | l :: ls -> *)
(*         let pls = product ls in *)
(*         List.concat (List.map (fun e -> List.map (fun ll -> e :: ll) pls) l) in *)
(*   let rec all_exprs = function *)
(*       Op(op, args) -> *)
(*         let all_args = product (List.map all_exprs args) in *)
(*         begin match op with *)
(*           "[]" -> *)
(*             List.concat (List.map *)
(*                            (fun args -> *)
(*                              List.map (fun cand -> Op(cand, args)) candidates) *)
(*                            all_args) *)
(*         | op -> *)
(*             List.map (fun args -> Op(op, args)) all_args *)
(*         end *)
(*     | value -> [value] *)
(*   in List.filter well_typed (all_exprs expr) *)
