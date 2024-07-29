local actionMove = {}

function actionMove.init()
    GuardStateTag = sdk.find_type_definition("snow.player.ActStatus"):get_field("Guard"):get_data(nil)
    LongSwordMaxSpirit = sdk.find_type_definition("snow.player.LongSword.LongSwordKijin"):get_field("LvMax"):get_data(nil)
    DualBladeNormal = sdk.find_type_definition("snow.player.DualBlades.DualBladesState"):get_field("Normal"):get_data(nil)
	DualBladeKijin = sdk.find_type_definition("snow.player.DualBlades.DualBladesState"):get_field("Kijin"):get_data(nil)
    DualBladeKijinJyuu = sdk.find_type_definition("snow.player.DualBlades.DualBladesState"):get_field("Kijin_Jyuu"):get_data(nil)
    LanceCharge = sdk.find_type_definition("snow.player.LanceTag"):get_field("Charge"):get_data(nil)
    actionMove.weaponType = {
        [0] = "greatSword",
        [1] = "slashAxe", -- aka switch axe
        [2] = "longSword",
        [3] = "lightBowgun",
        [4] = "heavyBowgun",
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
            ["iai_release"] = 662313942,
            ["foresight"] = 1265650183,
            ["serene_pose"] = 276632468,
            ["spirit_blade"] = 3756441082,
            ["up_sacred_iai"] = 3564270813,
            ["down_sacred_iai"] = 1003674723,
            ["left_scared_iai"] = 92514231,
            ["right_sacred_iai"] = 2730865880,
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
        ["heavyBowgun"] = {
            ["normal"] = 1731229352,
            ["up_escape"] = 1731229352,
            ["down_escape"] = 3999410464,
            ["left_escape"] = 1731229350,
            ["right_escape"] = 1731229351,
            ["left_step"] = 163832306,
            ["right_step"] = 893403418,
            ["counter_shot"] = 1966874939,
            ["counter_charge"] = 3013461642,
        },
        ["hammer"] = {
            ["normal"] = 1731229352,
            ["water_strike"] = 265605206,
            ["water_strike_cont"] = 1162063468,
        },
        ["shortSword"] = {
            ["normal"] = 1731229352,
            ["windmill"] = 3012216100,
            ["guard_slash"] = 1622021678,
        },
        ["insectGlaive"] = {
            ["normal"] = 1731229352
        },
        ["lightBowgun"] = {
            ["normal"] = 377966749,
            ["up_step_1"] = 1731229352,
            ["up_step_2"] = 3638676728,
            ["left_step_1"] = 1731229350,
            ["left_step_2"] = 433668853,
            ["right_step_1"] = 1731229351,
            ["right_step_2"] = 1937083628,
            ["down_step_1"] = 3999410464,
            ["down_step_2"] = 3300539662,
            ["wyvern_counter"] = 3692710800,
        },
        ["horn"] = {
            ["normal"] = 1731229352
        },
        ["slashAxe"] = {
            ["normal"] = 1731229352,
            ["sword"] = 1888074074
        },
        ["chargeAxe"] = {
            ["normal"] = 1731229352,
            ["axe"] = 3940639656,
            ["normal_counter"] = 2842504719,
            ["axe_counter"] = 1460612556,
            ["normal_morph_slash"] = 3224744091,
            ["counter_morph_slash"] = 3760447530,
        },
        ["lance"] = {
            ["normal"] = 1731229352,
            ["guard"] = 1222480601, -- for during charging
            ["insta_guard"] = 230736702,
            ["spiral_thrust"] = 2709360959,
            ["anchor_rage"] = 2613376038,
        },
        ["gunLance"] = {
            ["normal"] = 1731229352,
            ["guard_edge"] = 1320170169,
        },
        ["bow"] = {
            ["normal"] = 1731229352,
            ["up_slide"] = 1085093222,
            ["down_slide"] = 2355006144,
            ["right_slide"] = 2183383014,
            ["left_slide"] = 2475175616,
            ["up_dodgebolt"] = 3705732986,
            ["down_dodgebolt"] = 1704832922,
            ["right_dodgebolt"] = 34212903,
            ["left_dodgebolt"] = 1440439516,
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
            [276632468] = true, -- serene pose
            -- [1265650183] = true, -- foresight
            -- [511268291] = true, -- missed foresight
            [3756441082] = true, -- spirit blade
            -- [2346527105] = true, -- iai stage 1 (bell ring)
            -- [1498247531] = true, -- iai stage 2 (after ring)
        },
        ["dualBlades"] = {
            [3316282274] = true, -- vault shroud kijin
            [3783600746] = true -- vault shourld kijin_kyouka, normal
        },
        ["horn"] = {},
        ["heavyBowgun"] = {
            [1966874939] = true, -- counter shot
            [3013461642] = true, -- counter charge
        },
        ["lightBowgun"] = {
            -- [2701919729] = true, -- reload: fastest
            -- [990782832] = true,
            -- [2317440563] = true, -- reload: fast
            -- [929939138] = true, 
            -- [2317440567] = true, -- reload: slow
        },
        ["hammer"] = {
            [265605206] = true, -- water_strike
        },
        ["shortSword"] = {
            [3012216100] = true, -- windmill
            [2477991369] = true, -- Metsu Shoryugeki
            [1622021678] = true, -- guard slash
        },
        ["insectGlaive"] = {},
        ["slashAxe"] = {
            [2777648365] = true, -- Compressed Finishing Discharge
            [2872321796] = true, -- Invincible Gambit
        },
        ["chargeAxe"] = {
            [2180283493] = true, -- silk normal guard
            [268149429] = true, -- silk axe guard
            [2842504719] = true, -- normal counter
            [1460612556] = true, -- axe counter
        },
        ["lance"] = {
            [2709360959] = true, -- spiral_thrust
            [2613376038] = true, -- anchor_rage
        },
        ["gunLance"] = {
            [1320170169] = true, -- guard_edge
        },
        ["bow"] = {},
    }

    actionMove.dodgeKeepLockMove = {
        ["greatSword"] = {
            [2059052316] = true, -- hunting edge continuation
            [3120743513] = true, -- hunting edge continuation
            [2542821223] = true, -- adamant_charged continuation
        },
        ["longSword"] = {
            [1261730324] = true, -- serene pose activated
            -- [49282411] = true, -- missed foresight ends
            -- [662313942] = true, -- iai
        },
        ["dualBlades"] = {
            [2399642468] = true,  -- shrouded vault kijin, kijin_jyuu activated
            [3862130673] = true -- shrouded vault kijin_kyouka, normal activated
        },
        ["horn"] = {},
        ["heavyBowgun"] = {
            [3508851309] = true, -- counter shot/charge ready
            [1922002985] = true, -- counter shot activated
            [335808431] = true, -- counter charge activated
        },
        ["lightBowgun"] = {},
        ["hammer"] = {
            [1162063468] = true, -- water_strike continuation
        },
        ["shortSword"] = {},
        ["insectGlaive"] = {},
        ["slashAxe"] = {},
        ["chargeAxe"] = {},
        ["lance"] = {},
        ["gunLance"] = {},
        ["bow"] = {},
    }

    actionMove.getDodgeMoveFuncs = {
        ["greatSword"] = actionMove.GetGreatSwordDodgeMove,
        ["longSword"] = actionMove.GetLongSwordDodgeMove,
        ["dualBlades"] = actionMove.GetDualBladesDodgeMove,
        ["horn"] = actionMove.GetGeneralDodgeMove,
        ["heavyBowgun"] = actionMove.GetHeavyBowgunDodgeMove,
        ["lightBowgun"] = actionMove.GetLightBowgunDodgeMove,
        ["hammer"] = actionMove.GetGeneralDodgeMove,
        ["shortSword"] = actionMove.GetShortSwordDodgeMove,
        ["insectGlaive"] = actionMove.GetGeneralDodgeMove,
        ["slashAxe"] = actionMove.GetSlashAxeDodgeMove,
        ["chargeAxe"] = actionMove.GetChargeAxeDodgeMove,
        ["lance"] = actionMove.GetLanceDodgeMove,
        ["gunLance"] = actionMove.GetGunlanceDodgeMove,
        ["bow"] = actionMove.GetBowDodgeMove,
    }

    actionMove.getTrackActionFuncs = {
        ["greatSword"] = actionMove.TrackGreatSwordAction,
        ["longSword"] = actionMove.TrackLongSwordAction,
        ["dualBlades"] = nil,
        ["horn"] = nil,
        ["heavyBowgun"] = actionMove.TrackHeavyBowgunAction,
        ["lightBowgun"] = actionMove.TrackLightBowgunAction,
        ["hammer"] = nil,
        ["shortSword"] = nil,
        ["insectGlaive"] = nil,
        ["slashAxe"] = nil,
        ["chargeAxe"] = nil,
        ["lance"] = nil,
        ["gunLance"] = nil,
        ["bow"] = actionMove.TrackBowAction,
    }

    actionMove.weaponOffExceptions = {
        [3550856967] = true, -- longSword iai
        [2346527105] = true, -- longSword iai
        [1498247531] = true, -- longSword iai
        [4092244120] = true, -- longSword sacred iai
        -- sacred iai dodge
        [3564270813] = true,
        [1003674723] = true,
        [92514231] = true,
        [2730865880] = true,
        [2636031599] = true, -- sacred iai idle
    }

