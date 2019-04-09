signature nic_stateLib =
sig

  val init_state_id_of: string -> int
  val init_is_autonomous_step: string -> bool
  val init_autonomous_step_list: string list
  val bstateval_init: string -> term

  val tx_state_id_of: string -> int
  val tx_is_autonomous_step: string -> bool
  val tx_autonomous_step_list: string list
  val bstateval_tx: string -> term

  val td_state_id_of: string -> int
  val td_is_autonomous_step: string -> bool
  val td_autonomous_step_list: string list
  val bstateval_td: string -> term

end (* nic_stateLib *)
