[=[
File: Arguments
This file defines argument types to be used in TODO.
]=]

[=[
Class: Arg

The base argument class.

Revisions:
	1.0.0 - Initial.
]=]
export class Arg
	[=[
	Function: ShortcutFn
	Only available statically, meant for internal use only.
	]=]
	@ShortcutFn = (name, typ, default using nil) =>
		@__base[name] = (val=default using nil) =>
			UtilX.CheckArg "#{@@__name}.#{name}", 1, typ, val
			@["_" .. name] = val
			@


	[=[
	Variables: Arg Variables
	All these variables are optional, with sensible defaults.

		_Default  - A value of *any type*. If an argument is optional and unspecified, this value is used.
		_Optional - A *boolean* of whether or not this argument is optional.
		_Hint - A *string* (usually a word or two) used in help output to give users a general idea of what the argument is for.
		_Help - A *string* used in longer help output to describe the argument.
	]=]
	_Default:  nil
	_Optional: false
	_Hint:     ""
	_Help:     ""

	@ShortcutFn "Default"
	@ShortcutFn "Optional", "boolean", true
	@ShortcutFn "Hint", "string"
	@ShortcutFn "Help", "string"


	[=[
	Function: UsageShort

	Parameters:
		str - An optional *string* to add the help into. _Defaults to ""_.

	Returns:
		A short, one-line help *string* for using the argument.
	]=]
	UsageShort: (str = "" using nil) =>
		str ..= ", "                   if @_Optional and #str > 0
		str ..= "default #{@_Default}" if @_Optional
		str = "#{@_Hint}: " .. str     if @_Hint
		str = "<" .. str .. ">"
		str = "[" .. str .. "]"        if @_Optional

		str


	[=[
	Function: UsageLong
	Similar to <UsageShort>, but has no length restrictions on the returned text.

	Parameters:
		str - An optional *string* to add the help into. _Defaults to ""_.

	Returns:
		A full *string* help for using the argument.
	]=]
	UsageLong: (str = "" using nil) =>
		str ..=   "Type:     #{@@__name}"
		str ..= "\nDefault:  #{@_Default} (used if argument is unspecified)" if @_Optional
		str ..= "\nHint:     #{@_Hint}"    if @_Hint
		str ..= "\nHelp:     #{@_Help}"    if @_Help

		str


	[=[
	Function: Completes

	Returns:
		TODO
	]=]
	Completes: (str using nil) =>
		--return {"Current entry is invalid"} if str\find("%S") and not @IsValid str
		{@UsageShort!}


	[=[
	Function: IsValid
	TODO
	]=]
	IsValid: (obj using nil) =>
		UtilX.RaiseUnimplemented "Arg.IsValid"


	[=[
	Function: Parse
	TODO
	]=]
	Parse: (str using nil) =>
		UtilX.RaiseUnimplemented "Arg.Parse"


	[=[
	Function: IsPermissible
	TODO
	]=]
	IsPermissible: (obj using nil) =>
		UtilX.RaiseUnimplemented "Arg.IsPermissible"


	[=[
	Function: Serialize
	TODO
	]=]
	Serialize: (str using nil) =>
		UtilX.RaiseUnimplemented "Arg.Serialize"


	[=[
	Function: Deserialize
	TODO
	]=]
	@Deserialize: (str, obj using nil) ->
		UtilX.RaiseUnimplemented "Arg.Deserialize"



