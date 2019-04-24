structure bir_wpLib =
struct

  val debug_trace = ref (1: int)
  val _ = register_trace ("bir_wpLib.DEBUG_LEVEL", debug_trace, 2)

  local

  open HolKernel Parse boolLib bossLib liteLib simpLib;

  open bir_wpTheory;

  open bir_programTheory;
  open bir_program_blocksTheory;
  open bir_program_terminationTheory;
  open bir_typing_progTheory;
  open bir_envTheory;
  open bir_exp_substitutionsTheory;
  open bir_bool_expTheory;
  open bir_auxiliaryTheory;
  open bir_valuesTheory;
  open bir_expTheory;
  open bir_program_env_orderTheory;
  open bir_extra_expsTheory;
  open bir_immSyntax;
  open bir_exp_memTheory;

  open bir_expLib;
  open finite_mapTheory finite_mapSyntax;
  open pairTheory pairSyntax;
  open wordsTheory;

  val ERR = Feedback.mk_HOL_ERR "bir_wpLib";
  val wrap_exn = Feedback.wrap_exn "bir_wpLib";

  in (* local *)

  val wps_id_prefix = "bir_wp_comp_wps_iter_step2_wp_"

  (* establish wps_bool_sound_thm for an initial analysis context (program, post, ls, wps) *)
  fun bir_wp_init_wps_bool_sound_thm (program, post, ls) wps defs =
      let
        fun REPEAT_MAX n tac =
          if n > 0 then ((tac THEN (REPEAT_MAX (n - 1) tac)) ORELSE ALL_TAC)
          else NO_TAC;
        val wps_bool_thm = prove(``bir_bool_wps_map ^wps``,
          REWRITE_TAC [bir_bool_wps_map_def] >>
          REWRITE_TAC defs >>
          REPEAT_MAX 20 (
            REWRITE_TAC [
              finite_mapTheory.FEVERY_FUPDATE,
              finite_mapTheory.DRESTRICT_FEMPTY,
              finite_mapTheory.FEVERY_FEMPTY
            ] >>
            SIMP_TAC (std_ss++wordsLib.SIZES_ss++HolBACoreSimps.holBACore_ss) [
              bir_is_bool_exp_def,
              type_of_bir_exp_def,
              bir_var_type_def,
              type_of_bir_imm_def,
              bir_type_is_Imm_def,
              BType_Bool_def
            ]
          )
        );
        val wps_sound_thm = prove(``bir_sound_wps_map ^program ^ls ^post ^wps``,
          REWRITE_TAC [bir_sound_wps_map_def] >>
          REWRITE_TAC defs >>
          REPEAT_MAX 20 (
            REWRITE_TAC [
              finite_mapTheory.FEVERY_FUPDATE,
              finite_mapTheory.DRESTRICT_FEMPTY,
              finite_mapTheory.FEVERY_FEMPTY,
              finite_mapTheory.FMERGE_DEF
            ] >>
            SIMP_TAC (srw_ss()) []
          )
        );
      in
        CONJ wps_bool_thm wps_sound_thm
      end;



  (* initial_thm_for_prog_post_ls *)
  fun bir_wp_comp_wps_iter_step0_init reusable_thm (program, post, ls) defs =
    let
      val var_l = ``l:(bir_label_t)``;
      val var_wps = ``wps:(bir_label_t |-> bir_exp_t)``;
      val var_wps1 = ``wps':(bir_label_t |-> bir_exp_t)``;
      val thm = SPECL [program, var_l, ls, post, var_wps, var_wps1] reusable_thm;

      val post_bool_conv = [
        bir_is_bool_exp_def,
        type_of_bir_exp_def,
        bir_var_type_def,
        type_of_bir_imm_def,
        bir_type_is_Imm_def,
        BType_Bool_def,
        bir_number_of_mem_splits_def,
        size_of_bir_immtype_def
      ];
      val prog_typed_conv = [
        bir_is_well_typed_program_def,
        bir_is_well_typed_block_def,
        bir_is_well_typed_stmtE_def,
        bir_is_well_typed_stmtB_def,
        bir_is_well_typed_label_exp_def,
        type_of_bir_exp_def,
        bir_var_type_def,
        bir_type_is_Imm_def,
        type_of_bir_imm_def,
        bir_extra_expsTheory.BExp_Aligned_type_of,
        BExp_unchanged_mem_interval_distinct_type_of,
        bir_exp_memTheory.bir_number_of_mem_splits_REWRS,
        BType_Bool_def,
        bir_exp_true_def,
        bir_exp_false_def,
        BExp_MSB_type_of,
        bir_nzcv_expTheory.BExp_nzcv_ADD_DEFS,
        bir_nzcv_expTheory.BExp_nzcv_SUB_DEFS,
        bir_immTheory.n2bs_def,
        bir_extra_expsTheory.BExp_word_bit_def,
        BExp_Align_type_of,
        BExp_ror_type_of,
        BExp_LSB_type_of,
        BExp_word_bit_exp_type_of,
        bir_nzcv_expTheory.BExp_ADD_WITH_CARRY_type_of,
        BExp_word_reverse_type_of,
        BExp_ror_exp_type_of
      ];
      val prog_valid_conv = [
        bir_program_valid_stateTheory.bir_is_valid_program_def,
        bir_program_valid_stateTheory.bir_program_is_empty_def,
        bir_program_valid_stateTheory.bir_is_valid_labels_def,
        bir_labels_of_program_def,
        BL_Address_HC_def
      ];
      val no_declare_conv = [
        bir_declare_free_prog_exec_def,
        bir_isnot_declare_stmt_def
      ];

      fun wrap_exn_ exn term message = wrap_exn ("bir_wp_comp_wps_iter_step0_init::"
        ^ message ^ ": \n" ^ (Hol_pp.term_to_string term) ^ "\n") exn
      val concl_tm = (snd o dest_eq o concl)

      val post_bool_thm = SIMP_CONV (srw_ss()) (post_bool_conv@defs) ``bir_is_bool_exp ^post``;
      val thm = MP thm (SIMP_RULE std_ss [] post_bool_thm)
        handle e => raise wrap_exn_ e (concl_tm post_bool_thm) "The postcondition isn't a bool";

      val prog_typed_thm = SIMP_CONV (srw_ss()) (prog_typed_conv@defs) ``bir_is_well_typed_program ^program``;
      val thm = MP thm (SIMP_RULE std_ss [] prog_typed_thm)
        handle e => raise wrap_exn_ e (concl_tm prog_typed_thm) "The program isn't well-typed";

      val prog_valid_thm = EVAL ``bir_is_valid_program ^program``;
      val thm = MP thm (SIMP_RULE std_ss [] prog_valid_thm)
        handle e => raise wrap_exn_ e (concl_tm prog_valid_thm) "The program isn't valid";

      val no_declare_thm = SIMP_CONV (srw_ss()) (no_declare_conv@defs) ``bir_declare_free_prog_exec ^program``;
      val thm = MP thm (SIMP_RULE std_ss [] no_declare_thm)
        handle e => raise wrap_exn_ e (concl_tm no_declare_thm) "The program isn't BStmt_Declare-free";

      val thm = GENL [var_l, var_wps, var_wps1] thm;
    in
	    thm
    end;

  (* include current label in reasoning *)
  fun bir_wp_comp_wps_iter_step1 label prog_thm (program, post, ls) defs =
    let
        val var_wps = ``wps:(bir_label_t |-> bir_exp_t)``;
        val var_wps1 = ``wps':(bir_label_t |-> bir_exp_t)``;
        val thm = SPECL [label, var_wps, var_wps1] prog_thm;

        val label_in_prog_conv = [bir_labels_of_program_def, BL_Address_HC_def];
        val edges_blocks_in_prog_conv = [bir_edges_blocks_in_prog_exec_def, bir_targets_in_prog_exec_def, bir_get_program_block_info_by_label_def, listTheory.INDEX_FIND_def, BL_Address_HC_def];
        val l_not_in_ls_conv = [BL_Address_HC_def];

        (* val label_in_prog_thm = SIMP_CONV (srw_ss()) (label_in_prog_conv@defs) ``MEM ^label (bir_labels_of_program ^program)``; *)
        val label_in_prog_thm = EVAL ``MEM ^label (bir_labels_of_program ^program)``;
        val thm = MP thm (SIMP_RULE std_ss [] label_in_prog_thm);
        (*val edges_blocks_in_prog_thm = SIMP_CONV (srw_ss()) (edges_blocks_in_prog_conv@defs) ``bir_edges_blocks_in_prog_exec ^program ^label``;*)
        val edges_blocks_in_prog_thm = EVAL ``bir_edges_blocks_in_prog_exec ^program ^label``;
        val thm = MP thm (SIMP_RULE std_ss [] edges_blocks_in_prog_thm);
        val l_not_in_ls_thm = SIMP_CONV (srw_ss()) (l_not_in_ls_conv@defs) ``~(^label IN ^ls)``;
        val thm = MP thm (SIMP_RULE std_ss [] l_not_in_ls_thm);

        val thm = GENL [var_wps, var_wps1] thm;
    in
        thm
    end;


  fun extract_new_wp fmterm = (snd o dest_pair o snd o dest_fupdate) fmterm;
  val lbl_strip_comment = (snd o dest_comb o concl o EVAL);

  val bir_wp_comp_wps_iter_step2_defs = ref ([]:thm list);
  val bir_wp_comp_wps_iter_step2_consts = ref ([]:term list);
  val bir_wp_comp_wps_iter_step2_cntr = ref 0;

  (* Generates a string suffix from the label. *)
  fun label_to_wps_id_suffix label =
    let
      (*-------------------------------------------------------------------
       * Replaces invalid identifier characters by '_', to conform to
       * Lexis.ok_identifier.
       *-------------------------------------------------------------------*)
      fun escape_non_alphanum c = if Char.isAlphaNum c then String.str c else "_";
      fun to_ident name = String.translate escape_non_alphanum name;

      val striped_label = lbl_strip_comment label;
      val wps_id_suffix =
        if (is_BL_Address striped_label)
          then (term_to_string o snd o gen_dest_Imm o dest_BL_Address) striped_label
          else (stringSyntax.fromHOLstring o dest_BL_Label) striped_label;
    in
      to_ident wps_id_suffix
    end;

  (* produce wps1 and reestablish bool_sound_thm for this one *)
  fun bir_wp_comp_wps_iter_step2 (wps, wps_bool_sound_thm) prog_l_thm ((program, post, ls), (label)) defs =
    let
        (*
        val wps_id_idx = !bir_wp_comp_wps_iter_step2_cntr;
        val _ = (bir_wp_comp_wps_iter_step2_cntr := (!bir_wp_comp_wps_iter_step2_cntr) + 1);
        val wps_id_suffix = Int.toString wps_id_idx;
        *)

        (* Generate a string suffix from the label. *)
        val wps_id_suffix = label_to_wps_id_suffix label;

        val var_wps1 = ``wps':(bir_label_t |-> bir_exp_t)``;
        val thm = SPECL [wps, var_wps1] prog_l_thm;

        (*  *)
        val thm = MP thm wps_bool_sound_thm;

        (*  *)
        val wps_eval_restrict_consts = !bir_wp_comp_wps_iter_step2_consts;
        val wps1_thm = computeLib.RESTR_EVAL_CONV wps_eval_restrict_consts
          (list_mk_comb
            (``bir_wp_exec_of_block:'a bir_program_t ->
                                    bir_label_t ->
                                    (bir_label_t -> bool) ->
                                    bir_exp_t ->
                                    (bir_label_t |-> bir_exp_t) ->
                                    (bir_label_t |-> bir_exp_t) option``,
            [program, label, ls, post, wps]));

        (* normalize *)
        val wps1_thm = SIMP_RULE pure_ss [GSYM bir_exp_subst1_def, GSYM bir_exp_and_def] wps1_thm;
	      val wps1 = (snd o dest_comb o snd o dest_eq o concl) wps1_thm;

        val new_wp_id = wps_id_prefix ^ wps_id_suffix;
        val new_wp_id_var = mk_var (new_wp_id, ``:bir_exp_t``);
        val new_wp_def = Define `^new_wp_id_var = ^(extract_new_wp wps1)`;
	      (*
	      val current_theory_s = current_theory();
        val new_wp_id_const = mk_const (new_wp_id, ``:bir_exp_t``);
        *)
        val new_wp_id_const = (fst o dest_eq o concl) new_wp_def;
        val _ = (bir_wp_comp_wps_iter_step2_consts := new_wp_id_const::wps_eval_restrict_consts);
        val wps1_thm2 = REWRITE_CONV [GSYM new_wp_def] ((snd o dest_eq o concl) wps1_thm);
        val wps1_thm = TRANS wps1_thm wps1_thm2
        val wps1 = (snd o dest_comb o snd o dest_eq o concl) wps1_thm;

        val thm = SPEC wps1 (GEN var_wps1 thm);
	      val wps1_bool_sound_thm = MP thm wps1_thm;
    in
	      (wps1, wps1_bool_sound_thm)
    end;


  (*
  (* helper for simple traversal in recursive procedure *)
  fun is_lbl_in_wps wps label =
      (optionSyntax.is_some o snd o dest_eq o concl o EVAL) ``FLOOKUP ^wps ^label``;
  *)

  fun cmp_label lbla lblb =
      let
        val lbla1 = lbl_strip_comment lbla;
        val lblb1 = lbl_strip_comment lblb;
      in
        term_eq lbla1 lblb1
      end;

  (*EVAL ``BL_Address_HC b hc``*)


  fun bir_wp_fmap_to_dom_list fmap =
      if is_fempty fmap then [] else
      let
        val (fmap1, kv) = dest_fupdate fmap;
        val k = (fst o dest_pair) kv;
      in
        (k)::(List.filter (fn k1 => not (cmp_label k1 k)) (bir_wp_fmap_to_dom_list fmap1))
      end;

  fun bir_wp_init_rec_proc_jobs prog_term wps_term =
      let
        val wpsdom = bir_wp_fmap_to_dom_list wps_term;
        val blocks = (snd o dest_BirProgram_list) prog_term;
        fun blstodofilter block = let
                                    val (label, _, _) = dest_bir_block block;
                                  in
                                    not (List.exists (fn el => cmp_label el label) wpsdom)
                                  end;
        val blstodo = List.filter blstodofilter blocks;
      in
        (wpsdom, blstodo)
      end;

  (* recursive procedure for traversing the control flow graph *)
  fun bir_wp_comp_wps prog_thm ((wps, wps_bool_sound_thm), (wpsdom, blstodo)) (program, post, ls) defs =
    let
      val block =
        List.find
          (fn block =>
            let
              val (label, _, end_statement) = dest_bir_block block;
              fun is_lbl_in_wps lbl = List.exists (fn el => cmp_label el lbl) wpsdom;
            in
              if (is_BStmt_Halt end_statement)
                then false else
              if (is_BStmt_Jmp end_statement)
                then
                  ((is_lbl_in_wps o dest_BLE_Label o dest_BStmt_Jmp) end_statement)
              else
              if (is_BStmt_CJmp end_statement)
                then
                  ((is_lbl_in_wps o dest_BLE_Label o #2 o dest_BStmt_CJmp) end_statement)
                  andalso
                  ((is_lbl_in_wps o dest_BLE_Label o #3 o dest_BStmt_CJmp) end_statement)
              else
                raise ERR "bir_wp_comp_wps" "unhandled end_statement type."
            end)
          blstodo
    in
      case block of
        SOME (bl) =>
          let
            val (label, _, _) = dest_bir_block bl;
            val wpsdom1 = label::wpsdom;

            val _ = if (!debug_trace > 1)
              then print ("\n\r\nstarting with block: " ^ (term_to_string label) ^ "\r\n")
              else ();

            val time_start = Time.now ();

            val prog_l_thm =
              bir_wp_comp_wps_iter_step1 label prog_thm (program, post, ls) defs;
            val (wps1, wps1_bool_sound_thm) =
              bir_wp_comp_wps_iter_step2
                (wps, wps_bool_sound_thm)
                prog_l_thm
                ((program, post, ls), (label))
                defs;

            (* Remove label from blstodo *)
            val blstodo1 =
              List.filter
                (fn block =>
                  let
                    val (label_el, _, _) = dest_bir_block block;
                  in
                    not (cmp_label label label_el)
                  end) blstodo;

            val _ = if (!debug_trace > 2)
              then let
                  val _ = print "label: ";
                  val _ = print_term label;
                  val _ = print "\n";
                  val wp_exp_term = (snd o dest_comb o concl o EVAL) ``(FAPPLY ^wps1 ^label)``;
                  val _ = bir_exp_pretty_print wp_exp_term;
                in () end else ();

            val _ = if (!debug_trace > 1)
              then let
                val time_as_sec = (Time.toSeconds ((Time.now ()) - time_start));
                val time_str = LargeInt.toString time_as_sec;
                val _ = print ("it took " ^ time_str ^ "s\r\n");
              in () end else ();

            val _ = if (!debug_trace > 0)
              then print ("remaining labels = " ^ (Int.toString (List.length blstodo1)) ^ "  \r")
              else ();
          in
            (* recursive call with new wps tuple (which is (wps1, wps1_bool_sound_thm)) *)
            bir_wp_comp_wps prog_thm ((wps1, wps1_bool_sound_thm), (wpsdom1, blstodo1)) (program, post, ls) defs
          end
        | NONE =>
          let
            val _ = if (!debug_trace > 0) then print "\n" else ();
          in (wps, wps_bool_sound_thm) end
    end;

  end (* local *)

end (* bir_wpLib *)
