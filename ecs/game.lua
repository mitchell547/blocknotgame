
TILESIZE = 26

require "ecs/ECS_Manager"
require "ecs/bit_components"
require "ecs/bit_systems"
require "ecs/bit_map_systems"
require "BtnLib"
require "event_lib"

local game = {}
local ecs = {}
local map = {}
local physics = {}

game.cur_level = 1

game.levels_finished = {}

game.players_count = 0
game.players_in_goal = 0

game.cur_script = require "default_script"

GAMESTATE = "game" -- "finish" "end"
local show_menu = false
local parent_app = {}
--show_menu = true

-- PAY ATTENTION on clearing tables (sometable={} just creates new table)

-- todo: make a signal when player cannot activate character

function create_player(mngr, _x, _y)
    -- this is old
    local pl = mngr.newEntity()
    --mngr.addComponent(pl, Comp_Physical_Body(_x, _y, 32, 64))
    mngr.addComponent(pl, Comp_Physical_Body(_x, _y, 24, 48))
    mngr.addComponent(pl, Comp_Player_Controls())
    return pl
end

local function init_systems()
    -- init
    map = System_Map()
    physics = System_Collisions(map.GetMap(), event_mngr)
    out_bounds = System_OutOfBoundsCheck()
    
    -- input
    ecs.addSystem(System_Players_Control())
    
    -- processing
    ecs.addSystem(System_Physics())
    ecs.addSystem(System_Change_Tiles_Light(map.GetMap()))
    ecs.addSystem(System_Change_Tiles_Activity(map.GetMap()))
    ecs.addSystem(System_Set_Tiles_Light(map.GetMap()))
    ecs.addSystem(physics)
    --ecs.addSystem(System_Physics())
    ecs.addSystem(out_bounds)
    
    -- drawing
    ecs.addSystem(map)
    --ecs.addSystem(System_Player_Drawing())    
    ecs.addSystem(System_Tiles_Drawing(map.GetMap()))
    ecs.addSystem(System_Animation_Drawing())
end

local goal_info = {
    map = {},
    ecs = {},
    plrs = {}
}

local function goal_check_callback(self, args, sender)
    local i, j = args.block.i, args.block.j    
    if self.map[i][j].t == 'goal' then
        if not self.plrs[args.player_id] then self.plrs[args.player_id] = 0 end
        -- count how many times player enter the yellow zone
        self.plrs[args.player_id] = self.plrs[args.player_id] + 1
        print(tostring(i)..' '..tostring(j), '+1')
        --[[local is_in = false
        for k, v in pairs(self.plrs) do
            if v == args.player_id then
                is_in = true
                break
            end
        end
        if not is_in then
            table.insert(self.plrs, args.player_id)
        end]]
    end
end

-- some problem here (self.plrs[id] == nil?)
-- also, bug with counting down the value of enters/exits
local function goal_check_out(self, args)
    local i, j = args.block.i, args.block.j
    if self.map[i][j].t == 'goal' then
        if not self.plrs[args.player_id] then print('impossibru!'); return end
        print(args, args.player_id)
        for k, v in pairs(self.plrs) do print('pl '..tostring(k)..' '..tostring(v)) end
        self.plrs[args.player_id] = self.plrs[args.player_id] - 1
        print(tostring(i)..' '..tostring(j), '-1')
        --[[for k, v in pairs(self.plrs) do
            if v == args.player_id then
                self.plrs[k] = nil
                break
            end
        end ]]       
    end
end

local function count_players_in_goal()
    local cnt = 0
    for k, v in pairs(goal_info.plrs) do
        if v > 0 then cnt = cnt + 1 end
    end
    return cnt
end

    -- rework GUI
    -- add keyboard settings

    -- todo: fix out of bounding tiles +
    
    -- todo: print players count in yellow zone +
    
    -- make more responsive physics
    -- add music and sound
    -- add tutorial !!
    -- make more responsive interface (improve gui lib architecture)
    
    -- label 'level N' at top-left corner sometimes become transparent (depend on turning on player inverting) +

