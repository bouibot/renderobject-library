if not RenderWindow then
    return error("Synapse v3 supported only.")
end

local uis = game:GetService("UserInputService")
local httpsservice = game:GetService("HttpService")

local v2new, v2zero = Vector2.new, Vector2.zero
local c3rgb, c3hsv, c3new = Color3.fromRGB, Color3.fromHSV, Color3.new

local library = {
    pointers = {},
    cons = {},
    active = false
}

local theme_thingies = {
    accent = {5, 6, 18, 19, 20, 22, 23, 25, 34, 35}
}

local entriesMetatable = {}
entriesMetatable.__index = entriesMetatable

do

    function entriesMetatable.button(self, info)

        info = info or {}

        local name = info.name or "button"
        local callback = info.callback or function() end

        if self.window.nameOverwrite then
            name = self.window.nameOverwrite
        end

        local button = {name = name, callback = callback}

        local button_frame = self.frame:Button()
        button_frame.Label = button.name

        button_frame.OnUpdated:Connect(button.callback)

        button.frame = button_frame

        return button

    end

    function entriesMetatable.colorbutton(self, info)

        info = info or {}

        local description = info.desc or info.description or "color button"
        local size = info.size or v2zero
        local color = info.color or c3new()
        local callback = info.callback or function() end

        if self.window.nameOverwrite then
            name = self.window.nameOverwrite
        end

        local colorbutton = {description = description, callback = callback}

        local colorbutton_frame = self.frame:ColorButton()
        colorbutton_frame.Description = colorbutton.description
        colorbutton_frame.Size = size
        colorbutton_frame.Color = color
        
        colorbutton_frame.OnUpdated:Connect(colorbutton.callback)

        colorbutton.frame = colorbutton_frame

        return colorbutton

    end

    function entriesMetatable.checkbox(self, info)

        info = info or {}

        local name = info.name or "checkbox"
        local def = info.def or info.default or false
        local pointer = info.pointer
        local callback = info.callback or function() end

        if self.window.nameOverwrite then
            name = self.window.nameOverwrite
        end

        local checkbox = {name = name, callback = callback}

        if pointer then
            library.pointers[pointer] = checkbox
        end

        local checkbox_frame = self.frame:CheckBox()
        checkbox_frame.Label = checkbox.name
        checkbox_frame.Value = def

        checkbox_frame.OnUpdated:Connect(checkbox.callback)

        checkbox.frame = checkbox_frame

        function checkbox.get(self)
            return self.frame.Value
        end

        function checkbox.set(self, value)
            self.frame.Value = value

            callback(value)
        end

        return checkbox

    end

    function entriesMetatable.colorpicker(self, info)

        info = info or {}

        local name = info.name or "colorpicker"
        local def = info.def or info.default or c3new(1, 0, 0)
        local alpha = info.alpha or 1
        local useAlpha = info.useAlpha or false
        local pointer = info.pointer
        local callback = info.callback or function() end

        if self.window.nameOverwrite then
            name = self.window.nameOverwrite
        end

        local colorpicker = {name = name, callback = callback}

        if pointer then
            library.pointers[pointer] = colorpicker
        end

        local cp_frame = self.frame:ColorPicker()
        cp_frame.Label = colorpicker.name
        cp_frame.Color = def
        cp_frame.UseAlpha = useAlpha
        cp_frame.Alpha = alpha

        cp_frame.OnUpdated:Connect(colorpicker.callback)

        colorpicker.frame = cp_frame

        function colorpicker.get(self)
            return self.frame.UseAlpha and {self.frame.Color, self.frame.Alpha} or {self.frame.Color}
        end

        function colorpicker.set(self, value)
            self.frame.Color = c3hsv(unpack(value[1]))

            if self.frame.UseAlpha then
                self.frame.Alpha = value[2]
            end

            callback(self.frame.Color)
        end

        return colorpicker

    end

    function entriesMetatable.combo(self, info)

        info = info or {}

        local name = info.name or "combo"
        local items = info.items or info.options or {"item 1", "item 2"}
        local def = info.def or info.default or 1
        local pointer = info.pointer
        local callback = info.callback or function() end

        if self.window.nameOverwrite then
            name = self.window.nameOverwrite
        end

        if typeof(def) == "string" then
            def = table.find(items, def)
        end

        local combo = {name = name, callback = callback}

        if pointer then
            library.pointers[pointer] = combo
        end

        local combo_frame = self.frame:Combo()
        combo_frame.Label = combo.name
        combo_frame.Items = items
        combo_frame.SelectedItem = def

        combo_frame.OnUpdated:Connect(combo.callback)

        combo.frame = combo_frame

        function combo.refresh(self, items)
            self.frame.Items = items
            self.frame.SelectedItem = 1
        end

        function combo.get(self)
            return self.frame.Items[self.frame.SelectedItem]
        end

        function combo.set(self, value)
            local selectedItem

            for index, newValue in next, self.frame.Items do
                if newValue == value then
                    selectedItem = index
                end
            end

            self.frame.SelectedItem = selectedItem

            callback(value)
        end

        return combo

    end

    function entriesMetatable.drag(self, info)

        info = info or {}

        local name = info.name or "drag"
        local speed = info.speed or 1
        local min = info.min or 0
        local max = info.max or 10
        local def = info.def or info.default or min
        local pointer = info.pointer
        local callback = info.callback or function() end

        if self.window.nameOverwrite then
            name = self.window.nameOverwrite
        end

        local drag = {name = name, callback = callback}

        if pointer then
            library.pointers[pointer] = drag
        end

        local drag_frame = self.frame:Drag()
        drag_frame.Label = drag.name
        drag_frame.Speed = speed
        drag_frame.Min = min
        drag_frame.Max = max
        drag_frame.Value = def
        
        drag_frame.OnUpdated:Connect(drag.callback)

        drag.frame = drag_frame

        function drag.get(self)
            return self.frame.Value
        end

        function drag.set(self, value)
            self.frame.Value = value

            callback(self.frame.Value)
        end

        return drag

    end

    function entriesMetatable.intdrag(self, info)

        info = info or {}

        local name = info.name or "int drag"
        local speed = info.speed or 1
        local min = info.min or 0
        local max = info.max or 10
        local def = info.def or info.default or min
        local pointer = info.pointer
        local callback = info.callback or function() end

        if self.window.nameOverwrite then
            name = self.window.nameOverwrite
        end

        local intdrag = {name = name, callback = callback}

        if pointer then
            library.pointers[pointer] = intdrag
        end

        local intdrag_frame = self.frame:IntDrag()
        intdrag_frame.Label = intdrag.name
        intdrag_frame.Speed = speed
        intdrag_frame.Min = min
        intdrag_frame.Max = max
        intdrag_frame.Value = def
        
        intdrag_frame.OnUpdated:Connect(intdrag.callback)

        intdrag.frame = intdrag_frame

        function intdrag.get(self)
            return self.frame.Value
        end

        function intdrag.set(self, value)
            self.frame.Value = value

            callback(self.frame.Value)
        end

        return intdrag

    end

    function entriesMetatable.textbox(self, info)

        info = info or {}

        local name = info.name or "textbox"
        local maxTextLength = info.mtl or info.maxTextLength or 16384
        local def = info.def or info.default or "text"
        local pointer = info.pointer
        local callback = info.callback or function() end

        if self.window.nameOverwrite then
            name = self.window.nameOverwrite
        end

        local textbox = {name = name, callback = callback}

        if pointer then
            library.pointers[pointer] = textbox
        end

        local textbox_frame = self.frame:TextBox()
        textbox_frame.Label = textbox.name
        textbox_frame.MaxTextLength = maxTextLength
        textbox_frame.Value = def

        textbox_frame.OnUpdated:Connect(textbox.callback)

        textbox.frame = textbox_frame

        function textbox.get(self)
            return self.frame.Value
        end

        function textbox.set(self, value)
            self.frame.Value = value

            callback(self.frame.Value)
        end

        return textbox

    end

    function entriesMetatable.separator(self, info)

        info = info or {}

        local separator = {}

        local separator_frame = self.frame:Separator()

        separator.frame = separator_frame

        return separator

    end

    function entriesMetatable.slider(self, info)

        info = info or {}

        local name = info.name or "slider"
        local min = info.min or 0
        local max = info.max or 10
        local def = info.def or info.default or min
        local pointer = info.pointer
        local callback = info.callback or function() end

        if self.window.nameOverwrite then
            name = self.window.nameOverwrite
        end

        local slider = {name = name, callback = callback}

        if pointer then
            library.pointers[pointer] = slider
        end

        local slider_frame = self.frame:Slider()
        slider_frame.Label = slider.name
        slider_frame.Min = min
        slider_frame.Max = max
        slider_frame.Value = def

        slider_frame.OnUpdated:Connect(slider.callback)

        slider.frame = slider_frame

        function slider.get(self)
            return self.frame.Value
        end

        function slider.set(self, value)
            self.frame.Value = value

            callback(self.frame.Value)
        end

        return slider

    end

    function entriesMetatable.intslider(self, info)

        info = info or {}

        local name = info.name or "int slider"
        local min = info.min or 0
        local max = info.max or 10
        local def = info.def or info.default or min
        local pointer = info.pointer
        local callback = info.callback or function() end

        if self.window.nameOverwrite then
            name = self.window.nameOverwrite
        end

        local intslider = {name = name, callback = callback}

        if pointer then
            library.pointers[pointer] = intslider
        end

        local intslider_frame = self.frame:IntSlider()
        intslider_frame.Label = intslider.name
        intslider_frame.Min = min
        intslider_frame.Max = max
        intslider_frame.Value = def

        intslider_frame.OnUpdated:Connect(intslider.callback)

        intslider.frame = intslider_frame

        function intslider.get(self)
            return self.frame.Value
        end

        function intslider.set(self, value)
            self.frame.Value = value

            callback(self.frame.Value)
        end

        return intslider

    end

    function entriesMetatable.keybind(self, info)

        info = info or {}

        local name = info.name or "keybind"
        local mode = info.mode or "toggle"
        local def = info.def or info.default or "Unknown"
        local pointer = info.pointer
        local callback = info.callback or function() end

        if self.window.nameOverwrite then
            name = self.window.nameOverwrite
        end

        if typeof(def) == "string" then
            def = Enum.KeyCode[def]
        end

        local keybind = {name = name, binding = false, active = false, value = def, mode = mode:lower(), callback = callback}

        if pointer then
            library.pointers[pointer] = keybind
        end

        local keybind_frame = self.frame:TextBox()
        keybind_frame.Label = keybind.name
        keybind_frame.Value = keybind.value.Name

        keybind.frame = keybind_frame

        local popup = entriesMetatable.popup({window = self.window})
        popup:button({name = "start binding", callback = function() keybind.binding = true end})
        popup:button({name = "reset keybind", callback = function() keybind.value = Enum.KeyCode.Unknown keybind.frame.Value = keybind.value.Name keybind.callback(keybind.value.Name) end})
        popup:separator()
        local popup_combo = popup:combo({name = "mode", items = {"toggle", "hold"}, def = keybind.mode, callback = function(n) keybind.mode = n == 1 and "toggle" or "hold" end})

        keybind_frame.OnUpdated:Connect(function()
            
            if keybind_frame.Value ~= keybind.value.Name then

                keybind_frame.Value = keybind.value.Name

            end

            popup:show()

        end)

        function keybind.get(self)
            return {self.value.Name, self.mode}
        end

        function keybind.isActive(self)
            return self.active
        end

        function keybind.set(self, value)

            local enumValue

            for _, method in next, {"UserInputType", "KeyCode"} do

                for _, item in next, Enum[method]:GetEnumItems() do
                    if item.Name == value[1] then
                        enumValue = item
                        break
                    end
                end

                if enumValue then
                    break
                end

            end

            self.value = enumValue
            self.frame.Value = self.value.Name
            self.mode = value[2]
            
            popup_combo:set(self.mode)

            callback(self.value.Name)

        end

        -- // yeah i thought i could make it thru library but then boom i know that i need so it toggles/other shit

        library:connect(uis.InputBegan, function(input)
            if keybind.binding then

                if input.UserInputType ~= Enum.UserInputType.Keyboard then
                    keybind:set({input.UserInputType.Name, keybind.mode})
                else
                    keybind:set({input.KeyCode.Name, keybind.mode})
                end

                keybind.binding = false

            else

                local activeValue = keybind.mode == "toggle" and not keybind.active or keybind.mode == "hold"

                if input.UserInputType == keybind.value then

                    keybind.active = activeValue

                elseif input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == keybind.value then

                    keybind.active = activeValue

                end

            end
        end)

        library:connect(uis.InputEnded, function(input)
            if keybind.mode == "hold" and keybind.active then

                if input.UserInputType == keybind.value then

                    keybind.active = false

                elseif input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == keybind.value then

                    keybind.active = false

                end

            end
        end)

        return keybind

    end

    function entriesMetatable.selectable(self, info)

        info = info or {}

        local name = info.name or "selectable"
        local size = info.size or v2zero
        local def = info.def or info.default or false
        local toggles = info.toggles or true
        local pointer = info.pointer
        local callback = info.callback or function() end

        if self.window.nameOverwrite then
            name = self.window.nameOverwrite
        end

        local selectable = {name = name, callback = callback}

        if pointer then
            library.pointers[pointer] = selectable
        end

        local selectable_frame = self.frame:Selectable()
        selectable_frame.Label = selectable.name
        selectable_frame.Size = size
        selectable_frame.Value = def
        selectable_frame.Toggles = toggles

        selectable_frame.OnUpdated:Connect(selectable.callback)

        selectable.frame = selectable_frame

        function selectable.get(self)
            return self.frame.Value
        end

        function selectable.set(self, value)
            self.frame.Value = value

            callback(self.frame.Value)
        end

        return selectable

    end

    function entriesMetatable.collapsable(self, info)

        info = info or {}

        local name = info.name or "collapsable"
        local open = info.open or false

        if self.window.nameOverwrite then
            name = self.window.nameOverwrite
        end
        
        local collapsable = {name = name, open = open, window = self.window}

        local collapsable_frame = self.frame:Collapsable(collapsable.name, collapsable.open)
        --collapsable_frame.Head

        collapsable.frame = collapsable_frame

        setmetatable(collapsable, entriesMetatable)

        return collapsable

    end

    function entriesMetatable.popup(self)

        local popup = {window = self.window}

        local popup_frame = self.window.frame:Popup()

        popup.frame = popup_frame

        function popup.show(self)
            self.frame:Show()
        end

        setmetatable(popup, entriesMetatable)

        return popup

    end

