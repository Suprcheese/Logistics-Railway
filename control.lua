require "util"
require "stdlib/entity/inventory"

local on_chest_created = nil
local on_chest_destroyed = nil

local logiRailNames = 
{
	["requester-rail"] = true,
	["passive-provider-rail"] = true,
	["active-provider-rail"] = true,
	["storage-rail"] = true
}

local validLogiRailDirections = {}
validLogiRailDirections[defines.direction.north] = true
validLogiRailDirections[defines.direction.south] = true
validLogiRailDirections[defines.direction.east]  = true
validLogiRailDirections[defines.direction.west]  = true

function getOrLoadCreatedEvent()
	if on_chest_created == nil then
		on_chest_created = script.generate_event_name()
	end
	return on_chest_created
end

function getOrLoadDestroyedEvent()
	if on_chest_destroyed == nil then
		on_chest_destroyed = script.generate_event_name()
	end
	return on_chest_destroyed
end

function generateEvents()
	getOrLoadCreatedEvent()
	getOrLoadDestroyedEvent()
end

script.on_load(function()
	generateEvents()
end)

script.on_init(function()
	generateEvents()
	global.workRef = global.workRef or {}
	global.workParts = global.workParts or {}
	for i = 0, 59 do
		global.workParts[i] = {}
	end
end)

script.on_configuration_changed(function(data)
	global.workRef = global.workRef or {}
	global.workParts = global.workParts or {}
	for i = 0, 59 do
		global.workParts[i] = global.workParts[i] or {}
	end
end)

function addEntity(event)
	local entity = event.created_entity
	local entityName
	if entity.name == "entity-ghost" then
		entityName = entity.ghost_name
	else
		entityName = entity.name
	end
	
	--Will not allow diagonal logi rails
	if logiRailNames[entityName] and not validLogiRailDirections[entity.direction] then
		entity.destroy()
		--If the player placed this then put it back into the players inventory
		if event.player_index then
			local player = game.players[event.player_index]
			player.insert{name = player.cursor_stack.name, count = 1}
		end
	end
	
	if entity.name == "requester-rail" then
		createDummyChest(entity.surface, "requester-rail-dummy-chest", entity.position, entity.force)
	end
end

script.on_event(defines.events.on_built_entity      , addEntity)
script.on_event(defines.events.on_robot_built_entity, addEntity)

function removeEntity(event)
	local entity = event.entity
	if (entity.type == "cargo-wagon" or entity.type == "locomotive") and entity.train and entity.train.valid then
		syncChests(entity.train)
	end
	if entity.name == "requester-rail-dummy-chest" then
		removeDummy(entity.surface, "requester-rail", entity.position)
		entity.clear_items_inside()
	end
	if entity.name == "requester-rail" then
		removeDummy(entity.surface, "requester-rail-dummy-chest", entity.position)
	end
end

script.on_event(defines.events.on_pre_player_mined_item, removeEntity)
script.on_event(defines.events.on_robot_pre_mined      , removeEntity)
script.on_event(defines.events.on_entity_died          , removeEntity)

script.on_event(defines.events.on_train_changed_state, function(event)
	local train = event.train
	-- Trains only interact with the logistics network when they are waiting at a station in automatic mode
	if train.state == defines.train_state.wait_station and train.speed == 0 then
		placeChests(train)
	else
		syncChests(train)
	end
end)

function placeLocoChest(locomotive)
	local requester = locomotive.surface.find_entity("requester-rail", locomotive.position)
	local created = false
	if requester then
		local chest = locomotive.surface.create_entity({name = "requester-chest-from-wagon", position = locomotive.position, force = locomotive.force})
		local chest_inventory = chest.get_inventory(defines.inventory.chest)
		local locomotive_inventory = locomotive.get_inventory(defines.inventory.fuel)
		Inventory.copy_inventory(locomotive_inventory, chest_inventory) -- Locomotive to chest
		locomotive.clear_items_inside()
		local dummy_requester = locomotive.surface.find_entity("requester-rail-dummy-chest", locomotive.position)
		for s = 1, 12 do
			local request = dummy_requester.get_request_slot(s)
			if request then
				chest.set_request_slot(request, s)
			end
		end
		created = chest
	end
	-- if created then
	   -- game.raise_event(on_chest_created, {chest=created, wagon_index=i, train=train})
	-- end
end

function placeChests(train)
	for i = 1, #train.locomotives.front_movers do
		placeLocoChest(train.locomotives.front_movers[i])
	end
	for i = 1, #train.locomotives.back_movers do
		placeLocoChest(train.locomotives.back_movers[i])
	end
	for i = 1, #train.cargo_wagons do
		local wagon = train.cargo_wagons[i]
		if wagon.type == "cargo-wagon" then
			local area = {{wagon.position.x - 0.5, wagon.position.y - 0.5}, {wagon.position.x + 0.5, wagon.position.y + 0.5}}
			local requester        = wagon.surface.find_entities_filtered({name = "requester-rail"       , area = area})[1]
			local passive_provider = wagon.surface.find_entities_filtered({name = "passive-provider-rail", area = area})[1]
			local active_provider  = wagon.surface.find_entities_filtered({name = "active-provider-rail" , area = area})[1]
			local storage          = wagon.surface.find_entities_filtered({name = "storage-rail"         , area = area})[1]
			local created = false
			
			if requester then
				created = placeRequesterChest(wagon)
			elseif passive_provider then
				created = placeLogiRailChest(wagon, "passive-provider-chest-from-wagon")
			elseif active_provider then
				created = placeLogiRailChest(wagon, "active-provider-chest-from-wagon")
			elseif storage then
				created = placeLogiRailChest(wagon, "storage-chest-from-wagon")
			end
			
			if created then
			   script.raise_event(on_chest_created, {chest = created, wagon_index = i, train = train})
			end
		end
	end
