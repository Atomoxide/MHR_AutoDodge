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
        ["weaponOff"] = 1505041940,
        ["greatSword"] = {
            ["normal"] = 1731229352,
            ["adamant_charged"] = 1148884139,
            ["plain_adamant_charged"] = 3883211982,
            ["tackle"] = 877278880,
            ["defensive_tackle_1"] = 345871120,
            ["defensive_tackle_2"] = 2805658423
        },
        ["longSword"] = {
            ["normal"] = 1731229352,
            ["iai"] = 662313942
        },
        ["dualBlades"] = {
            ["normal"] = 1731229352,
            ["kijin_kyouka"] = 1902167730,
            ["kijin"] = 2454049754,
            ["kijin_jyuu"] = 1540831430,
            ["normal_vault"] = 3783600746,
            ["kijin_kyouka_vault"] = 3783600746,
            ["kijin_vault"] = 3316282274,
            ["kijin_jyuu_vault"] = 3316282274
        },
        ["horn"] = {
            ["normal"] = 1731229352
        },
        ["lightBowGun"] = {
            ["normal"] = 377966749
        }
    }

    actionMove.dodgeLockMove = {
        ["greatSword"] = {
            [877278880] = true, -- tackle
            [345871120] = true, -- defensive tackle @ charge1
            [2805658423] = true, -- defensive tackle @ charge2/3
            [2051136789] = true, -- hunting edge
            [1148884139] = true, -- adamant charge
        },
        ["longSword"] = {
            [276632468] = true, -- saya
            [1265650183] = true, -- foresight
            [511268291] = true, -- missed foresight
            -- [2346527105] = true, -- iai stage 1 (bell ring)
            -- [1498247531] = true, -- iai stage 2 (after ring)
        },
        ["dualBlades"] = {
            [3316282274] = true, -- vault shroud kijin
            [3783600746] = true -- vault shourld kijin_kyouka, normal
        },
        ["horn"] = {},
        ["lightBowGun"] = {}
    }

    actionMove.dodgeKeepLockMove = {
        ["greatSword"] = {
            [2059052316] = true, -- hunting edge continuation
            [3120743513] = true, -- hunting edge continuation
            [2542821223] = true, -- adamant_charged continuation
        },
        ["longSword"] = {
            [1261730324] = true, -- saya activated
            -- [49282411] = true, -- missed foresight ends
            -- [662313942] = true, -- iai
        },
        ["dualBlades"] = {
            [2399642468] = true,  -- tower vault kijin, kijin_jyuu activated
            [3862130673] = true -- tower vault kijin_kyouka, normal activated
        },
        ["horn"] = {},
        ["lightBowGun"] = {}
    }

    actionMove.getDodgeMoveFuncs = {
        ["greatSword"] = actionMove.GetGreatSwordDodgeMove,
        ["longSword"] = actionMove.GetLongSwordDodgeMove,
        ["dualBlades"] = actionMove.GetDualBladesDodgeMove,
        ["horn"] = actionMove.GetGeneralDodgeMove,
        ["lightBowGun"] = actionMove.GetGeneralDodgeMove
    }

    actionMove.getTrackActionFuncs = {
        ["greatSword"] = actionMove.TrackGreatSwordAction,
        ["longSword"] = actionMove.TrackLongSwordAction,
        ["dualBlades"] = nil,
        ["horn"] = nil,
        ["lightBowGun"] = nil
    }

    actionMove.weaponOffExceptions = {
        [3550856967] = true, -- longSword iai
        [2346527105] = true, -- longSword iai
        [1498247531] = true, -- longSword iai
        [4092244120] = true, -- longSword the other iai
    }

end

---- Dodge move decision functions

function actionMove.GetGeneralDodgeMove (masterPlayer)
    return actionMove.dodgeMove[actionMove.weaponType[masterPlayer:get_field("_playerWeaponType")]]["normal"]
end

function actionMove.GetGreatSwordDodgeMove (masterPlayer)
    if not (InitialCharging or ContinueCharging) then
        return actionMove.dodgeMove["greatSword"]["normal"]
    end
    local replaceSkillSet = masterPlayer:get_field("_ReplaceAtkMysetHolder")
    local replaceSkillData4 = replaceSkillSet:call("getReplaceAtkTypeFromMyset", 4) -- adamant_charged
    local replaceSkillData0 = replaceSkillSet:call("getReplaceAtkTypeFromMyset", 0) -- tackle/ defensive tackle
    if (InitialCharging or ContinueCharging) and replaceSkillData4 == 1 then
        local wireNum = masterPlayer:getUsableHunterWireNum()
        if wireNum >= 2 then
            return actionMove.dodgeMove["greatSword"]["adamant_charged"]
        end
    end
    if replaceSkillData0 == 0 then
        return actionMove.dodgeMove["greatSword"]["tackle"]
    else
        if InitialCharging then
            return actionMove.dodgeMove["greatSword"]["defensive_tackle_1"]
        else
            return actionMove.dodgeMove["greatSword"]["defensive_tackle_2"]
        end
    end
end

function actionMove.GetDualBladesDodgeMove (masterPlayer)
    local normal
	local kijin
    local kijinJyuu
    local state
    local towerVaultDodge = false
    if EnableHunterWireCounter then
        local replaceSkillSet = masterPlayer:get_field("_ReplaceAtkMysetHolder")
        local replaceSkillData = replaceSkillSet:call("getReplaceAtkTypeFromMyset", 5)
        local wireNum = masterPlayer:getUsableHunterWireNum()
        towerVaultDodge = (replaceSkillData == 0) and (wireNum >= 1)
        -- log.debug(tostring(towerVaultDodge))
    end
	normal = sdk.find_type_definition("snow.player.DualBlades.DualBladesState"):get_field("Normal"):get_data(nil)
	kijin = sdk.find_type_definition("snow.player.DualBlades.DualBladesState"):get_field("Kijin"):get_data(nil)
    kijinJyuu = sdk.find_type_definition("snow.player.DualBlades.DualBladesState"):get_field("Kijin_Jyuu"):get_data(nil)
    state = masterPlayer:call("get_DBState")
	local kijinState = masterPlayer:call("isKijinKyouka")
    if towerVaultDodge then
        if kijinState then
            return actionMove.dodgeMove["dualBlades"]["kijin_kyouka_vault"]
        elseif state == kijin then
            return actionMove.dodgeMove["dualBlades"]["kijin_vault"]
        elseif state == kijinJyuu then
            return actionMove.dodgeMove["dualBlades"]["kijin_jyuu_vault"]
        elseif state == normal then
            return actionMove.dodgeMove["dualBlades"]["normal_vault"]
        else
            return actionMove.dodgeMove["dualBlades"]["normal_vault"]
        end
    else
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
end

function actionMove.GetLongSwordDodgeMove (masterPlayer)
    if Iai then
        return actionMove.dodgeMove["longSword"]["iai"]
    else
        return actionMove.dodgeMove["longSword"]["normal"]
    end
end



-- function actionMove.GetLightBowGunDodgeMove (masterPlayer)
--     local isStepEscape
--     isStepEscape = masterPlayer:get_field("_IsStepEscapeBuff")
--     if isStepEscape
-- end

---- Player action tracking functions

function actionMove.TrackGreatSwordAction (nodeID)
    InitialCharging = (nodeID == 2881805981)
    ContinueCharging = (nodeID == 2575542394) or (nodeID == 2408103841) or (nodeID == 1051964360)
end

function actionMove.TrackLongSwordAction (nodeID)
    Iai = (nodeID == 2346527105) or (nodeID == 1498247531)
    -- log.debug(tostring(nodeID))
end

return actionMove