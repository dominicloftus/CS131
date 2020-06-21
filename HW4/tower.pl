

column([], _, []).
column([[H|T]|TL], Ind, [E|R]) :-
	nth(Ind, [H|T], E),
	column(TL, Ind, R).


transpose(-1, _, _, _) :- !, fail.
transpose(0, _, [], _).
transpose(N, M, [C|T], _) :-
	column(M, N, C),
	P is N-1,
	transpose(P, M, T, o).
transpose(N, M, T) :-
	transpose(N, M, R, o),
	reverse(R, T).

% put all elements higher than the previous into a list
% then get the length of that list to find number of 
% visible towers
visible([],_,[]).
visible([H|T], Max, [H|L]) :-
	H > Max,
	visible(T, H, L).
visible([_|T], Max, L) :-
	visible(T, Max, L).
visible([H|T], R) :-
	visible([H|T], 0, L),
	length(L, R),!.

% compare visible towers in a row to the value it should be from counts
check_row(Row, Sum) :-
	visible(Row, Vis),
	Sum = Vis.

% fill out values for a row while checking each value against
% other values in the same row and values in the same column
% of other rows in the same matrix
find_row(_, -1, _, _, _) :- !, fail.
find_row(_, 0, _, _, []).
find_row(N, P, I, M, [E|R]) :-
    PP is P-1,
    II is I+1,
    find_row(N, PP, II, M, R),
    between(1, N, E),
    all_unique([E|R]),
    column(M, I, C),
    all_unique([E|C]).
find_row(N, M, R) :-
    find_row(N, N, 1, M, R).

% create NxN grid of unique columns and rows
make_grid(_, -1, _) :- !, fail.
make_grid(_, 0, []).
make_grid(N, P, [R|T]) :- 
    PP is P-1,
    make_grid(N, PP, T),
    find_row(N, T, R).
make_grid(N, T) :-
	make_grid(N, N, T).

all_unique([]).
all_unique([H|T]) :- member(H, T), !, fail.
all_unique([_|T]) :- all_unique(T).	

plain_tower(N, T, C) :-
	C = counts(Top, Bot, Left, Right),
	make_grid(N, T),
	transpose(N, T, Trans),
	maplist(check_row, T, Left),
	maplist(reverse, T, Rev),
	maplist(check_row, Rev, Right),
	maplist(check_row, Trans, Top),
	maplist(reverse, Trans, Revtrans),
	maplist(check_row, Revtrans, Bot).



% Redefinitions of previous functions with FDS constraints
fd_transpose(-1, _, _, _) :- !, fail.
fd_transpose(0, _, [], _).
fd_transpose(N, M, [C|T], _) :-
	column(M, N, C),
	P #= N-1,
	fd_transpose(P, M, T, o).
fd_transpose(N, M, T) :-
	fd_transpose(N, M, R, o),
	reverse(R, T).


fd_visible([],_,[]).
fd_visible([H|T], Max, [H|L]) :-
	H #> Max,
	fd_visible(T, H, L).
fd_visible([H|T], Max, L) :-
	H #=< Max,
	fd_visible(T, Max, L).
fd_visible([H|T], Sum) :-
	fd_visible([H|T], 0, L),
	length(L, Sum).

fd_check_row(Row, Sum) :-
	fd_visible(Row, Vis),
	Sum #= Vis.

fd_domain_wrap(Min, Max, T) :-
	fd_domain(T, Min, Max).

length_wrap(N, T) :-
	length(T, N).



tower(N, T, C) :-
	C = counts(Top, Bot, Left, Right),
	length(T, N),
	maplist(length_wrap(N), T),
	length(Top,N),
	length(Bot,N),
	length(Left,N),
	length(Right,N),
	maplist(fd_domain_wrap(1, N), T),
	fd_transpose(N, T, Trans),
	maplist(fd_all_different, T),
	maplist(fd_all_different, Trans),
	maplist(reverse, T, Rev),
	maplist(reverse, Trans, Revtrans),
	maplist(fd_check_row, T, Left),
	maplist(fd_check_row, Rev, Right),
	maplist(fd_check_row, Trans, Top),
	maplist(fd_check_row, Revtrans, Bot),
	fd_labeling(Left),
	fd_labeling(Right),
	fd_labeling(Top),
	fd_labeling(Bot),
	maplist(fd_labeling, T).
	
	
% finds two NxN towers T1 and T2 that could both be
% solutions to Counts C
ambiguous(N, C, T1, T2) :-
	tower(N, T1, C),
	tower(N, T2, C),
	T1 \= T2.


speedup(Inc) :-
	statistics(cpu_time, [_, _]),
	plain_tower(5, _, counts([3,2,1,2,3],[3,4,3,1,2],[3,2,1,2,3],[3,4,3,1,2])),
	statistics(cpu_time, [_, Plain_time]),
	tower(5, _, counts([3,2,1,2,3],[3,4,3,1,2],[3,2,1,2,3],[3,4,3,1,2])),
	statistics(cpu_time, [_, Tower_time]),
	Inc is Plain_time / Tower_time.


