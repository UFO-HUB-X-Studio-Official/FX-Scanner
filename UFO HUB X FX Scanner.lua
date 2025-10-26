--===== UFOX • FX Scanner + Optimizer 🔎⚙️ (Standalone • Filter • Step-by-step) =====
-- ไม่แตะ UI เดิม • เปิดเองแน่นอน • มีสแกน + ปุ่มทดสอบปิดเป็นขั้น ๆ + คืนค่าเดิมได้

local Players      = game:GetService("Players")
local RunService   = game:GetService("RunService")
local Lighting     = game:GetService("Lighting")
local UIS          = game:GetService("UserInputService")
local lp = Players.LocalPlayer

-- parent resolver (CoreGui -> gethui -> PlayerGui)
local function resolveParent()
    local ok, hui = pcall(function() return gethui and gethui() end)
    local cg = game:FindService("CoreGui")
    if cg then return cg end
    if ok and hui then return hui end
    return lp:WaitForChild("PlayerGui")
end
local PARENT = resolveParent()

-- remove old
for _,n in ipairs({"UFOX_FXTOOLS_GUI","UFOX_FXTOOLS_TOGGLE"}) do
    local old = PARENT:FindFirstChild(n) or (lp:FindFirstChild("PlayerGui") and lp.PlayerGui:FindFirstChild(n))
    if old then pcall(function() old:Destroy() end) end
end

-- THEME
local THEME = {
    GREEN = Color3.fromRGB(25,255,125),
    WHITE = Color3.fromRGB(255,255,255),
    BLACK = Color3.fromRGB(0,0,0),
    TEXT  = Color3.fromRGB(235,235,235),
    RED   = Color3.fromRGB(220,50,50),
    DIM   = Color3.fromRGB(175,190,175),
}
local function corner(ui,r) local c=Instance.new("UICorner"); c.CornerRadius=UDim.new(0,r or 10); c.Parent=ui end
local function stroke(ui,th,col,tr)
    local s=Instance.new("UIStroke"); s.Thickness=th or 2; s.Color=col or THEME.GREEN
    s.Transparency = tr or 0; s.ApplyStrokeMode=Enum.ApplyStrokeMode.Border; s.Parent=ui
end
local function gprop(o,k) local ok,v=pcall(function() return o[k] end); return ok and v or nil end

-- toggle button (เปิด/ปิดหน้าต่าง)
local tgui = Instance.new("ScreenGui", PARENT)
tgui.Name="UFOX_FXTOOLS_TOGGLE"; tgui.IgnoreGuiInset=true; tgui.ResetOnSpawn=false
tgui.DisplayOrder=1000006; tgui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
local tbtn = Instance.new("TextButton", tgui)
tbtn.Size=UDim2.fromOffset(58,58); tbtn.Position=UDim2.fromOffset(24,220)
tbtn.Text="FX\nTools"; tbtn.Font=Enum.Font.GothamBlack; tbtn.TextSize=14
tbtn.TextColor3=THEME.BLACK; tbtn.BackgroundColor3=THEME.GREEN
corner(tbtn,10); stroke(tbtn,2,THEME.GREEN,0)

do -- drag
    local dragging, start, spos
    tbtn.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
            dragging=true; start=i.Position; spos=Vector2.new(tbtn.Position.X.Offset,tbtn.Position.Y.Offset)
        end
    end)
    tbtn.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dragging=false end
    end)
    UIS.InputChanged:Connect(function(i)
        if not dragging then return end
        if i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch then
            local d=i.Position-start
            tbtn.Position=UDim2.fromOffset(spos.X+d.X, spos.Y+d.Y)
        end
    end)
end

-- main gui
local gui = Instance.new("ScreenGui", PARENT)
gui.Name="UFOX_FXTOOLS_GUI"; gui.IgnoreGuiInset=true; gui.ResetOnSpawn=false
gui.DisplayOrder=1000007; gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
local win = Instance.new("Frame", gui)
win.Size=UDim2.fromOffset(760, 520); win.AnchorPoint=Vector2.new(0.5,0.5)
win.Position=UDim2.new(0.5,0,0.5,0); win.BackgroundColor3=THEME.BLACK
stroke(win,2.2,THEME.GREEN,0); corner(win,12)

