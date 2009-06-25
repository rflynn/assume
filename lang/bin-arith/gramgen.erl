-module(gramgen).
-export([combo/2, contains/2, test/0]).

% exposed interface
combo(_, 0) -> [[]];
combo([], _) -> [[]];
combo(L, Cnt) -> combo(L, Cnt, []).

% c(gramgen), l(gramgen).
% gramgen:combo([1,2,3],1).

% real function, accumulator
combo([],        _, Acc) -> [Acc];
combo(_,         0, Acc) -> [Acc];
combo([H|T],   Cnt, Acc) ->
  combo(T, Cnt, Acc) ++
  combo(T, Cnt, Acc ++ [H]).

contains([], _) -> false;
contains([Foo|_], Foo) -> true;
contains([_|T], Foo) -> contains(T, Foo).

test() ->
  combo([1,2], 2).

