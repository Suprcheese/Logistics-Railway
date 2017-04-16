require "util"
require "stdlib/entity/inventory"

local on_chest_created = nil
local on_chest_destroyed = nil

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
end)

script.on_event(defines.events.on_built_entity, function(event)
	local entity = event.created_entity
	if entity.name == "entity-ghost" then
		local ghost = entity.ghost_name
		if ghost == "requester-rail" or ghost == "passive-provider-rail" or ghost == "active-provider-rail" or ghost == "storage-rail" then
			local direction = entity.direction
			if direction == defines.direction.northeast or direction == defines.direction.southeast or direction == defines.direction.southwest or direction == defines.direction.northwest then
				entity.destroy() -- No diagonal ghosts allowed
				return
			end
			orderEntityDeconstruction(entity.surface, "requester-rail", entity.position) -- No overlapping Logistics Rails allowed
			orderEntityDeconstruction(entity.surface, "passive-provider-rail", entity.position)
			orderEntityDeconstruction(entity.surface, "active-provider-rail", entity.position)
			orderEntityDeconstruction(entity.surface, "storage-rail", entity.position)
			return
		end
	end
	local player = game.players[event.player_index]
	if entity.name == "requester-rail" or entity.name == "passive-provider-rail" or entity.name == "active-provider-rail" or entity.name == "storage-rail" then
		local direction = entity.direction
		if direction == defines.direction.northeast or direction == defines.direction.southeast or direction == defines.direction.southwest or direction == defines.direction.northwest then
			local previous_name = player.cursor_stack.name .. ""	-- All this is to disallow placement of diagonal Logistics Rails, and snap the rotation back to orthogonal if it gets stuck in diagonal
			local previous_count = player.cursor_stack.count + 0
			entity.destroy()
			player.cursor_stack.set_stack{name="straight-rail", count=1}
			player.rotate_for_build()
			player.cursor_stack.set_stack()
			player.insert{name=previous_name, count=(previous_count) + 1}
			return
		end
		removeDummy(entity.surface, "requester-rail-dummy-chest", entity.position) -- Don't want any duplicate dummy chests
		if removeDummy(entity.surface, "straight-rail", entity.position) then
			player.insert{name="straight-rail", count=1}
		end
	end
	if entity.name == "requester-rail" then
		insertDummyItem(entity.surface, "requester-rail-dummy-chest", entity.position, entity.force)
	end
end)

script.on_event(defines.events.on_robot_built_entity, function(event)
	local entity = event.created_entity
	removeDummy(entity.surface, "requester-rail-dummy-chest", entity.position) -- Don't want any duplicate dummy chests
	if entity.name == "requester-rail" or entity.name == "passive-provider-rail" or entity.name == "active-provider-rail" or entity.name == "storage-rail" then
		orderEntityDeconstruction(entity.surface, "straight-rail", entity.position) -- While vanilla Straight Rails can coexist on the same tile, Logistics Rails should not
	end
	if entity.name == "requester-rail" then
		insertDummyItem(entity.surface, "requester-rail-dummy-chest", entity.position, entity.force)
	end
end)

script.on_event(defines.events.on_preplayer_mined_item, function(event)
	local entity = event.entity
	if (entity.type == "cargo-wagon" or entity.type == "locomotive") and entity.train and entity.train.valid then
		syncChests(entity.train)
	end
	if entity.name == "requester-rail-dummy-chest" then
		removeDummy(entity.surface, "requester-rail", entity.position)
		return entity.clear_items_inside()
	end
	if entity.name == "requester-rail" then
		removeDummy(entity.surface, "requester-rail-dummy-chest", entity.position)
	end
end)

script.on_event(defines.events.on_robot_pre_mined, function(event) -- The dummy chest can't actually be robo-deconstructed, so we don't have to worry about it
	local entity = event.entity
	if entity.name == "requester-rail" then
		removeDummy(entity.surface, "requester-rail-dummy-chest", entity.position)
	end
end)

script.on_event(defines.events.on_entity_died, function(event) -- The dummy chest also can't die (indestructible), so we don't have to worry about it
	local entity = event.entity
	if (entity.type == "cargo-wagon" or entity.type == "locomotive") and entity.train and entity.train.valid then
		syncChests(entity.train) -- Clean up dummy chests if part of a train is destroyed
	end
	if entity.name == "requester-rail" then
		removeDummy(entity.surface, "requester-rail-dummy-chest", entity.position)
	end
end)

script.on_event(defines.events.on_train_changed_state, function(event)
	local train = event.train
	if train.state == defines.train_state.wait_station and train.speed == 0 then -- Trains only interact with the logistics network when they are waiting at a station in automatic mode
		placeChests(train)
	else
		syncChests(train)
	end
end)