-- top bar
local top = Instance.new("Frame", win)
top.Size=UDim2.new(1,-16,0,36); top.Position=UDim2.new(0,8,0,8)
top.BackgroundColor3=Color3.fromRGB(12,12,12); corner(top,10); stroke(top,1.1,THEME.GREEN,0.35)
local title = Instance.new("TextLabel", top)
title.BackgroundTransparency=1; title.Position=UDim2.new(0,10,0,0); title.Size=UDim2.new(1,-120,1,0)
title.Font=Enum.Font.GothamBold; title.TextSize=16; title.TextXAlignment=Enum.TextXAlignment.Left
title.TextColor3=THEME.TEXT; title.Text="FX Scanner 🔎 + Optimizer ⚙️  (Standalone)"

local closeBtn = Instance.new("TextButton", top)
closeBtn.Size=UDim2.fromOffset(28,28); closeBtn.Position=UDim2.new(1,-32,0.5,-14)
closeBtn.Text="✕"; closeBtn.Font=Enum.Font.GothamBold; closeBtn.TextSize=14
closeBtn.TextColor3=THEME.WHITE; closeBtn.BackgroundColor3=THEME.RED
corner(closeBtn,8); closeBtn.MouseButton1Click:Connect(function() win.Visible=false end)
tbtn.MouseButton1Click:Connect(function() win.Visible = not win.Visible end)

-- left: scanner
local left = Instance.new("Frame", win); left.BackgroundTransparency=1
left.Position=UDim2.new(0,12,0,56); left.Size=UDim2.new(0.55,-18,1,-68)

local runBtn = Instance.new("TextButton", left)
runBtn.Size=UDim2.fromOffset(120,28); runBtn.Text="Run Scan"
runBtn.Font=Enum.Font.GothamBold; runBtn.TextSize=13; runBtn.TextColor3=THEME.BLACK
runBtn.BackgroundColor3=THEME.GREEN; corner(runBtn,8)

local pct = Instance.new("TextLabel", left)
pct.BackgroundTransparency=1; pct.Position=UDim2.new(0,130,0,0); pct.Size=UDim2.new(0,80,0,28)
pct.Font=Enum.Font.GothamBold; pct.TextSize=13; pct.TextColor3=THEME.WHITE
pct.TextXAlignment=Enum.TextXAlignment.Left; pct.Text="0%"

local status = Instance.new("TextLabel", left)
status.BackgroundTransparency=1; status.Position=UDim2.new(0,0,0,32); status.Size=UDim2.new(1,0,0,22)
status.Font=Enum.Font.Gotham; status.TextSize=13; status.TextColor3=THEME.DIM
status.TextXAlignment=Enum.TextXAlignment.Left; status.Text="Idle — press Run Scan."

local out = Instance.new("TextBox", left)
out.Position=UDim2.new(0,0,0,56); out.Size=UDim2.new(1,0,1,-56)
out.ClearTextOnFocus=false; out.MultiLine=true; out.TextEditable=true; out.RichText=false
out.TextXAlignment=Enum.TextXAlignment.Left; out.TextYAlignment=Enum.TextYAlignment.Top
out.Font=Enum.Font.Code; out.TextSize=12; out.TextColor3=THEME.WHITE
out.PlaceholderText="Results will appear here…"; out.BackgroundColor3=Color3.fromRGB(12,12,12)
corner(out,8); stroke(out,1,THEME.GREEN,0.35)

local copyBtn = Instance.new("TextButton", left)
copyBtn.Size=UDim2.fromOffset(80,26); copyBtn.Position=UDim2.new(1,-88,1,-30)
copyBtn.Text="Copy"; copyBtn.Font=Enum.Font.GothamBold; copyBtn.TextSize=12
copyBtn.TextColor3=THEME.BLACK; copyBtn.BackgroundColor3=THEME.GREEN; corner(copyBtn,6)
copyBtn.MouseButton1Click:Connect(function()
    local txt=out.Text or ""; local ok=pcall(function() if setclipboard then setclipboard(txt) end end)
    status.Text = ok and "Copied to clipboard." or "Select all and copy manually."
end)

-- right: optimizer panel
local right = Instance.new("Frame", win); right.BackgroundTransparency=1
right.Position=UDim2.new(0.55,6,0,56); right.Size=UDim2.new(0.45,-18,1,-68)

local box = Instance.new("Frame", right)
box.Size=UDim2.new(1,0,1,0); box.BackgroundColor3=Color3.fromRGB(12,12,12)
corner(box,10); stroke(box,1.4,THEME.GREEN,0.35)

