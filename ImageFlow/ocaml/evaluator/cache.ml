open Expr

module HashedExpr =
  struct
    type t = Expr.t
    let equal = Expr.equal
    let hash = Hashtbl.hash
  end

module HashTable = Hashtbl.Make(HashedExpr)

type t = {
    max_space: int;
    table: Image.t HashTable.t;
    mutable lru_list: Expr.t list
  }

let make max_space =
  { max_space = max_space;
    table = HashTable.create 20;
    lru_list = [] }

let total_size cache = 
  HashTable.fold (fun _ i s -> s + (Image.byte_size i)) cache.table 0

let overflow_size cache =
  max 0 ((total_size cache) - cache.max_space)

let prune cache =
  let overflow = overflow_size cache in
  let rec collect = function
      [] ->
        ([], [], overflow)
    | hd :: tl ->
        let (to_keep, to_remove, left) = collect tl in
        if left <= 0 then
          (hd :: to_keep, to_remove, left)
        else (
          let image = HashTable.find cache.table hd in
          if Image.is_locked image then
            (hd :: to_keep, to_remove, left)
          else
            (to_keep, hd :: to_remove, left - (Image.byte_size image)))
  in
  if overflow > 0 then begin
    let (to_keep, to_remove, _) = collect cache.lru_list in
    List.iter (HashTable.remove cache.table) to_remove;
    cache.lru_list <- to_keep
  end

let update_lru_list cache expr =
  let rec remove_first = function
      [] -> []
    | hd :: tl when Expr.equal hd expr -> tl
    | hd :: tl -> hd :: (remove_first tl)
  in
  cache.lru_list <- expr :: (remove_first cache.lru_list)

let store cache expr value =
  HashTable.replace cache.table expr value;
  update_lru_list cache expr;
  prune cache

let lookup cache expr =
  let res = HashTable.find cache.table expr in
  update_lru_list cache expr;
  Image res
