

local dodgeMove = {
    ["dualBlades"] = {
        ["normal"] = 1731229352,
        ["kijin_kyouka"] = 1902167730,
        ["kijin"] = 2454049754
    },
    ["huntingHorn"] = {
        ["normal"] = 1731229352
    }
}

local dodgeLockMove = {
    ["dulaBlades"] = {
        [3316282274] = true, -- vault shroud kijin
        [3783600746] = true -- vault shourld kijin_kyouka, normal
    }
}

local dodgeUnlockMove = {
    ["dualBlades"] = {
        [2399642468] = true,
        [3862130673] = true
    }
}

local getDodgeMoveFuncs = {
    ["dualBlades"] = GetDualBladesDodgeMove
}

function GetDualBladesDodgeMove (masterPlayer)
    local normal
	local kijin
    local state
	normal = sdk.find_type_definition("snow.player.DualBlades.DualBladesState"):get_field("Normal"):get_data(nil)
	kijin = sdk.find_type_definition("snow.player.DualBlades.DualBladesState"):get_field("Kijin"):get_data(nil)
    state = masterPlayer:call("get_DBState")
	local kijinState = masterPlayer:call("isKijinKyouka")
	if kijinState then
		return dodgeMove["dulaBlades"]["kijin_kyouka"]
	elseif state == kijin then
		return dodgeMove["dulaBlades"]["kijin"]
	elseif state == normal then
		return dodgeMove["dulaBlades"]["normal"]
	else
		return dodgeMove["dulaBlades"]["normal"]
	end
end