end

---- Dodge move decision functions

function actionMove.GetGeneralDodgeMove (masterPlayer)
    return actionMove.dodgeMove[actionMove.weaponType[masterPlayer:get_field("_playerWeaponType")]]["normal"]
end

function actionMove.GetGreatSwordDodgeMove (masterPlayer)
    if masterPlayer:call("isActionStatusTag(snow.player.ActStatus)", GuardStateTag) then
        return nil
    end
    if not (InitialCharging or ContinueCharging) then
        return actionMove.dodgeMove["greatSword"]["normal"]
    end
    local replaceSkillSet = masterPlayer:get_field("_ReplaceAtkMysetHolder")
    local replaceSkillData4 = replaceSkillSet:call("getReplaceAtkTypeFromMyset", 4) -- adamant_charged
    local replaceSkillData0 = replaceSkillSet:call("getReplaceAtkTypeFromMyset", 0) -- tackle/ defensive tackle
    if (InitialCharging or ContinueCharging) and replaceSkillData4 == 1 and DodgeConfig.adamantChargedSlash then
        local wireNum = masterPlayer:getUsableHunterWireNum()
        if wireNum >= 2 then
            return actionMove.dodgeMove["greatSword"]["adamant_charged"]
        end
    end
    if not DodgeConfig.tackle then
        return nil
    elseif replaceSkillData0 == 0 then
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
    local state
    local shroudedVaultDodge = false
    if DodgeConfig.shroudedVault then
        local replaceSkillSet = masterPlayer:get_field("_ReplaceAtkMysetHolder")
        local replaceSkillData = replaceSkillSet:call("getReplaceAtkTypeFromMyset", 5)
        local wireNum = masterPlayer:getUsableHunterWireNum()
        shroudedVaultDodge = (replaceSkillData == 0) and (wireNum >= 1)
        -- log.debug(tostring(shroudedVaultDodge))
    end
	
    state = masterPlayer:call("get_DBState")
	local kijinState = masterPlayer:call("isKijinKyouka")
    if shroudedVaultDodge then
        if kijinState then
            return actionMove.dodgeMove["dualBlades"]["kijin_kyouka_vault"]
        elseif state == DualBladeKijin then
            return actionMove.dodgeMove["dualBlades"]["kijin_vault"]
        elseif state == DualBladeKijinJyuu then
            return actionMove.dodgeMove["dualBlades"]["kijin_jyuu_vault"]
        elseif state == DualBladeNormal then
            return actionMove.dodgeMove["dualBlades"]["normal_vault"]
        else
            return actionMove.dodgeMove["dualBlades"]["normal_vault"]
        end
    else
        if kijinState then
            return actionMove.dodgeMove["dualBlades"]["kijin_kyouka"]
        elseif state == DualBladeKijin then
            return actionMove.dodgeMove["dualBlades"]["kijin"]
        elseif state == DualBladeKijinJyuu then
            return actionMove.dodgeMove["dualBlades"]["kijin_jyuu"]
        elseif state == DualBladeNormal then
            return actionMove.dodgeMove["dualBlades"]["normal"]
        else
            return actionMove.dodgeMove["dualBlades"]["normal"]
        end
    end
