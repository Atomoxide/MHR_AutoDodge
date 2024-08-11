local configPath = "AutoDodge.json"
local masterPlayerIndex
local masterPlayer
local nodeID
local dodgeReady = true
local jumpStateTag = sdk.find_type_definition("snow.player.ActStatus"):get_field("Jump"):get_data(nil)
local wireJumpStateTag = sdk.find_type_definition("snow.player.ActStatus"):get_field("WireJump"):get_data(nil)
local escapeStateTag = sdk.find_type_definition("snow.player.ActStatus"):get_field("Escape"):get_data(nil)
local damageStateTag = sdk.find_type_definition("snow.player.ActStatus"):get_field("Damage"):get_data(nil)
local rideStateTag = sdk.find_type_definition("snow.player.ActStatus"):get_field("Ride"):get_data(nil)
-- local guardStateTag = sdk.find_type_definition("snow.player.ActStatus"):get_field("Guard"):get_data(nil)
local masterPlayerBehaviorTree
local isFromEnemy, masterPlayerDamage
local dodgeAction
local dodgeLock = false
local weaponType
local dodgeActionFunc
local trackActionFunc
local counterCallbackFunc, counterCallbackMove, counterPreMoveFunc
local weaponOn
local callbackFlag = false
local callbackReady = false
local lockOnTargetId
local targetList = {}
AttackStateTag = sdk.find_type_definition("snow.player.ActStatus"):get_field("Attack"):get_data(nil)

local actionMove = require("weaponData.ActionMove")
actionMove.init()

---- config
local function DefaultConfig()
	return {
		enabled = true, -- general
		rollDodge = true, 
		weaponOffDodge = true,
		shroudedVault = true, -- DB
		shroudedVaultDistance = 4,
		strongArmStance = true, -- GS
		tackle = true, -- GS
		wyvernCounter = true, -- LBG
		wyvernCounterDistance = 4,
		counterShot = true, -- HBG
		counterCharge = true, -- HBG
		foresight = true, -- LS
		iaiRelease = true, -- LS
		serenePose = true, -- LS
		serenePoseDistance = 4,
		spiritBlade = true, -- LS
		spiritBladeDistance = 4,
		counterPeakPerforamce = true, -- CB
		autoGuardPoints = true, -- CB
		elementalCounter = true, -- SA
		windmill = true, -- SS
		windmillDistance = 4,
		shoryugeki = true, -- SS
		shoryugekiDistance = 3,
		guardSlash = true, -- SS
		guardEdge = true, -- GL
		instaGuard = true, -- LA
		spiralThrust = true, -- LA
		spiralThrustDistance = 7,
		anchorRage = true, -- LA
		dodgeBolt = true, -- BW
	}
end

DodgeConfig = DefaultConfig()

---- Load config file
local function LoadAutoDodgeConfig()
    if json ~= nil then
        local file = json.load_file(configPath)
        if file then
            DodgeConfig.enabled = file.enabled
			DodgeConfig.rollDodge = file.rollDodge
			DodgeConfig.weaponOffDodge = file.weaponOffDodge
            popWindow = file.popWindow
			DodgeConfig.shroudedVault = file.shroudedVault
			DodgeConfig.shroudedVaultDistance = file.shroudedVaultDistance
			DodgeConfig.strongArmStance = file.adamantChargedSlash
			DodgeConfig.tackle = file.tackle
			DodgeConfig.wyvernCounter = file.wyvernCounter
			DodgeConfig.wyvernCounterDistance = file.wyvernCounterDistance
			DodgeConfig.counterShot = file.counterShot
			DodgeConfig.counterCharge = file.counterCharge
			DodgeConfig.foresight = file.foresight
			DodgeConfig.iaiRelease = file.iaiRelease
			DodgeConfig.serenePose = file.serenePose
			DodgeConfig.serenePoseDistance = file.serenePoseDistance
			DodgeConfig.spiritBlade = file.spiritBlade
			DodgeConfig.spiritBladeDistance = file.spiritBladeDistance
			DodgeConfig.counterPeakPerforamce = file.counterPeakPerforamce
			DodgeConfig.autoGuardPoints = file.autoGuardPoints
			DodgeConfig.elementalCounter = file.elementalCounter
			DodgeConfig.windmill = file.windmill
			DodgeConfig.windmillDistance = file.windmillDistance
			DodgeConfig.shoryugeki = file.shoryugeki
			DodgeConfig.shoryugekiDistance = file.shoryugekiDistance
			DodgeConfig.guardSlash = file.guardSlash
			DodgeConfig.guardEdge = file.guardEdge
			DodgeConfig.instaGuard = file.instaGuard
			DodgeConfig.spiralThrust = file.spiralThrust
			DodgeConfig.spiralThrustDistance = file.spiralThrustDistance
			DodgeConfig.anchorRage = file.anchorRage
			DodgeConfig.dodgeBolt = file.dodgeBolt
        end
    end
