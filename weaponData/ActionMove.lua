local actionMove = {}

function actionMove.init()
    actionMove.weaponType = {
        [0] = "greatSword",
        [1] = "slashAxe", -- aka switch axe
        [2] = "longSword",
        [3] = "lightBowGun",
        [4] = "heavyBowGun",
        [5] = "hammer",
        [6] = "gunLance",
        [7] = "lance",
        [8] = "shortSword", -- aka sword & shield
        [9] = "dualBlades",
        [10] = "horn", -- aka hunting horn
        [11] = "chargeAxe",
        [12] = "insectGlaive",
        [13] = "bow"
    }

    actionMove.dodgeMove = {
        ["dualBlades"] = {
            ["normal"] = 1731229352,
            ["kijin_kyouka"] = 1902167730,
            ["kijin"] = 2454049754,
            ["kijin_jyuu"] = 1540831430
        },
        ["horn"] = {
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
            [2399642468] = true,  -- vault shroud kijin, kijin_jyuu activated
            [3862130673] = true -- vault shourld kijin_kyouka, normal activated
        }
    }

    actionMove.getDodgeMoveFuncs = {
        ["dualBlades"] = actionMove.GetDualBladesDodgeMove
    }
end

function actionMove.GetDualBladesDodgeMove (masterPlayer)
    local normal
	local kijin
    local kijinJyuu
    local state
	normal = sdk.find_type_definition("snow.player.DualBlades.DualBladesState"):get_field("Normal"):get_data(nil)
	kijin = sdk.find_type_definition("snow.player.DualBlades.DualBladesState"):get_field("Kijin"):get_data(nil)
    kijinJyuu = sdk.find_type_definition("snow.player.DualBlades.DualBladesState"):get_field("Kijin_Jyuu"):get_data(nil)
    state = masterPlayer:call("get_DBState")
	local kijinState = masterPlayer:call("isKijinKyouka")
	if kijinState then
		return actionMove.dodgeMove["dualBlades"]["kijin_kyouka"]
	elseif state == kijin then
		return actionMove.dodgeMove["dualBlades"]["kijin"]
    elseif state == kijinJyuu then
		return actionMove.dodgeMove["dualBlades"]["kijin_jyuu"]
	elseif state == normal then
		return actionMove.dodgeMove["dualBlades"]["normal"]
	else
		return actionMove.dodgeMove["dualBlades"]["normal"]
	end
end

return actionMove