--===== UFOX • FX Scanner 🔎 (Standalone UI, 0–100%, copyable) =====
-- Standalone: ไม่พึ่ง registerRight/scroll, ไม่เข้าไปผสมกับ UI เดิม
local Players      = game:GetService("Players")
local RunService   = game:GetService("RunService")
local Lighting     = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local lp = Players.LocalPlayer

-- ถ้ามีของเก่าอยู่ ลบทิ้งก่อน (กันซ้ำ)
local OLD = (lp:FindFirstChild("PlayerGui") and lp.PlayerGui:FindFirstChild("UFOX_FXSCANNER_GUI"))
if OLD then OLD:Destroy() end

-- THEME
local THEME = {
	GREEN = Color3.fromRGB(25,255,125),
	WHITE = Color3.fromRGB(255,255,255),
	BLACK = Color3.fromRGB(0,0,0),
	TEXT  = Color3.fromRGB(255,255,255),
	RED   = Color3.fromRGB(255,40,40),
	DIM   = Color3.fromRGB(175,190,175),
}

local function corner(ui,r) local c=Instance.new("UICorner"); c.CornerRadius=UDim.new(0,r or 12); c.Parent=ui end
local function stroke(ui,th,col) local s=Instance.new("UIStroke"); s.Thickness=th or 2.0; s.Color=col or THEME.GREEN; s.ApplyStrokeMode=Enum.ApplyStrokeMode.Border; s.Parent=ui end
local function gprop(o,k) local ok,v=pcall(function() return o[k] end); return ok and v or nil end

-- ScreenGui
local gui = Instance.new("ScreenGui")
gui.Name = "UFOX_FXSCANNER_GUI"
gui.IgnoreGuiInset = true
gui.ResetOnSpawn = false
gui.DisplayOrder = 1000002
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = lp:WaitForChild("PlayerGui")

-- Window
local win = Instance.new("Frame", gui)
win.Name = "Window"
win.Size = UDim2.fromOffset(560, 380)
win.Position = UDim2.new(0.5, -280, 0.5, -190)
win.BackgroundColor3 = THEME.BLACK
stroke(win, 2.2, THEME.GREEN)
corner(win, 12)

-- Top bar (drag)
local top = Instance.new("Frame", win)
top.BackgroundColor3 = Color3.fromRGB(12,12,12)
top.Size = UDim2.new(1, -16, 0, 36)
top.Position = UDim2.new(0, 8, 0, 8)
corner(top, 10)
stroke(top, 1.2, THEME.GREEN)

local title = Instance.new("TextLabel", top)
title.BackgroundTransparency = 1
title.Position = UDim2.new(0, 10, 0, 0)
title.Size = UDim2.new(1, -120, 1, 0)
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.TextXAlignment = Enum.TextXAlignment.Left
title.TextColor3 = THEME.TEXT
title.Text = "FX Scanner 🔎  (Standalone)"

local closeBtn = Instance.new("TextButton", top)
closeBtn.Size = UDim2.fromOffset(28, 28)
closeBtn.Position = UDim2.new(1, -32, 0.5, -14)
closeBtn.Text = "✕"
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 14
closeBtn.TextColor3 = THEME.BLACK
closeBtn.BackgroundColor3 = THEME.RED
corner(closeBtn, 8)
closeBtn.MouseButton1Click:Connect(function() gui:Destroy() end)

-- Drag support
do
	local UIS = game:GetService("UserInputService")
	local dragging, dragStart, startPos
	top.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = win.Position
		end
	end)
	top.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
			dragging = false
		end
	end)
	UIS.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch) then
			local delta = input.Position - dragStart
			win.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)
end

-- Controls row
local ctr = Instance.new("Frame", win)
ctr.BackgroundTransparency = 1
ctr.Position = UDim2.new(0, 12, 0, 56)
ctr.Size = UDim2.new(1, -24, 0, 30)

local runBtn = Instance.new("TextButton", ctr)
runBtn.Size = UDim2.fromOffset(120, 28)
runBtn.Text = "Run Scan"
runBtn.Font = Enum.Font.GothamBold
runBtn.TextSize = 13
runBtn.TextColor3 = THEME.BLACK
runBtn.BackgroundColor3 = THEME.GREEN
corner(runBtn, 8)

local pct = Instance.new("TextLabel", ctr)
pct.BackgroundTransparency = 1
pct.Position = UDim2.new(0, 130, 0, 0)
pct.Size = UDim2.new(0, 80, 1, 0)
pct.Font = Enum.Font.GothamBold
pct.TextSize = 13
pct.TextColor3 = THEME.WHITE
pct.TextXAlignment = Enum.TextXAlignment.Left
pct.Text = "0%"

local status = Instance.new("TextLabel", ctr)
status.BackgroundTransparency = 1
status.Position = UDim2.new(0, 210, 0, 0)
status.Size = UDim2.new(1, -210, 1, 0)
status.Font = Enum.Font.Gotham
status.TextSize = 13
status.TextColor3 = THEME.DIM
status.TextXAlignment = Enum.TextXAlignment.Left
status.Text = "Idle — press Run Scan."

-- Output box
local out = Instance.new("TextBox", win)
out.Position = UDim2.new(0, 12, 0, 92)
out.Size = UDim2.new(1, -24, 1, -140)
out.ClearTextOnFocus = false
out.MultiLine = true
out.TextEditable = true
out.RichText = false
out.TextXAlignment = Enum.TextXAlignment.Left
out.TextYAlignment = Enum.TextYAlignment.Top
out.Font = Enum.Font.Code
out.TextSize = 12
out.TextColor3 = THEME.WHITE
out.PlaceholderText = "Results will appear here…"
out.BackgroundColor3 = Color3.fromRGB(12,12,12)
corner(out, 8)
stroke(out, 1, THEME.GREEN)

