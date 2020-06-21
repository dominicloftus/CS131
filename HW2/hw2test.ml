

let accept_all string = Some string
let accept_empty_suffix = function
   | _::_ -> None
   | x -> Some x

type baker_nonterminals =
  | Open | HelpCustomer | Prep | Bake | Eat

let baker_grammar1 =
  Open,
  [Eat, [T"Yum"];
   Bake, [N Eat];
   Bake, [T"Food Ready"];
   Prep, [N Bake];
   HelpCustomer, [N Prep];
   HelpCustomer, [T"Next in line"; N HelpCustomer];
   Open, [T"Open for business"; N HelpCustomer];
   Open, [T"Open for business"; N Prep]]


let baker_grammar = convert_grammar baker_grammar1

let frag = ["Open for business"; "Next in line"; 
            "Next in line"; "Yum"; "nice"; "Yay"]

let make_matcher_test = 
  (make_matcher baker_grammar accept_all frag = Some ["nice"; "Yay"])

