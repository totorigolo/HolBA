signature nic_helpersLib =
sig

  (* Frequent type abbreviations *)
  type bir_block = term * term list * term;

  (* BSL extensions *)
  val bvarstate: string -> term
  val bdenstate: string -> term
  val bstateval: int -> term
  val bjmplabel_str: string -> term

  val gen_state_map_fns: (string * int) list -> (
      (string, int) Redblackmap.dict
    * (string -> int)
    * (string -> term)
  )

  (* Frequent BIR blocks *)
  val block_nic_die: (string * string) -> bir_block
  val bjmp_block: (string * string) -> bir_block

  val bstate_cases: (string * string * (string -> term))
                 -> (string * string * string) list
                 -> bir_block list

  (* WP helpers *)
  val prove_p_imp_wp: string -> thm -> (term * term) -> (term list * term) -> (term * term * thm)

  (* Misc. helpers *)
  val timer_start: unit -> Time.time
  val timer_stop: Time.time -> LargeInt.int
  val timer_stop_str: Time.time -> string

end (* nic_helpersLib *)
