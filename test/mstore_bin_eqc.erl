-module(mstore_bin_eqc).

-include_lib("eqc/include/eqc.hrl").
-include_lib("eunit/include/eunit.hrl").
-include("../include/mstore.hrl").

-import(mstore_heler, [int_array/0, float_array/0, non_neg_int/0, pos_int/0,
                       i_or_f_list/0, i_or_f_array/0, out/1]).

-compile(export_all).

non_obvious_list() ->
    oneof([
          ?LET({N, L}, {non_neg_int(), list(int())},
               oneof(
                 [{integer, <<(mstore_bin:empty(N))/binary, (mstore_bin:from_list(L))/binary>>} || L =/= []] ++
                     [{undefined, <<(mstore_bin:empty(N))/binary, (mstore_bin:from_list(L))/binary>>} || L == []])),
          ?LET({N, L}, {non_neg_int(), list(real())},
               oneof(
                 [{float, <<(mstore_bin:empty(N))/binary, (mstore_bin:from_list(L))/binary>>} || L =/= []] ++
                     [{undefined, <<(mstore_bin:empty(N))/binary, (mstore_bin:from_list(L))/binary>>} || L == []]))]).

prop_empty() ->
    ?FORALL(Length, non_neg_int(),
            byte_size(mstore_bin:empty(Length)) == Length*?DATA_SIZE).

prop_l2b_b2l() ->
    ?FORALL(List, i_or_f_list(),
            List == ?B2L(?L2B(List))).

prop_b2l() ->
    ?FORALL({_, L, B}, i_or_f_array(),
            L == ?B2L(B)).

prop_find_type() ->
    ?FORALL({T, B}, non_obvious_list(),
            T == mstore_bin:find_type(B)).

run_test_() ->
    Props = [
             fun prop_empty/0,
             fun prop_b2l/0,
             fun prop_find_type/0,
             fun prop_l2b_b2l/0
             ],
    [
     begin
         P = out(Prop()),
         ?_assert(quickcheck(numtests(500,P)))
     end
     || Prop <- Props].
