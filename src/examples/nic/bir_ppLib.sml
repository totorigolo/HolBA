structure bir_ppLib :> bir_ppLib =
struct

  open HolKernel Parse boolLib bossLib;
  open bslSyntax;
  open pretty_exnLib;

  val ERR = mk_HOL_ERR "bir_ppLib";
  val wrap_exn = Feedback.wrap_exn "bir_ppLib";

  val log_level = ref (2: int)
  val _ = register_trace ("bir_ppLib", log_level, 4)

  val (error, warn, info, debug, trace) = logLib.gen_log_fns "bir_ppLib" log_level;

  (* End of prelude
   ****************************************************************************)

  (*****************************************************************************
   * Colors
   *)

  fun checkterm pfx s = (* This is from HOL/Parse *)
    case OS.Process.getEnv "TERM" of
        NONE => s
      | SOME term => if String.isPrefix "xterm" term then pfx ^ s ^ "\027[0m" else s
  val bold = checkterm "\027[1m"
  val boldred = checkterm "\027[31m\027[1m"
  val boldgreen = checkterm "\027[32m\027[1m"
  val boldyellow = checkterm "\027[33m\027[1m"
  val boldblue = checkterm "\027[34m\027[1m"
  val boldmagenta = checkterm "\027[35m\027[1m"
  val boldcyan = checkterm "\027[36m\027[1m"
  val red = checkterm "\027[31m"
  val green = checkterm "\027[32m"
  val yellow = checkterm "\027[33m"
  val blue = checkterm "\027[34m"
  val magenta = checkterm "\027[35m"
  val cyan = checkterm "\027[36m"
  val dim = checkterm "\027[2m"
  val clear = checkterm "\027[0m"

  (*****************************************************************************
   * Pretty printers
   *)

  fun hol_string_printer gs be sys ppfns gravs depth t =
    let
      open Portable term_pp_types smpp
      infix >>
      val {add_string=str, add_break=brk,...} =
        ppfns: term_pp_types.ppstream_funs
      val sml_string = stringSyntax.fromHOLstring t
    in
      str (green ("\"" ^ sml_string ^ "\""))
    end
      handle HOL_ERR _ => raise term_pp_types.UserPP_Failed

  fun bir_immtype_t_printer gs be sys ppfns gravs depth t =
    let
      open Portable term_pp_types smpp
      infix >>
      val {add_string=str, add_break=brk,...} =
        ppfns: term_pp_types.ppstream_funs
      val bit_str = if bir_immSyntax.is_Bit1 t then "Bit1"
        else if bir_immSyntax.is_Bit8 t then "Bit8"
        else if bir_immSyntax.is_Bit16 t then "Bit16"
        else if bir_immSyntax.is_Bit32 t then "Bit32"
        else if bir_immSyntax.is_Bit64 t then "Bit64"
        else if bir_immSyntax.is_Bit128 t then "Bit128"
        else raise ERR "bir_immtype_t_printer" "unknown bir_immtype_t"
    in
      str (blue bit_str)
    end
      handle HOL_ERR _ => raise term_pp_types.UserPP_Failed

  fun bir_imm_printer gs be sys ppfns gravs depth t =
    let
      open Portable term_pp_types smpp
      infix >>
      val {add_string=str, add_break=brk,...} =
        ppfns: term_pp_types.ppstream_funs
      val (bit_str, dest_fn) = if bir_immSyntax.is_Imm1 t then ("Imm1", bir_immSyntax.dest_Imm1)
        else if bir_immSyntax.is_Imm8 t then ("Imm8", bir_immSyntax.dest_Imm8)
        else if bir_immSyntax.is_Imm16 t then ("Imm16", bir_immSyntax.dest_Imm16)
        else if bir_immSyntax.is_Imm32 t then ("Imm32", bir_immSyntax.dest_Imm32)
        else if bir_immSyntax.is_Imm64 t then ("Imm64", bir_immSyntax.dest_Imm64)
        else if bir_immSyntax.is_Imm128 t then ("Imm128", bir_immSyntax.dest_Imm128)
        else raise ERR "bir_imm_printer" "unknown bir_imm type"
    in
      str "("
      >> str (blue bit_str)
      >> str " "
      >> str (magenta (Hol_pp.term_to_string (dest_fn t)))
      >> str ")"
    end
      handle HOL_ERR _ => raise term_pp_types.UserPP_Failed

  fun bir_block_printer gs be sys ppfns gravs depth t =
    let
      open Portable term_pp_types smpp
      infix >>
      val {add_string=str, add_break=brk,...} =
        ppfns: term_pp_types.ppstream_funs

      val stmt_fmt = (fn s => (boldgreen " - ") ^ s ^ "\n")

      val block = t
      val (label_tm, stmts_tm, end_statement_tm) = dest_bir_block block
      val stmt_tms = (fst o listSyntax.dest_list) stmts_tm
    in
      str (dim "--------------------------------------\n")
      >> str (dim "--------------------------------------\n")
      >> str (boldgreen " label: ") >> str (Hol_pp.term_to_string label_tm)
      >> str "\n"
      >> (if (List.length stmt_tms = 0) then str (boldgreen "  stmts: []\n") else
        (str (boldgreen "  stmts: [\n")
          >> List.foldr (op >>) (str "") (List.map (str o stmt_fmt o Hol_pp.term_to_string) stmt_tms)
          >> str (boldgreen " ]\n")))
      >> str (boldgreen " end_stmt: ") >> str (Hol_pp.term_to_string end_statement_tm)
      >> str "\n"
    end
      handle HOL_ERR _ => raise term_pp_types.UserPP_Failed

  fun bir_program_printer gs be sys ppfns gravs depth t =
    let
      open Portable term_pp_types smpp
      infix >>
      val {add_string=str, add_break=brk,...} =
        ppfns: term_pp_types.ppstream_funs

      val program_tm = t
      val blocks = (fst o listSyntax.dest_list o dest_BirProgram) program_tm;
      val n_blocks = List.length blocks
      val n_blocks_str = Int.toString n_blocks
    in
      str "BirProgram ["
        >> str (yellow ("(* " ^ n_blocks_str ^ " blocks *)"))
        >> str "\n"
      >> List.foldr (op >>) (str "") (List.map (str o Hol_pp.term_to_string) blocks)
      >> str "] "
        >> str (yellow "(* end of BirProgram *)")
    end
      handle HOL_ERR _ => raise term_pp_types.UserPP_Failed

  (*****************************************************************************
   * List of all available pretty printers
   *)

  val pretty_printers = [
    ("HOL_string", ``str: string``, hol_string_printer),
    ("bir_immtype_t", ``bit: bir_immtype_t``, bir_immtype_t_printer),
    ("bir_imm_t", ``bir_imm: bir_imm_t``, bir_imm_printer),
    ("bir_block_t", ``bir_block: 'a bir_block_t``, bir_block_printer),
    ("bir_program_t", ``bir_program: 'a bir_program_t``, bir_program_printer)
  ]

  (*****************************************************************************
   * Public functions
   *)

  fun install_bir_pretty_printers () =
    let
      val _ = List.map Parse.temp_add_user_printer pretty_printers
    in () end
    handle e => raise wrap_exn "install_pretty_printer" e;

  fun remove_bir_pretty_printers () =
    let
      fun fst (a, b, c) = a
      val _ = List.map (Parse.temp_remove_user_printer o fst) pretty_printers
    in () end
    handle e => raise wrap_exn "remove_pretty_printer" e;

end (* bir_ppLib *)
