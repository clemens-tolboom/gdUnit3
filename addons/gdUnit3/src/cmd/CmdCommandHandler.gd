class_name CmdCommandHandler
extends Reference

var _cmd_options :CmdOptions
var _command_func_refs :Dictionary

func _init(cmd_options :CmdOptions):
	_cmd_options = cmd_options

# register a callback function for given command
# cmd_name short name of the command
# fr_arg a funcref to a function with a single argument
func register_cb(cmd_name :String, fr :FuncRef) -> CmdCommandHandler:
	var registered_fr :Array = _command_func_refs.get(cmd_name, [null,null])
	if registered_fr[0]:
		push_error("A function for command '%s' is already registered!" % cmd_name)
		return self
	registered_fr[0] = fr
	_command_func_refs[cmd_name] = registered_fr
	return self

# register a callback function for given command
# fr a funcref to a function with a variable number of arguments but expects all parameters to be passed via a single Array.
func register_cbv(cmd_name :String, fr :FuncRef) -> CmdCommandHandler:
	var registered_fr :Array = _command_func_refs.get(cmd_name, [null, null])
	if registered_fr[1]:
		push_error("A function for command '%s' is already registered!" % cmd_name)
		return self
	registered_fr[1] = fr
	_command_func_refs[cmd_name] = registered_fr
	return self

func _validate() -> Result:
	var errors := PoolStringArray()
	var registers_func_cbs := Dictionary()
	
	for cmd_name in _command_func_refs.keys():
		var fr :FuncRef = _command_func_refs[cmd_name][0] if _command_func_refs[cmd_name][0] else _command_func_refs[cmd_name][1]
		if fr == null:
			errors.append("Invalid function reference for command '%s', Null is not a allowed!" % cmd_name)
		elif not fr.is_valid():
			errors.append("Invalid function reference for command '%s', Check the function reference!" % cmd_name)
		if _cmd_options.get_option(cmd_name) == null:
			errors.append("The command '%s' is unknown, verify your CmdOptions!" % cmd_name)
		
		# verify for multiple registered command callbacks
		if fr != null:
			var func_cb_name := fr.get_function()
			if registers_func_cbs.has(func_cb_name):
				var already_registered_cmd = registers_func_cbs[func_cb_name] 
				errors.append("The function reference '%s' already registerd for command '%s'!" % [func_cb_name, already_registered_cmd])
			else:
				registers_func_cbs[func_cb_name] = cmd_name
	
	if errors.empty():
		return Result.success(true)
	else:
		return Result.error(errors.join("\n"))

func execute(commands :Array) -> Result:
	var result := _validate()
	if result.is_error():
		return result
	
	for index in commands.size():
		var cmd :CmdCommand = commands[index]
		assert(cmd is CmdCommand, "commands contains invalid command object '%s'" % cmd)
		var cmd_name := cmd.name()
		if _command_func_refs.has(cmd_name):
			var fr_s :FuncRef = _command_func_refs.get(cmd_name)[0]
			var fr_m :FuncRef = _command_func_refs.get(cmd_name)[1]
			if cmd.arguments().empty():
				fr_s.call_func()
			else:
				if cmd.arguments().size() == 1:
					fr_s.call_func(cmd.arguments()[0])
				else:
					fr_m.call_func(cmd.arguments())
	return Result.success(true)
	