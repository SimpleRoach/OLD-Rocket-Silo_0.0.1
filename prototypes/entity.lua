local silo = table.deepcopy(data.raw["rocket-silo"]["rocket-silo"])

silo.name = "old-rocket-silo"
silo.minable.result = "old-rocket-silo"

data:extend({silo})
