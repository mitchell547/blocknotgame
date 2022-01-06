-- ~2 hours ...
-- +~3 hours
-- +2h

EPS = 0.000001

local scrw, scrh = 800, 600
local maxw = math.floor(scrw / TILESIZE ) +1
local maxh = math.floor(scrh / TILESIZE )  +1
--print(maxw, maxh)

function System_Physics()
	local self = System_Base()
	self.name = "physics"
	
	self.requirements = {
        "physical_body",
        "player_controls"
	}
	
	function self.update(dt)
		for i, e in pairs(self.subscribers) do
            if not e.player_controls.turned_on then
                local body = e.physical_body
                body.ay = body.ay + 9
                --body.ax = -body.vx*20
                body.ax = -body.vx*6
                body.vx, body.vy = body.vx + body.ax*dt, body.vy + body.ay*dt
                --body.x, body.y = body.x + body.vx*TILESIZE*dt, body.y + body.vy*TILESIZE*dt	-- moved to collision system
                body.ax, body.ay = 0, 0
            end
		end
	end
	
	return self
end


function System_Player_Drawing()
    local self = System_Base()
	self.name = "player_drawing"
	
	self.requirements = {
        "physical_body",
        "player_controls"
	}
    
    function self.draw()
        for i, e in pairs(self.subscribers) do
			local body = e.physical_body
            COLOR_PUSH()
            love.graphics.setColor(0.0, 0.0, 1.0, 1.0)
            local fill = 'fill'
            if e.player_controls.turned_on then fill = 'line' end
            local lw = love.graphics.getLineWidth()
            love.graphics.setLineWidth(3)
            love.graphics.rectangle(fill, body.x, body.y, body.w, body.h)
            love.graphics.setLineWidth(lw)
            
            if e.player_controls.active then
                love.graphics.setColor(1.0, 1.0, 0.2, 1.0)
                if e.player_controls.turned_on then love.graphics.setColor(1.0, 0.2, 0.2, 1.0) end
                love.graphics.rectangle('fill', body.x+body.w/2-4, body.y+body.h/4-4, 8, 8)
            end
            COLOR_POP()
        end
    end
    
    return self
end

function System_Players_Control()
    local self = System_Base()
	self.name = "physics"
	
	self.requirements = {
        "physical_body",
        "player_controls"
	}
    local active_player = 1
    local inited = false
	
    local move = 
        {['right'] = {x=1, y=0},
        ['down'] = {x=0, y=1},
        ['left'] = {x=-1, y=0},
        ['up'] = {x=0, y=0}}
        
    
    local function player_get_cell(plr)
        return math.floor(plr.x / TILESIZE + 0.5), math.floor(plr.y / TILESIZE + 0.5)
    end
    
    function self.update(dt)        
        local id = 1
        for i, e in pairs(self.subscribers) do
            local c = e.player_controls
            c.active = false
            if id == active_player then 
                c.active = true 
            end
            if id == active_player and not c.turned_on then
                --c.active = true
                local b = e.physical_body
                local plr = b
                
                local speed = 4
                
                if love.keyboard.isDown(c.speedup) then speed = speed * 2 end
                local mv = {}
                if love.keyboard.isDown(c.left) then
                    plr.vx = plr.vx-speed*8*dt
                    if plr.vx < -speed then plr.vx = -speed end
                elseif love.keyboard.isDown(c.right) then
                    plr.vx = plr.vx+speed*8*dt
                    if plr.vx > speed then plr.vx = speed end
                else
                    --plr.vx = 0
                end
                --[[for k, v in pairs(move) do
                    if love.keyboard.isDown(k) then
                        plr.x, plr.y = plr.x + v.x*TILESIZE*speed*dt, plr.y + v.y*TILESIZE*speed*dt
                    end
                end]]--
                if false and love.keyboard.isDown(c.jump) and b.on_floor then
                    --plr.vy = -400*dt
                    plr.ay = -400
                    b.on_floor = false
                    --plr.y = plr.y + plr.vy * dt
                end
                
                local xh, yh = math.floor(plr.x / TILESIZE + 0.5), math.floor(plr.y / TILESIZE + 0.5)
                if not inited then
                    --self.addComponent(i, Comp_Event_Set_Tile_Light(xh, yh, true))
                    inited = true
                end
                --self.addComponent(i, Comp_Event_Change_Tile_Light(c.prevx, c.prevy, xh, yh))
                if c.prevx ~= -99 and (xh ~= c.prevx or yh ~= c.prevy) then
                    --self.addComponent(i, Comp_Event_Change_Tile_Light(c.prevx, c.prevy, xh, yh))
                    -- a bit stupid solution, because player already has pos and prevpos
                    --set_quad_light(prevxh, prevyh, false)
                    --set_quad_light(xh, yh, true)
                end
                c.prevx, c.prevy = xh, yh
            end
            id = id + 1
        end
        
    end
    
    function self.keypressed(key)
        -- + bug when deactivating player (tile field is invisible until moving)
        
        
        local id = 1
        for i, e in pairs(self.subscribers) do
            local c = e.player_controls
            c.active = false
            if id == active_player then
                local b = e.physical_body
                local xh, yh = math.floor(b.x / TILESIZE + 0.5), math.floor(b.y / TILESIZE + 0.5) 
                --self.addComponent(i, Comp_Event_Set_Tile_Light(xh, yh, true))
                c.active = true
                if key == c.turnon then
                    self.addComponent(i, Comp_Event_Inv_Tile_Activity(xh, yh))
                    c.turned_on = not c.turned_on
                elseif key == c.switch then
                    --self.addComponent(i, Comp_Event_Set_Tile_Light(xh, yh, false))
                    active_player = active_player + 1
                    if active_player > #self.subscribers then active_player = 1 end
                elseif key == c.jump and b.on_floor then
                    --plr.vy = -400*dt
                    b.ay = -420
                    b.on_floor = false
                    --plr.y = plr.y + plr.vy * dt
                end
                break
            end
            
            id = id + 1
        end
        
        id = 1
        for i, e in pairs(self.subscribers) do
            local c = e.player_controls
            --c.active = false
            if id == active_player then
                local b = e.physical_body
                local xh, yh = math.floor(b.x / TILESIZE + 0.5), math.floor(b.y / TILESIZE + 0.5)                                    
                --self.addComponent(i, Comp_Event_Set_Tile_Light(xh, yh, true))
                break
            end
            id = id + 1
        end
    end
  
    return self
