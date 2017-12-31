local storage_rail = util.table.deepcopy(data.raw["straight-rail"]["straight-rail"])
local passive_provider_rail = util.table.deepcopy(data.raw["straight-rail"]["straight-rail"])
local active_provider_rail = util.table.deepcopy(data.raw["straight-rail"]["straight-rail"])
local requester_rail = util.table.deepcopy(data.raw["straight-rail"]["straight-rail"])

storage_rail.name = "storage-rail"
passive_provider_rail.name = "passive-provider-rail"
active_provider_rail.name = "active-provider-rail"
requester_rail.name = "requester-rail"

storage_rail.fast_replaceable_group = "rails"
passive_provider_rail.fast_replaceable_group = "rails"
active_provider_rail.fast_replaceable_group = "rails"
requester_rail.fast_replaceable_group = "rails"

storage_rail.flags = {"placeable-neutral", "player-creation"}
passive_provider_rail.flags = {"placeable-neutral", "player-creation"}
active_provider_rail.flags = {"placeable-neutral", "player-creation"}
requester_rail.flags = {"placeable-neutral", "player-creation"}

storage_rail.collision_box = {{-0.7, -0.99999}, {0.7, 0.99999}}
passive_provider_rail.collision_box = {{-0.7, -0.99999}, {0.7, 0.99999}}
active_provider_rail.collision_box = {{-0.7, -0.99999}, {0.7, 0.99999}}
requester_rail.collision_box = {{-0.7, -0.99999}, {0.7, 0.99999}}

-- requester_rail.selection_box = {{-0.1, -0.1}, {0.1, 0.1}} -- This doesn't seem to actually work

storage_rail.pictures.straight_rail_vertical.metals.tint = { r = 1.0, g = 1.0, b = 0.0, a = 0.5 }
-- storage_rail.pictures.straight_rail_diagonal.metals.tint = { r = 1.0, g = 1.0, b = 0.0, a = 0.5 }
storage_rail.pictures.straight_rail_horizontal.metals.tint = { r = 1.0, g = 1.0, b = 0.0, a = 0.5 }
passive_provider_rail.pictures.straight_rail_vertical.metals.tint = { r = 1.0, g = 0.0, b = 0.0, a = 0.5 }
-- passive_provider_rail.pictures.straight_rail_diagonal.metals.tint = { r = 1.0, g = 0.0, b = 0.0, a = 0.5 }
passive_provider_rail.pictures.straight_rail_horizontal.metals.tint = { r = 1.0, g = 0.0, b = 0.0, a = 0.5 }
active_provider_rail.pictures.straight_rail_vertical.metals.tint = { r = 1.0, g = 0.0, b = 1.0, a = 0.5 }
-- active_provider_rail.pictures.straight_rail_diagonal.metals.tint = { r = 1.0, g = 0.0, b = 1.0, a = 0.5 }
active_provider_rail.pictures.straight_rail_horizontal.metals.tint = { r = 1.0, g = 0.0, b = 1.0, a = 0.5 }
requester_rail.pictures.straight_rail_vertical.metals.tint = { r = 0.0, g = 0.0, b = 1.0, a = 0.5 }
-- requester_rail.pictures.straight_rail_diagonal.metals.tint = { r = 0.0, g = 0.0, b = 1.0, a = 0.5 }
requester_rail.pictures.straight_rail_horizontal.metals.tint = { r = 0.0, g = 0.0, b = 1.0, a = 0.5 }

data:extend({storage_rail, passive_provider_rail, active_provider_rail, requester_rail})

if expensiveRails then
	data.raw["straight-rail"]["storage-rail"].minable.result = "storage-rail"
	data.raw["straight-rail"]["passive-provider-rail"].minable.result = "passive-provider-rail"
	data.raw["straight-rail"]["active-provider-rail"].minable.result = "active-provider-rail"
	data.raw["straight-rail"]["requester-rail"].minable.result = "requester-rail"
end
