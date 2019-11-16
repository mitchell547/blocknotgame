
script = {}

script.state = 'arrows'  -- walking
-- 'near_wall'      -- waiting
-- 'inverting'  -- turning on
-- 'swap'       -- changing player
-- 'going_right' -- waiting
-- 'goal'       -- going to goal
-- 'nice'       -- finish

local ecs = {}
local events = {}

local next_state = script.state
local state_time = 1.0

local function change_state(new_state_)
    next_state = new_state_
    if new_state_ == 'inverting' or new_state_ == 'goal' then return end -- no waiting
    state_time = 0.5
end

local players_on_left = {}
local players_in_goal = {}

function script.load(ecs_, events_, map_)
    ecs = ecs_
    events = events_
    map = map_
    
    events.CatchEvent("OnKeyPress", 
        function(self, args) 
            if self.state == 'arrows' and (args == 'left' or args == 'right') then change_state('near_wall'); return end 
            if self.state == 'inverting' and args == 'x' then change_state('swap'); return end
            if self.state == 'swap' and args == 'tab' then change_state('going_right'); return end
            if self.state == 'going_right' and args == 'x' then change_state('goal'); return end
        end, 
        script)
        
    events.CatchEvent("OnPlayerHitBlock",
        function(self, args)
            if self.state == 'near_wall' then                
                if args.block.i > 5 then change_state('inverting') end
                return
            end
            if self.state == 'going_right' then
                if args.block.i > 8 then players_on_left[args.player_id] = true end
                --if #players_on_left == 2 then change_state('goal') end
                return
            end
            if self.state == 'goal' then
                if map[args.block.i][args.block.j].t == 'goal' then 
                    players_in_goal[args.player_id] = true end
                if #players_in_goal == 2 then change_state('nice') end
                return
            end
        end,
        script)
        
    print('loaded level01')
end

function script.restart()
    script.state = 'arrows'
    players_in_goal = {}
    players_on_left = {}
end

function script.update(dt)
    if next_state ~= script.state then
        state_time = state_time - dt
        if state_time <= 0 then
            script.state = next_state
            state_time = 1.0
        end
    end
end

function script.draw()
    local r,g,b,a=love.graphics.getColor()
    love.graphics.setColor(1, 1, 1, state_time*2)
    if script.state == 'arrows' then
        love.graphics.print('(left/right - walking) \n\t  (up - jump)', 150, 200)
        
    elseif script.state == 'near_wall' then
        --
        
    elseif script.state == 'inverting' then
        love.graphics.print('(press X to invert)', 300, 200)
        
    elseif script.state == 'swap' then
        love.graphics.print('(press TAB to switch)', 400, 200)
        
    elseif script.state == 'going_right' then
        love.graphics.print('(bring both chars here)', 400, 200)
        
    elseif script.state == 'goal' then
        love.graphics.print('(go there)', 600, 200)
        
    elseif script.state == 'nice' then
        --
    end
    love.graphics.setColor(r,g,b,a)
end

return script