function placeLocoChest(locomotive)
	local requester = locomotive.surface.find_entities_filtered({ name = "requester-rail", area = locomotive.bounding_box })[1]
	local created = false
	if requester then
		local chest = locomotive.surface.create_entity({name = "requester-chest-from-wagon", position = locomotive.position, force = locomotive.force})
		local chest_inventory = chest.get_inventory(defines.inventory.chest)
		local locomotive_inventory = locomotive.get_inventory(defines.inventory.fuel)
		Inventory.copy_inventory(locomotive_inventory, chest_inventory) -- Locomotive to chest
		locomotive.clear_items_inside()
		local dummy_requester = locomotive.surface.find_entities_filtered({ name = "requester-rail-dummy-chest", area = locomotive.bounding_box })[1]
		for s = 1, 10 do			-- It seems all requester chests are limited to 10 request slots
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
			local requester = wagon.surface.find_entities_filtered({ name = "requester-rail", area = wagon.bounding_box })[1]
			local passive_provider = wagon.surface.find_entities_filtered({ name = "passive-provider-rail", area = wagon.bounding_box })[1]
			local active_provider = wagon.surface.find_entities_filtered({ name = "active-provider-rail", area = wagon.bounding_box })[1]
			local storage = wagon.surface.find_entities_filtered({ name = "storage-rail", area = wagon.bounding_box })[1]
			local created = false
			if requester then
				wagon.operable = false -- Don't want any changes to the wagon's inventory while it's been copied over to the proxy chest
				local chest = wagon.surface.create_entity({name = "requester-chest-from-wagon", position = wagon.position, force = wagon.force})
				local wagon_inventory = wagon.get_inventory(defines.inventory.chest)
				local wagon_filters = {}
				local wagon_filters_count = {}
				for f = 1, #wagon_inventory do
					local _slot_filter = wagon.get_filter(f)
					if _slot_filter then
						local _slot_filter_not_listed = true
						for l = 1, #wagon_filters do
							if wagon_filters[l] == _slot_filter then
								_slot_filter_not_listed = false
								wagon_filters_count[l] = wagon_filters_count[l] + 1
							end
						end
						if _slot_filter_not_listed then
							table.insert(wagon_filters, _slot_filter)
							table.insert(wagon_filters_count, 1)
						end
					end
				end
				wagon_inventory.setbar(0)
				local chest_inventory = chest.get_inventory(defines.inventory.chest)
				local wagon_inventory = wagon.get_inventory(defines.inventory.chest)
				if #chest_inventory > #wagon_inventory then
					chest_inventory.setbar(#wagon_inventory)	-- Limit the chest inventory size to equal the wagon inventory size; proxy chest has a lot of slots to accommodate modded wagons
				end
				Inventory.copy_inventory(wagon_inventory, chest_inventory) -- Wagon to chest
				wagon.clear_items_inside()
				local dummy_requester = wagon.surface.find_entities_filtered({ name = "requester-rail-dummy-chest", area = wagon.bounding_box })[1]
				for s = 1, 10 do			-- It seems all requester chests are limited to 10 request slots
					local request = dummy_requester.get_request_slot(s)
					if request then
						if #wagon_filters == 0 then
							chest.set_request_slot(request, s)
						else
							for r = 1, #wagon_filters do
								if request.name == wagon_filters[r] then
									local request_item_amount = wagon_filters_count[r] * game.item_prototypes[request.name].stack_size
									chest.set_request_slot({name=request.name, count=request_item_amount}, s)
								end
							end
						end
					end
				end
				created = chest
			elseif passive_provider then
				wagon.operable = false -- Don't want any changes to the wagon's inventory while it's been copied over to the proxy chest
				local chest = wagon.surface.create_entity({name = "passive-provider-chest-from-wagon", position = wagon.position, force = wagon.force})
				local chest_inventory = chest.get_inventory(defines.inventory.chest)
				local wagon_inventory = wagon.get_inventory(defines.inventory.chest)
				wagon_inventory.setbar(0)
				Inventory.copy_inventory(wagon_inventory, chest_inventory) -- Wagon to chest
				wagon.clear_items_inside()
				created = chest
			elseif active_provider then
				wagon.operable = false -- Don't want any changes to the wagon's inventory while it's been copied over to the proxy chest
				local chest = wagon.surface.create_entity({name = "active-provider-chest-from-wagon", position = wagon.position, force = wagon.force})
				local chest_inventory = chest.get_inventory(defines.inventory.chest)
				local wagon_inventory = wagon.get_inventory(defines.inventory.chest)
				wagon_inventory.setbar(0)
				Inventory.copy_inventory(wagon_inventory, chest_inventory) -- Wagon to chest
				wagon.clear_items_inside()
				created = chest
			elseif storage then
				wagon.operable = false -- Don't want any changes to the wagon's inventory while it's been copied over to the proxy chest
				local chest = wagon.surface.create_entity({name = "storage-chest-from-wagon", position = wagon.position, force = wagon.force})
				local chest_inventory = chest.get_inventory(defines.inventory.chest)
				local wagon_inventory = wagon.get_inventory(defines.inventory.chest)
				wagon_inventory.setbar(0)
				local chest_inventory = chest.get_inventory(defines.inventory.chest)
				if #chest_inventory > #wagon_inventory then
					chest_inventory.setbar(#wagon_inventory) -- Limit the chest inventory size to equal the wagon inventory size; proxy chest has a lot of slots to accommodate modded wagons
				end
				Inventory.copy_inventory(wagon_inventory, chest_inventory) -- Wagon to chest
				wagon.clear_items_inside()
				created = chest
			end
			if created then
			   game.raise_event(on_chest_created, {chest=created, wagon_index=i, train=train})
			end
		end
	end
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
			game.raise_event(on_chest_destroyed, {wagon_index=i, train=train})
		end
	end
end

function prepareDeparture(wagon, chestName)
	local chest = wagon.surface.find_entity(chestName, wagon.position)
	if chest and chest.valid then
		local wagon_inventory = wagon.get_inventory(defines.inventory.chest)
		local chest_inventory = chest.get_inventory(defines.inventory.chest)
		wagon_inventory.setbar()
		Inventory.copy_inventory(chest_inventory, wagon_inventory) -- Chest to wagon
		chest.destroy()
		wagon.operable = true
	end
end

function orderEntityDeconstruction(surface, entityName, position)
	local chest = surface.find_entity(entityName, position)
	if chest and chest.valid then
		chest.order_deconstruction(chest.force)
	end
end

function insertDummyItem(surface, chestName, chestPosition, chestForce)
	local dummy = surface.create_entity({name = chestName, position = chestPosition, force = chestForce})
	dummy.insert{name="dummy-item", count=1}
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
