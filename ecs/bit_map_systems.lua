
local scrw, scrh = 800, 600
local TILESIZE_OLD = 32
local maxw = math.floor(scrw / TILESIZE_OLD ) +1
local maxh = math.floor(scrh / TILESIZE_OLD )  +1

-- BUG!!!
-- when load level with 3 robots, and the try to load level with 2 robots, there is still 3 robots on level

-- Block types:
-- 'ground' - general block (active = solid, not active = air)
-- 'empty' - air block (used only in map format)
-- 'goal' - finish zone of level
-- 'spawnN' - spawn cell of character

function System_Map()
	local self = System_Base()
	self.name = "map_system"
	
	self.requirements = {
        "nonexistent_map_comp"
	}
    
    local map = {}
    local players_init = {}
    
    self.finished = false
    
    function self.GetMap()
        return map
    end
    
    function self.GetPlayersCnt()
        return #players_init
    end
    
    local function create_player(mngr, _x, _y, num)
        local pl = mngr.newEntity()
        --mngr.addComponent(pl, Comp_Physical_Body(_x, _y, 32, 64))
        mngr.addComponent(pl, Comp_Physical_Body(_x, _y, 26, 52))
        mngr.addComponent(pl, Comp_Player_Controls())
        local spr_path = "gfx/bot1a.png"
        if num == 2 then
            spr_path = "gfx/bot2a.png"
        end
        mngr.addComponent(pl, Comp_Anim_Sprite(spr_path, 16, 26, -2, 4))
        return pl
    end
    
    local function set_quad_inv(xx, yy)
        for i = math.max(-1, xx-2), math.min(maxw, xx+2) do
            for j = math.max(-1, yy-1), math.min(maxh, yy+2) do
                if false then--act_plr == 1 then
                    map[i][j].active = not map[i][j].active
                else
                    if map[i][j].init then
                        map[i][j].active = not map[i][j].active
                        map[i][j].deact = not map[i][j].deact
                    end
                end
            end
        end
    end
    
    local function set_quad_light(xx, yy, val)
        for i = math.max(-1, xx-2), math.min(maxw, xx+2) do
            for j = math.max(-1, yy-1), math.min(maxh, yy+2) do
                map[i][j].deact = val
            end
        end
    end
    
    function self.Reload()
        self.finished = false
        local mngr = self.get_manager()
        for k, v in pairs(players_init) do
            local pb = mngr.getComponent(v.entity, 'physical_body')
            local pc = mngr.getComponent(v.entity, 'player_controls')
            local xh, yh = math.floor(pb.x / TILESIZE + 0.5), math.floor(pb.y / TILESIZE + 0.5)                                                                
            if pc.turned_on then
                set_quad_light(xh, yh, false)
                set_quad_inv(xh, yh)
                pc.turned_on = false
            end
            pb.x = v.x
            pb.y = v.y
            pb.vx = 0
            pb.vy = 0
        end
    end
    
    -- Block types:
    -- 'ground' - general block (active = solid, not active = air)
    -- 'empty' - air block (used only in map format)
    -- 'goal' - finish zone of level
    -- 'spawnN' - spawn cell of character
    
    function self.LoadMap(level_path)
        self.finished = false
        --mapname = "/level" .. tostring(mapnum) .. ".map"
        --mapname = "/"..mapnum
        local mapname = "/" .. level_path.pack .. "/" .. level_path.level
        local i = -1
        --players_init = {}
        --[[for k, v in pairs(players_init) do
            -- PROBLEM with entity deleting!!!
            local mg = self.get_manager()
            mg.deleteEntity(v.entity)
            players_init[k] = nil
        end]]
        for line in love.filesystem.lines("/levels"..mapname) do
            map[i] = {}
            local id = -1
            if not line then break end
            for j in string.gmatch(line, "[^ ]+") do 
                map[i][id] = {x = i*TILESIZE, y = id*TILESIZE}
                if j == "spawn1" or j == "spawn2" or j == "spawn3" then
                    map[i][id].t = "ground"
                    local xx, yy = i * TILESIZE, id * TILESIZE       
                    --if #players_init < 2 then
                    local id = tonumber(j:match("%d"))
                    --if #players_init < 3 then
                    if not players_init[id] then
                        local pl = create_player(self.get_manager(), xx, yy, id)
                        table.insert(players_init, {x=xx, y=yy, entity=pl})
                    else                        
                        local b = self.get_manager().getComponent(players_init[id].entity, 'physical_body')
                        local c = self.get_manager().getComponent(players_init[id].entity, 'player_controls')
                        c.turned_on = false
                        players_init[id].x, players_init[id].y = xx, yy
                        b.x = players_init[id].x
                        b.y = players_init[id].y
                        b.vy = 0                        
                    end
                    --players[1].x = i * TILESIZE
                    --players[1].y = id * TILESIZE
                --[[elseif j == "spawn2" then
                    map[i][id].t = "ground"
                    local xx, yy = i * TILESIZE, id * TILESIZE
                    if #players_init < 2 then                    
                        local pl = create_player(self.get_manager(), xx, yy)
                        table.insert(players_init, {x=xx, y=yy, entity=pl})
                    else
                        local b = self.get_manager().getComponent(players_init[2].entity, 'physical_body')
                        local c = self.get_manager().getComponent(players_init[2].entity, 'player_controls')
                        c.turned_on = false                        
                        players_init[2].x, players_init[2].y = xx, yy
                        b.x = players_init[2].x
                        b.y = players_init[2].y
                        b.vy = 0
                    end
                    --players[2].x = i * TILESIZE
                    --players[2].y = id * TILESIZE
				]]--
                elseif j == "ground" then
                    map[i][id].t = j
                    map[i][id].active = true
                    map[i][id].init = true
                elseif j == "empty" then
                    map[i][id].t = "ground"
                    map[i][id].active = false
                    map[i][id].init = false
                elseif j == "goal" then
                    map[i][id].t = j
                end
                    id = id + 1
            end
            i = i + 1
        end
    end
    
    function self.draw()
        local tt = love.timer.getTime()
        --for i, row in pairs(map) do
        --    for j, v in pairs(row) do
        COLOR_PUSH()
        for i = -1, maxw do
            for j = -1, maxh do
                v = map[i][j]
                if v.t == 'ground' then
                    if (not v.active and v.deact) then
                        love.graphics.setColor(0.8, 0.8, 0.8, 0.25)
                        love.graphics.rectangle('fill', v.x+1, v.y+1, TILESIZE-2, TILESIZE-2)
                        -- field around active and not turned on player (not block)
                    end
                    if v.active then
                        --love.graphics.setColor(1.0, 1.0, 1.0, 1.0) -- default block
                        love.graphics.setColor(0.25, 0.25, 0.63, 0.9) -- default block
                        if v.deact then love.graphics.setColor(0.25, 0.25, 0.63, 0.83) end -- lighted block around active player
                        if self.finished then
                            love.graphics.setColor(math.sin(tt*j+i), math.sin(tt*j+i+2), math.sin(tt*j+i+4), 1.0)
                        end
                        love.graphics.rectangle('fill', v.x+1, v.y+1, TILESIZE-2, TILESIZE-2)
                    elseif v.init and not v.active then
                        love.graphics.setColor(1.0, 1.0, 1.0, 0.25)
                        love.graphics.rectangle('fill', v.x+1, v.y+1, TILESIZE-2, TILESIZE-2)
                        -- turned off block
                    end
                end
                if v.t == 'goal' then
                    love.graphics.setColor(1.0, 1.0, 0.2, 1.0)
                    --love.graphics.rectangle('fill', v.x+1, v.y+1, TILESIZE-2, TILESIZE-2)
                end
            end
        end
        COLOR_POP()
        love.graphics.setColor(1, 1, 1, 1)
    end
	
	return self
