(** Module implements evaluation of the proof 
The proof evaluated by this module start either with `Prog or `Axiom.
`Prog is evaluated by the program and `Axiom is appended to the global list of facts.
It is also possible to define an Axiom inside of a proof. It's also added to the list of facts. *)
open Expr
open Rules

exception EvalError of string

(** Type expr_properties is a tuple with rules that can be applied to particular expression and error message for that expression *)
type expr_properties = (inverse_nd_rule list * string)
let or_properties    : expr_properties = [Rules.find; Rules.orI; Rules.andE; Rules.negE; Rules.implE; Rules.orE], "cannot deduce disjunction"
let and_properites   : expr_properties = [Rules.find; Rules.andI; Rules.andE; Rules.negE; Rules.implE; Rules.orE], "cannot deduce conjunction"
let neg_properties   : expr_properties = [Rules.find; Rules.negI; Rules.negE], "cannot deduce negation"
let impl_properties  : expr_properties = [Rules.find; Rules.implI; Rules.andE; Rules.negE; Rules.implE; Rules.orE], "cannot deduce implication"
let var_properties   : expr_properties = [Rules.find; Rules.andE; Rules.orE; Rules.negE; Rules.implE], "cannot deduce variable"
let false_properties : expr_properties = [Rules.falseI],"cannot deduce false"

(**/**)
let error = fun (msg) ->
  raise (EvalError msg)

let print = fun e -> 
  Printf.printf "Env: ";
  List.iter (fun a -> Printf.printf "%s \n" (to_string a)) e;
  Printf.printf "\n"
(**/**)

(** function adds premise to the list of facts and
  evaluates frame's proof element by element appending 
  the result of evaluation to the list of local facts and returns the last proven fact
*)
let get_fact_from_premise = fun (premise, formulas, global_env, evaluation_fun) : expr ->
  let rec aux aux_formulas env = match aux_formulas with
    | x::xs -> let new_fact =(match evaluation_fun x env with
                | `False  -> `False
                | `True   -> `True
                | `Error(msg) -> raise ( EvalError msg)
                | fact -> fact
                ) in aux xs (new_fact::env) 
    | [] ->  List.hd env
  in aux formulas (premise::global_env)

(** Function evaluates a single frame. It calls get_fact_from_premise and matches the reslut with the following expressions:
  `True - since TRUE was deduced by evaluating frame's proof the premise is returned as the expression that will be added to global list of facts.
  `False - because of rule negation introduction it returns negation of the premise
  other expression - it return implication premise => other expression
*)
let eval_frame = fun (`Frame(premise, formulas), env, evaluation_fun) : expr  ->
  match (premise, formulas, env, evaluation_fun) |> get_fact_from_premise with
  | `True -> premise
  | `False -> `Neg(premise)
  | conclusion -> `Impl(premise, conclusion)

(** Function checks if any of the rules can be applied to the expression. 
    If it can the it returns the expression.
    Else raises an error.
*)
let apply_rules = fun (expr, env, (rules, err_msg)) : expr  ->
  let rec aux = function
  | rule::rest -> if rule (expr, env) then expr
                  else aux rest
  | [] -> error(Printf.sprintf "%s: %s" err_msg (to_string expr))
  in aux rules

(**/**)
let convert_eq = fun (`Eq(left, right)) -> 
  `And(`Impl(left, right), `Impl(right, left))
(**/**)

(** eval_expr function matches given expression with possible ones and tries to apply rules on it excluding 
    `Frame, `Eq and `True.
    In case of `True it return the expression.
    In case of `Eq it converts equality to conjunction of implication and calls eval_expr function on that new exprssion.
    In case of `Frame it calls eval_frame function.
*)
let rec eval_expr = fun (expr : expr) (env : expr list) : expr  -> 
  match expr with
  | `Frame (a, b) as frame      -> (frame,     env, eval_expr)       |> eval_frame
  | `Var v as variable          -> (variable,  env, var_properties)  |> apply_rules
  | `False                      -> (`False,    env, false_properties)|> apply_rules
  | `True                       -> `True
  | `Or (a, b) as or_expr       -> (or_expr,   env, or_properties)   |> apply_rules
  | `And (a, b) as and_expr     -> (and_expr,  env, and_properites)  |> apply_rules
  | `Impl (a, b) as impl_expr   -> (impl_expr, env, impl_properties) |> apply_rules
  | `Neg x as neg_expr          -> (neg_expr,  env, neg_properties)  |> apply_rules
  | `Eq (a, b) as eq_expr       -> eval_expr (convert_eq(eq_expr)) env
  | `Paren e                    -> `Paren (eval_expr e env)
  | `Axiom e                    -> e
  | _ -> raise (EvalError "invalid expression")

(** eval_proof evaluates the proof element by element calling function eval_expr.
    It appends the result of eval_expr function to list of global proven facts.
    At the end it returns the last proven formula of the proof.
*)
let rec eval_proof (prog : expr) (env : expr list) : expr option = 
  match prog with 
  | `Proof xs -> 
    let conclusion = List.fold_left (
      fun aux_env x -> 
        match eval_expr x aux_env with
        | fact -> (fact::aux_env)) env xs 
    in Some (List.hd conclusion)
  | _ -> raise (EvalError "no proof to eval")

(** Helper function for getting name of the proof *)
let rec get_name = function
  | `Goal (a, b)  -> get_name a
  | `Name a -> a
  | _ -> raise (EvalError "cannot get name")

(** Helper function for getting goal of the proof *)
let rec get_goal_clause = function 
  | `Goal (a, b)  -> b
  | _ -> raise (EvalError "cannot get name")

(** Main function that takes parse tree of one single proof and call eval_proof on it 
to check if the result is the same as the goal of the proof. *)
let eval = fun (expr : expr) (out_file : out_channel) (facts : expr list) : expr option -> match expr with
  | `Prog (a, b)  -> 
    let name = get_name a and goal = get_goal_clause a in
    Printf.fprintf out_file "Start checking proof:%s   " name;
    (match 
      try eval_proof b facts 
      with EvalError msg -> Printf.fprintf out_file "✘  -> %s \n" msg; None
    with 
    | Some conclusion -> 
        if conclusion === goal 
        then (Printf.fprintf out_file "✔ \n"; Some conclusion)
        else (Printf.fprintf out_file "✘ \n"; None)
    | _ -> None)
  | `Axiom a -> (Printf.fprintf out_file "Axiom: %s\n" (to_string a); Some a)
  | _ -> raise (EvalError "wrong start of a program");;


  
