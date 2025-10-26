--===== UFO HUB X • SETTINGS — FX Scanner 🔎 (per-map, progressive, crash-safe) =====
registerRight("Settings", function(scroll)
    local Players      = game:GetService("Players")
    local TweenService = game:GetService("TweenService")
    local RunService   = game:GetService("RunService")
    local Lighting     = game:GetService("Lighting")

    -- THEME (เหมือนของเดิม)
    local THEME = {
        GREEN = Color3.fromRGB(25,255,125),
        WHITE = Color3.fromRGB(255,255,255),
        BLACK = Color3.fromRGB(0,0,0),
        TEXT  = Color3.fromRGB(255,255,255),
        RED   = Color3.fromRGB(255,40,40),
        DIM   = Color3.fromRGB(175,190,175),
    }
    local function corner(ui,r) local c=Instance.new("UICorner"); c.CornerRadius=UDim.new(0,r or 12); c.Parent=ui end
    local function stroke(ui,th,col) local s=Instance.new("UIStroke"); s.Thickness=th or 2.2; s.Color=col or THEME.GREEN; s.ApplyStrokeMode=Enum.ApplyStrokeMode.Border; s.Parent=ui end
    local function tween(o,p) TweenService:Create(o, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), p):Play() end
    local function gprop(o,k) local ok,v=pcall(function() return o[k] end); return ok and v or nil end

    -- --- Layout ensure
    local list = scroll:FindFirstChildOfClass("UIListLayout") or Instance.new("UIListLayout", scroll)
    list.Padding = UDim.new(0,12); list.SortOrder = Enum.SortOrder.LayoutOrder
    scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y

    -- เคลียร์ของเก่า
    local NAME = "UFOX_FXSCAN_WRAP"
    local old = scroll:FindFirstChild(NAME); if old then old:Destroy() end

    -- ===== Header
    local head = Instance.new("TextLabel", scroll)
    head.Name="A2_Header_Scan"; head.BackgroundTransparency=1; head.Size=UDim2.new(1,0,0,36)
    head.Font=Enum.Font.GothamBold; head.TextSize=16; head.TextColor3=THEME.TEXT
    head.TextXAlignment=Enum.TextXAlignment.Left; head.Text="FX Scanner 🔎"; head.LayoutOrder = 40

    -- ===== Box
    local box = Instance.new("Frame", scroll)
    box.Name = NAME; box.Size = UDim2.new(1,-6,0,180); box.BackgroundColor3 = THEME.BLACK
    corner(box,12); stroke(box,2.2,THEME.GREEN); box.LayoutOrder = 41

    -- Top bar
    local top = Instance.new("Frame", box)
    top.BackgroundTransparency=1; top.Size=UDim2.new(1,-24,0,42); top.Position=UDim2.new(0,12,0,6)

    local title = Instance.new("TextLabel", top)
    title.BackgroundTransparency=1; title.Size=UDim2.new(1,-140,1,0)
    title.Font=Enum.Font.GothamBold; title.TextSize=14; title.TextXAlignment=Enum.TextXAlignment.Left
    title.TextColor3=THEME.WHITE; title.Text="Scan effects in this map (progressive, safe)."

    local btn = Instance.new("TextButton", top)
    btn.Size=UDim2.fromOffset(120,28); btn.Position=UDim2.new(1,-120,0.5,-14)
    btn.Text="Run Scan"; btn.Font=Enum.Font.GothamBold; btn.TextSize=13; btn.TextColor3=THEME.BLACK
    btn.BackgroundColor3=THEME.GREEN; corner(btn,8)

    -- Progress
    local prog = Instance.new("TextLabel", box)
    prog.BackgroundTransparency=1; prog.Position=UDim2.new(0,12,0,44); prog.Size=UDim2.new(1,-24,0,20)
    prog.Font=Enum.Font.Gotham; prog.TextSize=12; prog.TextXAlignment=Enum.TextXAlignment.Left
    prog.TextColor3=THEME.DIM; prog.Text="Idle — press Run Scan."

    -- Results scroller
    local res = Instance.new("ScrollingFrame", box)
    res.BackgroundTransparency=1; res.BorderSizePixel=0; res.Position=UDim2.new(0,12,0,68)
    res.Size=UDim2.new(1,-24,1,-80); res.CanvasSize=UDim2.new(0,0,0,0); res.ScrollBarThickness=4
    local rlist = Instance.new("UIListLayout", res); rlist.Padding=UDim.new(0,6); rlist.SortOrder=Enum.SortOrder.LayoutOrder

    local function addLine(txt, dim)
        local lab = Instance.new("TextLabel", res)
        lab.BackgroundColor3 = Color3.fromRGB(12,12,12)
        lab.Size=UDim2.new(1,0,0,28); lab.TextXAlignment=Enum.TextXAlignment.Left
        lab.Font=Enum.Font.Gotham; lab.TextSize=12; lab.TextColor3 = dim and THEME.DIM or THEME.WHITE
        lab.Text = "  "..txt
        corner(lab,8)
        res.CanvasSize = UDim2.new(0,0,0,rlist.AbsoluteContentSize.Y + 6)
        return lab
    end

    -- ====== Scanner ======
    local SCAN_RUNNING = false

    local function runScan()
        if SCAN_RUNNING then return end
        SCAN_RUNNING = true
        -- reset UI
        for _,ch in ipairs(res:GetChildren()) do if ch:IsA("GuiObject") then ch:Destroy() end end
        prog.Text = "Scanning workspace... 0%"
        addLine("Summary will appear here...", true)

        -- buckets / metrics
        local counts = {
            ParticleEmitter = {total=0, enabled=0, rate_sum=0},
            Trail   = {total=0, enabled=0, bright_sum=0},
            Beam    = {total=0, enabled=0, bright_sum=0},
            Smoke   = {total=0, enabled=0},
            Fire    = {total=0, enabled=0},
            Sparkles= {total=0, enabled=0},
        }
        local samples = {ParticleEmitter={}, Trail={}, Beam={}, Smoke={}, Fire={}, Sparkles={}}

        local descendants = workspace:GetDescendants()
        local n = #descendants
        local step = math.max(150, math.floor(n/40)) -- กำหนด batch ขึ้นกับขนาดแมพ

        for i,inst in ipairs(descendants) do
            -- classify (ใช้ pcall กัน property)
            if inst.ClassName == "ParticleEmitter" then
                local b = counts.ParticleEmitter
                b.total += 1
                if gprop(inst,"Enabled") then b.enabled += 1 end
                local r = gprop(inst,"Rate") or 0; b.rate_sum += r
                if #samples.ParticleEmitter < 3 then table.insert(samples.ParticleEmitter, inst:GetFullName()) end

            elseif inst.ClassName == "Trail" then
                local b = counts.Trail; b.total += 1; if gprop(inst,"Enabled") then b.enabled += 1 end
                b.bright_sum += (gprop(inst,"Brightness") or 0)
                if #samples.Trail < 3 then table.insert(samples.Trail, inst:GetFullName()) end

            elseif inst.ClassName == "Beam" then
                local b = counts.Beam; b.total += 1; if gprop(inst,"Enabled") then b.enabled += 1 end
                b.bright_sum += (gprop(inst,"Brightness") or 0)
                if #samples.Beam < 3 then table.insert(samples.Beam, inst:GetFullName()) end

            elseif inst.ClassName == "Smoke" then
                local b = counts.Smoke; b.total += 1; if gprop(inst,"Enabled") then b.enabled += 1 end
                if #samples.Smoke < 3 then table.insert(samples.Smoke, inst:GetFullName()) end

            elseif inst.ClassName == "Fire" then
                local b = counts.Fire; b.total += 1; if gprop(inst,"Enabled") then b.enabled += 1 end
                if #samples.Fire < 3 then table.insert(samples.Fire, inst:GetFullName()) end

            elseif inst.ClassName == "Sparkles" then
                local b = counts.Sparkles; b.total += 1; if gprop(inst,"Enabled") then b.enabled += 1 end
                if #samples.Sparkles < 3 then table.insert(samples.Sparkles, inst:GetFullName()) end
            end

            -- progressive update
            if (i % step) == 0 then
                prog.Text = string.format("Scanning workspace... %d%%", math.floor(i/n*100))
                RunService.Heartbeat:Wait()
            end
        end

        prog.Text = "Scanning Lighting post-effects..."
        -- Lighting post-process
        local PP = {"BloomEffect","ColorCorrectionEffect","DepthOfFieldEffect","SunRaysEffect","BlurEffect"}
        local pp_list = {}

        for _,o in ipairs(Lighting:GetChildren()) do
            for _,cn in ipairs(PP) do
                if o.ClassName == cn then
                    local item = {class=cn, name=o.Name, enabled=o.Enabled}
                    if cn == "BlurEffect" then item.size = gprop(o,"Size")
                    else item.intensity = gprop(o,"Intensity") end
                    table.insert(pp_list, item)
                end
            end
            if #pp_list % 5 == 0 then RunService.Heartbeat:Wait() end
        end

        -- ===== Render results =====
        for _,ch in ipairs(res:GetChildren()) do if ch:IsA("GuiObject") then ch:Destroy() end end

        addLine("Workspace Effects (by class):")
        local function line(fmt, ...)
            addLine("• "..string.format(fmt, ...), true)
        end

        line("ParticleEmitter  — total: %d, enabled: %d, total Rate: %.0f",
             counts.ParticleEmitter.total, counts.ParticleEmitter.enabled, counts.ParticleEmitter.rate_sum)
        line("Trail            — total: %d, enabled: %d, total Brightness: %.2f",
             counts.Trail.total, counts.Trail.enabled, counts.Trail.bright_sum)
        line("Beam             — total: %d, enabled: %d, total Brightness: %.2f",
             counts.Beam.total, counts.Beam.enabled, counts.Beam.bright_sum)
        line("Smoke            — total: %d, enabled: %d", counts.Smoke.total, counts.Smoke.enabled)
        line("Fire             — total: %d, enabled: %d", counts.Fire.total, counts.Fire.enabled)
        line("Sparkles         — total: %d, enabled: %d", counts.Sparkles.total, counts.Sparkles.enabled)

        local function showSamples(class, arr)
            if #arr > 0 then
                addLine("    samples for "..class..":", true)
                for _,path in ipairs(arr) do addLine("      - "..path, true) end
            end
        end
        showSamples("ParticleEmitter", samples.ParticleEmitter)
        showSamples("Trail", samples.Trail)
        showSamples("Beam", samples.Beam)
        showSamples("Smoke", samples.Smoke)
        showSamples("Fire", samples.Fire)
        showSamples("Sparkles", samples.Sparkles)

        addLine("")
        addLine("Lighting Post-Process:")
        if #pp_list == 0 then
            addLine("• (none found)", true)
        else
            for _,it in ipairs(pp_list) do
                local tail = ""
                if it.class == "BlurEffect" and it.size ~= nil then tail = string.format(" — Size: %d", it.size)
                elseif it.intensity ~= nil then tail = string.format(" — Intensity: %.2f", it.intensity) end
                addLine(string.format("• %s  (%s)  — Enabled: %s%s",
                        it.class, it.name, tostring(it.enabled), tail), true)
            end
        end

        prog.Text = "Scan complete."
        SCAN_RUNNING = false
    end

    btn.MouseButton1Click:Connect(runScan)
end)
