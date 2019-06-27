structure bir_htSyntax :> bir_htSyntax =
struct

open HolKernel boolLib liteLib simpLib Parse bossLib;
open bir_htTheory;


val ERR = mk_HOL_ERR "bir_htSyntax"
val wrap_exn = Feedback.wrap_exn "bir_htSyntax"
fun syntax_fns n d m = HolKernel.syntax_fns {n = n, dest = d, make = m} "bir_ht"

fun syntax_fns0 s = let val (tm, _, _, is_f) = syntax_fns 0
   (fn tm1 => fn e => fn tm2 =>
       if Term.same_const tm1 tm2 then () else raise e)
   (fn tm => fn () => tm) s in (tm, is_f) end;

fun dest_quinop c e tm =
   case with_exn strip_comb tm e of
      (t, [t1, t2, t3, t4, t5]) =>
         if same_const t c then (t1, t2, t3, t4, t5) else raise e
    | _ => raise e
fun list_of_quintuple (a, b, c, d, e) = [a, b, c, d, e];
fun mk_quinop tm = HolKernel.list_mk_icomb tm o list_of_quintuple

fun dest_sexop c e tm =
   case with_exn strip_comb tm e of
      (t, [t1, t2, t3, t4, t5, t6]) =>
         if same_const t c then (t1, t2, t3, t4, t5, t6) else raise e
    | _ => raise e
fun list_of_sextuple (a, b, c, d, e, f) = [a, b, c, d, e, f];
fun mk_sexop tm = HolKernel.list_mk_icomb tm o list_of_sextuple

val syntax_fns1 = syntax_fns 1 HolKernel.dest_monop HolKernel.mk_monop;
val syntax_fns2 = syntax_fns 2 HolKernel.dest_binop HolKernel.mk_binop;
val syntax_fns3 = syntax_fns 3 HolKernel.dest_triop HolKernel.mk_triop;
val syntax_fns4 = syntax_fns 4 HolKernel.dest_quadop HolKernel.mk_quadop;
val syntax_fns5 = syntax_fns 5 dest_quinop mk_quinop;
val syntax_fns6 = syntax_fns 6 dest_sexop mk_sexop;

(* No-assumes related *)
val (bir_prog_has_no_assumes_tm, mk_bir_prog_has_no_assumes, dest_bir_prog_has_no_assumes, is_bir_prog_has_no_assumes) = syntax_fns1 "bir_prog_has_no_assumes";
val (bir_block_has_no_assumes_tm, mk_bir_block_has_no_assumes, dest_bir_block_has_no_assumes, is_bir_block_has_no_assumes) = syntax_fns1 "bir_block_has_no_assumes";
val (bir_stmtsB_has_no_assumes_tm, mk_bir_stmtsB_has_no_assumes, dest_bir_stmtsB_has_no_assumes, is_bir_stmtsB_has_no_assumes) = syntax_fns1 "bir_stmtsB_has_no_assumes";
val (bir_stmtB_is_not_assume_tm, mk_bir_stmtB_is_not_assume, dest_bir_stmtB_is_not_assume, is_bir_stmtB_is_not_assume) = syntax_fns1 "bir_stmtB_is_not_assume";

(* bir_exec_to_labels_triple *)
val (bir_exec_to_labels_triple_tm, mk_bir_exec_to_labels_triple, dest_bir_exec_to_labels_triple, is_bir_exec_to_labels_triple) = syntax_fns5 "bir_exec_to_labels_triple";

end
