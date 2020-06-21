app([], M, M).
app([X|L], M, [X|LM]) :- app(L, M, LM).

is_but_a(man, reed).
weakest(reed, nature).
thinking(man).

thinking_reed(X) :-
    thinking(X),
    weak(X).

weak(X) :-
    weakest(Y, nature),
    similar(X, Y).

similar(X, X).
similar(X, Y) :-
    is_but_a(X, Y).

reverse_2d(X, RX) :-
    maplist(reverse, X, RX).


check_row(_, Row, Sum) :-
    nth(1, Row, Sum).
	
	

plain_tower(N, T, C) :-
	count(Top, Bot, Left, Right) = C,
	maplist(check_row(N), T, Right).



%find_row(-1,[],_) :- !, fail.
%find_row(0,[],_).
%find_row(N, [N|R], _) :-
%	P is N-1,
%	find_row(P, R, _).
%find_row(N, L) :-
%	find_row(N, R, o),
%	permutation(R, L).
%
%
%make_grid(-1, _, _) :- !, fail.
%make_grid(0, _, []).
%make_grid(N, L, [R|T]) :-
%	find_row(L, R),
%	P is N-1,
%	make_grid(P, L, T).
%make_grid(N, T) :-
%	make_grid(N, N, T).


% hint of accelerating plain_tower

% a list contain N elements 
% http://www.gprolog.org/manual/html_node/gprolog033.html
% http://www.gprolog.org/manual/gprolog.html#hevea_default674
% Domain is all the enumerated answers of between(1, N, X)
within_domain(N, Domain) :- 
    findall(X, between(1, N, X), Domain).

% fill in a 2D array with lists of fixed length (N)
% http://www.gprolog.org/manual/gprolog.html#sec215
fill_2d([], _).
fill_2d([Head | Tail], N) :-
    within_domain(N, Domain),
    permutation(Domain, Head),
    fill_2d(Tail, N).

% here is an example that it might help you with...
% but you know this is not the final answer...
% for example, try calling 
%        create_grid(Grid, 3).
create_grid(Grid, N) :-
    length(Grid, N),
    fill_2d(Grid, N).

column([], _, []).
column([[H|T]|TL], Ind, [E|R]) :-
	nth(Ind, [H|T], E),
	column(TL, Ind, R).

all_unique([]).
all_unique([H|T]) :- member(H, T), !, fail.
all_unique([_|T]) :- all_unique(T).	

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


make_grid(_, -1, _) :- !, fail.
make_grid(_, 0, []).
make_grid(N, P, [R|T]) :- 
    PP is P-1,
    make_grid(N, PP, T),
    find_row(N, T, R).
    
length_wrap(N, T) :-
    length(T, N).

fd_domain_wrap(Min, Max, T) :-
    fd_domain(T, Min, Max).

test(N, T) :-
    maplist(length_wrap(N), T),
    maplist(fd_domain_wrap(1, N), T),
    maplist(fd_all_different, T),
    maplist(fd_labeling, T).


temp(N, T) :-
    maplist(length_wrap(N), T).


