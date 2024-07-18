local masterPlayerIndex
local masterPlayer
local PlayerManager
local action_id
local last_id
local userArmature
local nodeID, last_nodeID

-- sdk.hook(sdk.find_type_definition("snow.player.PlayerMotionControl"):get_method("lateUpdate"),
-- function(args)
-- 	local motionControl = sdk.to_managed_object(args[2])
-- 	local refPlayerBase = motionControl:get_field("_RefPlayerBase")
-- 	local curPlayerIndex = refPlayerBase:get_field("_PlayerIndex")
	
-- 	if curPlayerIndex == masterPlayerIndex then
-- 		action_id = motionControl:get_field("_OldMotionID")
-- 		-- action_bank_id = motionControl:get_field("_OldBankID")
-- 	end
-- 	if action_id ~= last_id then
--         log.debug("action" .. tostring(action_id))
--         last_id = action_id
--     end
	
-- 	if nodeID ~= last_nodeID then
-- 		log.debug("node: " .. tostring(nodeID))
-- 		last_nodeID = nodeID
-- 	end
	
-- end,
-- function(retval) end
-- )

---- Check Player current Status

sdk.hook(sdk.find_type_definition("snow.player.PlayerMotionControl"):get_method("lateUpdate"),
function(args)
	-- local dodgeTag
	-- local isDodging
	local state
	local kijinState
	-- dodgeTag = sdk.find_type_definition("snow.player.ActStatus"):get_field("ContinueAction"):get_data(nil)
	-- isDodging = masterPlayer:call("isActionStatusTag(snow.player.ActStatus)", dodgeTag)
	-- isDodging = masterPlayer:call("checkWeaponDraw(System.Boolean)", true)
	state = masterPlayer:call("get_DBState")
	kijinState = masterPlayer:call("isKijinKyouka")
	-- if isDodging then
	-- 	log.debug("in state")
	-- else
	-- 	log.debug("nope")
	-- end
	local normal
	local kijin
	normal = sdk.find_type_definition("snow.player.DualBlades.DualBladesState"):get_field("Normal"):get_data(nil)
	kijin = sdk.find_type_definition("snow.player.DualBlades.DualBladesState"):get_field("Kijin"):get_data(nil)
	if kijinStateL then
		log.debug("kijin kyouka")
	elseif state == kijin then
		log.debug("kijin")
	elseif state == normal then
		log.debug("normal")
	else
		log.debug("Unknown")
	end
	
end,
function(retval) end
)

re.on_frame(function()
	if not PlayerManager then
        PlayerManager = sdk.get_managed_singleton('snow.player.PlayerManager')
    end
	if not PlayerManager then return end
	masterPlayer = PlayerManager:call("findMasterPlayer")
    if not masterPlayer then return end
	masterPlayerIndex = masterPlayer:get_field("_PlayerIndex")
	userArmature = masterPlayer:getMotionFsm2()
	nodeID = userArmature:getCurrentNodeID(0)
	
end)