end

function placeRequesterChest(wagon)
	local chest = placeLogiRailChest(wagon, "requester-chest-from-wagon")
	local wagon_inventory = wagon.get_inventory(defines.inventory.chest)
	local wagon_filters = {}
	for f = 1, #wagon_inventory do
		local filter = wagon.get_filter(f)
		if filter then
			wagon_filters[filter] = (wagon_filters[filter] or 0) + 1
		end
	end
	local area = {{wagon.position.x - 0.5, wagon.position.y - 0.5}, {wagon.position.x + 0.5, wagon.position.y + 0.5}}
	local dummy_requester = wagon.surface.find_entities_filtered({name = "requester-rail-dummy-chest", area = area})[1]
	for s = 1, 12 do
		local request = dummy_requester.get_request_slot(s)
		if request then
			if wagon_filters[request.name] then
				request.count = wagon_filters[request.name] * game.item_prototypes[request.name].stack_size
			end
			chest.set_request_slot(request, s)
		end
	end
end

function placeLogiRailChest(wagon, chestName)
	wagon.operable = false -- Don't want any changes to the wagon's inventory while it's copied over to the proxy chest
	local chest = wagon.surface.create_entity({name = chestName, position = wagon.position, force = wagon.force})
	local chest_inventory = chest.get_inventory(defines.inventory.chest)
	local wagon_inventory = wagon.get_inventory(defines.inventory.chest)
	--wagon_inventory.setbar(1)
	Inventory.copy_inventory(wagon_inventory, chest_inventory) -- Wagon to chest
	--wagon.clear_items_inside()
	
	if #chest_inventory > #wagon_inventory then
		-- Limit the chest inventory size to equal the wagon inventory size.
		-- Proxy chest has a lot of slots to accommodate modded wagons
		chest_inventory.setbar(#wagon_inventory)
	end
	
	addChestToWagonLink(wagon, chest_inventory, wagon_inventory)
	
	return chest
end

function addChestToWagonLink(wagon, chest_inventory, wagon_inventory)
	local tick = game.tick % 60
	global.workParts[tick][wagon.unit_number] = 
	{
		chest_inventory = chest_inventory,
		wagon_inventory = wagon_inventory
	}
	global.workRef[wagon.unit_number] = global.workParts[tick]
end

function removeChestToWagonLink(wagon)
	global.workRef[wagon.unit_number][wagon.unit_number] = nil
end

function syncLocoChest(locomotive)
	local chest = locomotive.surface.find_entity("requester-chest-from-wagon", locomotive.position)
	if chest and chest.valid then
		local locomotive_inventory = locomotive.get_inventory(defines.inventory.fuel)
		local chest_inventory = chest.get_inventory(defines.inventory.chest)
		Inventory.copy_inventory(chest_inventory, locomotive_inventory) -- Chest to locomotive
		chest.destroy()
		-- game.raise_event(on_chest_destroyed, {wagon_index=i, train=train})
	end
end

function syncChests(train)
	for i = 1, #train.locomotives.front_movers do
		syncLocoChest(train.locomotives.front_movers[i])
	end
	for i = 1, #train.locomotives.back_movers do
		syncLocoChest(train.locomotives.back_movers[i])
	end
	for i = 1, #train.cargo_wagons do
		local wagon = train.cargo_wagons[i]
		if wagon.type == "cargo-wagon" then
			prepareDeparture(wagon, "requester-chest-from-wagon")
			prepareDeparture(wagon, "passive-provider-chest-from-wagon")
			prepareDeparture(wagon, "active-provider-chest-from-wagon")
			prepareDeparture(wagon, "storage-chest-from-wagon")
			script.raise_event(on_chest_destroyed, {wagon_index = i, train = train})
		end
	end
end

function prepareDeparture(wagon, chestName)
	local chest = wagon.surface.find_entity(chestName, wagon.position)
	if chest and chest.valid then
		local wagon_inventory = wagon.get_inventory(defines.inventory.chest)
		local chest_inventory = chest.get_inventory(defines.inventory.chest)
		wagon_inventory.clear()
		Inventory.copy_inventory(chest_inventory, wagon_inventory) -- Chest to wagon
		chest.destroy()
		wagon.operable = true
		removeChestToWagonLink(wagon)
	end
end

script.on_event(defines.events.on_tick, function(event)
	local tick = game.tick % 60
	for _, workInfo in pairs(global.workParts[tick]) do
		if workInfo.chest_inventory.valid and workInfo.wagon_inventory.valid then
			workInfo.wagon_inventory.clear()
			Inventory.copy_inventory(workInfo.chest_inventory, workInfo.wagon_inventory)
		end
	end
end)

function createDummyChest(surface, chestName, chestPosition, chestForce)
	local dummy = surface.create_entity({name = chestName, position = chestPosition, force = chestForce})
	dummy.get_inventory(defines.inventory.chest).setbar(1)
end

function removeDummy(surface, dummyName, position)
	local dummy = surface.find_entity(dummyName, position)
	if dummy and dummy.valid then
		dummy.destroy()
		return true
	end
	return false
end

remote.add_interface("logistics_railway",
{
	get_chest_created_event = function()
		return getOrLoadCreatedEvent()
	end,

	get_chest_destroyed_event = function()
		return getOrLoadDestroyedEvent()
	end,
})
