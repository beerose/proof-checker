(** Module implementing natural deduction rules *) 
(** They are applied in inverse way - it checks if all facts needen to inferr an exprssion are already proven.
  Flags:
  bind - allows to use facts proven ealier in the file in further proofs
*)

open Expr

(** Common type for all inversed rules *)
type inverse_nd_rule = (expr * expr list) -> bool

(**/**)
(** Expressions comparator *)
let (===) expr1 expr2 =
  to_string expr1 = to_string expr2 ||
  expr1 = expr2 || (`Paren(expr1)) = expr2 || expr1 = (`Paren(expr2))

(** Function find looks for expresion in given list *)
let find = fun (expr, env) ->
  List.length (List.find_all (fun x ->  x === expr) env) > 0

 
(** Aksjomat for classical logic *)
let negAksj = fun (expr1, expr2) ->
  expr1 === (`Neg (expr2)) || (`Neg (expr1)) === expr2
(**/**) 

(** Inverse rule: conjunction introduction *)
let andI : inverse_nd_rule = fun (expr, env) ->
  match expr with
  | `And (left, right) ->
  find (left, env) && find (right, env)
  | _ -> false

(** Inverse rule: conjunction elimination *)
let andE : inverse_nd_rule = fun (expr, env) -> 
let rec aux = fun (expr, env) -> match env with
  | (`And(left, right))::rest -> 
      if left === expr || right === expr then true else aux (expr, rest)
  | _::rest  -> aux(expr, rest)
  | [] -> false
  in aux (expr, env)

(** Inverse rule: disjunction introduction *)
let orI : inverse_nd_rule = fun (expr, env) ->
  match expr with
  | `Or (left, right) -> negAksj(left, right) || find (left, env) || find (right, env)
  | _ -> false 


(**/**) 
let find_orE = fun (expr, env, left_goal) ->
  let rec aux aux_env = match aux_env with
  | `Impl(left, right)::rest -> 
      if right = expr && 
        (find ((`Or (left, left_goal)), aux_env) || find ((`Or (left_goal, left)), aux_env))
      then true  
      else aux rest
  | _::rest -> aux rest
  | [] -> false
  in aux env
(**/**) 
(** Inverse rule: disjunction elimination *)
let orE : inverse_nd_rule = fun (expr, env) -> 
  let rec aux aux_env = match aux_env with
  | `Impl(left, right)::rest -> 
      if right = expr && find_orE (expr, env, left)
      then true
      else aux rest
  | _::rest -> aux rest
  | [] -> false
  in aux env

(** Inverse rule: implication introduction *)
let implI : inverse_nd_rule = fun (expr, env) -> 
  find (expr, env)

(** Inverse rule: implication elimination *)
let implE : inverse_nd_rule = fun (expr, env) -> 
  let rec aux (expr, local_env) = match local_env with
  | `Impl(left, right)::rest -> 
    if right = expr && find(left, env) then true else aux (expr, rest)
  | _::rest -> aux (expr, rest)
  | [] -> false
  in aux (expr, env)

(** Inverse rule: negation introduction *)
let negI : inverse_nd_rule = fun (expr, env) -> 
  find (expr, env)

(** Inverse rule: negation elimination *)
let negE : inverse_nd_rule = fun (expr, env) -> 
  find (`Neg(`Neg(expr)), env)

(** Inverse rule: false introduction *)
let falseI : inverse_nd_rule = fun (expr, env) ->
  let rec aux = fun env ->
    match env with 
    | (`Neg x)::xs -> if find (x, env) then true else aux env
    | x::xs -> if find (`Neg(x), env) then true else aux env
    | [] -> false
  in aux env

  (**/**)
