open Expr
open Type

(* Type checker *)

let op_type fresh_var = function
    "blend" -> TFun([|TImage; TImage; TInt|], TImage)
  | "constant-color" -> TFun([|TColor|], TImage)
  | "crop" -> TFun([|TImage; TRect|], TImage)
  | "crop-overlay" -> TFun([|TImage; TRect|], TImage)
  | "empty" -> TFun([||], TImage)
  | "gaussian-blur" -> let v = fresh_var() in TFun([|v; TNum|], v)
  | "invert" -> TFun([|TImage|], TImage)
  | "load" -> TFun([|TString|], TImage)
  | "mask" -> TFun([|TImage; TMask|], TImage)
  | "mask-overlay" -> TFun([|TImage; TMask|], TImage)
  | "opacity" -> TFun([|TImage; TNum|], TImage)
  | "paint" -> TFun([|TImage; (TArray TPoint)|], TImage)
  | "print" -> TFun([|TImage|], TAction)
  | "resample" -> TFun([|TImage; TNum|], TImage)
  | "save" -> TFun([|TImage|], TAction)
  | "threshold" -> TFun([|TImage; TNum|], TImage)
  | "translate" -> TFun([|TImage; TPoint|], TImage)
  | op -> failwith ("internal error: unknown operator " ^ op)

let rec apply_subst s = function
    TVar i as var ->
      begin try
        apply_subst s (List.assoc i s)
      with
        Not_found ->
          var
      end
  | TFun (ta, tr) ->
      TFun (Array.map (apply_subst s) ta, apply_subst s tr)
  | TArray t ->
      TArray (apply_subst s t)
  | basic_type ->
      basic_type

exception Unification_failure

let rec occurs i = function
    TVar j -> i = j
  | TFun (ta, tr) -> (occurs i tr) || (Marray.exists (occurs i) ta)
  | TArray t -> occurs i t
  | basic_type -> false

let unify cs =
  let rec unify' = function
      [] -> []
    | (TVar v, t) :: cs
    | (t, TVar v) :: cs when not (occurs v t) ->
        let cs' = List.map
            (fun (l,r) ->
              (apply_subst [(v, t)] l, apply_subst [(v, t)] r))
            cs in
        (v, t) :: (unify' cs')
    | (TFun (ta1, tr1), TFun (ta2, tr2)) :: cs ->
        unify' ((tr1, tr2)
                :: (List.combine (Array.to_list ta1) (Array.to_list ta2))
                @ cs)
    | (TArray t1, TArray t2) :: cs ->
        unify' ((t1, t2) :: cs)
    | (TImage, TImage) :: cs
    | (TMask, TMask) :: cs
    | (TColor, TColor) :: cs
    | (TRect, TRect) :: cs
    | (TSize, TSize) :: cs
    | (TPoint, TPoint) :: cs
    | (TString, TString) :: cs
    | (TNum, TNum) :: cs
    | (TInt, TInt) :: cs
    | (TBool, TBool) :: cs
    | (TAction, TAction) :: cs
    | (TError, TError) :: cs ->
        unify' cs
    | _ ->
        raise Unification_failure
  in try unify' cs with Invalid_argument _ -> raise Unification_failure

let constraints_for expr =
  let fresh_var_counter = ref 0 in
  let fresh_var () =
    decr fresh_var_counter;
    TVar !fresh_var_counter
  in
  let rec constr = function
    Op(name, args) ->
      let op_t = op_type fresh_var name
      and (args_t, args_c) = List.split (List.map constr (Array.to_list args))
      and ret_t = fresh_var() in
      (ret_t, (TFun(Array.of_list args_t, ret_t), op_t) :: (List.concat args_c))
  | Var name ->
      (fresh_var(), [])
  | Parent index ->
      (TVar index, [])
  | Array els ->
      let array_t = fresh_var()
      and (els_t, els_c) = List.split (List.map constr (Array.to_list els)) in
      (TArray array_t,
       (List.map (fun t -> (array_t, t)) els_t) @ (List.concat els_c))
  | Image _ -> (TImage, [])
  | Mask _ -> (TMask, [])
  | Color _ -> (TColor, [])
  | Rect _ -> (TRect, [])
  | Size _ -> (TSize, [])
  | Point _ -> (TPoint, [])
  | String _ -> (TString, [])
  | Num _ -> (TNum, [])
  | Int _ -> (TInt, [])
  | Bool _ -> (TBool, [])
  | Action _ -> (TAction, [])
  | Error _ -> (TError, [])
  in constr expr

let parents_count expr =
  (* TODO check that parent indices are contiguous *)
  let rec parents_ids = function
      Op(_, children) | Array(children) ->
        Array.fold_left (fun ps c -> Mlist.union ps (parents_ids c)) [] children
    | Parent index -> [index]
    | _ -> []
  in List.length (parents_ids expr)

let normalize_type_vars tp =
  let mapping = ref [] in
  let rec normalize = function
      TVar i ->
        begin try
          List.assoc i !mapping
        with Not_found ->
          let normalized = TVar (List.length !mapping) in
          mapping := (i, normalized) :: !mapping;
          normalized
        end
    | TFun (args, ret) ->
        let nargs = Array.map normalize args in
        TFun (nargs, normalize ret)
    | TArray elems ->
        TArray (normalize elems)
    | basic_type ->
        basic_type
  in normalize tp

let node_type expr =
  let parents_count = parents_count expr in
  let (tp, constraints) = constraints_for expr in
  let subst = unify constraints in
  normalize_type_vars (TFun(Array.map
                              (apply_subst subst)
                              (Array.init parents_count (fun i -> TVar i)),
                            apply_subst subst tp))

