open Expr
open Type

(* Make sure that all types use a different set of type variables *)
let next_free_var =
  let counter = ref (-1) in fun () -> incr counter; !counter
let alpha_rename_tvars types =
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
  in List.map (fun t -> snd (alpha_rename [] t)) types

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
    | (TImage t1, TImage t2) :: cs ->
        unify' ((t1, t2) :: cs)
    | (t1, t2) :: cs when t1 = t2 ->
        unify' cs
    | _ ->
        raise Unification_failure
  in try unify' cs with Invalid_argument _ -> raise Unification_failure

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

let valid_configurations preds types =
  let rec loop valid_confs = function
      [] -> valid_confs
    | c :: cs ->
        try 
          let subst = unify (unification_constraints preds c) in
          loop ((List.map (apply_subst subst) c) :: valid_confs) cs
        with Unification_failure ->
          loop valid_confs cs
  in loop [] (Mlist.cartesian_product (List.map alpha_rename_tvars types))

let check preds types =
  match valid_configurations preds types with
    [] -> false
  | _ -> true

let infer paramsCount preds types =
  let res_type = function
      TFun(_, res_type) -> res_type
    | other -> other
  in
  List.map (fun conf ->
    TFun(Array.of_list (Mlist.take paramsCount conf),
         res_type (Mlist.last conf)))
    (valid_configurations preds types)

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
    List.iter (fun t ->
      print_string (Type.to_string t);
      print_newline()) ts)
    possible_types;
  let r = check constraints possible_types in
  print_endline ("res: " ^ (string_of_bool r));
  r
