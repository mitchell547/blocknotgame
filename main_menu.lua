require "BtnLib"

local function get_folder_files(dir, ext)
    local basedir = love.filesystem.getSourceBaseDirectory()
    local projdir = love.filesystem.getIdentity()
    local files = love.filesystem.getDirectoryItems(dir or "")
    local level_files = {}
    for k, file in ipairs(files) do
        ftype = love.filesystem.getInfo(dir..file)
        if (not ext and ftype=="directory") or file:match("^.+(%..+)$") == ext then
            table.insert(level_files, file)
        end
    end
    --print(#level_files)
    return level_files
end

local function scr_draw(self) 
    if self.visible then love.graphics.print(self.text, self.x, self.y) end 
end

local help_scr = {x=250, y=100, 
    visible = false, 
    text = 
        "|\t Left/Right - walking\n"..
        "|\t Shift + Left/Light - speedup\n"..
        "|\t Up - jumping\n" ..
        "|\t X - invert space\n" ..
        "|\t Tab - switch players\n" ..
        "\n" ..
        "|\t M - turn off/on music\n"..
        "\n" ..        
        "|\t goal: achieve yellow zone\n",
    draw = scr_draw}

local cred_scr = {x=250, y=100, 
    visible = false, 
    text = 
        "|\t programming - mitch\n"..
        "|\t music - Stateor\n\n"..
        "|\t 2018 - 2019\n\n" ..
        "|\t engine: Love2D\n",
    draw = scr_draw}

local exit_scr = {x=250, y=100, 
    visible = false, 
    text = 
        "|\n" ..
        "|\t sure?\n"..
        "|\n",
    draw = scr_draw}

local play_scr = {x=250, y=100, 
    visible = false, 
    text = 
        "|\n" ..
        "|\t play the game!\n"..
        "|\n",
    draw = scr_draw}
    
local music_scr = {x=250, y=100, 
    visible = false, 
    text = 
        "|\n" ..
        "|\t music turn off or on\n"..
        "|\n",
    draw = scr_draw}


    

local parent_app = {}    
local menu_btns = {}
local level_menu = {}
local levels_btns = {}
local levels_struct = {packs = {}, levels = {}}
local f = love.graphics.getFont()
local menu_state = "menu"   -- "levels"
local cur_level_pack = 1
local cur_selected_level = 1


local function main_btns_init()
    menu_btns = NewButtons()
    menu_btns.CreateButton(100, 100, "levels", f, nil, 
        function() play_scr.visible = true end, 
        nil, 
        function() menu_state = "levels" end, 
        function() play_scr.visible = false end)
    menu_btns.CreateButton(100, 120, "help", f, nil, 
        function() help_scr.visible = true end, 
        nil, 
        nil, 
        function() help_scr.visible = false end)
    menu_btns.CreateButton(100, 140, "credits", f, nil, 
        function() cred_scr.visible = true end, 
        nil, 
        nil, 
        function() cred_scr.visible = false end)
    music_btn=menu_btns.CreateButton(100, 160, "music (on)", f, nil, 
        function() music_scr.visible = true end, 
        nil, 
        function(self)  if parent_app.music_on then 
                            self.text="music (off)"; parent_app.pauseMusic() 
                        else 
                            self.text="music (on)"; parent_app.playMusic() 
                        end end, 
        function() music_scr.visible = false end)
    menu_btns.CreateButton(100, 180, "exit", f, nil, 
        function() exit_scr.visible = true end, 
        nil, 
        love.event.quit, 
        function() exit_scr.visible = false end)
end

local x_left = 200
local x_offset = 120

local function dumb_level_init()
    local k = 3
    local pack_name = "in progress"
    --[[local bb = level_menu.CreateButton(x_left + (k-1)*x_offset, 160, pack_name, f, nil, 
        function() cur_level_pack = k-1; level_menu.SetSelectedId(2) end, 
        nil, 
        nil, 
        function() end)
    bb.active = false]]
        
    levels_btns[k] = NewButtons()
    local b = levels_btns[k].CreateButton(x_left + (k-1) * x_offset, 160 + 0*20, "mb later...", f, nil, 
            function()  end, 
            nil, 
            nil, 
            function()  end)
    
    levels_struct.levels[pack_name] = {}
    for l = 1, 10 do
        local b = levels_btns[k].CreateButton(x_left + (k-1) * x_offset, 160 + l*20, "---", f, nil, 
            function()  end, 
            nil, 
            nil, 
            function()  end)
        b.active = false
    end
end

local function level_menu_init()
    local MAP_EXTENSION = ".map"
    level_menu = NewButtons()
    level_menu.SetControlKeys('right', 'left')
    fld_list = get_folder_files("levels")
    
    
    
    for k, pack_name in pairs(fld_list) do
        level_menu.CreateButton(x_left + (k-1)*x_offset, 160, pack_name, f, nil, 
            function() cur_level_pack = k end, 
            nil, 
            nil, 
            function() end)
            
        lvls = get_folder_files("levels/" .. pack_name, MAP_EXTENSION)
        levels_btns[k] = NewButtons()
        
        table.insert(levels_struct.packs, pack_name)
        
        levels_struct.levels[pack_name] = {}
        for l, lvl_file in pairs(lvls) do
            table.insert(levels_struct.levels[pack_name], {name=lvl_file, completed=false})
            levels_btns[k].CreateButton(x_left + (k-1) * x_offset, 160 + l*20, lvl_file:match("(.+)%..+"), f, nil, 
                function()  end, 
                nil, 
                function() parent_app.onLevelLoadClick({pack=pack_name, level=lvl_file}) end, 
                function()  end)
        end
        
    end
    parent_app.levels = levels_struct
    
    dumb_level_init()    
    
    level_menu.CreateButton(100-20, 260, "back", f, nil, 
        function() cur_level_pack = -1 end, 
        nil, 
        function() menu_state = "menu" end, 
        nil)
end


local font1 = love.graphics.getFont()
local font2 = love.graphics.newFont(100) 

function MenuLoad(app)
    parent_app = app
    main_btns_init()
    level_menu_init()
    
end

function MenuUpdate()
    if menu_state == "menu" then
        music_btn.text = "music " .. (parent_app.music_on and "(on)" or "(off)")    -- костыль
        menu_btns.Update()
    elseif menu_state == "levels" then
        level_menu.Update()
        for k, v in pairs(levels_btns) do
            v.SetActive(false)
            v.SetSelectedId(cur_selected_level)
        end        
        if cur_level_pack > 0 then
            levels_btns[cur_level_pack].SetActive(true)
            levels_btns[cur_level_pack].Update()
            --cur_selected_level = levels_btns[cur_level_pack].GetSelectedId()
        end
        --for k, v in pairs(levels_btns) do
        --    v.Update()
        --end
    end
end

function MenuKeypressed(k)
    if menu_state == "menu" then
        menu_btns.Keypressed(k)
    elseif menu_state == "levels" then
        level_menu.Keypressed(k)
        if cur_level_pack > 0 then
            levels_btns[cur_level_pack].Keypressed(k)
            cur_selected_level = levels_btns[cur_level_pack].GetSelectedId()
        end
        --for k, v in pairs(levels_btns) do
        --    v.Keypressed(k)
        --end
    end
end

function MenuDraw()
    local f = font1
    f:setFilter('nearest', 'nearest')
    if menu_state == "menu" then
        COLOR_PUSH()
        love.graphics.setColor(1.0, 1.0, 0.4, 1.0)
        
        menu_btns.Draw()
        
        play_scr:draw()
        help_scr:draw()
        cred_scr:draw()
        exit_scr:draw()  
        music_scr:draw()
        
        --love.graphics.setFont(font2)
        --love.graphics.print("blockNOT", 300, 500)
        --love.graphics.setFont(font1)
        COLOR_POP()
    elseif menu_state == "levels" then
        level_menu.Draw()
        for k, v in pairs(levels_btns) do            
            v.Draw()
        end
        
        for k, pack in pairs(levels_struct.packs) do
            for l, level in pairs(levels_struct.levels[pack]) do
                if level.completed then
                    love.graphics.print(' +', (x_left + (k-1) * x_offset), (160 + l*20-1))
                end
            end
        end
    end
end