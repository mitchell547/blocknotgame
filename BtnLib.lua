
--chosen_id = 1

BTN_STATE = {
    ['none'] = 0,
    ['focused'] = 1,
    ['pressed'] = 2
    }

function NewButtons()
local Buttons = {}

Buttons.chosen_id = 1

Buttons.buttons = {}

Buttons.up_ctrl = 'up'
Buttons.down_ctrl = 'down'

Buttons.active = true

--Buttons.color = {255, 255, 255, 255}

function Buttons.CreateButton(x, y, text, font, parent, focus, click, release, unfocus)
    local b = create_btn(#Buttons.buttons+1, x, y, text, font, parent, focus, click, release, unfocus)
    if #Buttons.buttons+1 == Buttons.chosen_id then b.state = BTN_STATE.focused end
    table.insert(Buttons.buttons, b)
    return b
end

function Buttons.Update()
    for k, v in pairs(Buttons.buttons) do
        update_btn(v, Buttons.chosen_id)
    end
end

function Buttons.SetControlKeys(down, up)
    Buttons.up_ctrl = up        -- decreasing
    Buttons.down_ctrl = down    -- increasing
end

function Buttons.SetActive(act)
    Buttons.active = act
    for k, v in pairs(Buttons.buttons) do
        v.active = act
    end
end

function Buttons.GetSelectedId()
    return Buttons.chosen_id
end

function Buttons.SetSelectedId(id)
    Buttons.chosen_id = id
end

function Buttons.Keypressed(key)
    if key == Buttons.down_ctrl then
        Buttons.chosen_id = Buttons.chosen_id + 1
        -- add scrolling through inactive and invisible buttons
        if Buttons.chosen_id > #Buttons.buttons then
            Buttons.chosen_id = 1
        end
    elseif key == Buttons.up_ctrl then
        Buttons.chosen_id = Buttons.chosen_id - 1
        -- add scrolling through inactive and invisible buttons
        if Buttons.chosen_id < 1 then
            Buttons.chosen_id = #Buttons.buttons
        end
    end
    for k, v in pairs(Buttons.buttons) do
      --  update_btn(v, Buttons.chosen_id)
    end
    
    --print(Buttons.chosen_id)
end

function Buttons.Draw()
    for k, v in pairs(Buttons.buttons) do
        --draw_btn_border(v)
        draw_btn_fixedw(v)
    end
end

function create_btn(id, x, y, text, font, parent, focus, click, release, unfocus)
    local self = {id=id, x=x, y=y, text=text, 
        w = font:getWidth(text),
        h = font:getHeight(),
        state = BTN_STATE.none, 
        prev = BTN_STATE.none,
        parent = parent,
        onFocus = focus,
        onClick = click,
        onRelease = release,
        onUnfocus = unfocus,
        visible = true,
        active = true
    }
    return self
end

function check_mouse_focus(btn, mx, my)
    return mx >= btn.x and mx <= btn.x + btn.w and 
        my >= btn.y and my <= btn.y + btn.h
end

function check_mouse_click()
    return love.mouse.isDown(1)
end

function check_arrow_nav(btn, id)
    return btn.id == id
end

function check_key_click()
    return love.keyboard.isDown('return')
end

function update_btn(btn, chosen_id, mx, my)
    btn.state = BTN_STATE.none
    if check_arrow_nav(btn, chosen_id) then
        btn.state = BTN_STATE.focused
        if check_key_click() then
            btn.state = BTN_STATE.pressed
        end
    end
    
    if btn.active and btn.visible and btn.prev ~= btn.state then
        if btn.onFocus and btn.prev == BTN_STATE.none and btn.state == BTN_STATE.focused then
            btn:onFocus(btn.parent)
        elseif btn.onClick and btn.state == BTN_STATE.pressed then
            btn:onClick(btn.parent)
        elseif btn.onRelease and btn.prev == BTN_STATE.pressed then
            btn:onRelease(btn.parent)
        elseif btn.onUnfocus and btn.prev == BTN_STATE.focused and btn.state == BTN_STATE.none then
            btn:onUnfocus(btn.parent)
        end
    end
    
    btn.prev = btn.state
end

function draw_btn_border(btn)
    if not btn.visible then return end
    if btn.state == BTN_STATE.none then
        love.graphics.setLineWidth(1)
    elseif btn.state == BTN_STATE.focused then
        love.graphics.setLineWidth(2)
    elseif btn.state == BTN_STATE.pressed then
        love.graphics.setLineWidth(0.5)
    end
    if not btn.active then
        love.graphics.setLineWidth(0.5)
    end
    local border_w = 40
    local w = love.graphics.getFont():getWidth(btn.text)
    local h = love.graphics.getFont():getHeight()
    love.graphics.setColor(0.0, 0.0, 0.0, 0.5)
    love.graphics.rectangle('fill', btn.x, btn.y, w + border_w, h)
    love.graphics.setColor(1.0, 1.0, 1.0, 1.0)
    love.graphics.rectangle('line', btn.x, btn.y, w + border_w, h)
    love.graphics.print(btn.text, btn.x+border_w/2, btn.y)
end

function draw_btn_fixedw(btn)
    if not btn.visible then return end
    if btn.state == BTN_STATE.none then
        love.graphics.setLineWidth(1)
    elseif btn.state == BTN_STATE.focused then
        love.graphics.setLineWidth(2)
    elseif btn.state == BTN_STATE.pressed then
        love.graphics.setLineWidth(0.5)
    end
    if not btn.active then
        love.graphics.setLineWidth(0.5)
    end
    local fixedw = 90
    local w = love.graphics.getFont():getWidth(btn.text)
    local h = love.graphics.getFont():getHeight()
    local border_w = fixedw-w
    love.graphics.setColor(0.0, 0.0, 0.0, 0.5)
    love.graphics.rectangle('fill', btn.x, btn.y, w + border_w, h)
    love.graphics.setColor(1.0, 1.0, 1.0, 1.0)
    love.graphics.rectangle('line', btn.x, btn.y, w + border_w, h)
    love.graphics.print(btn.text, btn.x+border_w/2, btn.y)
end

return Buttons
end

--return Buttons