local head = Instance.new("TextLabel", box)
head.BackgroundTransparency=1; head.Position=UDim2.new(0,12,0,8); head.Size=UDim2.new(1,-24,0,20)
head.Font=Enum.Font.GothamBold; head.TextSize=14; head.TextColor3=THEME.TEXT
head.TextXAlignment=Enum.TextXAlignment.Left; head.Text="Optimizer ⚙️ — step-by-step (with filter)"

local filterLab = Instance.new("TextLabel", box)
filterLab.BackgroundTransparency=1; filterLab.Position=UDim2.new(0,12,0,36); filterLab.Size=UDim2.new(0,110,0,22)
filterLab.Font=Enum.Font.Gotham; filterLab.TextSize=12; filterLab.TextColor3=THEME.DIM
filterLab.TextXAlignment=Enum.TextXAlignment.Left; filterLab.Text="Filter Path (contains):"

local filterBox = Instance.new("TextBox", box)
filterBox.Position=UDim2.new(0,126,0,34); filterBox.Size=UDim2.new(1,-138,0,26)
filterBox.ClearTextOnFocus=false; filterBox.PlaceholderText="e.g. Lawn Mower / FuseMachine (optional)"
filterBox.Font=Enum.Font.Code; filterBox.TextSize=12; filterBox.TextColor3=THEME.WHITE
filterBox.BackgroundColor3=Color3.fromRGB(20,20,20); corner(filterBox,6); stroke(filterBox,1,THEME.GREEN,0.2)

local sep = Instance.new("Frame", box)
sep.Position=UDim2.new(0,12,0,64); sep.Size=UDim2.new(1,-24,0,1); sep.BackgroundColor3=Color3.fromRGB(35,35,35)

-- buttons grid
local grid = Instance.new("UIGridLayout", box)
grid.CellPadding=UDim2.fromOffset(10,10); grid.CellSize=UDim2.fromOffset(170,34)
grid.FillDirectionMaxCells=2
local gridWrap = Instance.new("Frame", box)
gridWrap.BackgroundTransparency=1; gridWrap.Position=UDim2.new(0,12,0,74); gridWrap.Size=UDim2.new(1,-24,1,-120)

-- status bottom
local optStatus = Instance.new("TextLabel", box)
optStatus.BackgroundTransparency=1; optStatus.Position=UDim2.new(0,12,1,-40); optStatus.Size=UDim2.new(1,-24,0,30)
optStatus.Font=Enum.Font.Gotham; optStatus.TextSize=12; optStatus.TextColor3=THEME.DIM
optStatus.TextXAlignment=Enum.TextXAlignment.Left; optStatus.Text="Ready."

-- capture store
local SNAP = {}  -- [Instance] = { props... }
local PP_SNAP = {} -- [Effect] = {Enabled, Intensity?, Size?}

local function matchFilter(inst)
    local f = filterBox.Text
    if f == nil or f == "" then return true end
    local name = ""
    pcall(function() name = inst:GetFullName() end)
    return string.find(string.lower(name), string.lower(f), 1, true) ~= nil
end

local function capture(inst)
    if SNAP[inst] then return end
    local t={}
    pcall(function()
        if inst:IsA("ParticleEmitter") then t.Rate=inst.Rate; t.Enabled=inst.Enabled
        elseif inst:IsA("Trail") or inst:IsA("Beam") then t.Enabled=inst.Enabled; t.Brightness=inst.Brightness
        elseif inst:IsA("Smoke") then t.Enabled=inst.Enabled; t.Opacity=inst.Opacity
        elseif inst:IsA("Fire") then t.Enabled=inst.Enabled; t.Heat=inst.Heat; t.Size=inst.Size
        elseif inst:IsA("Sparkles") then t.Enabled=inst.Enabled end
    end)
    SNAP[inst]=t
    inst.AncestryChanged:Connect(function(_,p) if not p then SNAP[inst]=nil end end)
end

local function stashPP(o)
    if PP_SNAP[o] then return end
    PP_SNAP[o] = {
        Enabled  = o.Enabled,
        Intensity= gprop(o,"Intensity"),
        Size     = (o.ClassName=="BlurEffect") and gprop(o,"Size") or nil
    }
    o.AncestryChanged:Connect(function(_,p) if not p then PP_SNAP[o]=nil end end)
end

