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
	ShortcutFn: (name, typ, default using nil) =>
		@__base[name] = (val=default using nil) =>
			UtilX.CheckArg(1, "#{@@__name}.#{name}", typ, val)
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

	@ShortcutFn "Optional", "boolean", true
	@ShortcutFn "Default"
	@ShortcutFn "Hint", "string"
	@ShortcutFn "Help", "string"


	[=[
	Function: Combine
	TODO
	]=]
	@Combine: (args, copyTo=Arg() using nil) =>
		copyTo = Arg()
		for copyFrom in *args
			if copyFrom._Default ~= nil
				copyTo._Default = copyFrom._Default
			copyTo._Optional = copyFrom._Optional or copyTo._Optional

		copyTo


	[=[
	Function: UsageShort
	TODO
	]=]
	UsageShort: (str using nil) =>
		str ..= ", "                   if @_Optional and #str > 0
		str ..= "default #{@_Default}" if @_Optional
		str = "#{@_Hint}: " .. str     if @_Hint
		str = "<" .. str .. ">"
		str = "[" .. str .. "]"        if @_Optional

		str


	[=[
	Function: UsageLong
	TODO
	]=]
	UsageLong: (str using nil) =>
		str ..= "Type:     #{@__name}\n"
		str ..= "Default:  #{@_Default}\n" if @_Optional
		str ..= @_Optional and "This argument is optional\n" or "This argument is required\n"
		str ..= "Hint:     #{@_Hint}\n"    if @_Hint
		str ..= "Help:     #{@_Help}\n"    if @_Help

		str


	[=[
	Function: Completes
	TODO
	]=]
	Completes: (str using nil) =>
		nil

	[=[
	Function: Parse
	TODO
	]=]
	Parse: (str using nil) =>
		UtilX.Raise "Arg.Parse() called, but is intentionally unimplemented"

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
	Function: Combine
	TODO
	]=]
	@Combine: (args, copyTo=ArgNum() using nil) =>
		super\Combine args, copyTo
		for copyFrom in *args
			if copyFrom._Min and (not copyTo._Min or copyTo._Min and copyFrom._Min > copyTo._Min)
				copyTo._Min = copyFrom._Min
			if copyFrom._Max and (not copyTo._Max or copyTo._Max and copyFrom._Max < copyTo._Max)
				copyTo._Max = copyFrom._Max
			copyTo._Round = copyFrom._Round or copyTo._Round

		copyTo

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
		str = super\UsageLong str

		str ..= "Min:      #{@_Min}\n"   if @_Min
		str ..= "Max:      #{@_Max}\n"   if @_Max
		str ..= "Round:    #{@_Round}\n" if @_Round
		str


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
		Completes           - A *table or nil* of auto-completes (suggestions) for the argument.

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
