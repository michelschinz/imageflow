open Expr
open Type

let rec apply_subst s = function
    TVar i as var ->
      begin try
        apply_subst s (List.assoc i s)
      with
        Not_found ->
          var
      end
  | TFun (ta, tr) ->
      TFun (apply_subst s ta, apply_subst s tr)
  | TArray t ->
      TArray (apply_subst s t)
  | TTuple ts ->
      TTuple (List.map (apply_subst s) ts)
  | TImage t ->
      TImage (apply_subst s t)
  | basic_type ->
      basic_type

exception Unification_failure

let rec occurs i = function
    TVar j -> i = j
  | TFun (ta, tr) -> (occurs i ta) || (occurs i tr)
  | TArray t -> occurs i t
  | TTuple ts -> List.exists (occurs i) ts
  | TImage t -> occurs i t
  | _ -> false

let unify t1 t2 =
  let rec unify' = function
    | [] -> []
    | (TVar v, t) :: cs
    | (t, TVar v) :: cs when not (occurs v t) ->
        let cs' = List.map
            (fun (l,r) ->
              (apply_subst [(v, t)] l, apply_subst [(v, t)] r))
            cs in
        (v, t) :: (unify' cs')
    | (TFun (ta1, tr1), TFun (ta2, tr2)) :: cs ->
        unify' ((ta1, ta2) :: (tr1, tr2) :: cs)
    | (TArray t1, TArray t2) :: cs ->
        unify' ((t1, t2) :: cs)
    | (TTuple ts1, TTuple ts2) :: cs when List.length ts1 = List.length ts2 ->
        unify' ((List.combine ts1 ts2) @ cs)
    | (TImage t1, TImage t2) :: cs ->
        unify' ((t1, t2) :: cs)
    | (t1, t2) :: cs when t1 = t2 ->
        unify' cs
    | _ ->
        raise Unification_failure
  in unify' [ (t1, t2) ]

let can_unify t1 t2 =
  try
    unify t1 t2;
    true
  with
    Unification_failure ->
      false

exception Backtrack

let first_valid_types preds possible_types =
  let rec search preds curr_types = function
    | [] ->
        List.rev curr_types
    | [] :: _ ->
        raise Backtrack
    | (pth :: ptt) :: pts ->
        let arg_types = List.map
            (fun i ->
              (* TODO: we should use another technique to get the nodes' *)
              (* output type, as this one seems potentially incorrect. *)
              match List.nth (List.rev curr_types) i with
                TFun (_, tr) -> tr
              | other -> other)
            (List.hd preds) in
        try
          let subst = match arg_types with
            [] -> []
          | [ t1 ] -> unify (TFun (t1, TVar (-1))) pth
          | ts -> unify (TFun (TTuple ts, TVar (-1))) pth in
          let new_types = List.map (apply_subst subst) (pth :: curr_types) in
          search (List.tl preds) new_types pts
        with Unification_failure | Backtrack ->
          search preds curr_types (ptt :: pts)
  in try
    Some (search preds [] possible_types)
  with Backtrack ->
    None

let check preds possible_types =
  match first_valid_types preds possible_types with
  | Some _ -> true
  | None -> false

let first_valid_configuration preds possible_types =
  match first_valid_types preds possible_types with
  | Some types ->
      Some (List.map2
              (fun tp tps -> (Mlist.index (can_unify tp) tps, tp))
              types
              possible_types)
  | None ->
      None

(* Debugging *)

let verbose_check constraints possible_types =
  let string_of_int_list l =
    "[" ^ (String.concat ";" (List.map string_of_int l)) ^ "]" in
  print_string "constraints:\n";
  List.iter (fun c ->
    print_string (string_of_int_list c);
    print_newline()) constraints;
  print_string "possible types:\n";
  List.iter (fun ts ->
    List.iter (fun t -> print_string (Type.to_string t); print_string " | ") ts;
    print_newline())
    possible_types;
  let r = check constraints possible_types in
  print_endline ("res: " ^ (string_of_bool r));
  r