end

function actionMove.GetLongSwordDodgeMove (masterPlayer)
    if (DodgeConfig.serenePose or DodgeConfig.spiritBlade) and not Iai then
        local replaceSkillSet = masterPlayer:get_field("_ReplaceAtkMysetHolder")
        local replaceSkillData4 = replaceSkillSet:call("getReplaceAtkTypeFromMyset", 4)
        local replaceSkillData5 = replaceSkillSet:call("getReplaceAtkTypeFromMyset", 5)
        local wireNum = masterPlayer:getUsableHunterWireNum()
        local spiritGauge = masterPlayer:get_LongSwordGaugeLv()
        if DodgeConfig.serenePose and replaceSkillData5 == 0 and wireNum >= 2 and spiritGauge == LongSwordMaxSpirit then
            return actionMove.dodgeMove["longSword"]["serene_pose"]
        elseif DodgeConfig.spiritBlade and replaceSkillData4 == 1 and wireNum >= 1 then
            return actionMove.dodgeMove["longSword"]["spirit_blade"]
        end
    end
    if Iai and DodgeConfig.iaiRelease then
        return actionMove.dodgeMove["longSword"]["iai_release"]
    end
    if SacredIai then
        local dir = actionMove.GetLstickDir(masterPlayer)
        return actionMove.dodgeMove["longSword"][dir.."_sacred_iai"]
    end
    local isAttack = masterPlayer:call("isActionStatusTag(snow.player.ActStatus)", AttackStateTag)
    if isAttack then
        return actionMove.dodgeMove["longSword"]["foresight"]
    end
    return actionMove.dodgeMove["longSword"]["normal"]
    
    
