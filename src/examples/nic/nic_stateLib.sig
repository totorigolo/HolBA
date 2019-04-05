signature nic_stateLib =
sig

  val init_state_map: (string, int) Redblackmap.dict
  val bstateval_init: string -> term

  val tx_state_map: (string, int) Redblackmap.dict
  val bstateval_tx: string -> term

  val td_state_map: (string, int) Redblackmap.dict
  val bstateval_td: string -> term

end (* nic_stateLib *)