function game.load(par_app)
    parent_app = par_app
    ecs = {}
    ecs = ECSManager()
    event_mngr = EventManager()
    init_systems(ecs, event_mngr)
    
    goal_info.map = map.GetMap()
    goal_info.ecs = ecs
    event_mngr.CatchEvent("OnPlayerHitBlock", goal_check_callback, goal_info)
    event_mngr.CatchEvent("OnPlayerLeaveBlock", goal_check_out, goal_info)
    --map.LoadMap(1)
    
    --game.players_count = map.GetPlayersCnt()
    
    --[[ent = ecs.newEntity()
    ecs.addComponent(ent, Comp_Physical_Body(100, 100, 32, 64))
    ecs.addComponent(ent, Comp_Player_Controls())
    ]]--
    f = love.graphics.getFont()
    --font2 = love.graphics.newFont(150)    
    font2 = love.graphics.newFont("fonts/edunline.TTF", 80)
    
    
    btns = NewButtons()
    btns.SetControlKeys('right', 'left')
    local fn_ld_map = function()
        game.reload()
        game.cur_level = parent_app.getNextLevel(game.cur_level)
        --game.cur_level = game.cur_level + 1
        --[[if game.cur_level > 10 then
            GAMESTATE = "end"
            return
        end]]--
        if game.cur_level.pack ~= nil and game.cur_level.level ~= nil then
            game.load_map(game.cur_level)
        else
            GAMESTATE = "end"
        end
    end
    btns.CreateButton(100, 500, "menu", f, nil, nil, nil, function() game.reload(); GAMESTATE = "end" end)
    btns.CreateButton(200, 500, "restart", f, nil, nil, nil, function() game.reload() end)
    btns.CreateButton(300, 500, "next", f, nil, nil, nil, fn_ld_map)    
    GAMESTATE = 'game'
    show_menu = false
    
    game.cur_script.load(ecs, event_mngr, map.GetMap())
    
end

--function game.load_map(num)
function game.load_map(name)
    GAMESTATE = 'game'
    show_menu = false
    --game.cur_level = num
    game.cur_level = name
    map.LoadMap(game.cur_level)
    game.players_count = map.GetPlayersCnt()
    game.players_in_goal = 0
    goal_info.plrs = {}
    if name.level == 'level01.map' then 
        game.cur_script = require 'levels/01_basic/level01'
    else
        game.cur_script = require 'default_script'
    end
    game.cur_script.load(ecs, event_mngr, map.GetMap())
    physics.Restart()
end

function game.reload()
    GAMESTATE = 'game'
    show_menu = false    
    map.Reload()
    goal_info.plrs = {}
    game.cur_script.restart()
    physics.Restart()
    parent_app.musicHiVol()
end

local function check_levels_finished()    
    for k, v in pairs(game.levels_finished) do
        if not v then return false end
    end
    return true
end

all_in_goal = false

function game.update(dt)
    -- todo: fix out of bounding tiles
    
    if dt > 0.17 then dt = 0.17 end    -- some problems with window dragging
    ecs.update(dt)
    --all_in_goal, game.players_in_goal = physics.AllPlayersInGoal()
    --game.players_in_goal = #goal_info.plrs
    game.players_in_goal = count_players_in_goal()
    if GAMESTATE == "finish" then game.players_in_goal = game.players_count end
    --if physics.AllPlayersInGoal() and GAMESTATE == "game" then
    if game.players_count == game.players_in_goal and GAMESTATE == "game" then
        parent_app.onLevelComplete(game.cur_level)
        GAMESTATE = "finish"
        btns.SetSelectedId(3)
        --game.levels_finished[game.cur_level] = true
        if parent_app.isPackCompleted(game.cur_level) then 
            map.finished = true 
            btns.SetSelectedId(1)
            parent_app.musicLowVol()
        end
        show_menu = true
        
    end
    if out_bounds.isPlayerOutOfBounds() and not show_menu then
        show_menu = true
        btns.SetSelectedId(2)
    end
    if show_menu then
        btns.Update()
    end
    event_mngr.Update()
    game.cur_script.update(dt)
    --  make event from collisions when players on goal == players cnt
    
    -- + bug if pressing left or right and then press tab without release left/right
    
    -- + bug with displaying tile field of inactive players
    --if dt < 0.16 then love.timer.sleep(0.01) end
