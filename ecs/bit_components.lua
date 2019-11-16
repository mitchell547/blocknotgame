
function Comp_Physical_Body(_x, _y, _w, _h, _vx, _vy)
	local self = {	
		name = "physical_body",
		x = _x or 0, 
		y = _y or 0,
        w = _w or 10,
        h = _h or 10,
        vx = _vx or 0,
        vy = _vy or 0,
        ax = 0,
        ay = 0,
        on_floor = false,
        prevx = _x or 0,
        prevy = _y or 0
    }
	return self
end

function Comp_Player_Controls(_left, _right, _jump)
    local self = {
        name = "player_controls",
        left = _left or "left",
        right = _right or "right",
        jump = _jump or "up",
        switch = "tab",
        switch2 = "shift",
        turnon = "x",
        speedup = "lshift",
        turned_on = false,
        active = false,
        prevx = -99,
        prevy = -99
    }
    return self
end

function Comp_Event_Change_Tile_Light(_prevx, _prevy, _x, _y)
    local self = {
        name = "event_change_tile_light",
        prevx = _prevx, -- tiles coords in map
        prevy = _prevy,
        x = _x,
        y = _y
    }
    return self
end

function Comp_Event_Inv_Tile_Activity(_x, _y)
    local self = {
        name = "event_inv_tile_activity",
        x = _x,
        y = _y
    }
    return self
end

function Comp_Event_Set_Tile_Light(_x, _y, _val)
    local self = {
        name = "event_set_tile_light",
        x = _x,
        y = _y,
        val = _val
    }
    return self
end

function Comp_Anim_Sprite(sprite_path, frame_w_, frame_h_, ox, oy)
    local self = {
        name = "animated_sprite",
        offset = {x=ox or 0, y=oy or 0},
        spr_offset = {x=ox or 0, y=oy or 0},
        sprite, -- texture
        frame_w = frame_w_,
        frame_h = frame_h_,
        frame = 1,
        revert = false,
        flip_ver = false
    }
    self.sprite = love.graphics.newImage(sprite_path) 
    self.sprite:setFilter("nearest", "nearest")
    return self
end