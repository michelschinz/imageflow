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
      TFun (Array.map (apply_subst s) ta, apply_subst s tr)
  | TArray t ->
      TArray (apply_subst s t)
  | TImage t ->
      TImage (apply_subst s t)
  | basic_type ->
      basic_type

exception Unification_failure

let rec occurs i = function
    TVar j -> i = j
  | TFun (ta, tr) -> (occurs i tr) || (Marray.exists (occurs i) ta)
  | TArray t -> occurs i t
  | TImage t -> occurs i t
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
    | (TImage t1, TImage t2) :: cs ->
        unify' ((t1, t2) :: cs)
    | (t1, t2) :: cs when t1 = t2 ->
        unify' cs
    | _ ->
        raise Unification_failure
  in try unify' cs with Invalid_argument _ -> raise Unification_failure

let can_unify t1 t2 =
  try
    unify [(t1, t2)];
    true
  with
    Unification_failure ->
      false

let unification_constraints preds conf =
  let node_var i = TVar (- (succ i)) in
  let rec loop i preds conf acc = match preds, conf with
    [], [] ->
      acc
  | [] :: ps, tp :: tps ->
      loop (succ i) ps tps ((tp, node_var i) :: acc)
  | p :: ps, tp :: tps ->
      let args_tps = Array.map node_var (Array.of_list p) in
      loop (succ i) ps tps ((tp, TFun (args_tps, node_var i)) :: acc)
  in loop 0 preds conf []

let valid_types preds types =
  let rec loop valid_confs = function
      [] -> valid_confs
    | c :: cs ->
        try 
          let subst = unify (unification_constraints preds c) in
          loop ((List.map (apply_subst subst) c) :: valid_confs) cs
        with Unification_failure ->
          loop valid_confs cs
  in loop [] (Mlist.cartesian_product types)

let check preds types =
  match valid_types preds types with
    [] -> false
  | _ -> true

let first_valid_configuration preds possible_types =
  match valid_types preds possible_types with
    [] ->
      None
  | types ->
      let make_config types = (List.map2
                                 (fun tp tps ->
                                   (Mlist.index (can_unify tp) tps, tp))
                                 types
                                 possible_types) in
      (* TODO: sort configs. according to their histogram? *)
      Some (List.hd (List.sort compare (List.map make_config types)))

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
