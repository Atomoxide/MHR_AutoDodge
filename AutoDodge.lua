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
local counterCallbackFunc
AttackStateTag = sdk.find_type_definition("snow.player.ActStatus"):get_field("Attack"):get_data(nil)

local actionMove = require("weaponData.ActionMove")
actionMove.init()

---- config

DodgeConfig = {
	enabled = true, -- general
	rollDodge = true, 
	weaponOffDodge = true,
	shroudedVault = true, -- DB
	adamantChargedSlash = true, -- GS
	tackle = true, -- GS
	wyvernCounter = true, -- LBG
	counterShot = true, -- HBG
	counterCharge = true, -- HBG
	foresight = true, -- LS
	iaiRelease = true, -- LS
	serenePose = true, -- LS
	spiritBlade = true, -- LS
	counterPeakPerforamce = true, -- CB
	autoGuardPoints = true, -- CB
	windmill = true, -- SS
	shoryugeki = true, -- SS
	guardSlash = true, -- SS
	guardEdge = true, -- GL
	instaGuard = true, -- LA
	spiralThrust = true, -- LA
	anchorRage = true, -- LA
	dodgeBolt = true, -- BW
}

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
			DodgeConfig.adamantChargedSlash = file.adamantChargedSlash
			DodgeConfig.tackle = file.tackle
			DodgeConfig.wyvernCounter = file.wyvernCounter
			DodgeConfig.counterShot = file.counterShot
			DodgeConfig.counterCharge = file.counterCharge
			DodgeConfig.foresight = file.foresight
			DodgeConfig.iaiRelease = file.iaiRelease
			DodgeConfig.serenePose = file.serenePose
			DodgeConfig.spiritBlade = file.spiritBlade
			DodgeConfig.counterPeakPerforamce = file.counterPeakPerforamce
			DodgeConfig.autoGuardPoints = file.autoGuardPoints
			DodgeConfig.windmill = file.windmill
			DodgeConfig.shoryugeki = file.shoryugeki
			DodgeConfig.guardSlash = file.windmill
			DodgeConfig.guardEdge = file.guardEdge
			DodgeConfig.instaGuard = file.instaGuard
			DodgeConfig.spiralThrust = file.spiralThrust
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
		adamantChargedSlash = DodgeConfig.adamantChargedSlash,
		tackle = DodgeConfig.tackle,
		wyvernCounter = DodgeConfig.wyvernCounter,
		counterShot = DodgeConfig.counterShot,
		counterCharge = DodgeConfig.counterCharge,
		foresight = DodgeConfig.foresight,
		iaiRelease = DodgeConfig.iaiRelease,
		serenePose = DodgeConfig.serenePose,
		spiritBlade = DodgeConfig.spiritBlade,
		counterPeakPerforamce = DodgeConfig.counterPeakPerforamce,
		autoGuardPoints = DodgeConfig.autoGuardPoints,
		windmill = DodgeConfig.windmill,
		shoryugeki = DodgeConfig.shoryugeki,
		guardSlash = DodgeConfig.windmill,
		guardEdge = DodgeConfig.guardEdge,
		instaGuard = DodgeConfig.instaGuard,
		spiralThrust = DodgeConfig.spiralThrust,
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
	local weaponOn = masterPlayer:call("isWeaponOn")

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

	if (not weaponOn) and (not actionMove.weaponOffExceptions[nodeID]) then
		if DodgeConfig.weaponOffDodge then
			dodgeAction = actionMove.dodgeMove["weaponOff"]
		else
			dodgeAction = nil
		end
		return
		
	end
    
	if trackActionFunc ~= nil then
		trackActionFunc(masterPlayer, nodeID)
	end
	
	dodgeAction = dodgeActionFunc(masterPlayer)
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
		-- curPlayerIndex = manager:get_field("_PlayerIndex")
		
        -- log.debug("Damage detected")
	end,
    function(retval)
		local isHit = sdk.to_int64(retval) == 0
		if masterPlayerDamage and isFromEnemy and isHit then
			if dodgeReady and (dodgeAction ~= nil) then
				masterPlayerBehaviorTree:call("setCurrentNode(System.UInt64, System.UInt32, via.behaviortree.SetNodeInfo)",dodgeAction,nil,nil)
				if counterCallbackFunc ~= nil then
					counterCallbackFunc(masterPlayerBehaviorTree)
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
end,
function(retval) return retval end
)

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
		changed, DodgeConfig.adamantChargedSlash = imgui.checkbox("Auto-casting Adamant Charged Slash", DodgeConfig.adamantChargedSlash)
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
		imgui.spacing()
		changed, DodgeConfig.spiritBlade = imgui.checkbox("Auto-casting Spirit Blade", DodgeConfig.spiritBlade)
        imgui.unindent(25)
		imgui.spacing()

		imgui.text("Dual Blades:")
		imgui.spacing()
		imgui.indent(25)
        changed, DodgeConfig.shroudedVault = imgui.checkbox("Auto-casting Shrouded Vault", DodgeConfig.shroudedVault)
        imgui.unindent(25)
		imgui.spacing()

		imgui.text("Light Bowgun:")
		imgui.spacing()
		imgui.indent(25)
        changed, DodgeConfig.wyvernCounter = imgui.checkbox("Auto-casting Wyvern Counter", DodgeConfig.wyvernCounter)
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

		imgui.text("Sword & Shield:")
		imgui.spacing()
		imgui.indent(25)
        changed, DodgeConfig.windmill = imgui.checkbox("Auto-casting Windmill to counter damage", DodgeConfig.windmill)
		imgui.spacing()
		changed, DodgeConfig.shoryugeki = imgui.checkbox("Auto-casting Shoryugeki (uppercut) to counter damage", DodgeConfig.shoryugeki)
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
        if changed then SaveAutoDodgeConfig() end
    
        imgui.spacing()
        imgui.spacing()
        imgui.pop_style_var(2)
        imgui.end_window()
    elseif alreadyOpen then
        alreadyOpen = false
        SaveAutoDodgeConfig()
    end
end)