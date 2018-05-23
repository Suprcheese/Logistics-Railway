data:extend({
{
	type = "item",
	name = "dummy-item",
	icon = "__Logistics Railway__/graphics/control-panel.png",
	flags = {"hidden"},
	subgroup = "transport",
	order = "z",
	stack_size = 1,
	icon_size = 32
},
{
	type = "item",
	name = "storage-rail",
	icon = "__Logistics Railway__/graphics/storage-rail.png",
	flags = {"goes-to-quickbar"},
	subgroup = "transport",
	order = "a[train-system]-b[rail-storage]",
	place_result = "storage-rail",
	stack_size = 100,
	icon_size = 32
},
{
	type = "item",
	name = "passive-provider-rail",
	icon = "__Logistics Railway__/graphics/passive-provider-rail.png",
	flags = {"goes-to-quickbar"},
	subgroup = "transport",
	order = "a[train-system]-b[rail-passive-provider]",
	place_result = "passive-provider-rail",
	stack_size = 100,
	icon_size = 32
},
{
	type = "item",
	name = "active-provider-rail",
	icon = "__Logistics Railway__/graphics/active-provider-rail.png",
	flags = {"goes-to-quickbar"},
	subgroup = "transport",
	order = "a[train-system]-b[rail-active-provider]",
	place_result = "active-provider-rail",
	stack_size = 100,
	icon_size = 32
},
{
	type = "item",
	name = "requester-rail",
	icon = "__Logistics Railway__/graphics/requester-rail.png",
	flags = {"goes-to-quickbar"},
	subgroup = "transport",
	order = "a[train-system]-b[rail-requester]",
	place_result = "requester-rail",
	stack_size = 100,
	icon_size = 32
},
})
