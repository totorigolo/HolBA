open HolKernel Parse boolLib bossLib;

val _ = Parse.current_backend := PPBackEnd.vt100_terminal;
val _ = Globals.linewidth := 100;

(*
val _ = Globals.show_tags := true;
val _ = Globals.show_types := true;
val _ = Globals.show_assums := true;
*)

val level_log = ref (logLib.level_info: int)
val {error, warn, info, debug, trace, ...} = logLib.gen_fn_log_fns "print-prog-test" level_log;

(* End of prelude
 ****************************************************************************)

(* Configuration *)
val dot_path = "./cfg.dot";
val show_cfg = true;

(* Load the program *)
val _ = info "Loading the program...";
val program_tm = nic_programLib.nic_program;
val _ = info "Done.";

(* Print the program *)
val _ = Hol_pp.print_term program_tm;

(* Export the CFG *)
val _ = info "Exporting the CFG...";
val _ = bir_cfgVizLib.bir_export_graph_from_prog program_tm dot_path;
val _ = if show_cfg then graphVizLib.convertAndView (OS.Path.base dot_path) else ();
val _ = info "Done.";