-- Copy button + Save button (optional)
local btnRow = Instance.new("Frame", win)
btnRow.BackgroundTransparency = 1
btnRow.Position = UDim2.new(0, 12, 1, -40)
btnRow.Size = UDim2.new(1, -24, 0, 28)

local copyBtn = Instance.new("TextButton", btnRow)
copyBtn.Size = UDim2.fromOffset(90, 26)
copyBtn.Text = "Copy"
copyBtn.Font = Enum.Font.GothamBold
copyBtn.TextSize = 12
copyBtn.TextColor3 = THEME.BLACK
copyBtn.BackgroundColor3 = THEME.GREEN
corner(copyBtn, 6)

copyBtn.MouseButton1Click:Connect(function()
	local txt = out.Text or ""
	local ok = pcall(function() if setclipboard then setclipboard(txt) end end)
	status.Text = ok and "Copied to clipboard." or "Select all and copy manually."
end)

-- ================== SCAN ROUTINE ==================
local running = false
local function upd(i,n,phase)
	local p = (n>0) and math.floor(i/n*100 + 0.5) or 100
	pct.Text = tostring(math.clamp(p,0,100)).."%"
	status.Text = phase
end

local function runScan()
	if running then return end
	running = true
	out.Text = ""
	pct.Text = "0%"
	status.Text = "Scanning workspace…"

	-- buckets
	local counts = {
		ParticleEmitter = {total=0, enabled=0, rate_sum=0},
		Trail   = {total=0, enabled=0, bright_sum=0},
		Beam    = {total=0, enabled=0, bright_sum=0},
		Smoke   = {total=0, enabled=0},
		Fire    = {total=0, enabled=0},
		Sparkles= {total=0, enabled=0},
	}
	local samples = {ParticleEmitter={}, Trail={}, Beam={}, Smoke={}, Fire={}, Sparkles={}}

	local desc = workspace:GetDescendants()
	local n = #desc
	local batch = math.max(200, math.floor(n/40))

	for i,inst in ipairs(desc) do
		local cn = inst.ClassName
		if cn=="ParticleEmitter" then
			local b=counts.ParticleEmitter; b.total+=1; if gprop(inst,"Enabled") then b.enabled+=1 end
			b.rate_sum += (gprop(inst,"Rate") or 0)
			if #samples.ParticleEmitter<3 then table.insert(samples.ParticleEmitter, inst:GetFullName()) end
		elseif cn=="Trail" then
			local b=counts.Trail; b.total+=1; if gprop(inst,"Enabled") then b.enabled+=1 end
			b.bright_sum += (gprop(inst,"Brightness") or 0)
			if #samples.Trail<3 then table.insert(samples.Trail, inst:GetFullName()) end
		elseif cn=="Beam" then
			local b=counts.Beam; b.total+=1; if gprop(inst,"Enabled") then b.enabled+=1 end
			b.bright_sum += (gprop(inst,"Brightness") or 0)
			if #samples.Beam<3 then table.insert(samples.Beam, inst:GetFullName()) end
		elseif cn=="Smoke" then
			local b=counts.Smoke; b.total+=1; if gprop(inst,"Enabled") then b.enabled+=1 end
			if #samples.Smoke<3 then table.insert(samples.Smoke, inst:GetFullName()) end
		elseif cn=="Fire" then
			local b=counts.Fire; b.total+=1; if gprop(inst,"Enabled") then b.enabled+=1 end
			if #samples.Fire<3 then table.insert(samples.Fire, inst:GetFullName()) end
		elseif cn=="Sparkles" then
			local b=counts.Sparkles; b.total+=1; if gprop(inst,"Enabled") then b.enabled+=1 end
			if #samples.Sparkles<3 then table.insert(samples.Sparkles, inst:GetFullName()) end
		end

		if (i % batch)==0 then
			upd(i,n,"Scanning workspace…")
			RunService.Heartbeat:Wait()
		end
	end

	-- Lighting
	upd(n,n,"Scanning Lighting…")
	local PP = {"BloomEffect","ColorCorrectionEffect","DepthOfFieldEffect","SunRaysEffect","BlurEffect"}
	local pp_list = {}
	local kids = Lighting:GetChildren()
	for j,o in ipairs(kids) do
		for _,cn in ipairs(PP) do
			if o.ClassName == cn then
				local it = {class=cn, name=o.Name, enabled=o.Enabled}
				if cn=="BlurEffect" then
					it.size = gprop(o,"Size")
				else
					it.intensity = gprop(o,"Intensity")
				end
				table.insert(pp_list, it)
			end
		end
		if (j % 10)==0 then
			RunService.Heartbeat:Wait()
		end
	end

	-- Compose report
	local rep = {}
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

	add("")
	add("Lighting Post-Process:")
	if #pp_list==0 then
		add("  (none)")
	else
		for _,it in ipairs(pp_list) do
			local tail=""
			if it.class=="BlurEffect" and it.size~=nil then
				tail = string.format(" — Size: %d", it.size)
			elseif it.intensity~=nil then
				tail = string.format(" — Intensity: %.2f", it.intensity)
			end
			add("  %s (%s) — Enabled: %s%s", it.class, it.name, tostring(it.enabled), tail)
		end
	end

	out.Text = table.concat(rep, "\n")
	pct.Text = "100%"
	status.Text = "Scan complete — "..tostring(#desc).." objects checked."
	running = false
end

runBtn.MouseButton1Click:Connect(runScan)
