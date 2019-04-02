signature logLib =
sig

  (****************************************************************************)
  (* Log function generating library.                                         *)
  (*                                                                          *)
  (* Usage:                                                                   *)
  (*   val (error, warn, info, trace) = gen_log_fns                     *)
  (*     "my_fancyLib" ref_to_debug_level;                                    *)
  (*                                                                          *)
  (* Where ref_to_debug_level goes at least from 0 to 3 (inclusive).          *)
  (*  - error: ref_to_debug_level >= 0                                        *)
  (*  - warn : ref_to_debug_level >= 1                                        *)
  (*  - info : ref_to_debug_level >= 2                                        *)
  (*  - trace: ref_to_debug_level >= 3                                        *)
  (*                                                                          *)
  (****************************************************************************)

  val gen_log_fns: string -> int ref -> (
      (string -> string -> unit)
    * (string -> string -> unit)
    * (string -> string -> unit)
    * (string -> string -> unit)
    );

  val gen_toplevel_log_fns: string -> int ref -> (
      (string -> unit)
    * (string -> unit)
    * (string -> unit)
    * (string -> unit)
    );

end
