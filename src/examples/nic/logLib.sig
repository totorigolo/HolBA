signature logLib =
sig

  (****************************************************************************)
  (* Log function generating library.                                         *)
  (*                                                                          *)
  (* Usage:                                                                   *)
  (*   val (error, warn, info, debug, trace) = gen_log_fns                    *)
  (*     "my_fancyLib" ref_to_debug_level;                                    *)
  (*                                                                          *)
  (* Where ref_to_debug_level goes at least from 0 to 4 (inclusive).          *)
  (*  - error: ref_to_debug_level >= 0                                        *)
  (*  - warn : ref_to_debug_level >= 1                                        *)
  (*  - info : ref_to_debug_level >= 2                                        *)
  (*  - debug: ref_to_debug_level >= 3                                        *)
  (*  - trace: ref_to_debug_level >= 4                                        *)
  (*                                                                          *)
  (****************************************************************************)

  val level_error: int
  val level_warn: int
  val level_info: int
  val level_debug: int
  val level_trace: int
  val level_max: int

  type log_functions = {
    error: string -> unit,
    warn : string -> unit,
    info : string -> unit,
    debug: string -> unit,
    trace: string -> unit
  }
  val gen_log_fns: string -> int ref -> log_functions;

  type fn_log_functions = {
    error: string -> string -> unit,
    warn : string -> string -> unit,
    info : string -> string -> unit,
    debug: string -> string -> unit,
    trace: string -> string -> unit
  }
  val gen_fn_log_fns: string -> int ref -> fn_log_functions;

end