end



function System_Tiles_Drawing(map_)
	local self = System_Base()
	self.name = "tiles_system"
	
	self.requirements = {
        "nonexistent_map_comp"
	}
    
    local TILES_PATH = "gfx/tiles2.png"
    local TILE_W = 13
    local TILE_H = 13
    
    local map = map_
    
    -- Initialization
	local tiles_exist = love.filesystem.exists( TILES_PATH )
	local tile_tex = nil
	if tiles_exist then
		tile_tex = love.graphics.newImage(TILES_PATH)
		tile_tex:setFilter("nearest", "nearest")
	end
	
	if tile_tex == nil then
		--TILE_W = 1
		--TILE_H = 1
		local tiles_x, tiles_y = 3, 7
		local canvas = love.graphics.newCanvas(tiles_x * TILE_W, tiles_y * TILE_H)
		local img_data = canvas:newImageData(0, 1, 0, 0, tiles_x * TILE_W, tiles_y * TILE_H )
		img_data:mapPixel(function (x, y, r, g, b, a) return 0.7, 0.2, 0.2, 0.0; end)		
		--img_data:setPixel(0, 4, 0.2, 0.2, 0.2, 0.0)
		--img_data:setPixel(2, 4, 0.2, 0.2, 0.2, 0.0)
		img_data:mapPixel(function (x, y, r, g, b, a) return 0.7, 0.7, 0.2, 1.0; end, 2 * TILE_W, 6 * TILE_W, TILE_W, TILE_H)
		tile_tex = love.graphics.newImage( img_data )
	end
    
    local tile_batch = love.graphics.newSpriteBatch(tile_tex, (maxw+2)*(maxh+2)*5) 
    
    local tile_tex_w = tile_tex:getWidth()
    local tile_tex_h = tile_tex:getHeight()
	
	local tile_quads = {}   
    tile_quads.center       = love.graphics.newQuad(1*TILE_W, 1*TILE_H, TILE_W, TILE_H, tile_tex_w, tile_tex_h)
    
    tile_quads.left_wall    = love.graphics.newQuad(0*TILE_W, 1*TILE_H, TILE_W, TILE_H, tile_tex_w, tile_tex_h)
    tile_quads.right_wall   = love.graphics.newQuad(2*TILE_W, 1*TILE_H, TILE_W, TILE_H, tile_tex_w, tile_tex_h)
    
    tile_quads.upper_wall   = love.graphics.newQuad(1*TILE_W, 0*TILE_H, TILE_W, TILE_H, tile_tex_w, tile_tex_h)
    tile_quads.lower_wall   = love.graphics.newQuad(1*TILE_W, 2*TILE_H, TILE_W, TILE_H, tile_tex_w, tile_tex_h)
    
    tile_quads.center_off   = love.graphics.newQuad(1*TILE_W, 4*TILE_H, TILE_W, TILE_H, tile_tex_w, tile_tex_h)
    
    tile_quads.left_glow    = love.graphics.newQuad(0*TILE_W, 4*TILE_H, TILE_W, TILE_H, tile_tex_w, tile_tex_h)
    tile_quads.right_glow   = love.graphics.newQuad(2*TILE_W, 4*TILE_H, TILE_W, TILE_H, tile_tex_w, tile_tex_h)
    
    tile_quads.low_right    = love.graphics.newQuad(0*TILE_W, 3*TILE_H, TILE_W, TILE_H, tile_tex_w, tile_tex_h)
    tile_quads.low_left     = love.graphics.newQuad(2*TILE_W, 3*TILE_H, TILE_W, TILE_H, tile_tex_w, tile_tex_h)
    tile_quads.up_right     = love.graphics.newQuad(0*TILE_W, 5*TILE_H, TILE_W, TILE_H, tile_tex_w, tile_tex_h)
    tile_quads.up_left      = love.graphics.newQuad(2*TILE_W, 5*TILE_H, TILE_W, TILE_H, tile_tex_w, tile_tex_h)
    
    tile_quads.lighted      = love.graphics.newQuad(0*TILE_W, 6*TILE_H, TILE_W, TILE_H, tile_tex_w, tile_tex_h)
    tile_quads.switched     = love.graphics.newQuad(1*TILE_W, 6*TILE_H, TILE_W, TILE_H, tile_tex_w, tile_tex_h)
    tile_quads.tport        = love.graphics.newQuad(2*TILE_W, 6*TILE_H, TILE_W, TILE_H, tile_tex_w, tile_tex_h)
    
    local tile_codes = {}
    --[[for j = 0, 9*5+3-1 do
        for i = 0, 2 do
            tile_quads[i+j*3+1] = 
                love.graphics.newQuad(i*TILE_W, j*TILE_H, TILE_W, TILE_H, tile_tex_w, tile_tex_h)
        end
    end
    
    
    -- 000 = '0'
    -- 010 = '2'
    -- 111 = '7'
    -- etc...
    tile_codes['020'] = 8
    tile_codes['070'] = 2
    tile_codes['222'] = 3
    tile_codes['227'] = 3
    
    tile_codes['077'] = 5
    tile_codes['177'] = 5
    tile_codes['477'] = 5
    tile_codes['777'] = 8
    tile_codes['770'] = 11
    
    tile_codes['333'] = 7
    tile_codes['666'] = 9
    
    tile_codes['030'] = 3+9*3+3*1+1
    tile_codes['431'] = 3+9*3+3*1+1
    tile_codes['060'] = 3+9*3+3*1+3
    tile_codes['164'] = 3+9*3+3*1+3
    
    tile_codes['022'] = 3+9*3+2
    tile_codes['220'] = 3+9*3+3*2+2
    tile_codes['221'] = 3+9*3+3*2+2
    tile_codes['224'] = 3+9*3+3*2+2
    ]]--
    -- Initialization END
    
    function self.update(dt)
        tile_batch:clear()
        for i = -1, maxw do
            for j = -1, maxh do
                v = map[i][j]
                if v.t == 'ground' then
                    if (not v.active and v.deact) then
                        --love.graphics.setColor(0.8, 0.2, 0.2, 0.5)
                        --love.graphics.rectangle('fill', v.x+TILESIZE/2-1, v.y+TILESIZE/2-1, 4, 4)
                        -- field around active and not turned on player (not block)
                        --tile_batch:add(tile_quads.lighted, v.x, v.y, 0, 2, 2) 
                    end
                    if v.active then
                        --love.graphics.setColor(1.0, 1.0, 1.0, 1.0) -- default block
                        --love.graphics.setColor(0.25, 0.25, 0.63, 0.9) -- default block
                        --if v.deact then love.graphics.setColor(0.25, 0.25, 0.63, 0.83) end -- lighted block around active player
                        
                        if self.finished then
                            --love.graphics.setColor(math.sin(tt*j+i), math.sin(tt*j+i+2), math.sin(tt*j+i+4), 1.0)
                        end
                        --love.graphics.rectangle('fill', v.x+1, v.y+1, TILESIZE-2, TILESIZE-2)
                        local neighbours = {}
                        local tile_code = '' -- using hex (or octo) coding for every row
                        for n_j = -1, 1 do
                            neighbours[n_j] = {}
                            local row_code = 0
                            for n_i = -1, 1 do
                                neighbours[n_j][n_i] = 0
                                if i+n_i >= -1 and i+n_i <= maxw and j+n_j >= -1 and j+n_j <= maxh then 
                                    local cur_t = map[i+n_i][j+n_j]
                                    local val = (cur_t.t == 'ground' and cur_t.active) and 1 or 0
                                    neighbours[n_j][n_i] = val
                                    -- bit shifting for every position
                                    row_code = row_code + val * math.pow(2, 2-(n_i+1))  
                                end                                
                            end
                            tile_code = tile_code .. tostring(row_code)
                        end                        
                        if not tile_codes[tile_code] then tile_code = '020' end

                        --tile_batch:add(tile_quads[tile_codes[tile_code]], v.x, v.y, 0, 2, 2)
                        if not v.deact then
                            tile_batch:add(tile_quads.center, v.x, v.y, 0, 2, 2)
                        else
                            tile_batch:add(tile_quads.center_off, v.x, v.y, 0, 2, 2)
                        end
                        
                        if neighbours[0][-1] == 0 then
                            tile_batch:add(tile_quads.left_wall, v.x, v.y, 0, 2, 2) 
                            
                            tile_batch:add(tile_quads.right_glow, v.x-TILE_W*2, v.y, 0, 2, 2) 
                        end                            
                        if neighbours[0][1] == 0 then
                            tile_batch:add(tile_quads.right_wall, v.x, v.y, 0, 2, 2) 
                            tile_batch:add(tile_quads.left_glow, v.x+TILE_W*2, v.y, 0, 2, 2) 
                        end
                            
                        if neighbours[-1][0] == 0 then
                            tile_batch:add(tile_quads.upper_wall, v.x, v.y, 0, 2, 2) end                            
                        if neighbours[1][0] == 0 then
                            tile_batch:add(tile_quads.lower_wall, v.x, v.y, 0, 2, 2) end
                        

                        if neighbours[1][1] == 0 and neighbours[1][0] == 1 and neighbours[0][1] == 1 then
                            tile_batch:add(tile_quads.low_right, v.x, v.y, 0, 2, 2) end
                            
                        if neighbours[1][-1] == 0 and neighbours[1][0] == 1 and neighbours[0][-1] == 1 then
                            tile_batch:add(tile_quads.low_left, v.x, v.y, 0, 2, 2) end
                        
                        if neighbours[-1][1] == 0 and neighbours[-1][0] == 1 and neighbours[0][1] == 1 then
                            tile_batch:add(tile_quads.up_right, v.x, v.y, 0, 2, 2) end
                            
                        if neighbours[-1][-1] == 0 and neighbours[-1][0] == 1 and neighbours[0][-1] == 1 then
                            tile_batch:add(tile_quads.up_left, v.x, v.y, 0, 2, 2) end
                            
                        if v.deact then
                            -- lighted block around active player
                            --tile_batch:add(tile_quads.switched, v.x, v.y, 0, 2, 2) 
                        end
                        
                    elseif v.init and not v.active then
                        --love.graphics.setColor(1.0, 1.0, 1.0, 0.25)
                        --love.graphics.rectangle('fill', v.x+1, v.y+1, TILESIZE-2, TILESIZE-2)
                        -- turned off block
                    end
                end
                if v.t == 'goal' then
                    tile_batch:add(tile_quads.tport, v.x, v.y, 0, 2, 2) 
                end
            end            
        end
        tile_batch:flush()
    end
    
    function self.draw()
        love.graphics.draw(tile_batch)
        --[[local tt = love.timer.getTime()
        for i = -1, maxw do
            for j = -1, maxh do
                v = map[i][j]
                
            end            
        end]]--
    end
    
    return self
