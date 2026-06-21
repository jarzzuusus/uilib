-- Colorpicker.lua
return function(TweenService, UserInputService, CoreGui, getIconId, _, __, ___, ElementsModule)
    local module = {}

    function module.MakeColorPicker(Config, SectionAdd, CountItem, AccentColor, MainDropShadow)
        Config          = Config or {}
        local title     = Config.Title    or "Color"
        local default   = Config.Default   or Color3.fromRGB(255, 0, 0)
        local cb        = Config.Callback  or function() end

        local currentColor = default

        -- ── Row dalam section ─────────────────────────────────────────
        local Row = Instance.new("Frame")
        Row.BackgroundTransparency = 1
        Row.BorderSizePixel = 0
        Row.Size = UDim2.new(1, 0, 0, 30)
        Row.Parent = SectionAdd

        local TitleLbl = Instance.new("TextLabel")
        TitleLbl.Text  = title
        TitleLbl.Font  = Enum.Font.Gotham
        TitleLbl.TextSize = 12
        TitleLbl.TextColor3 = Color3.fromRGB(200, 200, 215)
        TitleLbl.TextXAlignment = Enum.TextXAlignment.Left
        TitleLbl.BackgroundTransparency = 1
        TitleLbl.BorderSizePixel = 0
        TitleLbl.Position = UDim2.new(0, 6, 0, 0)
        TitleLbl.Size     = UDim2.new(1, -44, 1, 0)
        TitleLbl.TextTruncate = Enum.TextTruncate.AtEnd
        TitleLbl.Parent   = Row

        -- Color preview swatch (opens picker)
        local Swatch = Instance.new("TextButton")
        Swatch.Text = ""
        Swatch.AutoButtonColor = false
        Swatch.BackgroundColor3 = currentColor
        Swatch.BorderSizePixel  = 0
        Swatch.AnchorPoint = Vector2.new(1, 0.5)
        Swatch.Position = UDim2.new(1, -6, 0.5, 0)
        Swatch.Size = UDim2.new(0, 28, 0, 18)
        Swatch.Parent = Row
        Instance.new("UICorner", Swatch).CornerRadius = UDim.new(0, 5)

        local SwatchStroke = Instance.new("UIStroke")
        SwatchStroke.Color = Color3.fromRGB(255, 255, 255)
        SwatchStroke.Thickness = 1
        SwatchStroke.Transparency = 0.65
        SwatchStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        SwatchStroke.Parent = Swatch

        -- ── Floating picker window ─────────────────────────────────────
        local PickerGui = nil

        local function ClosePicker()
            if PickerGui then PickerGui:Destroy() PickerGui = nil end
        end

        local function HSVtoColor(h, s, v)
            return Color3.fromHSV(h, s, v)
        end

        local function OpenPicker()
            if PickerGui then ClosePicker() return end

            PickerGui = Instance.new("ScreenGui")
            PickerGui.Name = "ColorPickerOverlay_" .. tostring(CountItem)
            PickerGui.ResetOnSpawn = false
            PickerGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
            PickerGui.Parent = CoreGui

            -- Backdrop close
            local Backdrop = Instance.new("TextButton")
            Backdrop.Text = ""
            Backdrop.BackgroundTransparency = 1
            Backdrop.Size = UDim2.new(1, 0, 1, 0)
            Backdrop.ZIndex = 50
            Backdrop.Parent = PickerGui
            Backdrop.MouseButton1Click:Connect(ClosePicker)

            -- Picker card
            local Card = Instance.new("Frame")
            Card.Name = "PickerCard"
            Card.BackgroundColor3 = Color3.fromRGB(20, 20, 27)
            Card.BorderSizePixel  = 0
            Card.ZIndex           = 51
            Card.Size             = UDim2.new(0, 220, 0, 260)
            Card.AnchorPoint      = Vector2.new(0.5, 0.5)
            Card.Position         = UDim2.new(0.5, 0, 0.5, 0)
            Card.Parent           = PickerGui
            Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 8)

            local CardStroke = Instance.new("UIStroke")
            CardStroke.Color = AccentColor
            CardStroke.Thickness = 1.2
            CardStroke.Transparency = 0.5
            CardStroke.Parent = Card

            -- Title
            local CardTitle = Instance.new("TextLabel")
            CardTitle.Text  = title
            CardTitle.Font  = Enum.Font.GothamBold
            CardTitle.TextSize = 13
            CardTitle.TextColor3 = Color3.fromRGB(220, 220, 235)
            CardTitle.BackgroundTransparency = 1
            CardTitle.BorderSizePixel = 0
            CardTitle.Position = UDim2.new(0, 12, 0, 8)
            CardTitle.Size     = UDim2.new(1, -24, 0, 18)
            CardTitle.ZIndex   = 52
            CardTitle.Parent   = Card

            local h, s, v = Color3.toHSV(currentColor)

            -- SV Square
            local SatValFrame = Instance.new("ImageLabel")
            SatValFrame.Name = "SatValSquare"
            SatValFrame.Image = "rbxassetid://698052001"  -- white → transparent gradient
            SatValFrame.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
            SatValFrame.BorderSizePixel = 0
            SatValFrame.Position = UDim2.new(0, 12, 0, 32)
            SatValFrame.Size     = UDim2.new(1, -24, 0, 120)
            SatValFrame.ZIndex   = 52
            SatValFrame.Parent   = Card
            Instance.new("UICorner", SatValFrame).CornerRadius = UDim.new(0, 5)

            -- Saturation overlay (black)
            local BlackOverlay = Instance.new("ImageLabel")
            BlackOverlay.Image = "rbxassetid://698052001"
            BlackOverlay.ImageColor3 = Color3.fromRGB(0, 0, 0)
            BlackOverlay.Rotation = 90
            BlackOverlay.BackgroundTransparency = 1
            BlackOverlay.BorderSizePixel = 0
            BlackOverlay.Size = UDim2.new(1, 0, 1, 0)
            BlackOverlay.ZIndex = 53
            BlackOverlay.Parent = SatValFrame

            -- SV cursor
            local SVCursor = Instance.new("Frame")
            SVCursor.Name = "SVCursor"
            SVCursor.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            SVCursor.BorderSizePixel = 0
            SVCursor.AnchorPoint = Vector2.new(0.5, 0.5)
            SVCursor.Size = UDim2.new(0, 10, 0, 10)
            SVCursor.ZIndex = 54
            SVCursor.Position = UDim2.new(s, 0, 1 - v, 0)
            SVCursor.Parent = SatValFrame
            Instance.new("UICorner", SVCursor).CornerRadius = UDim.new(1, 0)

            -- Hue slider
            local HueBar = Instance.new("ImageLabel")
            HueBar.Name = "HueBar"
            HueBar.Image = "rbxassetid://698053051"
            HueBar.BackgroundTransparency = 1
            HueBar.BorderSizePixel = 0
            HueBar.Position = UDim2.new(0, 12, 0, 162)
            HueBar.Size     = UDim2.new(1, -24, 0, 16)
            HueBar.ZIndex   = 52
            HueBar.Parent   = Card
            Instance.new("UICorner", HueBar).CornerRadius = UDim.new(1, 0)

            local HueCursor = Instance.new("Frame")
            HueCursor.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            HueCursor.BorderSizePixel = 0
            HueCursor.AnchorPoint = Vector2.new(0.5, 0.5)
            HueCursor.Size = UDim2.new(0, 8, 1, 4)
            HueCursor.ZIndex = 53
            HueCursor.Position = UDim2.new(h, 0, 0.5, 0)
            HueCursor.Parent = HueBar
            Instance.new("UICorner", HueCursor).CornerRadius = UDim.new(0, 3)

            -- Hex input
            local HexInput = Instance.new("TextBox")
            HexInput.Text  = "#" .. currentColor:ToHex():upper()
            HexInput.Font  = Enum.Font.Gotham
            HexInput.TextSize = 11
            HexInput.TextColor3 = Color3.fromRGB(210, 210, 225)
            HexInput.BackgroundColor3 = Color3.fromRGB(14, 14, 20)
            HexInput.BorderSizePixel = 0
            HexInput.ClearTextOnFocus = false
            HexInput.Position = UDim2.new(0, 12, 0, 188)
            HexInput.Size     = UDim2.new(0.5, -6, 0, 24)
            HexInput.ZIndex   = 52
            HexInput.Parent   = Card
            Instance.new("UICorner", HexInput).CornerRadius = UDim.new(0, 5)
            Instance.new("UIStroke", HexInput).Color = Color3.fromRGB(55, 55, 68)

            local HexPad = Instance.new("UIPadding")
            HexPad.PaddingLeft = UDim.new(0, 6)
            HexPad.Parent = HexInput

            -- Preview swatch (inside picker)
            local PreviewSwatch = Instance.new("Frame")
            PreviewSwatch.BackgroundColor3 = currentColor
            PreviewSwatch.BorderSizePixel = 0
            PreviewSwatch.AnchorPoint = Vector2.new(1, 0)
            PreviewSwatch.Position = UDim2.new(1, -12, 0, 188)
            PreviewSwatch.Size = UDim2.new(0.5, -18, 0, 24)
            PreviewSwatch.ZIndex = 52
            PreviewSwatch.Parent = Card
            Instance.new("UICorner", PreviewSwatch).CornerRadius = UDim.new(0, 5)

            -- Apply / Close buttons
            local ApplyBtn = Instance.new("TextButton")
            ApplyBtn.Text = "Apply"
            ApplyBtn.Font = Enum.Font.GothamBold
            ApplyBtn.TextSize = 12
            ApplyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            ApplyBtn.AutoButtonColor = false
            ApplyBtn.BackgroundColor3 = AccentColor
            ApplyBtn.BorderSizePixel = 0
            ApplyBtn.Position = UDim2.new(0, 12, 1, -38)
            ApplyBtn.Size = UDim2.new(0.5, -6, 0, 24)
            ApplyBtn.ZIndex = 52
            ApplyBtn.Parent = Card
            Instance.new("UICorner", ApplyBtn).CornerRadius = UDim.new(0, 5)

            local CancelBtn = Instance.new("TextButton")
            CancelBtn.Text = "Cancel"
            CancelBtn.Font = Enum.Font.GothamBold
            CancelBtn.TextSize = 12
            CancelBtn.TextColor3 = Color3.fromRGB(200, 200, 215)
            CancelBtn.AutoButtonColor = false
            CancelBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 46)
            CancelBtn.BorderSizePixel = 0
            CancelBtn.AnchorPoint = Vector2.new(1, 0)
            CancelBtn.Position = UDim2.new(1, -12, 1, -38)
            CancelBtn.Size = UDim2.new(0.5, -6, 0, 24)
            CancelBtn.ZIndex = 52
            CancelBtn.Parent = Card
            Instance.new("UICorner", CancelBtn).CornerRadius = UDim.new(0, 5)

            -- ── Interaction ──────────────────────────────────────────────
            local function UpdateAll()
                currentColor = HSVtoColor(h, s, v)
                Swatch.BackgroundColor3 = currentColor
                PreviewSwatch.BackgroundColor3 = currentColor
                SatValFrame.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
                SVCursor.Position = UDim2.new(s, 0, 1 - v, 0)
                HueCursor.Position = UDim2.new(h, 0, 0.5, 0)
                HexInput.Text = "#" .. currentColor:ToHex():upper()
            end

            -- SV drag
            local svDragging = false
            SatValFrame.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or
                   input.UserInputType == Enum.UserInputType.Touch then
                    svDragging = true
                end
            end)
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or
                   input.UserInputType == Enum.UserInputType.Touch then
                    svDragging = false
                end
            end)
            UserInputService.InputChanged:Connect(function(input)
                if not svDragging then return end
                if input.UserInputType ~= Enum.UserInputType.MouseMovement and
                   input.UserInputType ~= Enum.UserInputType.Touch then return end
                local absP = SatValFrame.AbsolutePosition
                local absS = SatValFrame.AbsoluteSize
                s = math.clamp((input.Position.X - absP.X) / absS.X, 0, 1)
                v = 1 - math.clamp((input.Position.Y - absP.Y) / absS.Y, 0, 1)
                UpdateAll()
            end)

            -- Hue drag
            local hueDragging = false
            HueBar.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or
                   input.UserInputType == Enum.UserInputType.Touch then
                    hueDragging = true
                end
            end)
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or
                   input.UserInputType == Enum.UserInputType.Touch then
                    hueDragging = false
                end
            end)
            UserInputService.InputChanged:Connect(function(input)
                if not hueDragging then return end
                if input.UserInputType ~= Enum.UserInputType.MouseMovement and
                   input.UserInputType ~= Enum.UserInputType.Touch then return end
                local absP = HueBar.AbsolutePosition
                local absS = HueBar.AbsoluteSize
                h = math.clamp((input.Position.X - absP.X) / absS.X, 0, 1)
                UpdateAll()
            end)

            -- Hex input
            HexInput.FocusLost:Connect(function()
                local hex = HexInput.Text:gsub("#", ""):gsub("%s", "")
                if #hex == 6 then
                    local ok, col = pcall(Color3.fromHex, hex)
                    if ok then
                        h, s, v = Color3.toHSV(col)
                        UpdateAll()
                    end
                end
            end)

            -- Buttons
            ApplyBtn.MouseButton1Click:Connect(function()
                pcall(cb, currentColor)
                ClosePicker()
            end)
            CancelBtn.MouseButton1Click:Connect(ClosePicker)

            UpdateAll()
        end

        Swatch.MouseButton1Click:Connect(OpenPicker)

        -- ── Public API ────────────────────────────────────────────────
        local api = {}
        api.Value = currentColor
        function api:Set(color)
            currentColor = color
            Swatch.BackgroundColor3 = color
            api.Value = color
        end
        function api:GetValue() return currentColor end
        api.Type = "Colorpicker"
        return api
    end

    return module
end