-- initial capture
for _,d in ipairs(workspace:GetDescendants()) do
    if d:IsA("ParticleEmitter") or d:IsA("Trail") or d:IsA("Beam") or d:IsA("Smoke") or d:IsA("Fire") or d:IsA("Sparkles") then
        capture(d)
    end
end
for _,o in ipairs(Lighting:GetChildren()) do
    if o:IsA("PostEffect") or o:IsA("BlurEffect") then stashPP(o) end
end

-- helper apply
local function eachFX(classNames, fn)
    for inst,_ in pairs(SNAP) do
        if inst.Parent and classNames[inst.ClassName] and matchFilter(inst) then
            pcall(function() fn(inst, SNAP[inst]) end)
        end
    end
end
local function eachPP(fn)
    for o,t in pairs(PP_SNAP) do
        if o.Parent and matchFilter(o) then pcall(function() fn(o,t) end) end
    end
end

-- buttons
local function mkBtn(text, onClick)
    local b = Instance.new("TextButton", gridWrap)
    b.Text = text; b.Font=Enum.Font.GothamBold; b.TextSize=12
    b.TextColor3 = THEME.BLACK; b.BackgroundColor3=THEME.GREEN
    corner(b,8); stroke(b,1,THEME.GREEN,0.2)
    b.MouseButton1Click:Connect(function()
        local ok,err = pcall(onClick)
        optStatus.Text = ok and ("Done: "..text) or ("Error: "..tostring(err))
    end)
    return b
end

-- ParticleEmitter
mkBtn("Emitters: Half Rate", function()
    eachFX({ParticleEmitter=true}, function(i,t) i.Enabled=true; i.Rate=math.max(0, math.floor((t.Rate or i.Rate or 10)*0.5)) end)
end)
mkBtn("Emitters: OFF", function()
    eachFX({ParticleEmitter=true}, function(i,_) i.Enabled=false; i.Rate=0 end)
end)

-- Trails / Beams
mkBtn("Trails: OFF", function()
    eachFX({Trail=true}, function(i,_) if i.Enabled~=nil then i.Enabled=false end end)
end)
mkBtn("Beams: OFF", function()
    eachFX({Beam=true}, function(i,_) if i.Enabled~=nil then i.Enabled=false end end)
end)

-- Post-Process
mkBtn("PostFX: Half (Intensity/Size)", function()
    eachPP(function(o,t)
        o.Enabled=true
        if o.ClassName=="BlurEffect" and t.Size~=nil then o.Size=math.floor((t.Size or 0)*0.5) end
        if t.Intensity~=nil then o.Intensity = (t.Intensity or 1)*0.5 end
    end)
end)
mkBtn("PostFX: OFF", function()
    eachPP(function(o,_) o.Enabled=false end)
end)

-- Restore
mkBtn("Restore ALL (FX + PostFX)", function()
    for i,t in pairs(SNAP) do
        if i.Parent then pcall(function() for k,v in pairs(t) do i[k]=v end end) end
    end
    for o,t in pairs(PP_SNAP) do
        if o.Parent then
            pcall(function()
                o.Enabled=t.Enabled
                if o.ClassName=="BlurEffect" and t.Size~=nil then o.Size=t.Size end
                if t.Intensity~=nil then o.Intensity=t.Intensity end
            end)
        end
    end
end)

--=============== Scanner (ซ้าย) ===============
local running=false
local function upd(i,n,phase)
    local p=(n>0) and math.floor(i/n*100+0.5) or 100
    pct.Text=tostring(math.clamp(p,0,100)).."%"; status.Text=phase
end

