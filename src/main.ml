(** Main module calling lexer, parser and proof evaluation on given file *)
open Core
open Lexer
open Lexing
open Eval

type error = Error 

(**/**)
let print_position outx lexbuf =
  let pos = lexbuf.lex_curr_p in
  Printf.fprintf outx "%s:%d:%d" pos.pos_fname
    pos.pos_lnum pos.pos_bol
(**/**)

(** Function parse_with_error tries to parse given lexbuf and in case of errors it writes error messages to the file. *)
let parse_with_error lexbuf out_file =
  try Parser.prog Lexer.read lexbuf with
  | SyntaxError msg ->
    Printf.fprintf out_file "%a: %s\n" print_position lexbuf msg;
    None
  | Parser.Error ->
    Printf.fprintf out_file "%a: syntax error\n" print_position lexbuf;
    None

(** Function eval_with_error tries to execute evaluation function on particular proof and in case
    of EvalError it writes error message to file and return None
*)
let rec eval_with_error value lexbuf out_file facts =
  try eval value out_file facts with
      | EvalError msg -> Printf.fprintf out_file "%a: eval error %s\n" print_position lexbuf msg; None

(** parse_and_eval matches result of function parse_with_error 
    and in case of None it returns (). Otherwise wneh it gest Some value it 
    calls eval_with_error function on each proof in the file.
*)
let rec parse_and_eval = fun (lexbuf, out_file, facts, bind) ->
  match parse_with_error lexbuf out_file with
  | None ->  ()
  | Some value -> 
  match eval_with_error value lexbuf out_file facts with
      | Some value -> if bind = Some "bind" then parse_and_eval (lexbuf, out_file, (value::facts),  bind)
                      else parse_and_eval (lexbuf, out_file, facts, bind)
      | None -> parse_and_eval (lexbuf, out_file, facts, bind)

(** Function main open files given as parameters to the programm and calls parse_and_eval function *
    After that it closes files 
*)
let main filename out_filename bind () =
  let inx = open_in filename 
  and out = open_out out_filename in
  let lexbuf = Lexing.from_channel inx in
  lexbuf.lex_curr_p <- { lexbuf.lex_curr_p with pos_bol = 0;
                         pos_lnum = lexbuf.lex_curr_pos; pos_fname = filename};
  parse_and_eval (lexbuf, out, [], bind);
  close_in inx; close_out out

let () =
  Command.basic ~summary:"Parser"
    Command.Spec.(empty +> anon ("filename" %: file)
                        +> anon ("out_filename" %: file)
                        +> anon (maybe ("bind" %: string)))
    main 
  |> Command.run