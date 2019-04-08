structure nic_stateLib :> nic_stateLib =
struct

  open HolKernel Parse boolLib bossLib;
  open bslSyntax;
  open pretty_exnLib;
  open nic_helpersLib;

  val ERR = mk_HOL_ERR "nic_stateLib";
  val wrap_exn = Feedback.wrap_exn "nic_stateLib";

  val level_log = ref (logLib.level_info: int)
  val _ = register_trace ("nic_stateLib", level_log, logLib.level_max)

  val {error, warn, info, debug, trace, ...} = logLib.gen_fn_log_fns "nic_stateLib" level_log;

  (* End of prelude
   ****************************************************************************)

  val (init_state_map, _, bstateval_init) = gen_state_map_fns [
    ("it_power_on", 1),
    ("it_reset", 2),
    ("it_initialize_hdp_cp", 3),
    ("it_initialized", 4)
  ]

  val (tx_state_map, _, bstateval_tx) = gen_state_map_fns [
    ("tx1_idle", 1),
    ("tx2_fetch_next_bd", 2),
    ("tx3_issue_next_memory_read_request", 3),
    ("tx4_process_memory_read_reply", 4),
    ("tx5_post_process", 5),
    ("tx6_clear_owner_and_hdp", 6),
    ("tx7_write_cp", 7)
  ]

  val (td_state_map, _, bstateval_td) = gen_state_map_fns [
    ("td_idle", 1),
    ("td_set_eoq", 2),
    ("td_set_td", 3),
    ("td_clear_owner_and_hdp", 4),
    ("td_write_cp", 5)
  ]

end (* nic_stateLib *)
