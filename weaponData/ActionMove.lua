local actionMove = {}

function actionMove.init()
    actionMove.dodgeMove = {
        ["dualBlades"] = {
            ["normal"] = 1731229352,
            ["kijin_kyouka"] = 1902167730,
            ["kijin"] = 2454049754
        },
        ["huntingHorn"] = {
            ["normal"] = 1731229352
        }
    }

    actionMove.dodgeLockMove = {
        ["dualBlades"] = {
            [3316282274] = true, -- vault shroud kijin
            [3783600746] = true -- vault shourld kijin_kyouka, normal
        }
    }

    actionMove.dodgeUnlockMove = {
        ["dualBlades"] = {
            [2399642468] = true,
            [3862130673] = true
        }
    }

    actionMove.getDodgeMoveFuncs = {
        ["dualBlades"] = actionMove.GetDualBladesDodgeMove
    }
end

function actionMove.GetDualBladesDodgeMove (masterPlayer)
    local normal
	local kijin
    local state
	normal = sdk.find_type_definition("snow.player.DualBlades.DualBladesState"):get_field("Normal"):get_data(nil)
	kijin = sdk.find_type_definition("snow.player.DualBlades.DualBladesState"):get_field("Kijin"):get_data(nil)
    state = masterPlayer:call("get_DBState")
	local kijinState = masterPlayer:call("isKijinKyouka")
	if kijinState then
		return actionMove.dodgeMove["dualBlades"]["kijin_kyouka"]
	elseif state == kijin then
		return actionMove.dodgeMove["dualBlades"]["kijin"]
	elseif state == normal then
		return actionMove.dodgeMove["dualBlades"]["normal"]
	else
		return actionMove.dodgeMove["dualBlades"]["normal"]
	end
end

return actionMove