end
LoadAutoDodgeConfig()

-- Save the config
local function SaveAutoDodgeConfig()
    json.dump_file(configPath, {
        enabled = DodgeConfig.enabled,
		rollDodge = DodgeConfig.rollDodge,
		weaponOffDodge = DodgeConfig.weaponOffDodge,
        shroudedVault = DodgeConfig.shroudedVault,
		shroudedVaultDistance = DodgeConfig.shroudedVaultDistance,
		adamantChargedSlash = DodgeConfig.strongArmStance,
		tackle = DodgeConfig.tackle,
		wyvernCounter = DodgeConfig.wyvernCounter,
		wyvernCounterDistance = DodgeConfig.wyvernCounterDistance,
		counterShot = DodgeConfig.counterShot,
		counterCharge = DodgeConfig.counterCharge,
		foresight = DodgeConfig.foresight,
		iaiRelease = DodgeConfig.iaiRelease,
		serenePose = DodgeConfig.serenePose,
		serenePoseDistance = DodgeConfig.serenePoseDistance,
		spiritBlade = DodgeConfig.spiritBlade,
		spiritBladeDistance = DodgeConfig.spiritBladeDistance,
		counterPeakPerforamce = DodgeConfig.counterPeakPerforamce,
		autoGuardPoints = DodgeConfig.autoGuardPoints,
		elementalCounter = DodgeConfig.elementalCounter,
		windmill = DodgeConfig.windmill,
		windmillDistance = DodgeConfig.windmillDistance,
		shoryugeki = DodgeConfig.shoryugeki,
		shoryugekiDistance = DodgeConfig.shoryugekiDistance,
		guardSlash = DodgeConfig.guardSlash,
		guardEdge = DodgeConfig.guardEdge,
		instaGuard = DodgeConfig.instaGuard,
		spiralThrust = DodgeConfig.spiralThrust,
		spiralThrustDistance = DodgeConfig.spiralThrustDistance,
		anchorRage = DodgeConfig.anchorRage,
		dodgeBolt = DodgeConfig.dodgeBolt,
    })
end

