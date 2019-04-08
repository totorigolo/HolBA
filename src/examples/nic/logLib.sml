structure logLib :> logLib =
struct

  local

  open HolKernel Parse;

  val ERR = mk_HOL_ERR "logLib";
  val wrap_exn = Feedback.wrap_exn "logLib";

  (* Colors *)
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

  in (* local *)

  val level_error = 0
  val level_warn = 1
  val level_info = 2
  val level_debug = 3
  val level_trace = 4
  val level_max = level_trace

  type log_functions = {
    error: string -> unit,
    warn : string -> unit,
    info : string -> unit,
    debug: string -> unit,
    trace: string -> unit
  }
  fun gen_log_fns lib_name level_ref =
    let
      fun error msg = if !level_ref >= level_error then (
          print (boldred ("[ERROR @ " ^ lib_name ^ "] "));
          print (red msg);
          print "\n"
        ) else ();
      fun warn msg = if !level_ref >= level_warn then (
          print (boldyellow ("[ WARN @ " ^ lib_name ^ "] "));
          print msg;
          print "\n"
        ) else ();
      fun info msg = if !level_ref >= level_info then (
          print (boldblue ("[ INFO @ " ^ lib_name ^ "] "));
          print msg;
          print "\n"
        ) else ();
      fun debug msg = if !level_ref >= level_debug then (
          print (boldcyan ("[DEBUG @ " ^ lib_name ^ "] "));
          print msg;
          print "\n"
        ) else ();
      fun trace msg = if !level_ref >= level_trace then (
          print (boldmagenta ("[TRACE @ " ^ lib_name ^ "] "));
          print msg;
          print "\n"
        ) else ();
    in
      {error=error, warn=warn, info=info, debug=debug, trace=trace}
    end;

  type fn_log_functions = {
    error: string -> string -> unit,
    warn : string -> string -> unit,
    info : string -> string -> unit,
    debug: string -> string -> unit,
    trace: string -> string -> unit
  }
  fun gen_fn_log_fns lib_name level_ref =
    let
      fun error func_name msg = if !level_ref >= level_error then (
          print (boldred ("[ERROR @ " ^ lib_name ^ "::" ^ func_name ^ "] "));
          print (red msg);
          print "\n"
        ) else ();
      fun warn func_name msg = if !level_ref >= level_warn then (
          print (boldyellow ("[ WARN @ " ^ lib_name ^ "::" ^ func_name ^ "] "));
          print msg;
          print "\n"
        ) else ();
      fun info func_name msg = if !level_ref >= level_info then (
          print (boldblue ("[ INFO @ " ^ lib_name ^ "::" ^ func_name ^ "] "));
          print msg;
          print "\n"
        ) else ();
      fun debug func_name msg = if !level_ref >= level_debug then (
          print (boldcyan ("[DEBUG @ " ^ lib_name ^ "::" ^ func_name ^ "] "));
          print msg;
          print "\n"
        ) else ();
      fun trace func_name msg = if !level_ref >= level_trace then (
          print (boldmagenta ("[TRACE @ " ^ lib_name ^ "::" ^ func_name ^ "] "));
          print msg;
          print "\n"
        ) else ();
    in
      {error=error, warn=warn, info=info, debug=debug, trace=trace}
    end;

  end (* local *)

end (* logLib *)