end



function System_Change_Tiles_Light(_map)
	local self = System_Base()
	self.name = "change_tiles_light"
	
	self.requirements = {
        --"event_change_tile_light"
        "physical_body",
        "player_controls"
	}
    
    local map = _map
    
    local function set_quad_light(xx, yy, val)
        for i = math.max(-1, xx-2), math.min(maxw, xx+2) do
            for j = math.max(-1, yy-1), math.min(maxh, yy+2) do
                if map[i] and map[i][j] then
                    --if map[i][j].init and
                    map[i][j].deact = val
                end
            end
        end
    end
    
    local function set_quad_inv(xx, yy)
        if (map[xx] and map[xx][yy] and map[xx][yy+1]) and ((map[xx][yy].init and not map[xx][yy].active) 
            or (map[xx][yy+1].init and not map[xx][yy+1].active)) then
            return false
        end
        print('aa')
        for i = math.max(-1, xx-2), math.min(maxw, xx+2) do
            for j = math.max(-1, yy-1), math.min(maxh, yy+2) do
                if false then--act_plr == 1 then
                    map[i][j].active = not map[i][j].active
                else
                    if map[i][j].init then
                        map[i][j].active = not map[i][j].active
                        map[i][j].deact = not map[i][j].deact
                    end
                end
            end
        end
        return true
    end
    
    
    local function player_get_cell(plr)
        return math.floor(plr.x / TILESIZE + 0.5), math.floor(plr.y / TILESIZE + 0.5)
    end
    
    function self.update(dt)
        for i = -1, maxw do
            for j = -1, maxh do
                v = map[i][j]
                v.deact = false
            end            
        end
        
        for i, e in pairs(self.subscribers) do
            local c = e.player_controls
            local p = e.physical_body
            local cx, cy = player_get_cell(p)
            if c.active  then
                set_quad_light(cx, cy, true)
            elseif c.turned_on then
                --set_quad_light(cx, cy, false)
                --set_quad_inv(cx, cy)
            end
        end
        
        --[[for i, e in pairs(self.subscribers) do
            local p = e.event_change_tile_light
            set_quad_light(p.prevx, p.prevy, false)
            set_quad_light(p.x, p.y, true)
            self.removeComponent(i, p.name)
        end]]
    end
    
    return self
