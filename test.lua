local masterPlayerIndex
local masterPlayer
local PlayerManager
local action_id
local last_id
local userArmature
local nodeID, last_nodeID
local enableDodge = false
local jumpStateTag = sdk.find_type_definition("snow.player.ActStatus"):get_field("Jump"):get_data(nil)
local wireJumpStateTag = sdk.find_type_definition("snow.player.ActStatus"):get_field("WireJump"):get_data(nil)
local escapeStateTag = sdk.find_type_definition("snow.player.ActStatus"):get_field("Escape"):get_data(nil)
local damageStateTag = sdk.find_type_definition("snow.player.ActStatus"):get_field("Damage"):get_data(nil)


sdk.hook(sdk.find_type_definition("snow.player.PlayerMotionControl"):get_method("lateUpdate"),
function(args)
	local motionControl = sdk.to_managed_object(args[2])
	local refPlayerBase = motionControl:get_field("_RefPlayerBase")
	local curPlayerIndex = refPlayerBase:get_field("_PlayerIndex")
	
	if curPlayerIndex == masterPlayerIndex then
		action_id = motionControl:get_field("_OldMotionID")
		-- action_bank_id = motionControl:get_field("_OldBankID")
	end
	if action_id ~= last_id then
        -- log.debug("action" .. tostring(action_id))
        last_id = action_id
    end
	
	if nodeID ~= last_nodeID then
		log.debug("node: " .. tostring(nodeID))
		last_nodeID = nodeID
	end
	
end,
function(retval) end
)


---- Check Player current Status
-- sdk.hook(sdk.find_type_definition("snow.player.PlayerMotionControl"):get_method("lateUpdate"),
-- function(args)
-- 	if not masterPlayer then return end

-- 	---- check is weapon drawn
-- 	local weaponOn = masterPlayer:call("isWeaponOn")
-- 	if not weaponOn then
-- 		dodgeReady = false
-- 		return
-- 	end

-- 	local isJump = masterPlayer:call("isActionStatusTag(snow.player.ActStatus)", jumpStateTag)
-- 	local isWireJump = masterPlayer:call("isActionStatusTag(snow.player.ActStatus)", wireJumpStateTag)
-- 	local isEscape = masterPlayer:call("isActionStatusTag(snow.player.ActStatus)", escapeStateTag)
-- 	local isDamage = masterPlayer:call("isActionStatusTag(snow.player.ActStatus)", damageStateTag)

-- 	if isJump or isWireJump or isEscape or isDamage then
-- 		dodgeReady = false
-- 		return
-- 	end

-- 	local stateTag
-- 	local isInState
-- 	-- local state
-- 	-- local kijinState

-- 	---- check snow.player.ActionNoAttack
-- 	-- stateTag = sdk.find_type_definition("snow.player.ActionNoAttack"):get_field("Attack000"):get_data(nil)
-- 	-- isInState = masterPlayer:call("isActionNoAttackTag(snow.player.ActionNoAttack)", stateTag)

-- 	---- check snow.player.ActStatus
-- 	stateTag = sdk.find_type_definition("snow.player.ActStatus"):get_field("WireJump"):get_data(nil)
-- 	isInState = masterPlayer:call("isActionStatusTag(snow.player.ActStatus)", stateTag)

	

-- 	-- isInState = masterPlayer:call("checkWeaponDraw(System.Boolean)", true)
-- 	-- state = masterPlayer:call("get_DBState")
-- 	-- kijinState = masterPlayer:call("isKijinKyouka")
-- 	if isInState then
-- 		log.debug("in state")
-- 	else
-- 		log.debug("nope")
-- 	end
-- 	-- local normal
-- 	-- local kijin
-- 	-- normal = sdk.find_type_definition("snow.player.DualBlades.DualBladesState"):get_field("Normal"):get_data(nil)
-- 	-- kijin = sdk.find_type_definition("snow.player.DualBlades.DualBladesState"):get_field("Kijin"):get_data(nil)
-- 	-- if kijinState then
-- 	-- 	log.debug("kijin kyouka")
-- 	-- elseif state == kijin then
-- 	-- 	log.debug("kijin")
-- 	-- elseif state == normal then
-- 	-- 	log.debug("normal")
-- 	-- else
-- 	-- 	log.debug("Unknown")
-- 	-- end
	
-- end,
-- function(retval) return retval end
-- )

---- Hook player info
local playerInputHook = playerInputHook or sdk.find_type_definition("snow.player.PlayerInput"):get_method("initCommandInfo()")
sdk.hook(playerInputHook,
function(args)
	playerManager = playerManager or sdk.get_managed_singleton("snow.player.PlayerManager")
	masterPlayer = playerManager:call("findMasterPlayer") -- snow.player.PlayerBase
	if not masterPlayer then return end
	masterPlayerIndex = masterPlayer:get_field("_PlayerIndex")
	userArmature = masterPlayer:getMotionFsm2() -- via.motion.MotionFsm2
	nodeID = userArmature:getCurrentNodeID(0) -- System.UInt64
end,
function(retval) return retval end
)

-- re.on_frame(function()
-- 	if not PlayerManager then
--         PlayerManager = sdk.get_managed_singleton('snow.player.PlayerManager')
--     end
-- 	if not PlayerManager then return end
-- 	masterPlayer = PlayerManager:call("findMasterPlayer")
--     if not masterPlayer then return end
-- 	masterPlayerIndex = masterPlayer:get_field("_PlayerIndex")
-- 	userArmature = masterPlayer:getMotionFsm2()
-- 	nodeID = userArmature:getCurrentNodeID(0)
	
-- end)