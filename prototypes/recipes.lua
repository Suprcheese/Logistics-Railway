data:extend({
{
    type = "recipe",
    name = "storage-rail",
    enabled = "false",
    ingredients =
    {
      {"rail", 1},
    },
    result = "storage-rail"
},
{
    type = "recipe",
    name = "passive-provider-rail",
    enabled = "false",
    ingredients =
    {
      {"rail", 1},
    },
    result = "passive-provider-rail"
},
{
    type = "recipe",
    name = "active-provider-rail",
    enabled = "false",
    ingredients =
    {
      {"rail", 1},
    },
    result = "active-provider-rail"
},
{
    type = "recipe",
    name = "requester-rail",
    enabled = "false",
    ingredients =
    {
      {"rail", 1},
    },
    result = "requester-rail"
},
})

if expensiveRails then
	data.raw["recipe"]["storage-rail"].ingredients[2] = {"advanced-circuit", 1}
	data.raw["recipe"]["passive-provider-rail"].ingredients[2] = {"advanced-circuit", 1}
	data.raw["recipe"]["active-provider-rail"].ingredients[2] = {"advanced-circuit", 1}
	data.raw["recipe"]["requester-rail"].ingredients[2] = {"advanced-circuit", 1}
end
