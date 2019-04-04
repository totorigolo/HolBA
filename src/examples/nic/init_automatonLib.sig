signature init_automatonLib =
sig

  type bir_block = term * term list * term;

  val init_state_map: (string, int) Redblackmap.dict
  val bstateval_init: string -> term

  val init_blocks: bir_block list
  val init_program: term

end (* init_automatonLib *)