end

function library.connect(self, con, call)
    local connected = con:Connect(call)

    table.insert(self.cons, connected)

    return connected
end

function library.window(self, info)

    info = info or {}

    local name = info.name or "render object"
    local resizable = info.resizable or false
    local minSize = info.minSize or v2new(500, 600)
    local maxSize = info.maxSize or v2new(800, 900)
    local defSize = info.defSize or minSize
    local toggleKey = info.toggleKey or Enum.KeyCode.Home
    
    local window = {name = name, tabs = {}}

    local main_frame = RenderWindow.new(name)
    main_frame.CanResize = resizable
    main_frame.MinSize = minSize
    main_frame.MaxSize = maxSize
    main_frame.DefaultSize = defSize
    main_frame.VisibilityOverride = true

    local tab_menu = main_frame:TabMenu()

    window.frame = main_frame
    window.tabmenu = tab_menu

    function window.toggle(self)
        self.frame.Visible = not self.frame.Visible
    end

    function window.tab(self, info)

        info = info or {}

        local name = info.name or ("tab #%s"):format(tostring(#self.tabs))

        if self.nameOverwrite then
            name = ("%s %s"):format(tostring(self.nameOverwrite), tostring(#self.tabs))
        end

        local tab = {name = name, window = self}

        local tab_frame = self.tabmenu:Add(name)

        tab.frame = tab_frame

        setmetatable(tab, entriesMetatable)

        return tab

    end

    function window.get_config(self)

        local valuesTable = {}

        for i, v in pairs(library.pointers) do
            local value = v:get()

            if typeof(value) == "table" and typeof(value[1]) == "Color3" then
                value = {{value[1]:ToHSV()}, value[2]}
            end

            valuesTable[i] = value
        end

        return httpsservice:JSONEncode(valuesTable)
    end

    function window.load_config(self, data)
        for i, v in pairs(data) do
            if library.pointers[i] then
                library.pointers[i]:set(v)
            end
        end
    end

    function window.unload(self)
        library.active = false

        for _, connection in next, library.cons do
            connection:Disconnect()
        end

        self.frame:Remove()
    end

    function window.change_theme(self, new_theme)

        for thingName, thingValue in pairs(new_theme) do
            if theme_thingies[thingName] then
                for _, enumIndex in pairs(theme_thingies[thingName]) do
                    self.frame:SetColor(enumIndex, thingValue, 1)
                end
            end
        end

    end

    self:connect(uis.InputBegan, function(input)
        if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == toggleKey then
            window:toggle()
        end
    end)

    setmetatable(window, entriesMetatable)

    library.active = true

    return window

end

return library
