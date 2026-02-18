local SILO_NAME = "old-rocket-silo"
local SCIENCE_NAME = "space-science-pack"
local SCIENCE_AMOUNT = 1000

--------------------------------------------------
-- INIT
--------------------------------------------------

script.on_init(function()
    global.silo_science = {}
end)

script.on_configuration_changed(function()
    global.silo_science = global.silo_science or {}
end)

--------------------------------------------------
-- UTILITY
--------------------------------------------------

local function get_science(silo)
    return global.silo_science[silo.unit_number] or 0
end

local function set_science(silo, value)
    global.silo_science[silo.unit_number] = value
end

local function destroy_gui(player)
    if player.gui.screen.science_frame then
        player.gui.screen.science_frame.destroy()
    end
end

--------------------------------------------------
-- ON ROCKET LAUNCHED
--------------------------------------------------

script.on_event(defines.events.on_rocket_launched, function(event)
    local silo = event.rocket_silo
    if not (silo and silo.valid) then return end
    if silo.name ~= SILO_NAME then return end

    set_science(silo, SCIENCE_AMOUNT)
end)

--------------------------------------------------
-- BLOCK NEW LAUNCH IF SCIENCE NOT TAKEN
--------------------------------------------------

script.on_event(defines.events.on_rocket_launch_ordered, function(event)
    local silo = event.rocket_silo
    if not (silo and silo.valid) then return end
    if silo.name ~= SILO_NAME then return end

    if get_science(silo) > 0 then
        event.cancel = true

        silo.surface.create_entity{
            name = "flying-text",
            position = silo.position,
            text = "Take white science first!"
        }
    end
end)

--------------------------------------------------
-- OPEN GUI
--------------------------------------------------

script.on_event(defines.events.on_gui_opened, function(event)
    if not event.entity then return end
    if event.entity.name ~= SILO_NAME then return end

    local player = game.get_player(event.player_index)
    if not player then return end

    destroy_gui(player)

    local frame = player.gui.screen.add{
        type = "frame",
        name = "science_frame",
        caption = "White Science Output",
        direction = "vertical"
    }

    frame.auto_center = true

    local count = get_science(event.entity)

    frame.add{
        type = "sprite-button",
        name = "take_science_button",
        sprite = "item/" .. SCIENCE_NAME,
        number = count,
        style = "slot_button"
    }
end)

--------------------------------------------------
-- TAKE SCIENCE
--------------------------------------------------

script.on_event(defines.events.on_gui_click, function(event)
    if not event.element.valid then return end
    if event.element.name ~= "take_science_button" then return end

    local player = game.get_player(event.player_index)
    if not player then return end

    local silo = player.opened
    if not (silo and silo.valid and silo.name == SILO_NAME) then return end

    local count = get_science(silo)
    if count <= 0 then return end

    local inserted = player.insert{
        name = SCIENCE_NAME,
        count = count
    }

    set_science(silo, count - inserted)

    event.element.number = get_science(silo)
end)

--------------------------------------------------
-- CLEANUP IF SILO REMOVED
--------------------------------------------------

script.on_event(defines.events.on_entity_died, function(event)
    if event.entity.name ~= SILO_NAME then return end
    global.silo_science[event.entity.unit_number] = nil
end)

script.on_event(defines.events.on_player_mined_entity, function(event)
    if event.entity.name ~= SILO_NAME then return end
    global.silo_science[event.entity.unit_number] = nil
end)
