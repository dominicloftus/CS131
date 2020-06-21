
type ('nonterminal, 'terminal) symbol =
  | N of 'nonterminal
  | T of 'terminal
;;

type ('nonterminal, 'terminal) parse_tree =
  | Node of 'nonterminal * ('nonterminal, 'terminal) parse_tree list
  | Leaf of 'terminal
;;

(* Match nonterm taken in curried form with the nonterminals from the grammar
and concatenate each matching rule into a list of lists *)
let rec conv_gram_help rules nonterm =
    match rules with
    |[] -> []
    |h::t -> if (fst h) = nonterm then (snd h)::(conv_gram_help t nonterm)
                                else conv_gram_help t nonterm
;;

let convert_grammar gram1 =
    ((fst gram1), conv_gram_help (snd gram1))
;;

(* Traverse the parse tree in order while concatenating and appending found
leaves together *)
let rec parse_tree_helper =
    function
    |[] -> []
    |h::t -> 
        match h with
        |Node (nonterm, tree_list) -> parse_tree_helper tree_list @ parse_tree_helper t
        |Leaf l -> l::parse_tree_helper t
;;

let parse_tree_leaves =
    function
    |Node (nonterm, tree_list) -> parse_tree_helper tree_list
    |Leaf l -> [l]
;;

let accept_all string = Some string;;
let accept_empty_suffix = function
   | _::_ -> None
   | x -> Some x;;

(* Takes list of all rules for a nonterminal symbol and goes through each
until a match is found. If not found then it moves on to the next rule
for that nonterminal symbol. If it runs out of rules then the nonterminal
symbol has no matching rule and returns None *)
let rec matcher prod_func rules acceptor fragment =
    match rules with
    |[] -> None
    |h::t ->
        let test = test_rule prod_func h acceptor fragment in
        match test with
        |None -> matcher prod_func t acceptor fragment
        |Some s -> Some s

(* Takes a singular rule and tests each nonterminal or terminal symbol to
see if the terminal symbols match with fragment. If it encounters a nonterminal
symbol it branches into that symbol's list of rules and looks for a match which
returns the new fragment and continues matching the current rule's other
symbols. If it reaches the end of the current rule it returns the fragment
in the current state. If fragment runs out or isn't accepted by the acceptor
then it returns none *)
and test_rule prod_func rule acceptor fragment =
    match rule with
    |[] -> Some fragment
    |h::t ->
        match h with
        |N nonterm -> (match fragment with
            |[] -> None
            |_ -> let matched = matcher prod_func (prod_func nonterm) acceptor fragment in
            (match matched with
            |None -> None
            |Some s -> test_rule prod_func t acceptor s))

        |T term ->
            match fragment with
            |[] -> None
            |fragh::fragt -> if term = fragh
                then 
                    let tail = acceptor fragt in
                    match tail with
                    |None -> None
                    |Some s -> test_rule prod_func t acceptor s
                else
                    None
;;

let make_matcher grammar = 
    matcher (snd grammar) ((snd grammar) (fst grammar))
;;

let make_parser gram frag = None;;