local item = table.deepcopy(data.raw["item"]["rocket-silo"])

item.name = "old-rocket-silo"
item.place_result = "old-rocket-silo"

data:extend({item})
