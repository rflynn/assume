% 
% given a symbolic grammar, generate valid input for it
% 

-module(gramgen).
-export([combo/2, choose/1, test_perm/0, contains/2]).

% c(gramgen), l(gramgen).
% gramgen:combo([1,2,3], 2).

combo([], _) -> [[]];
combo(L, Max) -> combo([], L, Max).
combo(Acc, [],    _) -> [Acc];
combo(_,     0, Acc) -> [Acc];
combo(Acc, Max, [H|T]) ->
  combo(T, Max-1, Acc) ++
  combo(T, Max-1, Acc ++ [H]).

choose([]) -> [[]];
choose(L)  -> choose([], L).

choose(Acc, []) -> [Acc];
choose(Acc, [H|T]) ->
  choose(Acc ++ [H], T) ++ % take it
  choose(Acc, T).          % don't

test_choose() ->
  test_choose(0).
test_choose(6) -> true;
test_choose(N) when N >= 0 ->
  Len = length(choose(lists:seq(0,N))),
  Expect = math:pow(2, N),
  if
    Len /= Expect ->
      io:format("Shit! N=~p Expect=~p L=~p~n", [N,Expect,Len]),
      exit(shit);
    true ->
      test_choose(N+1)
  end.

contains([], _) -> false;
contains([Foo|_], Foo) -> true;
contains([_|T], Foo) -> contains(T, Foo).

fac(0) -> 0;
fac(1) -> 1;
fac(N) when N > 1 -> N * fac(N-1).