[=[
Class: ArgNum
The argument class used for any numeric data.

Passes:
	A *number* value, defaulting to _0_.

Revisions:
	1.0.0 - Initial.
]=]
export class ArgNum extends Arg
	-- Values from parent that we want to override the defaults for
	_Default: 0
	_Hint:    "number"
	_Help:    "A number argument"

	@ShortcutFn "Default", "number"

	[=[
	Variables: ArgNum Variables
	All these variables are optional, with sensible defaults.

		_Min   - A *number or nil* specifying the minimum value for the argument.
		_Max   - A *number or nil* specifying the maximum value for the argument.
		_Round - A *number or nil* specifying the digit to round to, as passed to <UtilX.Round>.
		_Hint  - A *string* (usually a word or two) used in help output to give users a general idea of what the argument is for.
	]=]
	_Min:   nil
	_Max:   nil
	_Round: nil

	@ShortcutFn "Min", {"number", "nil"}
	@ShortcutFn "Max", {"number", "nil"}
	@ShortcutFn "Round", {"number", "nil"}, 0


	[=[
	Function: UsageShort
	TODO
	]=]
	UsageShort: (str = "" using nil) =>
		if @_Min and @_Min == @_Max
			str ..= tostring @_Min

		else
			str ..= @_Min .. "<=" if @_Min
			str ..= "x"
			str ..= "<=" .. @_Max if @_Max

		super\UsageShort str


	[=[
	Function: UsageLong
	TODO
	]=]
	UsageLong: (str = "" using nil) =>
		str = super\UsageLong(str)

		str ..= "\nMin:      #{@_Min}"   if @_Min
		str ..= "\nMax:      #{@_Max}"   if @_Max
		str ..= "\nRound:    #{@_Round}" if @_Round

		str


	[=[
	Function: IsValid
	TODO
	]=]
	IsValid: (obj using nil) =>
		valid = tonumber(obj) ~= nil
		valid or (obj == nil and @_Optional)


	[=[
	Function: Parse
	TODO
	]=]
	Parse: (str using nil) =>
		num = tonumber(str)
		num = @_Default if not num and @_Optional
		num = UtilX.Round num, @_Round if @_Round
		num


	[=[
	Function: IsPermissible
	TODO
	]=]
	IsPermissible: (num using nil) =>
		return false, "Below minimum (#{@_Min})" if num < @_Min
		return false, "Above maximum (#{@_Max})" if num > @_Max
		true


	[=[
	Function: Serialize
	TODO
	]=]
	Serialize: (str using nil) =>
		"#{@_Min}:#{@_Max}"


	[=[
	Function: Deserialize
	TODO
	]=]
	@Deserialize: (str, obj using nil) ->
		splitPt = str\find ":"

		local min, max
		if splitPt
			min = tonumber(str\sub(1, splitPt-1))
			max = tonumber(str\sub(splitPt+1))
		else -- Assume they want it restricted to one value
			min = tonumber(str)
			max = min

		ArgNum!\Min(min)\Max(max)



[=[
Class: ArgTime
The argument class used for a timespan using natural language.

Passes:
	A *number* of seconds, defaulting to _0_.

Revisions:
	1.0.0 - Initial.
]=]
class ArgTime extends ArgNum
	[=[
	Variables: ArgNum Variables
	All these variables are optional, with sensible defaults.

		Min - A *number, string, or nil* specifying the minimum value for the argument.
		Max - A *number, string, or nil* specifying the maximum value for the argument.
	]=]
	Min: nil
	Max: nil



[=[
Class: ArgString
The argument class used for string arguments.

Passes:
	A *string* value, defaulting to _0_.

Revisions:
	1.0.0 - Initial.
]=]
class ArgString extends Arg
	[=[
	Variables: ArgString Variables
	All these variables are optional, with sensible defaults.

		Default - A *string*, defaults to _""_. If an argument is optional and unspecified, this value is used.
		RestrictToCompletes - A *boolean*, defaults to _false_.
			If true, the argument passed will /always/ be one of the arguments from the <Completes> table.
		Completes           - A *list of strings or nil* of auto-completes (suggestions) for the argument.

	]=]
	Default:             ""
	RestrictToCompletes: false
	Completes:           nil



[=[
Class: ArgPlayerID
The argument class used for SteamID arguments.

Passes:
	A *table of strings or players* (between one and <MaximumTargets> items).
	Each item is either a valid SteamID or a connected player.

Revisions:
	1.0.0 - Initial.
]=]
class ArgPlayerID extends Arg
	[=[
	Variables: ArgPlayerID Variables
	All these variables are optional, with sensible defaults.

		Default            - A *string*, defaults to _"^"_ (keyword for the player calling the command).
			If an argument is optional and unspecified, this value is used.
		RestrictTarget     - A *string or nil* specifying the players this argument is allowed to target.
			This is passed to <TODO.GetUser()>. Nil indicates no restriction.
		MaximumTargets     - A *number*, defaulting to _1_, specifying the maximum number of players this argument can target.
		PassPlayerIfActive - A *boolean*. If true, will pass the player object if they are connected.

	]=]
	Default:            "^"
	RestrictTarget:     nil
	MaximumTargets:     1
	PassPlayerIfActive: false



[=[
Class: ArgPlayerActive
The argument class used for player arguments.

Passes:
	A *table of players* (between one and <MaximumTargets> items).

Revisions:
	1.0.0 - Initial.
]=]
class ArgPlayerActive extends ArgPlayerID
