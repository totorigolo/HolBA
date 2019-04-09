open HolKernel Parse boolLib bossLib;
open bslSyntax;
open pretty_exnLib;
open nic_helpersLib nic_stateLib;

(* Load the dependencies in interactive sessions *)
val _ = if !Globals.interactive then (
  load "HolSmtLib"; (* HOL/src/HolSmt *)
  ()) else ();

val _ = if !Globals.interactive then () else (
  Feedback.set_trace "HolSmtLib" 0;
  Feedback.set_trace "bir_wpLib.DEBUG_LEVEL" 1;
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

val level_log = ref (logLib.level_info: int)
val {error, warn, info, debug, trace, ...} = logLib.gen_fn_log_fns "init-wp-test" level_log;

(* End of prelude
 ****************************************************************************)

(* Load and print the program *)
val nic_program_def = Define `nic_program = ^(nic_programLib.nic_program)`;
val _ = (Hol_pp.print_thm nic_program_def; print "\n");

(*  *)
val (_, _, init_autonomous_step_doesnt_die_thm) = prove_p_imp_wp
  "init_automaton_doesnt_die"
  (* prog_def *) nic_program_def
  (* Precondition *) (
    blabel_str "init_entry",
    bandl [
      beq ((bden o bvarimm1) "nic_dead", bfalse),
      borl (List.map (fn s => beq (bdenstate "nic_init_state", bstateval_init s))
            init_autonomous_step_list)
    ]
  )
  (* Postcondition *) (
    [blabel_str "init_end"],
    beq ((bden o bvarimm1) "nic_dead", bfalse)
  )
val _ = info "Successfully proved: init automaton doesn't die"
val _ = if !level_log >= logLib.level_info
  then (Hol_pp.print_thm init_autonomous_step_doesnt_die_thm; print "\n")
  else ();

(*  *)
val (_, _, tx_autonomous_step_doesnt_die_thm) = prove_p_imp_wp
  "tx_automaton_doesnt_die"
  (* prog_def *) nic_program_def
  (* Precondition *) (
    blabel_str "tx_entry",
    bandl [
      beq ((bden o bvarimm1) "nic_dead", bfalse),
      borl (List.map (fn s => beq (bdenstate "nic_tx_state", bstateval_tx s))
            tx_autonomous_step_list)
    ]
  )
  (* Postcondition *) (
    [blabel_str "tx_end"],
    beq ((bden o bvarimm1) "nic_dead", bfalse)
  )
val _ = info "Successfully proved: tx automaton doesn't die"
val _ = if !level_log >= logLib.level_info
  then (Hol_pp.print_thm tx_autonomous_step_doesnt_die_thm; print "\n")
  else ();
