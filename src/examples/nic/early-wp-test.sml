open HolKernel Parse boolLib bossLib;
open bslSyntax;
open pretty_exnLib;
open nic_helpersLib;

(* Load the dependencies in interactive sessions *)
val _ = if !Globals.interactive then (
  load "HolSmtLib"; (* HOL/src/HolSmt *)
  ()) else ();

val _ = if !Globals.interactive then () else (
  Feedback.set_trace "HolSmtLib" 0;
  Feedback.set_trace "bir_wpLib.DEBUG_LEVEL" 0;
  Feedback.set_trace "easy_noproof_wpLib" 2;
  Feedback.set_trace "nic_helpersLib" 4;
  Feedback.set_trace "Define.storage_message" 0;
  Feedback.emit_WARNING := false;
  ());

val _ = Parse.current_backend := PPBackEnd.vt100_terminal;
val _ = Globals.show_tags := true;
val _ = Globals.linewidth := 100;

val _ = bir_ppLib.install_bir_pretty_printers ();

(*
val _ = Globals.linewidth := 100;
val _ = Globals.show_tags := true;
val _ = Globals.show_types := true;
val _ = Globals.show_assums := true;
val _ = wordsLib.add_word_cast_printer ();
val _ = Feedback.set_trace "HolSmtLib" 0;
val _ = Feedback.set_trace "HolSmtLib" 4;
val _ = Feedback.set_trace "bir_wpLib.DEBUG_LEVEL" 2;
val _ = Feedback.set_trace "easy_noproof_wpLib" 2;
val _ = Feedback.set_trace "Define.storage_message" 1;
*)

val log_level = ref (2: int)
val (error, warn, info, debug, trace) = logLib.gen_toplevel_log_fns "init-wp-test" log_level;

(* End of prelude
 ****************************************************************************)

(* Load and print the program *)
val init_program_def = Define `init_program = ^(init_automatonLib.init_program)`;
val _ = (Hol_pp.print_thm init_program_def; print "\n");

(*  *)
val (_, smt_ready_tm, init_autonomous_step_doesnt_die_thm) = prove_p_imp_wp
  "init_autonomous_step_doesnt_die"
  (* prog_def *) init_program_def
  (* Precondition *) (
    blabel_str "init_entry",
    bandl [
      beq (bdenstate "init_state", init_automatonLib.bstateval_init "it_reset"),
      beq ((bden o bvarimm1) "nic_dead", bfalse)
    ]
  )
  (* Postcondition *) (
    [blabel_str "init_end"],
    beq ((bden o bvarimm1) "nic_dead", bfalse)
  )
val _ = (Hol_pp.print_thm init_autonomous_step_doesnt_die_thm; print "\n")
