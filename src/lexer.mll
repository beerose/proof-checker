{
(** Lexer for natural deduction proofs *)
open Lexing
open Parser

exception SyntaxError of string

(** Function next_lines assigns current position in file to the lexbuf*)
let next_line lexbuf =
  let pos = lexbuf.lex_curr_p in
  lexbuf.lex_curr_p <-
    { pos with pos_bol = lexbuf.lex_curr_pos;
               pos_lnum = pos.pos_lnum + 1
    }
}

(** Regular expressions used in lexer *)
let white = [' ' '\t']+
let newline = '\r' | '\n' | "\r\n"
let id = ['a'-'z' 'A'-'Z' '_'] ['a'-'z' 'A'-'Z' '0'-'9' '_']*

(** Main rule *)
rule read =
  parse
  | white                  { read lexbuf }
  | newline                { next_line lexbuf; read lexbuf }
  | "goal"                 { read_name (Buffer.create 17) lexbuf }
  | "proof"                { PROOF     }
  | "Axiom:"                { AXIOM     }
  | "end."                 { END       }
  | '('                    { LPAREN    }
  | ')'                    { RPAREN    }
  | '['                    { LPARENK   }
  | ']'                    { RPARENK   }
  | ':'                    { COLON     }
  | ';'                    { SEMICOLON }
  | 'F'                    { FALSE     }
  | 'T'                    { TRUE      }
  | ['a'-'z' 'A'-'Z'] as v { VAR v     }
  | "\\/"                  { OR        }
  | "/\\"                  { AND       }
  | "=>"                   { IMPL      }
  | "<=>"                  { EQ        }
  | '~'                    { NEG       }
  | "EXISTS"               { EXISTS    }
  | "FORALL"               { FORALL    }
  | _                      { raise (SyntaxError ("Unexpected char: " ^ Lexing.lexeme lexbuf)) }
  | eof                    { EOF   }

(** Rule reading name of the proof *)
and read_name buf =
  parse
  | ':'       { NAME (Buffer.contents buf) } 
  | [^ ':' '\\']+
    { Buffer.add_string buf (Lexing.lexeme lexbuf);
      read_name buf lexbuf
    }
  | _ { raise (SyntaxError ("Illegal string character: " ^ Lexing.lexeme lexbuf)) }
  | eof { raise (SyntaxError ("Name is not terminated")) }
