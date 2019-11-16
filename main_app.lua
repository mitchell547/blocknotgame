
local App = {
    levels = {},
    music_on = true,
    game_state = "menu"
}

local bg_music = nil
local Game = nil
local change_gamestate = nil

function App.init(tbl)
    Game = tbl.game
    bg_music = tbl.bg_music
    change_gamestate = tbl.change_state
end

function App.onLevelLoadClick(level_path)    
    --App.game_state = "game"
    change_gamestate("game")
    Game.load_map(level_path)
end

function App.onLevelComplete(level_path)
    local p, l = level_path.pack, level_path.level
    for k, v in pairs(App.levels.levels[p]) do
        if v.name == l then v.completed = true end
    end
    writeProgress()
end

function App.getNextLevel(level_path)
    local p, l = level_path.pack, level_path.level
    local cur_lvl_pack = App.levels.levels[p]
    local id = -1
    for k, v in pairs(cur_lvl_pack) do
        if v.name == l then id = k end
    end
    return {pack = p, level = cur_lvl_pack[id+1] and cur_lvl_pack[id+1].name or nil}
end

function App.isPackCompleted(level_path)
    local p = level_path.pack
    local cur_lvl_pack = App.levels.levels[p]
    local pack_finished = true
    for k, v in pairs(cur_lvl_pack) do
        if v.completed == false then 
            pack_finished = false
            break
        end
    end
    return pack_finished
end

function App.pauseMusic()
    bg_music:pause()
    --bg_music:setVolume(0)
    App.music_on = false
end

function App.playMusic()
    bg_music:play()
    --bg_music:setVolume(MUSIC_VOLUME)
    App.music_on = true
end

function App.musicLowVol()
    bg_music:setVolume(0)
end

function App.musicHiVol()
    bg_music:setVolume(MUSIC_VOLUME)
end

return App