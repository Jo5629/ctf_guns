-- ctf_range/custom_controls.lua
--> Modified code for scopes to work.

local player_scope_huds = {}
local player_nominal_zooms = {}

local old_binoculars_update

local function scope_hud(player, change)
   local w_item = player:get_wielded_item()
   local scope_zoom = w_item:get_definition().ctf_guns_scope_zoom
   local id = player_scope_huds[player:get_player_name()]
   if change and scope_zoom then
      player:hud_change(id, "text", "rangedweapons_scopehud.png")
   else
      player:hud_change(id, "text", "rangedweapons_empty_icon.png")
   end
end

local function binoculars_override(player)
   local new_zoom_fov = 0
   local w_item = player:get_wielded_item()
   local scope_zoom = w_item:get_definition().ctf_guns_scope_zoom

   if scope_zoom == nil then
      -- No gun equipped? check for binoculars
      if old_binoculars_update ~= nil then
         old_binoculars_update(player)
      end
      return
   end

   -- Only set property if necessary to avoid player mesh reload
   if player:get_properties().zoom_fov ~= scope_zoom then
      player:set_properties({zoom_fov = scope_zoom})
      return
   end
end

minetest.register_on_mods_loaded(function()
      if minetest.get_modpath("binoculars") then
         old_binoculars_update = binoculars.update_player_property
         binoculars.update_player_property = binoculars_override
      end

      controls.register_on_press(function(player, control_name)
	    if control_name == "zoom" then
         scope_hud(player, true)
         binoculars_override(player)
	    end
      end)
      controls.register_on_release(function(player, control_name, time)
	    if control_name == "zoom" then
         scope_hud(player, false)
         binoculars_override(player)
	    end
      end)
end)

minetest.register_on_joinplayer(function(player)
      player_scope_huds[player:get_player_name()] = player:hud_add({
	    hud_elem_type = "image",
	    alignment = { x=0.0, y=0.0 },
	    position = {x = 0.5, y = 0.5},
	    scale = { x=3.2, y=3.2 },
	    text = "rangedweapons_empty_icon.png",
      })
end)