open HolKernel Parse;

open bir_wpTheory bir_wpLib;

open listSyntax;

open bir_expLib;

open bir_wp_simpLib;



structure bir_wp_expLib =
struct

val ERR = mk_HOL_ERR "bir_wp_expLib";


fun get_nth_last_label prog_term n =
      let
        val (block_list, block_type) = (dest_list o dest_BirProgram) prog_term;
        val nth_last_block = List.nth (List.rev block_list, n)
      in
        (snd o dest_comb o concl o EVAL) ``(^nth_last_block).bb_label``
      end;

(* create subproblem for debugging and analysis *)
fun get_subprog_with_n_last prog_term n =
      let
        val (block_list, block_type) = (dest_list o dest_BirProgram) prog_term;
        val n_last_blocks = List.drop (block_list, (List.length block_list) - n)
      in
        mk_BirProgram (mk_list (n_last_blocks, block_type))
      end;

fun get_subprog_drop_n_at_end prog_term n =
      let
        val (block_list, block_type) = (dest_list o dest_BirProgram) prog_term;
        val n_last_blocks = List.rev (List.drop (List.rev block_list, n))
      in
        mk_BirProgram (mk_list (n_last_blocks, block_type))
      end;

fun get_prog_length prog_term =
      let
        val (block_list, block_type) = (dest_list o dest_BirProgram) prog_term;
      in
        List.length block_list
      end;


fun gen_lbl_list wps1_term =
  let
    fun wps_id_suffix striped_label =
      if (is_BL_Address striped_label)
        then (term_to_string o snd o gen_dest_Imm o dest_BL_Address) striped_label
        else (stringSyntax.fromHOLstring o dest_BL_Label) striped_label;
  in
    List.map wps_id_suffix (bir_wp_fmap_to_dom_list wps1_term)
  end;

end