local function runScan()
    if running then return end
    running=true; out.Text=""; pct.Text="0%"; status.Text="Scanning workspace…"

    local counts = {
        ParticleEmitter={total=0,enabled=0,rate_sum=0},
        Trail={total=0,enabled=0,bright_sum=0},
        Beam={total=0,enabled=0,bright_sum=0},
        Smoke={total=0,enabled=0},
        Fire={total=0,enabled=0},
        Sparkles={total=0,enabled=0},
    }
    local samples={ParticleEmitter={},Trail={},Beam={},Smoke={},Fire={},Sparkles={}}

    local desc=workspace:GetDescendants()
    local n=#desc; local batch=math.max(200, math.floor(n/40))
    for i,inst in ipairs(desc) do
        local cn=inst.ClassName
        if cn=="ParticleEmitter" then
            local b=counts.ParticleEmitter; b.total+=1; if gprop(inst,"Enabled") then b.enabled+=1 end
            b.rate_sum+=(gprop(inst,"Rate") or 0)
            if #samples.ParticleEmitter<3 then table.insert(samples.ParticleEmitter, inst:GetFullName()) end
            capture(inst)
        elseif cn=="Trail" then
            local b=counts.Trail; b.total+=1; if gprop(inst,"Enabled") then b.enabled+=1 end
            b.bright_sum+=(gprop(inst,"Brightness") or 0)
            if #samples.Trail<3 then table.insert(samples.Trail, inst:GetFullName()) end
            capture(inst)
        elseif cn=="Beam" then
            local b=counts.Beam; b.total+=1; if gprop(inst,"Enabled") then b.enabled+=1 end
            b.bright_sum+=(gprop(inst,"Brightness") or 0)
            if #samples.Beam<3 then table.insert(samples.Beam, inst:GetFullName()) end
            capture(inst)
        elseif cn=="Smoke" or cn=="Fire" or cn=="Sparkles" then
            local b=counts[cn]; b.total+=1; if gprop(inst,"Enabled") then b.enabled+=1 end
            if #samples[cn]<3 then table.insert(samples[cn], inst:GetFullName()) end
            capture(inst)
        end
        if (i%batch)==0 then upd(i,n,"Scanning workspace…"); RunService.Heartbeat:Wait() end
    end

    upd(n,n,"Scanning Lighting…")
    local PPe={"BloomEffect","ColorCorrectionEffect","DepthOfFieldEffect","SunRaysEffect","BlurEffect"}
    local pp_list={}
    local kids=Lighting:GetChildren()
    for j,o in ipairs(kids) do
        for _,cn in ipairs(PPe) do
            if o.ClassName==cn then
                local it={class=cn, name=o.Name, enabled=o.Enabled}
                if cn=="BlurEffect" then it.size=gprop(o,"Size") else it.intensity=gprop(o,"Intensity") end
                table.insert(pp_list,it)
                stashPP(o)
            end
        end
        if (j%10)==0 then RunService.Heartbeat:Wait() end
    end

    local rep={}
    local function add(fmt, ...) table.insert(rep, (select("#",...)>0) and string.format(fmt, ...) or fmt) end
    add("FX Scanner Report")
    add("Workspace Effects:")
    add("  ParticleEmitter  — total: %d, enabled: %d, total Rate: %.0f", counts.ParticleEmitter.total, counts.ParticleEmitter.enabled, counts.ParticleEmitter.rate_sum)
    add("  Trail            — total: %d, enabled: %d, total Brightness: %.2f", counts.Trail.total, counts.Trail.enabled, counts.Trail.bright_sum)
    add("  Beam             — total: %d, enabled: %d, total Brightness: %.2f", counts.Beam.total, counts.Beam.enabled, counts.Beam.bright_sum)
    add("  Smoke            — total: %d, enabled: %d", counts.Smoke.total, counts.Smoke.enabled)
    add("  Fire             — total: %d, enabled: %d", counts.Fire.total, counts.Fire.enabled)
    add("  Sparkles         — total: %d, enabled: %d", counts.Sparkles.total, counts.Sparkles.enabled)

    local function addSamples(name, arr)
        if #arr>0 then
            add("    samples for %s:", name)
            for _,p in ipairs(arr) do add("      - %s", p) end
        end
    end
    addSamples("ParticleEmitter", samples.ParticleEmitter)
    addSamples("Trail",           samples.Trail)
    addSamples("Beam",            samples.Beam)
    addSamples("Smoke",           samples.Smoke)
    addSamples("Fire",            samples.Fire)
    addSamples("Sparkles",        samples.Sparkles)

    add(""); add("Lighting Post-Process:")
    if #pp_list==0 then add("  (none)") else
        for _,it in ipairs(pp_list) do
            local tail=""
            if it.class=="BlurEffect" and it.size~=nil then tail=string.format(" — Size: %d", it.size)
            elseif it.intensity~=nil then tail=string.format(" — Intensity: %.2f", it.intensity) end
            add("  %s (%s) — Enabled: %s%s", it.class, it.name, tostring(it.enabled), tail)
        end
    end

    out.Text=table.concat(rep,"\n")
    pct.Text="100%"; status.Text="Scan complete — "..tostring(#desc).." objects checked."
    running=false
end
runBtn.MouseButton1Click:Connect(runScan)

-- force show
win.Visible=true
