structure init_automatonLib :> init_automatonLib =
struct

  open HolKernel Parse boolLib bossLib;
  open bslSyntax;
  open pretty_exnLib;
  open nic_helpersLib;

  val ERR = mk_HOL_ERR "init_automatonLib";
  val wrap_exn = Feedback.wrap_exn "init_automatonLib";

  val log_level = ref (2: int)
  val _ = register_trace ("init_automatonLib", log_level, 4)

  val (error, warn, info, debug, trace) = logLib.gen_log_fns "init_automatonLib" log_level;

  (* End of prelude
   ****************************************************************************)

  (*****************************************************************************
   * Lemma generators
   *)

(*  fun gen_NIC_DELTA_PRESERVES_IT_def =*)
(*    bandl [*)
(*      beq ((bden o bvarimm1) "nic_dead_0", (bden o bvarimm1) "nic_dead")*)
(*    ]*)

(*  val NIC_DELTA_PRESERVES_IT_def = Define `*)
(*    NIC_DELTA_PRESERVES_IT (nic_delta : nic_delta_type) =*)
(*    !nic. (nic_delta nic).it = nic.it`;*)

  (*****************************************************************************
   * Initialisation automaton
   *)

  val (init_state_map, _, bstateval_init) = gen_state_map_fns [
    ("it_power_on", 1),
    ("it_reset", 2),
    ("it_initialize_hdp_cp", 3),
    ("it_initialized", 4)
  ]

  val init_blocks = [
      bjmp_block ("init_entry", "init_try_s1"),

      (blabel_str "init_try_s1", [],
        bcjmp (beq (bdenstate "init_state", bstateval_init "it_reset"),
               belabel_str "init_s1_entry",
               belabel_str "init_unknown_state")),

      bjmp_block ("init_s1_entry", "init_s1_set_regs"),
      (blabel_str "init_s1_set_regs", [
        bassign (bvarimm1 "nic_regs_CPDMA_SOFT_RESET", bfalse),
        bassign (bvarstate "init_state", bstateval_init "it_initialize_hdp_cp")
      ], bjmplabel_str "init_s1_epilogue"),
      bjmp_block ("init_s1_epilogue", "init_s1_end"),
      bjmp_block ("init_s1_end", "init_epilogue"),

      block_nic_die ("init_unknown_state", "init_epilogue"),
      bjmp_block ("init_epilogue", "init_end"),
      bjmp_block ("init_end", "end")
    ];
    val init_program = bprog_list alpha init_blocks;

end (* init_automatonLib *)
