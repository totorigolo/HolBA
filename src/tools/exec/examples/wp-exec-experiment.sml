open HolKernel Parse;
load "bir_execLib";
open bir_execLib;

val _ = Parse.current_backend := PPBackEnd.vt100_terminal;


val _ = print "loading...";

val name1 = "wp_exec_experiment";
val prog1 = ``
  BirProgram [
    <|bb_label := BL_Label "entry";
      bb_statements := [
        BStmt_Assign (BVar "WP" (BType_Imm Bit1))
          (BExp_BinPred BIExp_Equal
            (BExp_Load
              (BExp_Store
                (BExp_Den (BVar "MEM" (BType_Mem Bit64 Bit8)))
                (BExp_BinExp BIExp_Plus
                  (BExp_Den (BVar "BASE_ADDR" (BType_Imm Bit64)))
                  (BExp_Const (Imm64 96w)))
                BEnd_BigEndian
                (BExp_Const (Imm64 42w)))
              (BExp_Den (BVar "ADDR" (BType_Imm Bit64)))
              BEnd_BigEndian
              Bit64)
            (BExp_Const (Imm64 42w)))
             ];
     bb_last_statement := BStmt_Halt (BExp_Const (Imm32 0w))
    |>
  ]``;

val state1 = ``<|
  bst_pc := <|bpc_label := BL_Label "entry"; bpc_index := 0|>;
  bst_environ :=
    BEnv (FEMPTY
      |+ ("WP", (BType_Imm Bit1, NONE))
      |+ ("x", (BType_Imm Bit64, SOME (BVal_Imm (Imm64 (x: word64)))))
      |+ ("MEM", (BType_Mem Bit64 Bit8, SOME (BVal_Mem Bit64 Bit8 (mem2: num -> num))))
      |+ ("BASE_ADDR", (BType_Imm Bit64, SOME (BVal_Imm (Imm64 (base_addr: word64)))))
      |+ ("ADDR", (BType_Imm Bit64, SOME (BVal_Imm (Imm64 (addr: word64)))))
    );
  bst_status := BST_Running
|>``;

val name = name1;
val prog = prog1;
val state = state1;

val validprog_o = NONE;
val welltypedprog_o = NONE;
val state_o = SOME state;

val n_max = 50;

val _ = print "ok\n";

(* Verbose EVAL *)
computeLib.monitoring := SOME (fn (tm: term) =>
  let
    val bir = String.isSubstring "bir" (term_to_string tm);
    val _ = if bir then
        (print "=> ``"; print_term tm; print "``: "; ())
      else ();
  in
    bir
  end);

val _ = bir_exec_prog_print name prog n_max validprog_o welltypedprog_o state_o;


















