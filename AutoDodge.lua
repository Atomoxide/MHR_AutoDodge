local masterPlayerIndex
local masterPlayer
local nodeID
local dodgeReady = true
local jumpStateTag = sdk.find_type_definition("snow.player.ActStatus"):get_field("Jump"):get_data(nil)
local wireJumpStateTag = sdk.find_type_definition("snow.player.ActStatus"):get_field("WireJump"):get_data(nil)
local escapeStateTag = sdk.find_type_definition("snow.player.ActStatus"):get_field("Escape"):get_data(nil)
local damageStateTag = sdk.find_type_definition("snow.player.ActStatus"):get_field("Damage"):get_data(nil)
local masterPlayerBehaviorTree
local dmgOwnerType, curPlayerIndex
local dodgeAction
local dodgeLock = false
local weaponType
local dodgeActionFunc
local trackActionFunc

local actionMove = require("weaponData.ActionMove")
actionMove.init()

---- Check Player current Status
sdk.hook(sdk.find_type_definition("snow.player.PlayerMotionControl"):get_method("lateUpdate"),
function(args)
	if not masterPlayer then return end
    -- log.debug(tostring(dodgeReady))
    ---- check player status
    local isJump = masterPlayer:call("isActionStatusTag(snow.player.ActStatus)", jumpStateTag)
	local isWireJump = masterPlayer:call("isActionStatusTag(snow.player.ActStatus)", wireJumpStateTag)
	local isEscape = masterPlayer:call("isActionStatusTag(snow.player.ActStatus)", escapeStateTag)
	local isDamage = masterPlayer:call("isActionStatusTag(snow.player.ActStatus)", damageStateTag)

	---- check is weapon drawn
	local weaponOn = masterPlayer:call("isWeaponOn")

	-- check dodgeLock
	if actionMove.dodgeLockMove[weaponType][nodeID] then
		dodgeLock = true
	elseif not actionMove.dodgeKeepLockMove[weaponType][nodeID] then
		dodgeLock = false
	end
	
	if (isJump or isWireJump or isEscape or isDamage) then
		dodgeReady = false
		return
    elseif dodgeLock then
		-- log.debug("dodge locked")
        dodgeReady = false
        return
	end

	dodgeReady = true

	if (not weaponOn) and (not actionMove.weaponOffExceptions[nodeID]) then
		dodgeAction = actionMove.dodgeMove["weaponOff"]
		return
	end
    
	if trackActionFunc ~= nil then
		trackActionFunc(nodeID)
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
		
		dmgOwnerType = damageData:call("get_OwnerType")
		curPlayerIndex = manager:get_field("_PlayerIndex")
		masterPlayerIndex = masterPlayer:get_field("_PlayerIndex")
        -- log.debug("Damage detected")
	end,
    function(retval)
		local dmgFlowType = sdk.to_int64(retval)
		if curPlayerIndex == masterPlayerIndex and dmgOwnerType == 1 and dmgFlowType == 0 then
			if dodgeReady then
				masterPlayerBehaviorTree:call("setCurrentNode(System.UInt64, System.UInt32, via.behaviortree.SetNodeInfo)",dodgeAction,nil,nil)
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
end,
function(retval) return retval end
)