end



function System_Change_Tiles_Activity(_map)
	local self = System_Base()
	self.name = "change_tiles_activity"
	
	self.requirements = {
        "event_inv_tile_activity"
	}
    
    local map = _map
    
    local function set_quad_light(xx, yy, val)
        for i = math.max(-1, xx-2), math.min(maxw, xx+2) do
            for j = math.max(-1, yy-1), math.min(maxh, yy+2) do
                map[i][j].deact = val
            end
        end
    end
    
    local function set_quad_inv(xx, yy)
        if (map[xx] and map[xx][yy] and map[xx][yy+1]) and ((map[xx][yy].init and not map[xx][yy].active) 
            or (map[xx][yy+1].init and not map[xx][yy+1].active)) then
            -- two vertical cells (player)
            return false
        end
        for i = math.max(-1, xx-2), math.min(maxw, xx+2) do
            for j = math.max(-1, yy-1), math.min(maxh, yy+2) do
                if false then--act_plr == 1 then
                    map[i][j].active = not map[i][j].active
                else
                    if map[i][j].init then
                        map[i][j].active = not map[i][j].active
                        map[i][j].deact = not map[i][j].deact
                    end
                end
            end
        end
        return true
    end
    
    function self.update(dt)
        for i, e in pairs(self.subscribers) do
            local p = e.event_inv_tile_activity
            if set_quad_inv(p.x, p.y) then
                set_quad_light(p.x, p.y, false)
            else
                -- not good mb ...
                e.player_controls.turned_on = not e.player_controls.turned_on
            end
            self.removeComponent(i, p.name)
        end
    end
    
    return self
end



function System_Set_Tiles_Light(_map)
	local self = System_Base()
	self.name = "set_tiles_light"
	
	self.requirements = {
        "event_set_tile_light"
	}
    
    local map = _map
    
    local function set_quad_light(xx, yy, val)
        for i = math.max(-1, xx-2), math.min(maxw, xx+2) do
            for j = math.max(-1, yy-1), math.min(maxh, yy+2) do
                map[i][j].deact = val
            end
        end
    end
    
    function self.update(dt)
        for i, e in pairs(self.subscribers) do
            local p = e.event_set_tile_light
            set_quad_light(p.x, p.y, p.val)
            self.removeComponent(i, p.name)
        end
    end
    
    return self
end