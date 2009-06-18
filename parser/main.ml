(* connect our "Lex"er and "C99" parser *)
let main () =
  try
    let lexbuf = Lexing.from_channel stdin in
    while true do
      C99.translation_unit Lex.c99 lexbuf
    done
  with
  | End_of_file -> exit 0
  (* FIXME: catch Parsing.Parse_error and figure out how to display it! *)
      
let _ = Printexc.print main ()