end

function actionMove.GetLightBowgunDodgeMove (masterPlayer)
    local replaceSkillSet = masterPlayer:get_field("_ReplaceAtkMysetHolder")
    local replaceSkillData4 = replaceSkillSet:call("getReplaceAtkTypeFromMyset", 4)
    local wireNum = masterPlayer:getUsableHunterWireNum()
    if replaceSkillData4 == 1 and wireNum >= 1 and DodgeConfig.wyvernCounter then
        return actionMove.dodgeMove["lightBowgun"]["wyvern_counter"]
    end

	-- local shot = sdk.find_type_definition("snow.player.LightBowgunTag"):get_field("Shot"):get_data(nil)
    local aiming = sdk.find_type_definition("snow.player.LightBowgunTag"):get_field("AimCamera"):get_data(nil)
    local isAiming = masterPlayer:call("isLightBowgunTag", aiming)
    -- local shotState = masterPlayer:call("isLightBowgunTag", shot)
    if not ShotState or not isAiming then
        return actionMove.dodgeMove["lightBowgun"]["normal"]
    end
    local dir = actionMove.GetLstickDir(masterPlayer)
    local key
    if dir then
        if Step1 then
            key = dir.."_step_2"
        else
            key = dir.."_step_1"
        end
    else
        if Step1 then
            key = "up_step_2"
        else
            key = "up_step_1"
        end
    end
    return actionMove.dodgeMove["lightBowgun"][key]
end

