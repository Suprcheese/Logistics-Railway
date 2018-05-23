data:extend({
  {
    type = "logistic-container",
    name = "storage-chest-from-wagon",
    icon = "__base__/graphics/icons/logistic-chest-storage.png",
    flags = {"placeable-neutral", "placeable-off-grid"},
    max_health = 1,
    corpse = "small-remnants",
    collision_box = {{-0.35, -0.35}, {0.35, 0.35}},
    selection_box = {{-0.2, -0.2}, {0.2, 0.2}},
	collision_mask = {"ghost-layer"},
	order = "z",
    inventory_size = 200,
    logistic_mode = "storage",
    open_sound = { filename = "__base__/sound/metallic-chest-open.ogg", volume=0.65 },
    close_sound = { filename = "__base__/sound/metallic-chest-close.ogg", volume = 0.7 },
    picture =
    {
      filename = "__Logistics Railway__/graphics/null.png",
      priority = "low",
      width = 1,
      height = 1,
      shift = {0, 0}
    },
    circuit_wire_max_distance = 0,
    icon_size = 32
  },
  {
    type = "logistic-container",
    name = "passive-provider-chest-from-wagon",
    icon = "__base__/graphics/icons/logistic-chest-passive-provider.png",
    flags = {"placeable-neutral", "placeable-off-grid"},
    max_health = 1,
    corpse = "small-remnants",
    collision_box = {{-0.35, -0.35}, {0.35, 0.35}},
    selection_box = {{-0.2, -0.2}, {0.2, 0.2}},
	collision_mask = {"ghost-layer"},
	order = "z",
    inventory_size = 200,
    logistic_mode = "passive-provider",
    open_sound = { filename = "__base__/sound/metallic-chest-open.ogg", volume=0.65 },
    close_sound = { filename = "__base__/sound/metallic-chest-close.ogg", volume = 0.7 },
    picture =
    {
      filename = "__Logistics Railway__/graphics/null.png",
      priority = "low",
      width = 1,
      height = 1,
      shift = {0, 0}
    },
    circuit_wire_max_distance = 0,
    icon_size = 32
  },
  {
    type = "logistic-container",
    name = "active-provider-chest-from-wagon",
    icon = "__base__/graphics/icons/logistic-chest-active-provider.png",
    flags = {"placeable-neutral", "placeable-off-grid"},
    max_health = 1,
    corpse = "small-remnants",
    collision_box = {{-0.35, -0.35}, {0.35, 0.35}},
    selection_box = {{-0.2, -0.2}, {0.2, 0.2}},
	collision_mask = {"ghost-layer"},
	order = "z",
    inventory_size = 200,
    logistic_mode = "active-provider",
    open_sound = { filename = "__base__/sound/metallic-chest-open.ogg", volume=0.65 },
    close_sound = { filename = "__base__/sound/metallic-chest-close.ogg", volume = 0.7 },
    picture =
    {
      filename = "__Logistics Railway__/graphics/null.png",
      priority = "low",
      width = 1,
      height = 1,
      shift = {0, 0}
    },
    circuit_wire_max_distance = 0,
    icon_size = 32
  },
  {
    type = "logistic-container",
    name = "requester-chest-from-wagon",
    icon = "__base__/graphics/icons/logistic-chest-requester.png",
    flags = {"placeable-neutral", "placeable-off-grid"},
    max_health = 1,
    logistic_slots_count = 12,
    corpse = "small-remnants",
    collision_box = {{-0.35, -0.35}, {0.35, 0.35}},
    selection_box = {{-0.2, -0.2}, {0.2, 0.2}},
	collision_mask = {"ghost-layer"},
	order = "z",
    inventory_size = 200,
    logistic_mode = "requester",
    open_sound = { filename = "__base__/sound/metallic-chest-open.ogg", volume=0.65 },
    close_sound = { filename = "__base__/sound/metallic-chest-close.ogg", volume = 0.7 },
    picture =
    {
      filename = "__Logistics Railway__/graphics/null.png",
      priority = "low",
      width = 1,
      height = 1,
      shift = {0, 0}
    },
    circuit_wire_max_distance = 0,
    icon_size = 32
  },
  {
    type = "logistic-container",
    name = "requester-rail-dummy-chest",
    icon = "__base__/graphics/icons/logistic-chest-requester.png",
    flags = {"placeable-neutral", "placeable-off-grid"},
	minable = {hardness = 0.2, mining_time = 0.5, result = "rail"},
    max_health = 1,
    corpse = "small-remnants",
    collision_box = {{-0.99999, -0.99999}, {0.99999, 0.99999}},
    selection_box = {{-1.25, -1.25}, {1.25, 1.25}},
	collision_mask = {"not-colliding-with-itself"},
	order = "z",
    inventory_size = 1,
    logistic_slots_count = 12,
    logistic_mode = "requester",
    picture =
    {
      filename = "__Logistics Railway__/graphics/null.png",
      priority = "low",
      width = 1,
      height = 1,
      shift = {0, 0}
    },
    circuit_wire_max_distance = 0,
    icon_size = 32
  },
})

if expensiveRails then
	data.raw["logistic-container"]["requester-rail-dummy-chest"].minable.result = "requester-rail"
end
