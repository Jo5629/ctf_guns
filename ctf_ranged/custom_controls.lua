-- ctf_range/custom_controls.lua
--> Modified code for scopes to work.

local player_scope_huds = {}
local activate_zoom = false
local old_fov = 0
local old_name = ""

local function scope_hud(player, change)
   local w_item = player:get_wielded_item()
   local gun_def = w_item:get_definition()
   old_name = w_item:get_name()
   local scope_zoom = gun_def.ctf_guns_scope_zoom
   local id = player_scope_huds[player:get_player_name()]
   if gun_def.ammo and scope_zoom == nil then
      scope_zoom = 15
   end
   if change and scope_zoom then
      player:hud_change(id, "text", "scope1.png")
      player:set_fov(scope_zoom)
   else
      player:hud_change(id, "text", "rangedweapons_empty_icon.png")
      player:set_fov(old_fov)
   end
end

minetest.register_on_mods_loaded(function()
      controls.register_on_press(function(player, control_name)
	    if control_name == "RMB" then
         if activate_zoom then
            activate_zoom = false
         else
            activate_zoom = true
         end
         scope_hud(player, activate_zoom)
	    end
       
      end)
end)

minetest.register_globalstep(function(dtime)
   for _, player in pairs(minetest.get_connected_players()) do
      local w_item = player:get_wielded_item()
      local gun_def = w_item:get_definition()
      if not gun_def.ammo or w_item:get_name() ~= old_name then
         activate_zoom = false
         scope_hud(player, activate_zoom)
      end
   end
end)

minetest.register_on_joinplayer(function(player)
   old_fov = player:get_fov()
      player_scope_huds[player:get_player_name()] = player:hud_add({
	    hud_elem_type = "image",
	    alignment = { x=0.0, y=0.0 },
	    position = {x = 0.5, y = 0.5},
	    scale = { x=2, y=2 },
	    text = "rangedweapons_empty_icon.png",
      })
end)