function actionMove.GetHeavyBowgunDodgeMove (masterPlayer)
    local replaceSkillSet = masterPlayer:get_field("_ReplaceAtkMysetHolder")
    local replaceSkillData4 = replaceSkillSet:call("getReplaceAtkTypeFromMyset", 4)
    local replaceSkillData1 = replaceSkillSet:call("getReplaceAtkTypeFromMyset", 1)
    local wireNum = masterPlayer:getUsableHunterWireNum()
    if replaceSkillData4 == 0 and replaceSkillData1 == 0 and wireNum >= 2 and DodgeConfig.counterShot then
        return actionMove.dodgeMove["heavyBowgun"]["counter_shot"]
    end

    if replaceSkillData1 == 1 and replaceSkillData4 == 0 and wireNum >= 1 and DodgeConfig.counterCharge then
        return actionMove.dodgeMove["heavyBowgun"]["counter_charge"]
    end
    if not HeavyBowgunAiming then
        -- log.debug("direct dodge")
        return actionMove.dodgeMove["heavyBowgun"]["normal"]
    else
        local dir = actionMove.GetLstickDir(masterPlayer)
        if (not ShotState) or (dir == "up") or (dir == "down") then
            -- log.debug("escape")
            return actionMove.dodgeMove["heavyBowgun"][dir.."_escape"]
        else
            -- log.debug("step")
            return actionMove.dodgeMove["heavyBowgun"][dir.."_step"]
        end
    end
end

function actionMove.GetBowDodgeMove (masterPlayer)
    local replaceSkillSet = masterPlayer:get_field("_ReplaceAtkMysetHolder")
    local replaceSkillData1 = replaceSkillSet:call("getReplaceAtkTypeFromMyset", 1)
    local dir = actionMove.GetLstickDir(masterPlayer)
    if BowAiming then
        -- log.debug("aiming mode")
        if replaceSkillData1 == 0 then
            return actionMove.dodgeMove["bow"][dir.."_slide"]
        else
            return actionMove.dodgeMove["bow"][dir.."_dodgebolt"]
        end
    end
    local isAttack = masterPlayer:call("isActionStatusTag(snow.player.ActStatus)", AttackStateTag)
    if isAttack then
        -- log.debug("attacking")
        if replaceSkillData1 == 0 then
            return actionMove.dodgeMove["bow"][dir.."_slide"]
        else
            return actionMove.dodgeMove["bow"][dir.."_dodgebolt"]
        end
    end
    -- log.debug("normal")
    return actionMove.dodgeMove["bow"]["normal"]
end

function actionMove.GetSlashAxeDodgeMove (masterPlayer)
    local sword
    local state
    sword = sdk.find_type_definition("snow.player.SlashAxe.WeaponMode"):get_field("Sword"):get_data(nil)
    state = masterPlayer:call("get_Mode")
    if state == sword then
        return actionMove.dodgeMove["slashAxe"]["sword"]
    else
        return actionMove.dodgeMove["slashAxe"]["normal"]
    end
end

function actionMove.GetChargeAxeDodgeMove (masterPlayer)
    if masterPlayer:get_field("_GuardPoint") then
        return nil
    end
    local axe
    local state
    local wireNum = masterPlayer:getUsableHunterWireNum()
    local isGuard = masterPlayer:call("isActionStatusTag(snow.player.ActStatus)", GuardStateTag)
    local replaceSkillSet = masterPlayer:get_field("_ReplaceAtkMysetHolder")
    local counterEquipped = replaceSkillSet:call("getReplaceAtkTypeFromMyset", 4) == 0 
            and replaceSkillSet:call("getReplaceAtkTypeFromMyset", 2) == 0 
            and wireNum >= 1
            and DodgeConfig.counterPeakPerforamce
    local counterMorphEquipped = replaceSkillSet:call("getReplaceAtkTypeFromMyset", 1) == 1
	axe = sdk.find_type_definition("snow.player.ChargeAxe.WeaponMode"):get_field("Axe"):get_data(nil)
    state = masterPlayer:call("get_Mode")
    if isGuard and not DodgeConfig.autoGuardPoints then
        return nil
    end
    if isGuard  then
        if counterMorphEquipped then 
            return actionMove.dodgeMove["chargeAxe"]["counter_morph_slash"]
        end
        return actionMove.dodgeMove["chargeAxe"]["normal_morph_slash"]
    end
    if state == axe then
        if counterEquipped then
            return actionMove.dodgeMove["chargeAxe"]["axe_counter"]
        end
        return actionMove.dodgeMove["chargeAxe"]["axe"]
    else
        if counterEquipped then
            return actionMove.dodgeMove["chargeAxe"]["normal_counter"]
        end
        return actionMove.dodgeMove["chargeAxe"]["normal"]
    end
