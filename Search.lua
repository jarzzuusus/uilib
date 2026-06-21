-- Search.lua
return function(GuiConfig, LayersTab, LayersFolder, LayersPageLayout, TweenService, searchOffset)
    local searchOffset = searchOffset or 34

    local SearchBox = Instance.new("TextBox")
    SearchBox.Name             = "GlobalSearchBox"
    SearchBox.PlaceholderText  = "  🔍  Search tab..."
    SearchBox.Text             = ""
    SearchBox.Font             = Enum.Font.Gotham
    SearchBox.TextSize         = 11
    SearchBox.TextColor3       = Color3.fromRGB(205, 205, 215)
    SearchBox.PlaceholderColor3 = Color3.fromRGB(90, 90, 108)
    SearchBox.TextXAlignment   = Enum.TextXAlignment.Left
    SearchBox.BackgroundColor3 = Color3.fromRGB(16, 16, 20)
    SearchBox.BorderSizePixel  = 0
    SearchBox.ClearTextOnFocus = false
    SearchBox.Position         = UDim2.new(0, 6, 0, 4)
    SearchBox.Size             = UDim2.new(1, -12, 0, searchOffset - 8)
    SearchBox.ZIndex           = 6
    SearchBox.Parent           = LayersTab

    Instance.new("UICorner", SearchBox).CornerRadius = UDim.new(0, 6)

    local SBStroke = Instance.new("UIStroke")
    SBStroke.Color = Color3.fromRGB(60, 60, 75)
    SBStroke.Thickness = 1
    SBStroke.Transparency = 0.4
    SBStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    SBStroke.Parent = SearchBox

    local SBPad = Instance.new("UIPadding")
    SBPad.PaddingLeft = UDim.new(0, 8)
    SBPad.Parent = SearchBox

    local accentColor = GuiConfig.Color or Color3.fromRGB(0, 208, 255)

    local function doSearch(query)
        query = query:lower():match("^%s*(.-)%s*$")

        -- Cari semua TextButton tab (di ScrollTab bawaan)
        for _, btn in ipairs(LayersTab:GetDescendants()) do
            if btn:IsA("TextButton") and btn.Name:sub(1, 4) == "Tab_" then
                local tabNameLbl = btn:FindFirstChild("TabName")
                local tabNameText = tabNameLbl and tabNameLbl.Text:lower() or btn.Name:lower()
                if query == "" or tabNameText:find(query, 1, true) then
                    TweenService:Create(btn, TweenInfo.new(0.12), {
                        BackgroundTransparency = 0,
                    }):Play()
                    if tabNameLbl then
                        TweenService:Create(tabNameLbl, TweenInfo.new(0.12), {
                            TextTransparency = 0,
                        }):Play()
                    end
                else
                    TweenService:Create(btn, TweenInfo.new(0.12), {
                        BackgroundTransparency = 0.6,
                    }):Play()
                    if tabNameLbl then
                        TweenService:Create(tabNameLbl, TweenInfo.new(0.12), {
                            TextTransparency = 0.5,
                        }):Play()
                    end
                end
            end
        end
    end

    SearchBox.Focused:Connect(function()
        TweenService:Create(SBStroke, TweenInfo.new(0.2), {
            Color = accentColor, Transparency = 0.2
        }):Play()
    end)

    SearchBox.FocusLost:Connect(function()
        TweenService:Create(SBStroke, TweenInfo.new(0.2), {
            Color = Color3.fromRGB(60, 60, 75), Transparency = 0.4
        }):Play()
        if SearchBox.Text == "" then doSearch("") end
    end)

    SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
        doSearch(SearchBox.Text)
    end)
end
