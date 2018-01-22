(** Module with expression type and to_string function implementation *)
type expr = [
  | `Prog of (expr * expr)
  | `Axiom of expr
  | `Name of string
  | `Goal of (expr * expr)
  | `Var of char
  | `Or of (expr * expr)
  | `And of (expr * expr)
  | `Impl of (expr * expr)
  | `Eq of (expr * expr)
  | `Neg of expr
  | `Proof of expr list
  | `Paren of expr
  | `Frame of (expr * expr list)
  | `Error of string
  | `False
  | `True
  | `End 
]

(** Function to_string converts each expression to string 
@param expr expression : expr
*)
let rec to_string  = function 
  | `Var v        -> Printf.sprintf "%c" v
  | `Name s       -> Printf.sprintf "Name: %s" s
  | `Paren s      -> Printf.sprintf "%s" (to_string s)
  | `Frame (a, b) -> let stringified = (List.map (fun x -> to_string x) b) in
                    Printf.sprintf "%s %s" (to_string a) (String.concat " " stringified)
  | `Prog (a, b)  -> Printf.sprintf "%s, %s" (to_string a) (to_string b)
  | `Axiom a      -> Printf.sprintf "Axiom: %s" (to_string a)
  | `Goal (a, b)  -> Printf.sprintf "GoalName: %s GoalClause: %s" (to_string a) (to_string b)
  | `Or (a, b)    -> Printf.sprintf "%s \\/ %s" (to_string a) (to_string b)
  | `And (a, b)   -> Printf.sprintf "%s /\\ %s" (to_string a) (to_string b)
  | `Impl (a, b)  -> Printf.sprintf "%s => %s" (to_string a) (to_string b)
  | `Eq (a, b)    -> to_string (`And( `Impl (a, b), `Impl (b, a)))
  | `Neg a        -> Printf.sprintf "~ %s" (to_string a)
  | `Proof xs     -> let stringified = (List.map (fun x -> to_string x) xs) in
                     Printf.sprintf "%s" (String.concat " " stringified)
  | `Error x      -> Printf.sprintf "Error: %s" x
  | `False        -> "False"
  | `True         -> "True"
  | `End          -> "End "