end

function actionMove.GetShortSwordDodgeMove (masterPlayer)
    local wireNum = masterPlayer:getUsableHunterWireNum()
    local isGuard = masterPlayer:call("isActionStatusTag(snow.player.ActStatus)", GuardStateTag)
    if isGuard and not DodgeConfig.guardSlash then
        return nil
    end
    if isGuard then
        return actionMove.dodgeMove["shortSword"]["guard_slash"]
    end
    local replaceSkillSet = masterPlayer:get_field("_ReplaceAtkMysetHolder")
    local windMillEquipped = replaceSkillSet:call("getReplaceAtkTypeFromMyset", 4) == 0 
            and replaceSkillSet:call("getReplaceAtkTypeFromMyset", 2) == 0 
            and wireNum >= 2
            and DodgeConfig.windmill
    if windMillEquipped then
        return actionMove.dodgeMove["shortSword"]["windmill"]
    end
    return actionMove.dodgeMove["shortSword"]["normal"]
end

function actionMove.GetGunlanceDodgeMove (masterPlayer)
    local wireNum = masterPlayer:getUsableHunterWireNum()
    local isGuard = masterPlayer:call("isActionStatusTag(snow.player.ActStatus)", GuardStateTag)
    if isGuard and not DodgeConfig.guardEdge then
        return nil
    end
    if isGuard then
        local replaceSkillSet = masterPlayer:get_field("_ReplaceAtkMysetHolder")
        local guardEdgeEquipped = replaceSkillSet:call("getReplaceAtkTypeFromMyset", 5) == 0 
                and wireNum >= 1
                and DodgeConfig.guardEdge
        if guardEdgeEquipped then
            return actionMove.dodgeMove["gunLance"]["guard_edge"]
        end
        return nil
    end
    return actionMove.dodgeMove["gunLance"]["normal"]

end

function actionMove.GetLanceDodgeMove (masterPlayer)
    local wireNum = masterPlayer:getUsableHunterWireNum()
    local isGuard = masterPlayer:call("isActionStatusTag(snow.player.ActStatus)", GuardStateTag)
    local replaceSkillSet = masterPlayer:get_field("_ReplaceAtkMysetHolder")
    local instaGuard = replaceSkillSet:call("getReplaceAtkTypeFromMyset", 2) == 1 and DodgeConfig.instaGuard
    local spiralThrustEquipped = replaceSkillSet:call("getReplaceAtkTypeFromMyset", 0) == 1 and DodgeConfig.spiralThrust
    local anchorRageEquipped = replaceSkillSet:call("getReplaceAtkTypeFromMyset", 0) == 0
        and replaceSkillSet:call("getReplaceAtkTypeFromMyset", 4) == 0
        and DodgeConfig.anchorRage
    if anchorRageEquipped then
        return actionMove.dodgeMove["lance"]["anchor_rage"]
    elseif spiralThrustEquipped then
        return actionMove.dodgeMove["lance"]["spiral_thrust"]
    end
    if isGuard then
        return nil
    end
    if masterPlayer:call("isLanceTag", LanceCharge) then return actionMove.dodgeMove["lance"]["guard"] end
    if instaGuard then return actionMove.dodgeMove["lance"]["insta_guard"] end
    return actionMove.dodgeMove["lance"]["normal"]
end

