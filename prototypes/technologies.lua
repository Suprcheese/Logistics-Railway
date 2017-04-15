data:extend({
  {
    type = "technology",
    name = "logistics-wagons",
    icon = "__LogisticsRailway__/graphics/logistics-trains.png",
	icon_size = 128,
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "storage-rail"
      },
      {
        type = "unlock-recipe",
        recipe = "passive-provider-rail"
      },
      {
        type = "unlock-recipe",
        recipe = "active-provider-rail"
      },
      {
        type = "unlock-recipe",
        recipe = "requester-rail"
      },
    },
    prerequisites = {"logistic-system", "automated-rail-transportation"},
    unit = {
      count = 150,
      ingredients = {
        {"science-pack-1", 1},
        {"science-pack-2", 1},
		{"science-pack-3", 1}
      },
      time = 30
    },
    order = "c-g-w",
  },
})
