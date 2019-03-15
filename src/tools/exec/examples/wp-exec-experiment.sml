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
                (BExp_Den (BVar "MEM" (BType_Mem Bit16 Bit8)))
                (BExp_BinExp BIExp_Plus
                  (BExp_Den (BVar "BASE_ADDR" (BType_Imm Bit16)))
                  (BExp_Const (Imm16 96w)))
                BEnd_BigEndian
                (BExp_Const (Imm16 42w)))
              (BExp_Den (BVar "ADDR" (BType_Imm Bit16)))
              BEnd_BigEndian
              Bit16)
            (BExp_Const (Imm16 42w)))
             ];
     bb_last_statement := BStmt_Halt (BExp_Const (Imm32 0w))
    |>
  ]``;

val state1 = ``<|
  bst_pc := <|bpc_label := BL_Label "entry"; bpc_index := 0|>;
  bst_environ :=
    BEnv (FEMPTY
      |+ ("WP", (BType_Imm Bit1, NONE))
      |+ ("x", (BType_Imm Bit16, SOME (BVal_Imm (Imm16 (x: word16)))))
      |+ ("MEM", (BType_Mem Bit16 Bit8, SOME (BVal_Mem Bit16 Bit8 (mem2: num -> num))))
      |+ ("BASE_ADDR", (BType_Imm Bit16, SOME (BVal_Imm (Imm16 (base_addr: word16)))))
      |+ ("ADDR", (BType_Imm Bit16, SOME (BVal_Imm (Imm16 (addr: word16)))))
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
    val sleep_time = Time.fromMilliseconds (Int.toLarge 10);
    (*val _ = OS.Process.sleep sleep_time;*)
    val yep = ((String.isSubstring "bir" (term_to_string tm))
        orelse (String.isSubstring "Bir" (term_to_string tm))
        orelse (String.isSubstring "b2" (term_to_string tm))
        orelse (String.isSubstring "w2" (term_to_string tm))
      );
    val nop = ((String.isSubstring "BIT" (term_to_string tm))
        orelse (String.isSubstring "NUMERAL" (term_to_string tm))
        orelse (String.isSubstring "numeral" (term_to_string tm))
        orelse (String.isSubstring "ORD" (term_to_string tm))
        orelse (String.isSubstring "ODD" (term_to_string tm))
        orelse (String.isSubstring "COND" (term_to_string tm))
        orelse (String.isSubstring "FDUB" (term_to_string tm))
        orelse (String.isSubstring "FUNPOW" (term_to_string tm))
        orelse (String.isSubstring "GENLIST" (term_to_string tm))
        (*orelse (String.isSubstring "DIV_2EXP" (term_to_string tm))*)
        orelse (String.isSubstring "SUC" (term_to_string tm))
        orelse (String.isSubstring "$<" (term_to_string tm))
        orelse (String.isSubstring "$=" (term_to_string tm))
        orelse (String.isSubstring "$~" (term_to_string tm))
        orelse (String.isSubstring "$-" (term_to_string tm))
        orelse (String.isSubstring "$/\\" (term_to_string tm)) (*"*)
        orelse (String.isSubstring "$\\/" (term_to_string tm))
      );
    (*val log = yep;*)
    val log = not nop;
    val _ = if log then (
      print "==========================================================\n";
      print "==========================================================\n";
      print "=> ``";
      print_term tm;
      print "``: ";
      ()
    ) else ();
    val _ = if log then print "=> " else ();
  in
    log
  end);
computeLib.monitoring := SOME (fn (tm: term) =>
  let
    val _ = print_term tm;
    val _ = print "\n";
    val tm_str = term_to_string tm;
  in
           (tm_str = "$'")
    orelse (tm_str = "LET")
    orelse (tm_str = "UNCURRY")
    orelse (tm_str = "n2l")
  end);
computeLib.monitoring := NONE;

computeLib.set_skip (computeLib.the_compset) ``COND`` (SOME 1);


val _ = bir_exec_prog_print name prog n_max validprog_o welltypedprog_o state_o;


(*
bir_env_write (BVar "WP" (BType_Imm Bit1))
  (BVal_Imm
     (Imm1
        (if
           n2w
             (BITWISE 16 $\/
                ((256 *
                  BITS 7 0
                    (if
                       SUC (w2n (base_addr + 96w)) MOD 65536 = w2n addr
                     then
                       42
                     else
                       (w2n (base_addr + 96w) MOD 65536 =+ 0) mem2
                         (w2n addr))) MOD 65536)
                (BITS 7 0
                   (if
                      SUC (w2n (base_addr + 96w)) MOD 65536 =
                      w2n (addr + 1w)
                    then
                      42
                    else
                      (w2n (base_addr + 96w) MOD 65536 =+ 0) mem2
                        (w2n (addr + 1w)))) MOD 65536) =
           42w
         then
           1w
         else 0w)))
*)














