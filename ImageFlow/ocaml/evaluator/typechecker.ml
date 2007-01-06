open Expr
open Type

(* Type checking *)

let arg_types = function
    TFun (arg_types, _) -> arg_types
  | _ -> [||]

let ret_type = function
    TFun (_, ret_type) -> ret_type
  | basic_type -> basic_type

let types_match ts1 ts2 =
  let type_match t1 t2 = match t1, t2 with
    TVar _, _
  | _, TVar _ -> true
  | _, _ -> t1 = t2
  in let rec loop i =
    i < 0 || (type_match ts1.(i) ts2.(i)) && (loop (pred i))
  and len = Array.length ts1 in
  (Array.length ts2) = len && (loop (pred len))

(* Make sure that all types use a different set of type variables *)
let alpha_rename_tvars types =
  let next_free_var =
    let counter = ref (-1) in
    fun () ->
      incr counter;
      !counter in
  let rec alpha_rename subst = function
      TVar i ->
        begin try
          (subst, TVar (List.assoc i subst))
        with Not_found ->
          let new_i = next_free_var() in
          ((i, new_i) :: subst, TVar new_i)
        end
    | TFun (tas, tr) ->
        let (subst', tas') = Array.fold_right
            (fun t (subst, acc) ->
              let (subst', t') = alpha_rename subst t in
              (subst', t' :: acc))
            tas
            (subst, []) in
        let (subst'', tr') = alpha_rename subst' tr in
        (subst'', TFun(Array.of_list tas', tr'))
    | TArray t ->
        let (subst', t') = alpha_rename subst t in
        (subst', TArray t')
    | basic_type ->
        (subst, basic_type)
  in 
  List.map (fun t -> snd (alpha_rename [] t)) types

let valid_configurations constraints possible_types =
  (* TODO handle substitutions when matching types *)
  let node_type conf node = ret_type (List.assoc node conf) in
  let rec loop n prev_configs constraints possible_types =
    match (constraints, possible_types) with
      [], [] ->
        prev_configs
    | c :: cs, ts :: tss ->
        let new_configs = ref [] in
        List.iter
          (fun t ->
            List.iter
              (fun v ->
                let expected_types = arg_types t
                and actual_types = Array.of_list (List.map (node_type v) c) in
                if types_match expected_types actual_types then
                  new_configs := ((n, t) :: v) :: !new_configs)
              prev_configs)
          ts;
        loop (succ n) !new_configs cs tss
  in loop 0 [[]] constraints (List.map alpha_rename_tvars possible_types)

let check constraints possible_types =
  match valid_configurations constraints possible_types with
    [] -> false
  | _ -> true

let verbose_check constraints possible_types =
  let string_of_int_list l =
    "[" ^ (String.concat ";" (List.map string_of_int l)) ^ "]" in
  print_string "constraints:\n";
  List.iter (fun c ->
    print_string (string_of_int_list c);
    print_newline()) constraints;
  print_string "possible types:\n";
  List.iter (fun ts ->
    List.iter (fun t ->
      print_string (Type.to_string t);
      print_newline()) ts)
    possible_types;
  let r = check constraints possible_types in
  print_endline ("res: " ^ (string_of_bool r));
  r

(* Type inference *)

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
  | _ -> false

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
  | Var _ ->
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