end

function game.keypressed(key)
    event_mngr.FireEvent("OnKeyPress", nil, key)
    ecs.keypressed(key)
    if key == 'escape' then
        if GAMESTATE == 'game' then
            show_menu = not show_menu
            btns.SetSelectedId(2)
        end
        if GAMESTATE == "finish" then
            show_menu = true
        end
    end
    if show_menu then
        btns.Keypressed(key)
    end
end

function print_if_finished()
    local f = love.graphics.getFont()
    COLOR_PUSH()
    local tt = love.timer.getTime()
    local txt = "NOICE"
    if map.finished then txt = txt .. "x10" end
    local ww, hh = font2:getWidth(txt), font2:getHeight(txt)
    
    love.graphics.setColor(0.0, 0.0, 0.0, 0.33)
    love.graphics.rectangle('fill', (800-ww)/2-8, (600-hh)/2-8, ww+8, hh)
    
    love.graphics.setColor(math.sin(tt*10), math.sin((tt+1)*14), math.sin((tt+2)*11), 1.0)    
    love.graphics.setFont(font2)
    love.graphics.print(txt, (800-ww)/2, (600-hh)/2-8)
    love.graphics.setFont(f)
    
    if map.finished then 
        local msg = "very cool! you can share your opinion about the game at mitch.itch.io/block-not"
        local mw = f:getWidth(msg)
        local mh = f:getHeight(msg)
        love.graphics.setColor(0.0, 0.0, 0.0, 0.33)
        love.graphics.rectangle('fill', (800-mw)/2-4, 460-4, mw+4, mh+4)    
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.print(msg, (800-mw)/2, 460) 
    end
    COLOR_POP()
end



local scrw, scrh = 800, 600
local TILESIZE_OLD = 32
local maxw = math.floor(scrw / TILESIZE_OLD ) +1
local maxh = math.floor(scrh / TILESIZE_OLD )  +1

function game.draw()
    love.graphics.push()
    love.graphics.translate((800-maxw*TILESIZE)/2, (600 - maxh*TILESIZE)/2)
    ecs.draw()
    love.graphics.pop()
    
    COLOR_PUSH()
    love.graphics.setColor(0.8, 0.8, 0.8, 1.0)
    love.graphics.print(tostring(game.cur_level):match("%:(.+)").." "..game.cur_level.level:match("(.+)%..+"), 10, 10)
    --love.graphics.print(tostring(game.cur_level):match("%:(.+)").." "..game.cur_level.level:match("(.+)%..+"), 11, 10)
    COLOR_POP()
    
    love.graphics.setColor(1.0, 1.0, 0.4, 1.0)
    love.graphics.print(string.format("%d/%d", game.players_in_goal, game.players_count), 800-6*10, 10)    
    love.graphics.print(string.format("%d/%d", game.players_in_goal, game.players_count), 800-6*10, 10+1)    
    local tt = love.timer.getTime()
    if GAMESTATE == "finish" then
        --[[for i=1, math.floor(800/TILESIZE) do
            for j=1, math.floor(600/TILESIZE) do
                love.graphics.setColor(math.sin(tt*j+i)*255, math.sin(tt*j+i+2)*255, math.sin(tt*j+i+4)*255, 127)           
                love.graphics.rectangle('fill', (i-1)*TILESIZE, (j-1)*TILESIZE, TILESIZE, TILESIZE*2)
            end
        end]]--
        print_if_finished()
        
    end
    
    if show_menu then
        love.graphics.setColor(0.0, 0.0, 0.0, 0.5)
        love.graphics.rectangle('fill', 100-4, 500-4, 300+8, 20+8)
        btns.Draw()
    end
    
    game.cur_script.draw()
end

return game