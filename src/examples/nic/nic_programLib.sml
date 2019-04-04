structure nic_programLib :> nic_programLib =
struct

  open HolKernel Parse boolLib bossLib;
  open bslSyntax;
  open pretty_exnLib;
  open nic_helpersLib;

  val ERR = mk_HOL_ERR "nic_programLib";
  val wrap_exn = Feedback.wrap_exn "nic_programLib";

  val log_level = ref (2: int)
  val _ = register_trace ("nic_programLib", log_level, 4)

  val (error, warn, info, debug, trace) = logLib.gen_log_fns "nic_programLib" log_level;

  (* End of prelude
   ****************************************************************************)

  (*****************************************************************************
   * Complete program
   *)

  val nic_program = bprog_list alpha (
        [(blabel_str "entry", [], bjmplabel_str "init_entry")]
      @ init_automatonLib.init_blocks
      @ [(blabel_str "end", [], bhalt (bconst32 0))]
    );

end (* nic_programLib *)
