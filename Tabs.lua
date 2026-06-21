-- Tabs.lua
return function(
    GuiConfig, LayersFolder, LayersPageLayout, ScrollTab, NameTab,
    MoreBlur, DropdownFolder, DropdownSelect, DropPageLayout,
    Elements, ElementsModule, KeybindModule, Mouse, TweenService,
    getIconId, CircleClick, _, _2, CreateColorpickerElement
)
    local TweenInfo   = TweenInfo
    local UDim2       = UDim2
    local Color3      = Color3
    local Enum        = Enum

    local TabFuncs    = {}
    local TabList     = {}
    local CurrentTab  = nil
    local CountItem   = 0

    local function SelectTab(tabData)
        if CurrentTab == tabData then return end
        CurrentTab = tabData

        -- Highlight active tab button
        for _, t in ipairs(TabList) do
            local isActive = (t == tabData)
            TweenService:Create(t.Button, TweenInfo.new(0.2), {
                BackgroundColor3 = isActive
                    and Color3.fromRGB(30, 30, 38)
                    or  Color3.fromRGB(18, 18, 22),
                TextColor3 = isActive
                    and GuiConfig.Color
                    or  Color3.fromRGB(140, 140, 155),
            }):Play()
            if t.Stroke then
                TweenService:Create(t.Stroke, TweenInfo.new(0.2), {
                    Transparency = isActive and 0.25 or 0.85,
                    Color = isActive and GuiConfig.Color or Color3.fromRGB(60, 60, 70),
                }):Play()
            end
            if t.IconLabel then
                TweenService:Create(t.IconLabel, TweenInfo.new(0.2), {
                    ImageColor3 = isActive and GuiConfig.Color or Color3.fromRGB(130, 130, 145),
                }):Play()
            end
        end

        -- Show the right page
        LayersPageLayout:JumpTo(tabData.Page)
    end

    function TabFuncs:AddTab(TabConfig)
        TabConfig       = TabConfig or {}
        local tabName   = TabConfig.Name or TabConfig.Title or "Tab"
        local iconName  = TabConfig.Icon or ""

        -- Tab button
        local Button = Instance.new("TextButton")
        Button.Name            = "Tab_" .. tabName
        Button.Text            = ""
        Button.AutoButtonColor = false
        Button.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
        Button.BackgroundTransparency = 0
        Button.BorderSizePixel = 0
        Button.Size            = UDim2.new(1, -6, 0, 32)
        Button.LayoutOrder     = #TabList + 1
        Button.ClipsDescendants = true
        Button.Parent          = ScrollTab

        Instance.new("UICorner", Button).CornerRadius = UDim.new(0, 6)

        local BtnStroke = Instance.new("UIStroke")
        BtnStroke.Color       = Color3.fromRGB(60, 60, 70)
        BtnStroke.Thickness   = 1
        BtnStroke.Transparency = 0.85
        BtnStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        BtnStroke.Parent      = Button

        -- Icon
        local iconId = getIconId(iconName)
        local IconLabel = nil
        local textOffsetX = 10

        if iconId ~= "" then
            IconLabel = Instance.new("ImageLabel")
            IconLabel.BackgroundTransparency = 1
            IconLabel.BorderSizePixel = 0
            IconLabel.AnchorPoint = Vector2.new(0, 0.5)
            IconLabel.Position = UDim2.new(0, 8, 0.5, 0)
            IconLabel.Size     = UDim2.new(0, 14, 0, 14)
            IconLabel.Image    = iconId
            IconLabel.ImageColor3 = Color3.fromRGB(130, 130, 145)
            IconLabel.ScaleType   = Enum.ScaleType.Fit
            IconLabel.Parent      = Button
            textOffsetX = 26
        end

        local TabName = Instance.new("TextLabel")
        TabName.Name            = "TabName"
        TabName.Font            = Enum.Font.GothamBold
        TabName.Text            = tabName
        TabName.TextColor3      = Color3.fromRGB(140, 140, 155)
        TabName.TextSize        = 12
        TabName.TextXAlignment  = Enum.TextXAlignment.Left
        TabName.BackgroundTransparency = 1
        TabName.BorderSizePixel = 0
        TabName.AnchorPoint     = Vector2.new(0, 0.5)
        TabName.Position        = UDim2.new(0, textOffsetX, 0.5, 0)
        TabName.Size            = UDim2.new(1, -textOffsetX - 4, 1, 0)
        TabName.Parent          = Button

        -- Page frame (dalam LayersFolder)
        local Page = Instance.new("Frame")
        Page.Name              = "Page_" .. tabName
        Page.BackgroundTransparency = 1
        Page.BorderSizePixel   = 0
        Page.Size              = UDim2.new(1, 0, 1, 0)
        Page.LayoutOrder       = #TabList + 1
        Page.Parent            = LayersFolder

        -- Section scroll di dalam page
        local SectionScroll = Instance.new("ScrollingFrame")
        SectionScroll.Name   = "SectionScroll"
        SectionScroll.BackgroundTransparency = 1
        SectionScroll.BorderSizePixel = 0
        SectionScroll.Position = UDim2.new(0, 0, 0, 0)
        SectionScroll.Size    = UDim2.new(1, 0, 1, 0)
        SectionScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
        SectionScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
        SectionScroll.ScrollBarThickness  = 2
        SectionScroll.ScrollBarImageColor3 = GuiConfig.Color or Color3.fromRGB(80, 80, 90)
        SectionScroll.ScrollBarImageTransparency = 0.4
        SectionScroll.Parent = Page

        local SectionList = Instance.new("UIListLayout")
        SectionList.Padding      = UDim.new(0, 8)
        SectionList.SortOrder    = Enum.SortOrder.LayoutOrder
        SectionList.HorizontalAlignment = Enum.HorizontalAlignment.Center
        SectionList.Parent       = SectionScroll

        local SectionPad = Instance.new("UIPadding")
        SectionPad.PaddingTop    = UDim.new(0, 6)
        SectionPad.PaddingBottom = UDim.new(0, 10)
        SectionPad.PaddingLeft   = UDim.new(0, 6)
        SectionPad.PaddingRight  = UDim.new(0, 6)
        SectionPad.Parent        = SectionScroll

        local tabData = {
            Button     = Button,
            Stroke     = BtnStroke,
            IconLabel  = IconLabel,
            Page       = Page,
            SectionScroll = SectionScroll,
        }
        table.insert(TabList, tabData)

        Button.MouseButton1Click:Connect(function()
            CircleClick(Button, Mouse.X, Mouse.Y)
            SelectTab(tabData)
        end)

        if #TabList == 1 then
            SelectTab(tabData)
        end

        -- ================================================================
        --  Section API
        -- ================================================================
        local SectionFuncs = {}

        function SectionFuncs:AddSection(SectionConfig)
            SectionConfig       = SectionConfig or {}
            local sectionTitle  = SectionConfig.Title or "Section"
            local startOpen     = SectionConfig.Open ~= nil and SectionConfig.Open or true

            local SectionFrame = Instance.new("Frame")
            SectionFrame.Name  = "SectionReal"
            SectionFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
            SectionFrame.BackgroundTransparency = 0.2
            SectionFrame.BorderSizePixel = 0
            SectionFrame.Size  = UDim2.new(1, 0, 0, 32)
            SectionFrame.AutomaticSize = Enum.AutomaticSize.Y
            SectionFrame.ClipsDescendants = false
            SectionFrame.Parent = SectionScroll

            Instance.new("UICorner", SectionFrame).CornerRadius = UDim.new(0, 7)

            local SectionStroke = Instance.new("UIStroke")
            SectionStroke.Color = Color3.fromRGB(255, 255, 255)
            SectionStroke.Thickness = 1
            SectionStroke.Transparency = 0.88
            SectionStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
            SectionStroke.Parent = SectionFrame

            -- Header row
            local HeaderBtn = Instance.new("TextButton")
            HeaderBtn.Name  = "SectionHeader"
            HeaderBtn.Text  = ""
            HeaderBtn.AutoButtonColor = false
            HeaderBtn.BackgroundTransparency = 1
            HeaderBtn.BorderSizePixel = 0
            HeaderBtn.Size  = UDim2.new(1, 0, 0, 30)
            HeaderBtn.Parent = SectionFrame

            local SectionTitle = Instance.new("TextLabel")
            SectionTitle.Name  = "SectionTitle"
            SectionTitle.Font  = Enum.Font.GothamBold
            SectionTitle.Text  = sectionTitle
            SectionTitle.TextColor3 = GuiConfig.Color
            SectionTitle.TextSize   = 13
            SectionTitle.TextXAlignment = Enum.TextXAlignment.Left
            SectionTitle.BackgroundTransparency = 1
            SectionTitle.BorderSizePixel = 0
            SectionTitle.Position = UDim2.new(0, 10, 0, 0)
            SectionTitle.Size     = UDim2.new(1, -30, 1, 0)
            SectionTitle.Parent   = HeaderBtn

            local ArrowIcon = Instance.new("ImageLabel")
            ArrowIcon.BackgroundTransparency = 1
            ArrowIcon.BorderSizePixel = 0
            ArrowIcon.AnchorPoint = Vector2.new(1, 0.5)
            ArrowIcon.Position = UDim2.new(1, -10, 0.5, 0)
            ArrowIcon.Size = UDim2.new(0, 14, 0, 14)
            ArrowIcon.Image = getIconId("lucide:chevron-right")
            ArrowIcon.ImageColor3 = Color3.fromRGB(140, 140, 155)
            ArrowIcon.ScaleType = Enum.ScaleType.Fit
            ArrowIcon.Rotation = startOpen and 90 or 0
            ArrowIcon.Parent = HeaderBtn

            -- Divider
            local Divider = Instance.new("Frame")
            Divider.BackgroundColor3 = GuiConfig.Color
            Divider.BackgroundTransparency = 0.78
            Divider.BorderSizePixel = 0
            Divider.Size = UDim2.new(1, -16, 0, 1)
            Divider.Position = UDim2.new(0, 8, 0, 30)
            Divider.Parent = SectionFrame

            -- Content frame
            local ContentFrame = Instance.new("Frame")
            ContentFrame.Name  = "SectionContent"
            ContentFrame.BackgroundTransparency = 1
            ContentFrame.BorderSizePixel = 0
            ContentFrame.Position = UDim2.new(0, 0, 0, 32)
            ContentFrame.Size     = UDim2.new(1, 0, 0, 0)
            ContentFrame.AutomaticSize = Enum.AutomaticSize.Y
            ContentFrame.Visible = startOpen
            ContentFrame.Parent  = SectionFrame

            Divider.Visible = startOpen

            local ContentList = Instance.new("UIListLayout")
            ContentList.Padding   = UDim.new(0, 4)
            ContentList.SortOrder = Enum.SortOrder.LayoutOrder
            ContentList.HorizontalAlignment = Enum.HorizontalAlignment.Center
            ContentList.Parent    = ContentFrame

            local ContentPad = Instance.new("UIPadding")
            ContentPad.PaddingTop    = UDim.new(0, 4)
            ContentPad.PaddingBottom = UDim.new(0, 8)
            ContentPad.PaddingLeft   = UDim.new(0, 6)
            ContentPad.PaddingRight  = UDim.new(0, 6)
            ContentPad.Parent        = ContentFrame

            -- Collapse toggle dengan animasi
            local isAnimating = false
            HeaderBtn.MouseButton1Click:Connect(function()
                if isAnimating then return end
                isAnimating = true

                local open = not ContentFrame.Visible

                -- Animasi arrow rotate: kanan = tertutup, bawah = terbuka
                TweenService:Create(ArrowIcon, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                    Rotation = open and 90 or 0,
                    ImageColor3 = open and GuiConfig.Color or Color3.fromRGB(140, 140, 155)
                }):Play()

                -- Animasi header background flash
                TweenService:Create(HeaderBtn, TweenInfo.new(0.1), {
                    BackgroundTransparency = 0.85
                }):Play()
                task.delay(0.1, function()
                    TweenService:Create(HeaderBtn, TweenInfo.new(0.15), {
                        BackgroundTransparency = 1
                    }):Play()
                end)

                if open then
                    ContentFrame.Visible = true
                    Divider.Visible = true
                    TweenService:Create(Divider, TweenInfo.new(0.2), {
                        BackgroundTransparency = 0.78
                    }):Play()
                else
                    TweenService:Create(Divider, TweenInfo.new(0.15), {
                        BackgroundTransparency = 1
                    }):Play()
                    task.delay(0.15, function()
                        ContentFrame.Visible = false
                    end)
                end

                -- Animasi stroke section saat diklik
                TweenService:Create(SectionStroke, TweenInfo.new(0.15), {
                    Transparency = 0.4,
                    Color = GuiConfig.Color
                }):Play()
                task.delay(0.3, function()
                    TweenService:Create(SectionStroke, TweenInfo.new(0.3), {
                        Transparency = 0.88,
                        Color = Color3.fromRGB(255, 255, 255)
                    }):Play()
                    isAnimating = false
                end)
            end)

            -- ============================================================
            --  Item API
            -- ============================================================
            local ItemFuncs = {}
            ItemFuncs._sectionAdd = ContentFrame

            local function MakeItemWrapper(height)
                height = height or 32
                local Row = Instance.new("Frame")
                Row.BackgroundTransparency = 1
                Row.BorderSizePixel = 0
                Row.Size = UDim2.new(1, 0, 0, height)
                Row.AutomaticSize = Enum.AutomaticSize.Y
                Row.Parent = ContentFrame
                return Row
            end

            -- ── Toggle ──────────────────────────────────────────────────
            function ItemFuncs:AddToggle(Cfg)
                Cfg = Cfg or {}
                local title   = Cfg.Title or "Toggle"
                local default = Cfg.Default or false
                local cb      = Cfg.Callback or function() end

                local Row = MakeItemWrapper(30)

                local Label = Instance.new("TextLabel")
                Label.Text  = title
                Label.Font  = Enum.Font.Gotham
                Label.TextSize = 12
                Label.TextColor3 = Color3.fromRGB(210, 210, 220)
                Label.TextXAlignment = Enum.TextXAlignment.Left
                Label.BackgroundTransparency = 1
                Label.BorderSizePixel = 0
                Label.Position = UDim2.new(0, 6, 0, 0)
                Label.Size     = UDim2.new(1, -52, 1, 0)
                Label.TextTruncate = Enum.TextTruncate.AtEnd
                Label.Parent   = Row

                local TrackBG = Instance.new("Frame")
                TrackBG.AnchorPoint = Vector2.new(1, 0.5)
                TrackBG.Position = UDim2.new(1, -6, 0.5, 0)
                TrackBG.Size = UDim2.new(0, 36, 0, 18)
                TrackBG.BackgroundColor3 = default and GuiConfig.Color or Color3.fromRGB(50, 50, 60)
                TrackBG.BorderSizePixel = 0
                TrackBG.Parent = Row
                Instance.new("UICorner", TrackBG).CornerRadius = UDim.new(1, 0)

                local Knob = Instance.new("Frame")
                Knob.Size = UDim2.new(0, 12, 0, 12)
                Knob.AnchorPoint = Vector2.new(0.5, 0.5)
                Knob.Position = default and UDim2.new(0.72, 0, 0.5, 0) or UDim2.new(0.28, 0, 0.5, 0)
                Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                Knob.BorderSizePixel = 0
                Knob.Parent = TrackBG
                Instance.new("UICorner", Knob).CornerRadius = UDim.new(1, 0)

                local value = default

                local ClickBtn = Instance.new("TextButton")
                ClickBtn.Text = ""
                ClickBtn.BackgroundTransparency = 1
                ClickBtn.Size = UDim2.new(1, 0, 1, 0)
                ClickBtn.Parent = Row

                local function SetValue(v)
                    value = v
                    TweenService:Create(TrackBG, TweenInfo.new(0.18), {
                        BackgroundColor3 = v and GuiConfig.Color or Color3.fromRGB(50, 50, 60)
                    }):Play()
                    TweenService:Create(Knob, TweenInfo.new(0.18), {
                        Position = v and UDim2.new(0.72, 0, 0.5, 0) or UDim2.new(0.28, 0, 0.5, 0)
                    }):Play()
                end

                ClickBtn.MouseButton1Click:Connect(function()
                    SetValue(not value)
                    pcall(cb, value)
                end)

                local api = {}
                api.Value = value
                function api:Set(v)
                    SetValue(v)
                    value = v
                    api.Value = v
                end
                function api:GetValue() return value end
                api.Type = "Toggle"
                return api
            end

            -- ── Button ───────────────────────────────────────────────────
            function ItemFuncs:AddButton(Cfg)
                Cfg = Cfg or {}
                local title = Cfg.Title or "Button"
                local cb    = Cfg.Callback or function() end

                local Row = MakeItemWrapper(30)

                local Btn = Instance.new("TextButton")
                Btn.Text = title
                Btn.Font = Enum.Font.GothamBold
                Btn.TextSize = 12
                Btn.TextColor3 = Color3.fromRGB(220, 220, 230)
                Btn.AutoButtonColor = false
                Btn.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
                Btn.BorderSizePixel = 0
                Btn.Size = UDim2.new(1, 0, 1, 0)
                Btn.Parent = Row
                Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 5)

                local BtnStroke2 = Instance.new("UIStroke")
                BtnStroke2.Color = GuiConfig.Color
                BtnStroke2.Thickness = 1
                BtnStroke2.Transparency = 0.6
                BtnStroke2.Parent = Btn

                Btn.MouseButton1Click:Connect(function()
                    CircleClick(Btn, Mouse.X, Mouse.Y)
                    pcall(cb)
                end)

                local api = {}
                return api
            end

            -- ── Slider ───────────────────────────────────────────────────
            function ItemFuncs:AddSlider(Cfg)
                Cfg = Cfg or {}
                local title     = Cfg.Title    or "Slider"
                local min       = Cfg.Min       or 0
                local max       = Cfg.Max       or 100
                local default   = Cfg.Default   or min
                local increment = Cfg.Increment or 1
                local cb        = Cfg.Callback  or function() end

                local Row = MakeItemWrapper(46)

                local TitleLbl = Instance.new("TextLabel")
                TitleLbl.Text  = title
                TitleLbl.Font  = Enum.Font.Gotham
                TitleLbl.TextSize = 12
                TitleLbl.TextColor3 = Color3.fromRGB(200, 200, 215)
                TitleLbl.TextXAlignment = Enum.TextXAlignment.Left
                TitleLbl.BackgroundTransparency = 1
                TitleLbl.BorderSizePixel = 0
                TitleLbl.Position = UDim2.new(0, 6, 0, 2)
                TitleLbl.Size     = UDim2.new(0.7, 0, 0, 18)
                TitleLbl.Parent   = Row

                local ValueLbl = Instance.new("TextLabel")
                ValueLbl.Text  = tostring(default)
                ValueLbl.Font  = Enum.Font.GothamBold
                ValueLbl.TextSize = 12
                ValueLbl.TextColor3 = GuiConfig.Color
                ValueLbl.TextXAlignment = Enum.TextXAlignment.Right
                ValueLbl.BackgroundTransparency = 1
                ValueLbl.BorderSizePixel = 0
                ValueLbl.AnchorPoint = Vector2.new(1, 0)
                ValueLbl.Position = UDim2.new(1, -6, 0, 2)
                ValueLbl.Size     = UDim2.new(0.3, 0, 0, 18)
                ValueLbl.Parent   = Row

                local TrackBG = Instance.new("Frame")
                TrackBG.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
                TrackBG.BorderSizePixel = 0
                TrackBG.Position = UDim2.new(0, 6, 0, 26)
                TrackBG.Size     = UDim2.new(1, -12, 0, 6)
                TrackBG.Parent   = Row
                Instance.new("UICorner", TrackBG).CornerRadius = UDim.new(1, 0)

                local fillRatio = math.clamp((default - min) / (max - min), 0, 1)

                local Fill = Instance.new("Frame")
                Fill.BackgroundColor3 = GuiConfig.Color
                Fill.BorderSizePixel = 0
                Fill.Size = UDim2.new(fillRatio, 0, 1, 0)
                Fill.Parent = TrackBG
                Instance.new("UICorner", Fill).CornerRadius = UDim.new(1, 0)

                local Knob = Instance.new("Frame")
                Knob.AnchorPoint = Vector2.new(0.5, 0.5)
                Knob.Position = UDim2.new(fillRatio, 0, 0.5, 0)
                Knob.Size = UDim2.new(0, 12, 0, 12)
                Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                Knob.BorderSizePixel = 0
                Knob.ZIndex = 2
                Knob.Parent = TrackBG
                Instance.new("UICorner", Knob).CornerRadius = UDim.new(1, 0)

                local value = default
                local dragging = false

                local function SetSlider(v)
                    v = math.clamp(v, min, max)
                    if increment > 0 then
                        v = math.round((v - min) / increment) * increment + min
                    end
                    v = math.clamp(v, min, max)
                    value = v
                    local r = (v - min) / (max - min)
                    Fill.Size = UDim2.new(r, 0, 1, 0)
                    Knob.Position = UDim2.new(r, 0, 0.5, 0)
                    ValueLbl.Text = tostring(v)
                end

                local ClickArea = Instance.new("TextButton")
                ClickArea.Text = ""
                ClickArea.BackgroundTransparency = 1
                ClickArea.Size = UDim2.new(1, 0, 1, 0)
                ClickArea.ZIndex = 3
                ClickArea.Parent = TrackBG

                local function UpdateFromInput(inputPos)
                    local absPos  = TrackBG.AbsolutePosition
                    local absSize = TrackBG.AbsoluteSize
                    local ratio   = math.clamp((inputPos.X - absPos.X) / absSize.X, 0, 1)
                    local v       = min + ratio * (max - min)
                    SetSlider(v)
                    pcall(cb, value)
                end

                ClickArea.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or
                       input.UserInputType == Enum.UserInputType.Touch then
                        dragging = true
                        UpdateFromInput(input.Position)
                    end
                end)
                game:GetService("UserInputService").InputChanged:Connect(function(input)
                    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or
                                     input.UserInputType == Enum.UserInputType.Touch) then
                        UpdateFromInput(input.Position)
                    end
                end)
                game:GetService("UserInputService").InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or
                       input.UserInputType == Enum.UserInputType.Touch then
                        dragging = false
                    end
                end)

                local api = {}
                api.Value = value
                function api:Set(v) SetSlider(v) api.Value = value end
                function api:GetValue() return value end
                api.Type = "Slider"
                return api
            end

            -- ── Dropdown ─────────────────────────────────────────────────
            function ItemFuncs:AddDropdown(Cfg)
                Cfg = Cfg or {}
                local title   = Cfg.Title   or "Dropdown"
                local options = Cfg.Options  or {}
                local default = Cfg.Default  or (options[1] or nil)
                local cb      = Cfg.Callback or function() end
                local multi   = Cfg.Multi    or false

                local currentValue = default
                local isOpen = false

                local Row = MakeItemWrapper(30)

                local TitleLbl = Instance.new("TextLabel")
                TitleLbl.Text  = title
                TitleLbl.Font  = Enum.Font.Gotham
                TitleLbl.TextSize = 12
                TitleLbl.TextColor3 = Color3.fromRGB(200, 200, 215)
                TitleLbl.TextXAlignment = Enum.TextXAlignment.Left
                TitleLbl.BackgroundTransparency = 1
                TitleLbl.BorderSizePixel = 0
                TitleLbl.Position = UDim2.new(0, 6, 0, 0)
                TitleLbl.Size     = UDim2.new(0.45, 0, 1, 0)
                TitleLbl.TextTruncate = Enum.TextTruncate.AtEnd
                TitleLbl.Parent   = Row

                local DropBtn = Instance.new("TextButton")
                DropBtn.Text = tostring(default or "")
                DropBtn.Font = Enum.Font.Gotham
                DropBtn.TextSize = 11
                DropBtn.TextColor3 = Color3.fromRGB(190, 190, 205)
                DropBtn.TextXAlignment = Enum.TextXAlignment.Left
                DropBtn.AutoButtonColor = false
                DropBtn.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
                DropBtn.BorderSizePixel = 0
                DropBtn.AnchorPoint = Vector2.new(1, 0.5)
                DropBtn.Position = UDim2.new(1, -6, 0.5, 0)
                DropBtn.Size = UDim2.new(0.5, 0, 0, 22)
                DropBtn.Parent = Row
                Instance.new("UICorner", DropBtn).CornerRadius = UDim.new(0, 5)
                Instance.new("UIStroke", DropBtn).Color = Color3.fromRGB(55, 55, 68)

                local ArrowLbl = Instance.new("TextLabel")
                ArrowLbl.Text = "▾"
                ArrowLbl.Font = Enum.Font.GothamBold
                ArrowLbl.TextSize = 12
                ArrowLbl.TextColor3 = Color3.fromRGB(130, 130, 145)
                ArrowLbl.BackgroundTransparency = 1
                ArrowLbl.AnchorPoint = Vector2.new(1, 0.5)
                ArrowLbl.Position = UDim2.new(1, -4, 0.5, 0)
                ArrowLbl.Size = UDim2.new(0, 14, 1, 0)
                ArrowLbl.Parent = DropBtn

                local PadBtn = Instance.new("UIPadding")
                PadBtn.PaddingLeft = UDim.new(0, 6)
                PadBtn.PaddingRight = UDim.new(0, 16)
                PadBtn.Parent = DropBtn

                -- Dropdown overlay
                local OverlayGui = nil

                local function CloseOverlay()
                    if OverlayGui then
                        OverlayGui:Destroy()
                        OverlayGui = nil
                    end
                    isOpen = false
                    ArrowLbl.Text = "▾"
                end

                local function OpenOverlay()
                    if isOpen then CloseOverlay() return end
                    isOpen = true
                    ArrowLbl.Text = "▴"

                    OverlayGui = Instance.new("ScreenGui")
                    OverlayGui.Name = "DropdownOverlay"
                    OverlayGui.ResetOnSpawn = false
                    OverlayGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
                    OverlayGui.Parent = game:GetService("CoreGui")

                    local CloseDetect = Instance.new("TextButton")
                    CloseDetect.Text = ""
                    CloseDetect.BackgroundTransparency = 1
                    CloseDetect.Size = UDim2.new(1, 0, 1, 0)
                    CloseDetect.ZIndex = 10
                    CloseDetect.Parent = OverlayGui
                    CloseDetect.MouseButton1Click:Connect(CloseOverlay)

                    local absPos  = DropBtn.AbsolutePosition
                    local absSize = DropBtn.AbsoluteSize
                    local listH   = math.min(#options * 26 + 8, 160)

                    local ListFrame = Instance.new("Frame")
                    ListFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
                    ListFrame.BorderSizePixel  = 0
                    ListFrame.Position = UDim2.new(0, absPos.X, 0, absPos.Y + absSize.Y + 2)
                    ListFrame.Size     = UDim2.new(0, absSize.X, 0, listH)
                    ListFrame.ZIndex   = 20
                    ListFrame.ClipsDescendants = true
                    ListFrame.Parent   = OverlayGui
                    Instance.new("UICorner", ListFrame).CornerRadius = UDim.new(0, 6)
                    local LS = Instance.new("UIStroke", ListFrame)
                    LS.Color = Color3.fromRGB(55, 55, 68)
                    LS.Thickness = 1

                    local ListScroll = Instance.new("ScrollingFrame")
                    ListScroll.BackgroundTransparency = 1
                    ListScroll.BorderSizePixel = 0
                    ListScroll.Size = UDim2.new(1, 0, 1, 0)
                    ListScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
                    ListScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
                    ListScroll.ScrollBarThickness  = 2
                    ListScroll.ZIndex = 20
                    ListScroll.Parent = ListFrame

                    local ItemList = Instance.new("UIListLayout")
                    ItemList.SortOrder = Enum.SortOrder.LayoutOrder
                    ItemList.Padding   = UDim.new(0, 2)
                    ItemList.Parent    = ListScroll

                    local IPad = Instance.new("UIPadding")
                    IPad.PaddingTop    = UDim.new(0, 4)
                    IPad.PaddingBottom = UDim.new(0, 4)
                    IPad.PaddingLeft   = UDim.new(0, 4)
                    IPad.PaddingRight  = UDim.new(0, 4)
                    IPad.Parent        = ListScroll

                    for _, opt in ipairs(options) do
                        local OptBtn = Instance.new("TextButton")
                        OptBtn.Text = tostring(opt)
                        OptBtn.Font = Enum.Font.Gotham
                        OptBtn.TextSize = 11
                        OptBtn.TextXAlignment = Enum.TextXAlignment.Left
                        OptBtn.AutoButtonColor = false
                        OptBtn.BackgroundColor3 = (currentValue == opt)
                            and Color3.fromRGB(35, 35, 46)
                            or  Color3.fromRGB(28, 28, 36)
                        OptBtn.TextColor3 = (currentValue == opt)
                            and GuiConfig.Color
                            or  Color3.fromRGB(190, 190, 205)
                        OptBtn.BorderSizePixel = 0
                        OptBtn.Size = UDim2.new(1, 0, 0, 24)
                        OptBtn.ZIndex = 20
                        OptBtn.Parent = ListScroll
                        Instance.new("UICorner", OptBtn).CornerRadius = UDim.new(0, 4)

                        local OPad = Instance.new("UIPadding")
                        OPad.PaddingLeft = UDim.new(0, 6)
                        OPad.Parent = OptBtn

                        OptBtn.MouseButton1Click:Connect(function()
                            currentValue = opt
                            DropBtn.Text = tostring(opt)
                            CloseOverlay()
                            pcall(cb, opt)
                        end)
                    end
                end

                DropBtn.MouseButton1Click:Connect(OpenOverlay)

                local api = {}
                api.Value = currentValue
                function api:Set(v)
                    currentValue = v
                    DropBtn.Text = tostring(v or "")
                    api.Value = v
                end
                function api:SetOptions(newOptions)
                    options = newOptions
                    if not table.find(options, currentValue) then
                        currentValue = options[1]
                        DropBtn.Text = tostring(currentValue or "")
                    end
                end
                api.Refresh = api.SetOptions
                api.SetValues = api.SetOptions
                api.UpdateOptions = api.SetOptions
                function api:GetValue() return currentValue end
                api.Type = "Dropdown"
                return api
            end

            -- ── Input ────────────────────────────────────────────────────
            function ItemFuncs:AddInput(Cfg)
                Cfg = Cfg or {}
                local title   = Cfg.Title   or "Input"
                local default = Cfg.Default  or ""
                local cb      = Cfg.Callback or function() end
                local ph      = Cfg.Placeholder or "Type here..."

                local Row = MakeItemWrapper(48)

                local TitleLbl = Instance.new("TextLabel")
                TitleLbl.Text  = title
                TitleLbl.Font  = Enum.Font.Gotham
                TitleLbl.TextSize = 12
                TitleLbl.TextColor3 = Color3.fromRGB(200, 200, 215)
                TitleLbl.TextXAlignment = Enum.TextXAlignment.Left
                TitleLbl.BackgroundTransparency = 1
                TitleLbl.BorderSizePixel = 0
                TitleLbl.Position = UDim2.new(0, 6, 0, 2)
                TitleLbl.Size     = UDim2.new(1, -12, 0, 16)
                TitleLbl.Parent   = Row

                local InputBox = Instance.new("TextBox")
                InputBox.Text  = tostring(default)
                InputBox.PlaceholderText = ph
                InputBox.Font  = Enum.Font.Gotham
                InputBox.TextSize = 11
                InputBox.TextColor3 = Color3.fromRGB(210, 210, 225)
                InputBox.PlaceholderColor3 = Color3.fromRGB(90, 90, 105)
                InputBox.TextXAlignment = Enum.TextXAlignment.Left
                InputBox.BackgroundColor3 = Color3.fromRGB(16, 16, 22)
                InputBox.BorderSizePixel = 0
                InputBox.ClearTextOnFocus = false
                InputBox.Position = UDim2.new(0, 6, 0, 22)
                InputBox.Size     = UDim2.new(1, -12, 0, 22)
                InputBox.Parent   = Row
                Instance.new("UICorner", InputBox).CornerRadius = UDim.new(0, 5)

                local IBPad = Instance.new("UIPadding")
                IBPad.PaddingLeft = UDim.new(0, 6)
                IBPad.Parent = InputBox

                local IBStroke = Instance.new("UIStroke")
                IBStroke.Color = Color3.fromRGB(55, 55, 68)
                IBStroke.Thickness = 1
                IBStroke.Parent = InputBox

                InputBox.Focused:Connect(function()
                    TweenService:Create(IBStroke, TweenInfo.new(0.15), {
                        Color = GuiConfig.Color, Transparency = 0.2
                    }):Play()
                end)
                InputBox.FocusLost:Connect(function(enter)
                    TweenService:Create(IBStroke, TweenInfo.new(0.15), {
                        Color = Color3.fromRGB(55, 55, 68), Transparency = 0
                    }):Play()
                    pcall(cb, InputBox.Text)
                end)

                local api = {}
                api.Value = InputBox.Text
                function api:Set(v) InputBox.Text = tostring(v or "") api.Value = InputBox.Text end
                function api:GetValue() return InputBox.Text end
                api.Type = "Input"
                return api
            end

            -- ── Keybind ──────────────────────────────────────────────────
            function ItemFuncs:AddKeybind(Cfg)
                Cfg = Cfg or {}
                local title   = Cfg.Title    or "Keybind"
                local default = Cfg.Value     or "None"
                local cb      = Cfg.Callback  or function() end

                local currentKey = default
                local listening  = false

                local Row = MakeItemWrapper(30)

                local TitleLbl = Instance.new("TextLabel")
                TitleLbl.Text  = title
                TitleLbl.Font  = Enum.Font.Gotham
                TitleLbl.TextSize = 12
                TitleLbl.TextColor3 = Color3.fromRGB(200, 200, 215)
                TitleLbl.TextXAlignment = Enum.TextXAlignment.Left
                TitleLbl.BackgroundTransparency = 1
                TitleLbl.BorderSizePixel = 0
                TitleLbl.Position = UDim2.new(0, 6, 0, 0)
                TitleLbl.Size     = UDim2.new(0.55, 0, 1, 0)
                TitleLbl.TextTruncate = Enum.TextTruncate.AtEnd
                TitleLbl.Parent   = Row

                local KeyBtn = Instance.new("TextButton")
                KeyBtn.Text = "[" .. tostring(currentKey) .. "]"
                KeyBtn.Font = Enum.Font.GothamBold
                KeyBtn.TextSize = 11
                KeyBtn.TextColor3 = GuiConfig.Color
                KeyBtn.AutoButtonColor = false
                KeyBtn.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
                KeyBtn.BorderSizePixel = 0
                KeyBtn.AnchorPoint = Vector2.new(1, 0.5)
                KeyBtn.Position = UDim2.new(1, -6, 0.5, 0)
                KeyBtn.Size = UDim2.new(0.4, 0, 0, 22)
                KeyBtn.Parent = Row
                Instance.new("UICorner", KeyBtn).CornerRadius = UDim.new(0, 5)
                Instance.new("UIStroke", KeyBtn).Color = Color3.fromRGB(55, 55, 68)

                KeyBtn.MouseButton1Click:Connect(function()
                    if listening then return end
                    listening = true
                    KeyBtn.Text = "..."
                    KeyBtn.TextColor3 = Color3.fromRGB(255, 255, 100)
                end)

                game:GetService("UserInputService").InputBegan:Connect(function(input, gpe)
                    if not listening then return end
                    if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
                    listening = false
                    local keyName = input.KeyCode.Name
                    currentKey = keyName
                    KeyBtn.Text = "[" .. keyName .. "]"
                    KeyBtn.TextColor3 = GuiConfig.Color
                    pcall(cb, input.KeyCode)
                end)

                local api = {}
                api.Value = currentKey
                function api:Set(v) currentKey = tostring(v) KeyBtn.Text = "[" .. currentKey .. "]" end
                return api
            end

            -- ── Paragraph ────────────────────────────────────────────────
            function ItemFuncs:AddParagraph(Cfg)
                Cfg = Cfg or {}
                local ptitle   = Cfg.Title   or ""
                local pcontent = Cfg.Content or ""

                local Row = Instance.new("Frame")
                Row.BackgroundTransparency = 1
                Row.BorderSizePixel = 0
                Row.Size = UDim2.new(1, 0, 0, 0)
                Row.AutomaticSize = Enum.AutomaticSize.Y
                Row.Parent = ContentFrame

                if ptitle ~= "" then
                    local TL = Instance.new("TextLabel")
                    TL.Text  = ptitle
                    TL.Font  = Enum.Font.GothamBold
                    TL.TextSize = 13
                    TL.TextColor3 = GuiConfig.Color
                    TL.TextXAlignment = Enum.TextXAlignment.Left
                    TL.TextWrapped = true
                    TL.BackgroundTransparency = 1
                    TL.BorderSizePixel = 0
                    TL.Size = UDim2.new(1, -12, 0, 0)
                    TL.AutomaticSize = Enum.AutomaticSize.Y
                    TL.Position = UDim2.new(0, 6, 0, 4)
                    TL.Parent = Row
                end

                if pcontent ~= "" then
                    local off = (ptitle ~= "") and 24 or 4
                    local CL = Instance.new("TextLabel")
                    CL.Text  = pcontent
                    CL.Font  = Enum.Font.Gotham
                    CL.TextSize = 11
                    CL.TextColor3 = Color3.fromRGB(170, 170, 185)
                    CL.TextXAlignment = Enum.TextXAlignment.Left
                    CL.TextWrapped = true
                    CL.BackgroundTransparency = 1
                    CL.BorderSizePixel = 0
                    CL.Size = UDim2.new(1, -12, 0, 0)
                    CL.AutomaticSize = Enum.AutomaticSize.Y
                    CL.Position = UDim2.new(0, 6, 0, off)
                    CL.Parent = Row
                end

                return {}
            end

            -- ── ColorPicker placeholder ───────────────────────────────────
            function ItemFuncs:AddColorPicker(Cfg)
                Cfg = Cfg or {}
                -- Diarahkan ke _CreateColorpickerElement dari main module
                if CreateColorpickerElement then
                    CountItem = CountItem + 1
                    return CreateColorpickerElement(ContentFrame, Cfg, CountItem, {})
                end
                return {}
            end
            ItemFuncs.AddColorpicker = ItemFuncs.AddColorPicker

            return ItemFuncs
        end

        return SectionFuncs
    end

    return TabFuncs
end