---- Check Player current Status
sdk.hook(sdk.find_type_definition("snow.player.PlayerMotionControl"):get_method("lateUpdate"),
function(args)
	if not masterPlayer then return end
	if not DodgeConfig.enabled then 
		dodgeReady = false
		return 
	end
    -- log.debug(tostring(dodgeReady))
    ---- check player status
    local isJump = masterPlayer:call("isActionStatusTag(snow.player.ActStatus)", jumpStateTag)
	local isWireJump = masterPlayer:call("isActionStatusTag(snow.player.ActStatus)", wireJumpStateTag)
	local isEscape = masterPlayer:call("isActionStatusTag(snow.player.ActStatus)", escapeStateTag)
	local isDamage = masterPlayer:call("isActionStatusTag(snow.player.ActStatus)", damageStateTag)
	local isRide = masterPlayer:call("isActionStatusTag(snow.player.ActStatus)", rideStateTag)
	-- local isGuard = masterPlayer:call("isActionStatusTag(snow.player.ActStatus)", guardStateTag)
	local dodgeDisabled = isJump or isWireJump or isEscape or isDamage or isRide
	-- log.debug(tostring(dodgeDisabled))

	---- check is weapon drawn
	weaponOn = masterPlayer:call("isWeaponOn")

	-- check dodgeLock
	if actionMove.dodgeLockMove[weaponType][nodeID] then
		dodgeLock = true
	elseif not actionMove.dodgeKeepLockMove[weaponType][nodeID] then
		dodgeLock = false
	end
	
	if dodgeDisabled then
		dodgeReady = false
		return
    elseif dodgeLock then
		-- log.debug("dodge locked")
        dodgeReady = false
        return
	end

	dodgeReady = true

	if trackActionFunc ~= nil then
		trackActionFunc(masterPlayer, nodeID)
	end
	
	-- dodgeAction = dodgeActionFunc(masterPlayer)
    -- log.debug(dodgeAction)

end,
function(retval) return retval end
)

sdk.hook(sdk.find_type_definition("snow.player.PlayerQuestBase"):get_method("checkCalcDamage_DamageSide"),
	function(args)
		local manager = sdk.to_managed_object(args[2])	
		local argManager = sdk.to_managed_object(args[3])
		local damageData = argManager:call("get_AttackData")
		masterPlayerIndex = masterPlayer:get_field("_PlayerIndex")
		masterPlayerDamage = masterPlayerIndex == manager:get_field("_PlayerIndex")

		isFromEnemy = damageData:call("get_OwnerType") == 1
		if (not weaponOn) and (not actionMove.weaponOffExceptions[nodeID]) then
			if DodgeConfig.weaponOffDodge then
				dodgeAction = actionMove.dodgeMove["weaponOff"]
			else
				dodgeAction = nil
			end
		else
			local target = targetList[lockOnTargetId]
			local distance = 999
			if target ~= nil then
				local targetPos = target:call("get_Pos")
				local playerPos = masterPlayer:call("get_GameObject"):call("get_Transform"):call("get_Position")
				distance = CalDistance(targetPos, playerPos)
			end
			-- log.debug(tostring(distance))
			dodgeAction = dodgeActionFunc(masterPlayer, distance)
		end
		
        -- log.debug("Damage detected")
	end,
    function(retval)
		local isHit = sdk.to_int64(retval) == 0
		if masterPlayerDamage and isFromEnemy and isHit then
			if dodgeReady and (dodgeAction ~= nil) then
				if counterPreMoveFunc ~= nil then
					counterPreMoveFunc(masterPlayer, dodgeAction)
				end
				masterPlayerBehaviorTree:call("setCurrentNode(System.UInt64, System.UInt32, via.behaviortree.SetNodeInfo)",dodgeAction,nil,nil)
				if counterCallbackFunc ~= nil and dodgeAction == counterCallbackMove then
					callbackFlag = true
					return sdk.to_ptr(2)
				end
				return sdk.to_ptr(1)
			else
				return retval
			end
			return retval
		end	
		return retval
	end
)

