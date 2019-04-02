structure nic_programLib :> nic_programLib =
struct

  open HolKernel Parse boolLib bossLib;
  open bslSyntax;
  open pretty_exnLib;

  val log_level = ref (2: int)
  val _ = register_trace ("nic_programLib", log_level, 3)

  val (error, warn, info, trace) = logLib.gen_log_fns "nic_programLib" log_level;

  (****************************************************************************)
  (* End of prelude *)
  (****************************************************************************)

  val nic_program = bprog_list alpha [
      (blabel_str "entry", [
        bassign (bvarimm1 "bit1", bmsbi 32 ((bden o bvarimm32) "R1"))
      ], (bjmp o belabel_str) "a"),
      (blabel_str "a", [
        bassign (bvarimm32 "R3", bconst32 25),
        bassign (bvarimm32 "R2", bconst32 7)
      ], (bjmp o belabel_str) "b"),
      (blabel_str "b", [
        bassign (bvarimm32 "R3", bplusl [
          (bden o bvarimm32) "R2",
          (bden o bvarimm32) "R3"
        ])
      ], bhalt (bconst32 1))
    ];

end (* nic_programLib *)