------- Glitched, do not use-----------------
-- function actionMove.GetHammerDodgeMove (masterPlayer)
--     local replaceSkillSet = masterPlayer:get_field("_ReplaceAtkMysetHolder")
--     local waterStrikeEquipped = replaceSkillSet:call("getReplaceAtkTypeFromMyset", 0) == 1 
--     if waterStrikeEquipped then
--         return WaterStrike
--     end
--     return actionMove.dodgeMove["hammer"]["normal"]
-- end


---- Player action tracking functions

function actionMove.TrackGreatSwordAction (masterPlayer, nodeID)
    InitialCharging = (nodeID == 2881805981)
    ContinueCharging = (nodeID == 2575542394) or (nodeID == 2408103841) or (nodeID == 1051964360)
end

function actionMove.TrackLongSwordAction (masterPlayer, nodeID)
    Iai = (nodeID == 2346527105) or (nodeID == 1498247531)
    if (nodeID == 4092244120) then
        SacredIai = true
    elseif actionMove.weaponOffExceptions[nodeID] == nil then
        SacredIai = false
    end
    -- log.debug(tostring(SacredIai))
end

function actionMove.TrackLightBowgunAction (masterPlayer, nodeID)
    Step1 = (nodeID == 1731229352) or (nodeID == 1731229350) or (nodeID == 1731229351) or (nodeID == 3999410464)
    local shot = sdk.find_type_definition("snow.player.LightBowgunTag"):get_field("Shot"):get_data(nil)
    ShotState = ShotState or masterPlayer:call("isLightBowgunTag", shot)
    if nodeID == 2926577812 or nodeID == 280999592 then
        ShotState = false
    end
    -- log.debug(tostring(ShotState))
end

function actionMove.TrackHeavyBowgunAction (masterPlayer, nodeID)
    -- log.debug(tostring(HeavyBowgunAiming))
    -- log.debug(tostring(nodeID))
    if nodeID == 3346707463 or nodeID == 2719596258 then
        -- log.debug("set true")
        HeavyBowgunAiming = true
    elseif nodeID == 4097256303 then
        -- log.debug("set false")
        HeavyBowgunAiming = false
    end
    
    local shot = sdk.find_type_definition("snow.player.HeavyBowgunTag"):get_field("Charge"):get_data(nil)
    ShotState = ShotState or masterPlayer:call("isHeavyBowgunTag", shot)
    if nodeID == 3346707463 or nodeID == 2719596258 then
        ShotState = false
    end
    
end

function actionMove.TrackBowAction (masterPlayer, nodeID)
    if nodeID == 2324425078 or nodeID == 2324425079 or nodeID == 4102615523 or nodeID == 2451015056 then
        BowAiming = true
    elseif nodeID == 3738870336 or nodeID ==  1564395738 then
        BowAiming = false
    end
end

-- function actionMove.TrackHammerAction (masterPlayer, nodeID)
--     if WaterStrike == nil then
--         WaterStrike = actionMove.dodgeMove["hammer"]["water_strike"]
--     end
--     if nodeID == actionMove.dodgeMove["hammer"]["water_strike"] then
--         WaterStrike = actionMove.dodgeMove["hammer"]["water_strike_cont"]
--     else
--         WaterStrike = actionMove.dodgeMove["hammer"]["water_strike"]
--     end
    
-- end

---- Player L Stick Direction
function actionMove.GetLstickDir (masterPlayer)
    local userInput = masterPlayer:get_RefPlayerInput() --snow.player.PlayerInput
	local leftJoyDir = userInput:getLstickDir()
	local dir = nil
	-- Up
	if (leftJoyDir >= -0.785 and leftJoyDir <= 0.785) or (leftJoyDir == 3.5762786865234e-07) then
		dir = "up"
	-- Down
	elseif	leftJoyDir >= -3.926 and leftJoyDir <= -2.357 then
		dir = "down"
	-- Left
	elseif	(leftJoyDir >= 0.785 and leftJoyDir <= 1.571) or (leftJoyDir >= -4.9 and leftJoyDir <= -3.926) then
		dir = "left"
	-- Right
	elseif	leftJoyDir >= -2.357 and leftJoyDir <= -0.785 then
		dir = "right"
	end
	return dir
end

return actionMove