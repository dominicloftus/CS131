type ('nonterminal, 'terminal) symbol =
    | N of 'nonterminal
    | T of 'terminal;;


let rec subset a b = 
    match a with
    |[] -> true
    |h::t when List.exists (fun x -> x = h) b -> subset t b
    |_ -> false;;

let equal_sets a b =
    if (subset a b && subset b a)
    then true
    else false;;

let set_union a b = 
    a @ b;;

let rec set_intersection a b = 
    match a with
    |[] -> []
    |h::t when List.exists (fun x -> x = h) b -> h::set_intersection t b
    |_ -> set_intersection (List.tl a) b;;

let rec set_diff a b = 
    match a with
    |[] -> []
    |h::t when not (List.exists (fun x -> x = h) b) -> h::set_diff t b
    |_ -> set_diff (List.tl a) b;;

let rec computed_fixed_point eq f x =
    if (eq (f x) x)
    then x
    else (computed_fixed_point (eq) (f) (f x));;

(* Take rhs of each rule already reached and restart process with remaining rules and *)
(* new nonterminals found *)
let rec find_next_nonterms rhs rules_left = 
    match rhs with
    |[] -> []
    |h::t -> 
        (match h with
        |N n -> filter_helper n rules_left @ find_next_nonterms t rules_left
        |_ -> find_next_nonterms t rules_left)
    
(* For each rule that has been reached (rules_matched), send rhs to find_next_nonterms *)
(* to be handled *)
and process_rules rules_matched rules_left = 
    match rules_matched with
    |[] -> []
    |h::t -> (find_next_nonterms (snd h) rules_left) @ (process_rules t rules_left)

(* Matches rules with a nonterminal symbol that has already been reached*)
and filter_helper nonterm rules = 
    let rules_matched = List.filter (fun x -> (fst x) = nonterm) rules in
    match rules_matched with
    |[] -> []
    |h::t -> (process_rules rules_matched (set_diff rules rules_matched)) @ rules_matched;;

let rec filter_reachable g =
    let filtered = filter_helper (fst g) (snd g) in
    (fst g), set_intersection (snd g) (filtered);; 




  