---- Hook player info
local playerInputHook = sdk.find_type_definition("snow.player.PlayerInput"):get_method("initCommandInfo()")
sdk.hook(playerInputHook,
function(args)
	local playerManager = playerManager or sdk.get_managed_singleton("snow.player.PlayerManager")
	masterPlayer = playerManager:call("findMasterPlayer") -- snow.player.PlayerBase
	if not masterPlayer then return end
	masterPlayerIndex = masterPlayer:get_field("_PlayerIndex")
	local masterPlayerArmature = masterPlayer:getMotionFsm2() -- via.motion.MotionFsm2
	nodeID = masterPlayerArmature:getCurrentNodeID(0) -- System.UInt64
    local masterPlayerGameObject = masterPlayer:call("get_GameObject") -- via.GameObject
	masterPlayerBehaviorTree = masterPlayerGameObject:call("getComponent(System.Type)",sdk.typeof("via.behaviortree.BehaviorTree"))
	weaponType = actionMove.weaponType[masterPlayer:get_field("_playerWeaponType")]
	dodgeActionFunc = actionMove.getDodgeMoveFuncs[weaponType]
	trackActionFunc = actionMove.getTrackActionFuncs[weaponType]
	counterCallbackFunc = actionMove.getCounterCallbackFuncs[weaponType]
	counterCallbackMove = actionMove.CounterCallbackMove[weaponType]
	counterPreMoveFunc = actionMove.CounterPreMoveFuncs[weaponType]
	if not GuiManager then
		GuiManager = sdk.get_managed_singleton("snow.gui.GuiManager")
	end
	if not EnemyManager then
		EnemyManager = sdk.get_managed_singleton("snow.enemy.EnemyManager")
	end
end,
function(retval) return retval end
)

---- track target enermy
re.on_frame (
	function ()
		if not GuiManager or not EnemyManager then return end
		local cameraLock = GuiManager:call("get_refGuiHud_TgCamera")
		if not cameraLock then return end
		lockOnTargetId = cameraLock:get_field("OldTargetingEmIndex")
		if lockOnTargetId < 0 then return end
		local index = 0
		for i = 0, EnemyManager:call("getBossEnemyCount") do
			local loopTarget = EnemyManager:call("getBossEnemy(System.Int32)", i)
			if loopTarget and loopTarget:call("checkDie") then
				index = index + 1
			else
				targetList[i - index] = loopTarget
			end
		end
	end
)


---- call backs

re.on_frame (
	function ()
		if callbackReady then
			callbackReady = false
			counterCallbackFunc(masterPlayerBehaviorTree)
		end

		if callbackFlag then
			callbackFlag = false
			callbackReady = true
		end

	end
)

---- Distance Calc
function CalDistance(targetPos, playerPos)
	return ((targetPos.x - playerPos.x)^2 + (targetPos.y - playerPos.y)^2)^(0.5)
end