end

function System_Collisions(_map, _events)
    local self = System_Base()
	self.name = "collisions"
	
	self.requirements = {
        "physical_body",
        "player_controls"
	}
    
    local map = _map
    local obj_w, obj_h = TILESIZE, TILESIZE
    local players_in_goal = 0
    
    local event_manager = _events
    local collided = {}
    
    -- not working more
    function self.AllPlayersInGoal()
        return players_in_goal == #self.subscribers, players_in_goal
    end
    
    function self.Restart()
        for k, cols in pairs(collided) do
            for l, blk in pairs(cols) do
                cols[l] = nil
            end
        end
    end
    
    --[[function self.GetPlayersCnt()
        return #self.subscribers
    end]]--
    
    local function get_overlap(plr, obj)
        local x0, x1 = math.min(plr.x, obj.x), math.max(plr.x + plr.w, obj.x + obj_w)
        local y0, y1 = math.min(plr.y, obj.y), math.max(plr.y + plr.h, obj.y + obj_h)
        local ow, oh = math.max(0, (plr.w + obj_w) - (x1 - x0)), math.max(0, (plr.h + obj_h) - (y1 - y0))
        if plr.x > obj.x then ow = -ow end
        if plr.y > obj.y then oh = -oh end
        return ow, oh
    end
    
    local function collision_side(plr, obj, dt)
		local oldX = plr.x - plr.vx*dt
		local oldY = plr.y - plr.vy*dt
		if oldX + plr.w < obj.x and plr.x + plr.w >= obj.x then
			return "R" end
		if oldX > obj.x + obj_w and plr.x <= obj.x + obj_w then
			return "L" end
		if oldY + plr.h < obj.y and plr.y + plr.h >= obj.y then
			return "D" end
		if oldY > obj.y + obj_h and plr.y <= obj.y + obj_h then
			return "U" end
	end
    
    local function is_collided(plrid, block_ij)
        for k, v in pairs(collided[plrid]) do
            if v[1] == block_ij[1] and v[2] == block_ij[2] then
                return true
            end
        end
        return false
    end
    
    local function remove_collided(plrid, block_ij)
        for k, v in pairs(collided[plrid]) do
            if v[1] == block_ij[1] and v[2] == block_ij[2] then
                table.remove(collided[plrid], k)
                --[[collided[plrid][k] = nil
                for i = k, #(collided[plrid])-1 do
                    collided[plrid][i] = collided[plrid][i+1]
                end
                collided[plrid][#(collided[plrid])] = nil -- don't forget!!!
                return ]]
            end
        end
    end
    
	local function is_solid_block(block_obj)
		return (block_obj.t == 'ground' and block_obj.active)
	end
	
    function self.update(dt)
        players_in_goal = 0
        for id, e in pairs(self.subscribers) do
            local plr = e.physical_body
            local xh, yh = math.floor(plr.x / TILESIZE + 0.5), math.floor(plr.y / TILESIZE + 0.5)
            local goal_checked = false
            if not collided[id] then collided[id] = {} end
			
			local tmp_plr = {}
			tmp_plr.x = plr.x
			tmp_plr.y = plr.y
			tmp_plr.w = plr.w
			tmp_plr.h = plr.h
			tmp_plr.y = tmp_plr.y + plr.vy*TILESIZE*dt
			
			
			
			local y_move_acceptable = true
			local x_move_acceptable = true
			
			local min_oh = 0000
			local min_ow = 0
			
			local max_collision = {}
            
            for i = math.max(-1, xh-1), math.min(maxw, xh+1) do                
                for j = math.max(-1, yh-1), math.min(maxh, yh+2) do
                    if map[i] and map[i][j] then 
					
                        local ow, oh = get_overlap(tmp_plr, map[i][j])
						--local ow2, oh2 = get_overlap(tmp_plr_h, map[i][j])
                        
						if (is_solid_block(map[i][j])) then
							--print(ow2, oh)
							--if (math.abs(oh) > EPS) then y_move_acceptable = false end
							--if (math.abs(ow2) > EPS) then x_move_acceptable = false end
							
							--if (math.abs(oh) > math.abs(min_oh)) then min_oh = oh end
							--if (math.abs(ow2) < math.abs(min_ow)) then min_ow = ow2 end
							
							if (#max_collision == 0 and math.abs(ow) > EPS) then 
								max_collision = {ow, oh} 
							else
								if (math.abs(ow) > EPS and ow > max_collision[1]) then
									max_collision = {ow, oh}
								end
							end
						
                        
							if math.abs(ow) > math.abs(oh) and oh > 0 then 
							--if col_s == 'D' then
								vert_coll = true
								plr.on_floor = true
								plr.vy = 0
							end
							
						end
						
                        if  math.abs(oh) > EPS then
                            
                            if not is_collided(id, {i, j}) then
								print("collision1", i, j)
                                event_manager.FireEvent("OnPlayerHitBlock", nil, {player_id=id, block={i=i, j=j}})
                                table.insert(collided[id], {i, j})
                            end
                        else
                            if is_collided(id, {i, j}) then
                                event_manager.FireEvent("OnPlayerLeaveBlock", nil, {player_id=id, block={i=i, j=j}})
                                remove_collided(id, {i, j})
                            end
                        end
                        --end
                    end
                    
					
                end
            end
	
			if y_move_acceptable then 
				--print(plr.vy)
				local dy = (#max_collision > 0) and max_collision[2] or 0
				if not e.player_controls.turned_on then
					plr.y = plr.y + plr.vy*TILESIZE*dt - dy
				end
				--plr.y = plr.y + min_oh
			else
				--plr.y = plr.y + min_oh
			end
			
			local tmp_plr_h = {}
			tmp_plr_h.x = plr.x
			tmp_plr_h.y = plr.y
			tmp_plr_h.w = plr.w
			tmp_plr_h.h = plr.h
			tmp_plr_h.x = tmp_plr_h.x + plr.vx*TILESIZE*dt
			
			max_collision = {}
			
			for i = math.max(-1, xh-1), math.min(maxw, xh+1) do                
                for j = math.max(-1, yh-1), math.min(maxh, yh+2) do
                    if map[i] and map[i][j] then 
					
                        --local ow, oh = get_overlap(tmp_plr, map[i][j])
						local ow2, oh2 = get_overlap(tmp_plr_h, map[i][j])
                        
						if (is_solid_block(map[i][j])) then
							print(ow2, oh2)
							--if (math.abs(oh) > EPS) then y_move_acceptable = false end
							--if (math.abs(ow2) > EPS) then x_move_acceptable = false end
							
							--if (math.abs(oh) < math.abs(min_oh)) then min_oh = oh end
							--if (math.abs(ow2) > math.abs(min_ow)) then min_ow = ow2 end
						
							if (#max_collision == 0 and math.abs(oh2) > EPS) then 
								max_collision = {ow2, oh2} 
							else
								if (math.abs(oh2) > EPS and oh2 > max_collision[2]) then
									max_collision = {ow2, oh2}
								end
							end
							
						end
						
                        if math.abs(ow2) > EPS  then
                            
                            if not is_collided(id, {i, j}) then
								print("collision2", i, j)
                                event_manager.FireEvent("OnPlayerHitBlock", nil, {player_id=id, block={i=i, j=j}})
                                table.insert(collided[id], {i, j})
                            end
                        else
                            if is_collided(id, {i, j}) then
                                event_manager.FireEvent("OnPlayerLeaveBlock", nil, {player_id=id, block={i=i, j=j}})
                                remove_collided(id, {i, j})
                            end
                        end
                        --end
                    end
                    
					
                end
            end
			
            
			if x_move_acceptable then 
				--print("min ow", min_ow)
				local dx = (#max_collision > 0) and max_collision[1] or 0
				if not e.player_controls.turned_on then
					plr.x = plr.x + plr.vx*TILESIZE*dt - dx
				end
				--plr.x = plr.x + min_ow
			else
				--plr.x = plr.x + min_ow
			end
            
        end
    end
    
	return self
end




function System_OutOfBoundsCheck()
    local self = System_Base()
	self.name = "out_of_bounds"
	
	self.requirements = {
        "physical_body",
        "player_controls"
	}
    
    local plr_out_of_bounds = false
    
    function self.isPlayerOutOfBounds()
        return plr_out_of_bounds
    end
	
	function self.update(dt)
        plr_out_of_bounds = false
		for i, e in pairs(self.subscribers) do
            local body = e.physical_body
            if body.x < -1 * TILESIZE - body.w or body.x > maxw * TILESIZE + body.w or
                body.y < -1 * TILESIZE - body.h or body.y > maxh * TILESIZE + body.h then
                plr_out_of_bounds = true
                break
            end
		end
	end
	
	return self
end



function System_Animation_Drawing()
    local self = System_Base()
    self.name = "animation_drawing"
    
    self.requirements = {"physical_body", "animated_sprite", "player_controls"}
    
    local function drawFrame(image0, x0, y0, frame0, fw, fh, reverse_, flip_ver)
        local SCALE_X, SCALE_Y = 2, 2
		local w, h = image0:getWidth(), image0:getHeight()
		frame0 = math.floor(frame0)
		frame0 = frame0 - 1        
		local fx = frame0 * fw
		local fy = math.floor(fx /w) * fh
		fx = fx % w
		local quad = love.graphics.newQuad(fx, fy, fw, fh, w, h)
        
		if reverse_ then
			turn = -1
			x0 = x0 + fw
		else 
            turn = 1 end
        
        if flip_ver then
            flip = -1
            y0 = y0 + fh
        else 
            flip = 1 end
		love.graphics.draw(image0, quad, x0, y0, 0, turn*SCALE_X, flip*SCALE_Y)	
	end
    
    function self.update(dt)
        local ANIM_SPEED = 4
        for i, e in pairs(self.subscribers) do
            local body = e.physical_body
            local anim = e.animated_sprite
            local pctrl = e.player_controls
            if pctrl.turned_on then
                anim.frame = 2
            elseif body.on_floor then
                if math.abs(body.vx) < 0.1 then
                    anim.frame = 1
                else
                    anim.frame = anim.frame + dt*(body.vx)*ANIM_SPEED
                    if anim.frame >= 6+4 then anim.frame = 6 end
                    if anim.frame < 6 then anim.frame = 9 end
                    --print(anim.frame)
                end
            else
                if body.vy < 0 then
                    anim.frame = 5*2+1
                else
                    anim.frame = 5*2+2
                end
            end
        end
    end
    
    function self.draw()
        love.graphics.setColor(1, 1, 1, 1)
        for i, e in pairs(self.subscribers) do
            local body = e.physical_body
            local anim = e.animated_sprite   
            local pctrl = e.player_controls            
            drawFrame(anim.sprite, 
                body.x + anim.offset.x, body.y + anim.offset.y, 
                anim.frame, anim.frame_w, anim.frame_h, anim.revert, anim.flip_ver)
            if pctrl.active then
                COLOR_PUSH()
                local tt = love.timer.getTime()
                love.graphics.setColor(1.0, 1.0, 0.2, 1.0)                
                love.graphics.rectangle('fill', body.x+body.w/2-5, body.y-6+math.sin(tt*8)*1.5, 10, 4)
                COLOR_POP()
            end
        end        
    end
    
    return self
end