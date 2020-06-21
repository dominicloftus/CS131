
let my_subset_test0 = subset [1;2;3;4] [1;2;3;4;5;6;7]
let my_subset_test1 = not (subset [3;1;3;4] [1;2;3;3;3;2])


let my_equal_sets_test0 = equal_sets [1;2;3] [3;1;3;2;3]
let my_equal_sets_test1 = not (equal_sets [1;3;4] [3;5;3;4])

let my_set_union_test0 = equal_sets (set_union [4;2;5] [1;2;3]) [1;2;3;4;5]
let my_set_union_test1 = equal_sets (set_union [] []) []

let my_set_intersection_test0 =
  equal_sets (set_intersection [] [1;2;3;4]) []
let my_set_intersection_test1 =
  equal_sets (set_intersection [1;1;3] [1;2;3;5]) [1;3]

let my_set_diff_test0 = equal_sets (set_diff [1;4;3;3] [1;4;3;1]) []
let my_set_diff_test1 = equal_sets (set_diff [4;3;1;1;3;2;] [1;3;3]) [4;2]


let my_computed_fixed_point_test0 =
  computed_fixed_point (=) (fun x -> x / 2) 250000 = 0
let my_computed_fixed_point_test1 =
  ((computed_fixed_point (fun x y -> abs_float (x -. y) < 1.)
			 (fun x -> x /. 2.)
			 10.)
   = 1.25)
let my_computed_fixed_point_test2 =
  computed_fixed_point (=) (fun x -> (x * x)/2) 2 = 2 


type baker_nonterminals =
  | Open | HelpCustomer | Prep | Bake | Eat 

let baker_grammar =
  Open,
  [Eat, [T"Yum"];
   Bake, [N Eat];
   Bake, [T"Food Ready"];
   Prep, [N Bake];
   HelpCustomer, [N Prep];
   HelpCustomer, [N HelpCustomer];
   Open, [T"Open for business"; N HelpCustomer];
   Open, [T"Open for business"; N Prep]]

let my_filter_reachable_test0 =
  filter_reachable baker_grammar = baker_grammar

let my_filter_reachable_test1 =
  filter_reachable (HelpCustomer, (snd baker_grammar)) =
    (HelpCustomer,
     [Eat, [T"Yum"];
      Bake, [N Eat];
      Bake, [T"Food Ready"];
      Prep, [N Bake];
      HelpCustomer, [N Prep];
      HelpCustomer, [N HelpCustomer]])