-- REFramework UI
re.on_draw_ui(function()
    if imgui.button("Toggle Auto Dodge Config GUI") then
        popWindow = not popWindow
        SaveAutoDodgeConfig()
    end
    if popWindow then
        
        imgui.push_style_var(11, 5.0) -- Rounded elements
        imgui.push_style_var(2, 10.0) -- Window Padding

        alreadyOpen = true
        popWindow = imgui.begin_window("Auto Dodge Config", popWindow, 64)
		
		local changed = false

		imgui.text_colored("NOTE: You MUST LOCK ON YOUR TARGET (by pressing right stick or Q) to allow auto-casting the counter actions", -16776961)
		imgui.text_colored("that countains distance settings", -16776961)

		imgui.text("General:")
		imgui.spacing()
		imgui.indent(25)
        changed, DodgeConfig.enabled = imgui.checkbox("Enable AutoDodge Mod", DodgeConfig.enabled)
		imgui.spacing()
		changed, DodgeConfig.rollDodge = imgui.checkbox("Auto weapon on roll-dodging", DodgeConfig.rollDodge)
		imgui.spacing()
		changed, DodgeConfig.weaponOffDodge = imgui.checkbox("Auto weapon off roll-dodging", DodgeConfig.weaponOffDodge)
        imgui.unindent(25)
		imgui.spacing()

		imgui.text("Great Sword:")
		imgui.spacing()
		imgui.indent(25)
		changed, DodgeConfig.strongArmStance = imgui.checkbox("Auto-casting Strong Arm Stance", DodgeConfig.strongArmStance)
		imgui.spacing()
		changed, DodgeConfig.tackle = imgui.checkbox("Auto Tackle during Charging", DodgeConfig.tackle)
        imgui.unindent(25)
		imgui.spacing()

		imgui.text("Long Sword:")
		imgui.spacing()
		imgui.indent(25)
        changed, DodgeConfig.foresight = imgui.checkbox("Auto-casting Foresight Slash", DodgeConfig.foresight)
		imgui.spacing()
		changed, DodgeConfig.iaiRelease = imgui.checkbox("Auto Iai Release", DodgeConfig.iaiRelease)
		imgui.spacing()
		changed, DodgeConfig.serenePose = imgui.checkbox("Auto-casting Serene Pose (only at Max Spirit Gauge)", DodgeConfig.serenePose)
		imgui.indent(25)
		imgui.begin_disabled(not DodgeConfig.serenePose)
		imgui.text("if the player is within " )
		imgui.same_line()
		changed, DodgeConfig.serenePoseDistance = imgui.slider_float(" feet to the lock-on target (Serene Pose)", DodgeConfig.serenePoseDistance, 0, 20)
		imgui.end_disabled()
		imgui.unindent(25)
		imgui.spacing()
		changed, DodgeConfig.spiritBlade = imgui.checkbox("Auto-casting Spirit Blade", DodgeConfig.spiritBlade)
		imgui.indent(25)
		imgui.begin_disabled(not DodgeConfig.spiritBlade)
		imgui.text("if the player is within ")
		imgui.same_line()
		changed, DodgeConfig.spiritBladeDistance = imgui.slider_float(" feet to the lock-on target (Spirit Blade)", DodgeConfig.spiritBladeDistance, 0, 20)
		imgui.end_disabled()
		imgui.unindent(25)
        imgui.unindent(25)
		imgui.spacing()

		imgui.text("Dual Blades:")
		imgui.spacing()
		imgui.indent(25)
        changed, DodgeConfig.shroudedVault = imgui.checkbox("Auto-casting Shrouded Vault", DodgeConfig.shroudedVault)
		imgui.indent(25)
		imgui.begin_disabled(not DodgeConfig.shroudedVault)
		imgui.text("if the player is within ")
		imgui.same_line()
		changed, DodgeConfig.shroudedVaultDistance = imgui.slider_float(" feet to the lock-on target (Shrouded Vault)", DodgeConfig.shroudedVaultDistance, 0, 20)
		imgui.end_disabled()
		imgui.unindent(25)
        imgui.unindent(25)
		imgui.spacing()

		imgui.text("Light Bowgun:")
		imgui.spacing()
		imgui.indent(25)
        changed, DodgeConfig.wyvernCounter = imgui.checkbox("Auto-casting Wyvern Counter", DodgeConfig.wyvernCounter)
		imgui.indent(25)
		imgui.begin_disabled(not DodgeConfig.wyvernCounter)
		imgui.text("if the player is within ")
		imgui.same_line()
		changed, DodgeConfig.wyvernCounterDistance = imgui.slider_float(" feet to the lock-on target (Wyvern Counter)", DodgeConfig.wyvernCounterDistance, 0, 20)
		imgui.end_disabled()
		imgui.unindent(25)
        imgui.unindent(25)
		imgui.spacing()

		imgui.text("Heavy Bowgun:")
		imgui.spacing()
		imgui.indent(25)
        changed, DodgeConfig.counterShot = imgui.checkbox("Auto-casting Counter Shot", DodgeConfig.counterShot)
		imgui.spacing()
		changed, DodgeConfig.counterCharge = imgui.checkbox("Auto-casting Counter Charge", DodgeConfig.counterCharge)
        imgui.unindent(25)
		imgui.spacing()

		imgui.text("Charge Blade:")
		imgui.spacing()
		imgui.indent(25)
        changed, DodgeConfig.counterPeakPerforamce = imgui.checkbox("Auto-casting Counter Peak Performance", DodgeConfig.counterPeakPerforamce)
		imgui.spacing()
		changed, DodgeConfig.autoGuardPoints = imgui.checkbox("Auto morph to gain Guard Points (when player is guarding under sword mode)", DodgeConfig.autoGuardPoints)
        imgui.unindent(25)
		imgui.spacing()

		imgui.text("Switch Axe:")
		imgui.spacing()
		imgui.indent(25)
        changed, DodgeConfig.elementalCounter = imgui.checkbox("Auto Elemental Burst (with an Elemental Counter readied)", DodgeConfig.elementalCounter)
        imgui.unindent(25)
		imgui.spacing()

		imgui.text("Sword & Shield:")
		imgui.spacing()
		imgui.indent(25)
        changed, DodgeConfig.windmill = imgui.checkbox("Auto-casting Windmill to counter damage", DodgeConfig.windmill)
		imgui.indent(25)
		imgui.begin_disabled(not DodgeConfig.windmill)
		imgui.text("if the player is within ")
		imgui.same_line()
		changed, DodgeConfig.windmillDistance = imgui.slider_float(" feet to the lock-on target (Windmill)", DodgeConfig.windmillDistance, 0, 20)
		imgui.end_disabled()
		imgui.unindent(25)
		imgui.spacing()
		changed, DodgeConfig.shoryugeki = imgui.checkbox("Auto-casting Shoryugeki (uppercut) to counter damage", DodgeConfig.shoryugeki)
		imgui.indent(25)
		imgui.begin_disabled(not DodgeConfig.shoryugeki)
		imgui.text("if the player is within ")
		imgui.same_line()
		changed, DodgeConfig.shoryugekiDistance = imgui.slider_float(" feet to the lock-on target (Shoryugeki)", DodgeConfig.shoryugekiDistance, 0, 20)
		imgui.end_disabled()
		imgui.unindent(25)
		imgui.spacing()
		changed, DodgeConfig.guardSlash = imgui.checkbox("Auto-casting Guard Slash (when player is guarding)", DodgeConfig.guardSlash)
        imgui.unindent(25)
		imgui.spacing()

		imgui.text("Gunlance:")
		imgui.spacing()
		imgui.indent(25)
        changed, DodgeConfig.guardEdge = imgui.checkbox("Auto-casting Guard Edge (when player is guarding)", DodgeConfig.guardEdge)
        imgui.unindent(25)
		imgui.spacing()

		imgui.text("Lance:")
		imgui.spacing()
		imgui.indent(25)
        changed, DodgeConfig.instaGuard = imgui.checkbox("Auto Insta Guard (when player is NOT guarding)", DodgeConfig.instaGuard)
		imgui.spacing()
		changed, DodgeConfig.spiralThrust = imgui.checkbox("Auto-casting Spiral Thrust", DodgeConfig.spiralThrust)
		imgui.indent(25)
		imgui.begin_disabled(not DodgeConfig.spiralThrust)
		imgui.text("if the player is within ")
		imgui.same_line()
		changed, DodgeConfig.spiralThrustDistance = imgui.slider_float(" feet to the lock-on target (Spiral Thrust)", DodgeConfig.spiralThrustDistance, 0, 20)
		imgui.end_disabled()
		imgui.unindent(25)
		imgui.spacing()
		changed, DodgeConfig.anchorRage = imgui.checkbox("Auto-casting Anchor Rage", DodgeConfig.anchorRage)
        imgui.unindent(25)
		imgui.spacing()

		imgui.text("Bow:")
		imgui.spacing()
		imgui.indent(25)
        changed, DodgeConfig.dodgeBolt = imgui.checkbox("Auto dodging with Charging Sidestep/Dodgebolt", DodgeConfig.dodgeBolt)
        imgui.unindent(25)
		imgui.spacing()

		imgui.spacing()
        if imgui.button("Reset to Default") then 
			DodgeConfig = DefaultConfig()
			SaveAutoDodgeConfig()
		end
        if changed then 
			SaveAutoDodgeConfig()
		end
    
        imgui.spacing()
        imgui.spacing()
        imgui.pop_style_var(2)
        imgui.end_window()
    elseif alreadyOpen then
        alreadyOpen = false
        SaveAutoDodgeConfig()
    end
end)