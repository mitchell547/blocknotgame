
Game = require "ecs/game"
--beholder = require "beholder"
require "BtnLib"
require "main_menu"
App = require "main_app"

-- Stack of size 1
local color_buf = {}

function COLOR_PUSH()
    color_buf = {love.graphics.getColor()}
end

function COLOR_POP()
    love.graphics.setColor(color_buf)
end

local game_state = "menu"



MUSIC_VOLUME = 0.2

local bg_music = love.audio.newSource("/sounds/stopnlistencut.ogg", 'stream')

local function setup_music()
    bg_music:setVolume(MUSIC_VOLUME)
    bg_music:setLooping(true)
    bg_music:seek(1.5)
    love.audio.setEffect('myEffect', {type = 'reverb', decaytime=3.0})
    --love.audio.setEffect('myEffect', {type = 'echo', feedback=0.05, delay=0.05, tapdelay=0.05})
    bg_music:setEffect('myEffect')
    love.audio.play(bg_music)
end




function string.fromhex(str)
    return (str:gsub('..', function (cc)
        return string.char(tonumber(cc, 16))
    end))
end

function string.tohex(str)
    return (str:gsub('.', function (c)
        return string.format('%02X', string.byte(c))
    end))
end

local SAVEFILE = "/savefile.bnsf"

-- Updates existing levels progress (call only after reading all levels)
function readProgress()
    -- TODO: add saving info about missing levels
    --local f = io.open(love.filesystem.getSource( )..SAVEFILE, "r")
    --print(love.filesystem.getRealDirectory(SAVEFILE))
    --print(love.filesystem.getSource( ), love.filesystem.getIdentity())
    --[[if not love.filesystem.getInfo(SAVEFILE) then
        return -- no saved progress
    end]]
    
    local filename = SAVEFILE
    local cur_pack = ""
    local lvl_id = 0
    local f = io.open(love.filesystem.getSource().."/../"..SAVEFILE, "r")
    if not f then return end    
    f:close()
    --for lineh in love.filesystem.lines(filename) do
    for lineh in io.lines(love.filesystem.getSource().."/../"..SAVEFILE) do
        local words = {}
        local line = string.fromhex(lineh)
        for word in string.gmatch(line, "[^ ]+") do 
            table.insert(words, word)
        end
        if words[1] == "pack:" then 
            cur_pack = words[2] 
            lvl_id = 1
        else
            local lvl = App.levels.levels[cur_pack]
            --print(lvl[lvl_id].name, words[1])            
            --assert(lvl and lvl[lvl_id] and lvl[lvl_id].name == words[1], "bad sav format (level indexing)")
            if lvl and lvl[lvl_id] and lvl[lvl_id].name == words[1] then    -- very bad solution! can be broken only with one odd file
            lvl[lvl_id].completed = (words[2] == '1')
            lvl_id = lvl_id + 1            
            end
        end
        assert(cur_pack ~= "", "bad sav format (keyword 'pack:')")
        --if cur_pack == "" then return end
    end
end

function writeProgress()
    print("writing...")
    local projdir = love.filesystem.getIdentity()
    local f, err = io.open(love.filesystem.getSource( ).."/../"..SAVEFILE, "wb")
    print(err)
    for k, pack in pairs(App.levels.packs) do
        f:write(string.tohex("pack: "..pack), "\n")
        for l, level in pairs(App.levels.levels[pack]) do
            f:write(string.tohex(level.name .. " " .. (level.completed and "1" or "0")), "\n")
        end
    end
    f:close()
    print("written!")
end

    
function love.load()    
    local ch_st = function(new_st) game_state = new_st end -- some hack
    App.init({bg_music = bg_music, game = Game, change_state = ch_st})
    Game.load(App)
    --local f = love.graphics.getFont()
    MenuLoad(App)
    readProgress()    
    setup_music()
end

local function chk_lvls_fin()
    for k, v in pairs(Game.levels_finished) do
        if v then lvls_checks.buttons[k].text = "+" end
    end
end

function love.update(dt)
    
    if game_state == "menu" then
        --menu_btns.Update()
        MenuUpdate()
    --[[elseif game_state == "levels" then
        lvls_btns.Update()
        lvls_checks.Update()
        lvls_checks.chosen_id = lvls_btns.chosen_id
        ]]--
    elseif game_state == "game" then
        Game.update(dt)        
        if GAMESTATE == 'end' then
            game_state = "menu"
            chk_lvls_fin()
        end
    end    
end

function love.keypressed(key)
    if key == "m" then
        if App.music_on then 
            App.pauseMusic() 
        else App.playMusic() end
    end
    if game_state == "menu" then
        --menu_btns.Keypressed(key)
        MenuKeypressed(key)
    --elseif game_state == "levels" then
    --    lvls_btns.Keypressed(key)
    elseif game_state == "game" then
        Game.keypressed(key)
    end
end

function love.quit()
    writeProgress()
    return false
end

function love.draw()
    if game_state == "menu" then
        MenuDraw()
    --[[    COLOR_PUSH()
        love.graphics.setColor(1.0, 1.0, 0.4, 1.0)
        menu_btns.Draw()
        play_scr:draw()
        help_scr:draw()
        cred_scr:draw()
        exit_scr:draw()
        COLOR_POP()
    elseif game_state == "levels" then
        COLOR_PUSH()
        love.graphics.setColor(0.6, 0.6, 1.0, 1.0)
        lvls_btns.Draw()
        lvls_checks.Draw()
        COLOR_POP()
        ]]--
    elseif game_state == "game" then
        Game.draw()
    end
end