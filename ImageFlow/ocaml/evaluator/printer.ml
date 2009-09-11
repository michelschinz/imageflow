open Expr
open Format

let action_kind_to_string = function
    Save -> "save"
  | Print -> "print"

let rec print0 fmt = function
    Op(op, args) ->
      pp_open_box fmt ((String.length op) + 2);
      pp_print_string fmt ("("^op);
      for i = 0 to (Array.length args) - 1 do
        if i == 0 then pp_print_string fmt " " else pp_print_space fmt ();
        print0 fmt args.(i)
      done;
      pp_print_string fmt ")";
      pp_close_box fmt()
  | Var name ->
      pp_print_string fmt(name)
  | Arg index ->
      pp_print_string fmt "#";
      pp_print_int fmt index
  | Parent index ->
      pp_print_string fmt "@";
      pp_print_int fmt index
  | Array elems ->
      pp_open_box fmt(1);
      pp_print_string fmt("[");
      for i = 0 to (Array.length elems) - 1 do
        if i > 0 then begin
          pp_print_string fmt ";";
          pp_print_space fmt()
        end;
        print0 fmt elems.(i)
      done;
      pp_print_string fmt "]";
      pp_close_box fmt()
  | Lambda b ->
      pp_open_box fmt 8;
      pp_print_string fmt ("(lambda");
      pp_print_space fmt ();
      print0 fmt b;
      pp_print_string fmt ")";
      pp_close_box fmt ()
  | Image i ->
      pp_print_string fmt ("<image " ^ (Rect.to_string (Image.extent i)) ^ ">")
  | Mask i ->
      pp_print_string fmt ("<mask " ^ (Rect.to_string (Image.extent i)) ^ ">")
  | Color c ->
      pp_print_string fmt (Color.to_string c)
  | Rect r ->
      pp_print_string fmt (Rect.to_string r)
  | Size s ->
      pp_print_string fmt (Size.to_string s)
  | Point p ->
      pp_print_string fmt (Point.to_string p)
  | String s ->
      pp_print_string fmt ("\"" ^ s ^ "\"")
  | Num n ->
      pp_print_float fmt n
  | Int n ->
      pp_print_int fmt n
  | Bool b ->
      pp_print_bool fmt b
  | Action (k, _) ->
      pp_print_string fmt ("<action " ^ (action_kind_to_string k) ^ ">")
  | Error Some msg ->
      pp_print_string fmt ("<ERROR " ^ msg ^ ">")
  | Error None ->
      pp_print_string fmt ("<ERROR>")

let print expr =
  print0 std_formatter expr;
  pp_print_newline std_formatter ()

let to_string expr =
  let buf = Buffer.create 100 in
  let fmt = (formatter_of_buffer buf) in
  pp_set_margin fmt 10000;
  print0 fmt expr;
  pp_print_flush fmt ();
  Buffer.contents buf
