local recipe = table.deepcopy(data.raw.recipe["rocket-silo"])

recipe.name = "old-rocket-silo"
recipe.result = "old-rocket-silo"

data:extend({recipe})
