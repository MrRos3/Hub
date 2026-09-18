-- Velora Hub v3 - Vanta-inspired script library
local P=game:GetService("Players")
local T=game:GetService("TweenService")
local U=game:GetService("UserInputService")
local L=game:GetService("Lighting")
local C=game:GetService("CoreGui")
local player=P.LocalPlayer

local theme={
bg=Color3.fromHex("#000000"),panel=Color3.fromHex("#050406"),dialog=Color3.fromHex("#0A0709"),
element=Color3.fromHex("#151116"),hover=Color3.fromHex("#1D161B"),button=Color3.fromHex("#251016"),
accent=Color3.fromHex("#A1162F"),bright=Color3.fromHex("#D23A57"),outline=Color3.fromHex("#5A1824"),
text=Color3.fromHex("#FFFFFF"),muted=Color3.fromHex("#9A9AA3"),faint=Color3.fromHex("#68636B")
}
local fontId="rbxassetid://12187365364"
local function ff(w)return Font.new(fontId,w or Enum.FontWeight.Regular,Enum.FontStyle.Normal)end
local function mk(c,p,ch)local o=Instance.new(c)for k,v in pairs(p or{})do o[k]=v end for _,x in ipairs(ch or{})do x.Parent=o end return o end
local function corn(r)return mk("UICorner",{CornerRadius=UDim.new(0,r)})end
local function stk(col,tr,th)return mk("UIStroke",{Color=col,Transparency=tr or 0,Thickness=th or 1,ApplyStrokeMode=Enum.ApplyStrokeMode.Border})end
local function tw(o,d,p)local a=T:Create(o,TweenInfo.new(d or .14,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),p)a:Play()return a end
local function norm(s)return string.lower(tostring(s or""))end
local function has(a,b)return b=="" or string.find(norm(a),b,1,true)~=nil end

-- Exact SaltyIcons PNGs, with Roblox asset fallbacks.
local base="https://raw.githubusercontent.com/MrRos3/SaltyIcons/main/icons/png/96/"
local meta={
search={"misc","search","rbxassetid://100557104978626"},close={"status","x","rbxassetid://104564513546348"},
minus={"status","minus","rbxassetid://123173530093622"},star={"misc","star","rbxassetid://130603316912957"},
heart={"social","heart","rbxassetid://80686764701725"},code={"developer","code","rbxassetid://131595473006887"},
blocks={"developer","blocks","rbxassetid://96464084024408"},globe={"misc","globe","rbxassetid://123107843015250"},
pin={"misc","map-pin","rbxassetid://103242899547315"},unlock={"security","lock-open","rbxassetid://104913770360781"},
eye={"security","eye","rbxassetid://75816651251769"},scan={"security","scan-line","rbxassetid://107823756128414"},
user={"social","user","rbxassetid://108864475481601"},wrench={"settings","wrench","rbxassetid://82686700366508"},
refresh={"misc","refresh-cw","rbxassetid://89604821239492"},timer={"status","timer","rbxassetid://118623780796527"},
palette={"settings","palette","rbxassetid://79971389143262"}
}
local ca=getcustomasset or getsynasset
local can=type(writefile)=="function" and type(isfile)=="function" and type(makefolder)=="function" and type(isfolder)=="function" and type(ca)=="function"
local cache={}
local function folder(p)if not can then return false end if not isfolder(p)then if not pcall(makefolder,p)then return false end end return true end
local function icon(k)
 if cache[k]then return cache[k]end
 local m=meta[k]if not m then return""end
 if can and folder("VeloraHub") and folder("VeloraHub/icons")then
  local p="VeloraHub/icons/"..m[1].."_"..m[2]..".png"
  if not isfile(p)then
   local ok,b=pcall(function()return game:HttpGet(base..m[1].."/"..m[2]..".png")end)
   if ok and type(b)=="string" and #b>100 then pcall(writefile,p,b)end
  end
  if isfile(p)then local ok,a=pcall(ca,p)if ok and a and a~=""then cache[k]=a return a end end
 end
 cache[k]=m[3]return m[3]
end
local function im(parent,k,pos,size,col)
 return mk("ImageLabel",{BackgroundTransparency=1,Position=pos,Size=size,Image=icon(k),ImageColor3=col or theme.text,ScaleType=Enum.ScaleType.Fit,Parent=parent})
end

local scripts={
{Id="ghost",Name="Ghost Driver",Type="Roblox",Cat="Roblox",Tags={"vehicle","automation"},Icon="pin",Demo=true},
{Id="blox",Name="Blox Fruits",Type="Roblox",Cat="Roblox",Tags={"farm"},Icon="globe",Demo=true},
{Id="pet",Name="Pet Simulator X",Type="Roblox",Cat="Roblox",Tags={"utility"},Icon="heart",Demo=true},
{Id="blade",Name="Blade Ball",Type="Roblox",Cat="Roblox",Tags={"combat"},Icon="star",Demo=true},
{Id="arsenal",Name="Arsenal",Type="Roblox",Cat="Roblox",Tags={"combat"},Icon="scan",Demo=true},
{Id="hood",Name="Da Hood",Type="Roblox",Cat="Roblox",Tags={},Icon="pin",Demo=true},
{Id="doors",Name="Doors",Type="Roblox",Cat="Roblox",Tags={"esp"},Icon="unlock",Demo=true},
{Id="mm2",Name="MM2",Type="Roblox",Cat="Roblox",Tags={"combat"},Icon="eye",Demo=true},
{Id="soul",Name="Type Soul",Type="Roblox",Cat="Roblox",Tags={},Icon="user",Demo=true},
{Id="jail",Name="Jailbreak",Type="Roblox",Cat="Roblox",Tags={"vehicle"},Icon="unlock",Demo=true},
{Id="universal",Name="Salty Universal",Type="Universal",Cat="Universal",Tags={"utility"},Icon="blocks",Demo=true},
{Id="ui",Name="Salty UI Library",Type="UI / Library",Cat="UI",Tags={"library"},Icon="palette",Demo=true},
{Id="spy",Name="Remote Spy",Type="Tools",Cat="Tools",Tags={"remote"},Icon="eye",Demo=true},
{Id="fe",Name="FE Scripts",Type="Universal",Cat="Universal",Tags={},Icon="code",Demo=true},
{Id="tp",Name="Teleport Hub",Type="Tools",Cat="Tools",Tags={"teleport"},Icon="pin",Demo=true},
{Id="utils",Name="Game Utilities",Type="Tools",Cat="Tools",Tags={"utility"},Icon="wrench",Demo=true},
{Id="farm",Name="Auto Farm",Type="Universal",Cat="Universal",Tags={"automation"},Icon="refresh",Demo=true},
{Id="speed",Name="Speed Hub",Type="Tools",Cat="Tools",Tags={"movement"},Icon="timer",Demo=true},
}

local parent
local ok,g=pcall(function()if gethui then return gethui()end return C end)
parent=(ok and g)or player:WaitForChild("PlayerGui")
local old=parent:FindFirstChild("VeloraHub")if old then old:Destroy()end
local ob=L:FindFirstChild("VeloraHubBlur")if ob then ob:Destroy()end
local blur=mk("BlurEffect",{Name="VeloraHubBlur",Size=0,Parent=L})tw(blur,.2,{Size=9})

local gui=mk("ScreenGui",{Name="VeloraHub",ResetOnSpawn=false,IgnoreGuiInset=true,DisplayOrder=999999,ZIndexBehavior=Enum.ZIndexBehavior.Sibling,Parent=parent})
pcall(function()if syn and syn.protect_gui then syn.protect_gui(gui)end end)
local dim=mk("Frame",{Size=UDim2.fromScale(1,1),BackgroundColor3=theme.bg,BackgroundTransparency=.66,BorderSizePixel=0,Parent=gui})
local main=mk("CanvasGroup",{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),Size=UDim2.fromScale(.70,.70),BackgroundColor3=theme.panel,BackgroundTransparency=.06,BorderSizePixel=0,ClipsDescendants=true,Parent=dim},{
 corn(13),stk(theme.outline,.20,1),mk("UISizeConstraint",{MinSize=Vector2.new(860,530),MaxSize=Vector2.new(1160,740)})
})
local top=mk("Frame",{Size=UDim2.new(1,0,0,60),BackgroundColor3=theme.dialog,BackgroundTransparency=.12,BorderSizePixel=0,Parent=main})
mk("Frame",{AnchorPoint=Vector2.new(0,1),Position=UDim2.new(0,0,1,0),Size=UDim2.new(1,0,0,1),BackgroundColor3=theme.outline,BackgroundTransparency=.34,BorderSizePixel=0,Parent=top})

local logo=mk("Frame",{Position=UDim2.fromOffset(16,11),Size=UDim2.fromOffset(38,38),BackgroundColor3=theme.button,BackgroundTransparency=.08,BorderSizePixel=0,Parent=top},{corn(10),stk(theme.outline,.35,1)})
im(logo,"blocks",UDim2.fromOffset(9,9),UDim2.fromOffset(20,20),theme.text)
mk("TextLabel",{BackgroundTransparency=1,Position=UDim2.fromOffset(65,9),Size=UDim2.fromOffset(175,20),Text="VELORA HUB",TextColor3=theme.text,TextSize=14,FontFace=ff(Enum.FontWeight.SemiBold),TextXAlignment=Enum.TextXAlignment.Left,Parent=top})
mk("TextLabel",{BackgroundTransparency=1,Position=UDim2.fromOffset(65,29),Size=UDim2.fromOffset(175,17),Text="SCRIPT LIBRARY",TextColor3=theme.muted,TextSize=9,FontFace=ff(Enum.FontWeight.Medium),TextXAlignment=Enum.TextXAlignment.Left,Parent=top})

local sw=mk("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.new(.5,16,.5,0),Size=UDim2.new(.44,0,0,36),BackgroundColor3=theme.element,BackgroundTransparency=.08,BorderSizePixel=0,Parent=top},{corn(9),stk(theme.outline,.46,1)})
im(sw,"search",UDim2.fromOffset(11,9),UDim2.fromOffset(18,18),theme.muted)
local sb=mk("TextBox",{BackgroundTransparency=1,Position=UDim2.fromOffset(38,0),Size=UDim2.new(1,-68,1,0),Text="",PlaceholderText="Search scripts...",PlaceholderColor3=theme.muted,TextColor3=theme.text,TextSize=11,FontFace=ff(),TextXAlignment=Enum.TextXAlignment.Left,ClearTextOnFocus=false,Parent=sw})
local clear=mk("TextButton",{AnchorPoint=Vector2.new(1,.5),Position=UDim2.new(1,-7,.5,0),Size=UDim2.fromOffset(22,22),Text="",BackgroundTransparency=1,Visible=false,AutoButtonColor=false,Parent=sw},{corn(6)})
im(clear,"close",UDim2.fromOffset(5,5),UDim2.fromOffset(12,12),theme.muted)

local wc=mk("Frame",{AnchorPoint=Vector2.new(1,.5),Position=UDim2.new(1,-12,.5,0),Size=UDim2.fromOffset(68,30),BackgroundTransparency=1,Parent=top})
local function wb(k,x)local b=mk("TextButton",{Position=UDim2.fromOffset(x,1),Size=UDim2.fromOffset(29,28),Text="",BackgroundColor3=theme.button,BackgroundTransparency=1,AutoButtonColor=false,Parent=wc},{corn(8)})im(b,k,UDim2.fromOffset(8,7),UDim2.fromOffset(13,13),theme.muted)b.MouseEnter:Connect(function()tw(b,.1,{BackgroundTransparency=.18})end)b.MouseLeave:Connect(function()tw(b,.1,{BackgroundTransparency=1})end)return b end
local min=wb("minus",0)local close=wb("close",38)

local bar=mk("Frame",{Position=UDim2.fromOffset(16,71),Size=UDim2.new(1,-32,0,32),BackgroundTransparency=1,Parent=main})
local filters=mk("Frame",{Size=UDim2.new(1,-120,1,0),BackgroundTransparency=1,Parent=bar},{mk("UIListLayout",{FillDirection=Enum.FillDirection.Horizontal,VerticalAlignment=Enum.VerticalAlignment.Center,Padding=UDim.new(0,7)})})
local count=mk("TextLabel",{AnchorPoint=Vector2.new(1,.5),Position=UDim2.new(1,0,.5,0),Size=UDim2.fromOffset(104,28),BackgroundColor3=theme.element,BackgroundTransparency=.14,Text="0 scripts",TextColor3=theme.muted,TextSize=9,FontFace=ff(Enum.FontWeight.Medium),Parent=bar},{corn(8),stk(theme.outline,.58,1)})

local grid=mk("ScrollingFrame",{Position=UDim2.fromOffset(16,112),Size=UDim2.new(1,-32,1,-145),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=2,ScrollBarImageColor3=theme.outline,ScrollBarImageTransparency=.18,AutomaticCanvasSize=Enum.AutomaticSize.Y,CanvasSize=UDim2.new(),Parent=main})
local gl=mk("UIGridLayout",{CellPadding=UDim2.fromOffset(9,9),CellSize=UDim2.fromOffset(300,102),FillDirectionMaxCells=3,SortOrder=Enum.SortOrder.LayoutOrder,Parent=grid})
mk("UIPadding",{PaddingTop=UDim.new(0,2),PaddingBottom=UDim.new(0,10),PaddingRight=UDim.new(0,4),Parent=grid})
local empty=mk("TextLabel",{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.55),Size=UDim2.fromOffset(320,60),BackgroundTransparency=1,Text="No scripts found\nTry another search.",TextColor3=theme.muted,TextSize=12,FontFace=ff(Enum.FontWeight.Medium),Visible=false,Parent=main})

local cards, favs, fbuttons={}, {}, {}
local current="All"
local selected
local function notice(s)
 local old=main:FindFirstChild("Toast")if old then old:Destroy()end
 local q=mk("TextLabel",{Name="Toast",AnchorPoint=Vector2.new(.5,1),Position=UDim2.new(.5,0,1,10),Size=UDim2.fromOffset(320,38),BackgroundColor3=theme.dialog,BackgroundTransparency=.02,Text=s,TextColor3=theme.text,TextSize=10,FontFace=ff(Enum.FontWeight.Medium),Parent=main},{corn(9),stk(theme.outline,.3,1)})
 tw(q,.14,{Position=UDim2.new(.5,0,1,-24)})task.delay(1.8,function()if q.Parent then tw(q,.12,{Position=UDim2.new(.5,0,1,10),TextTransparency=1,BackgroundTransparency=1})task.wait(.13)if q.Parent then q:Destroy()end end end)
end
local function run(e)
 if e.Demo then notice("Selected "..e.Name) return end
 if type(e.Run)=="function"then local ok,er=pcall(e.Run)if not ok then notice(tostring(er))end return end
 if e.Url then local ok,er=pcall(function()return loadstring(game:HttpGet(e.Url))()end)if not ok then notice(tostring(er))end end
end
local function selectCard(e)
 selected=e.Id
 for id,d in pairs(cards)do
  local on=id==selected
  d.b.Text=on and"Selected"or"Select";d.b.BackgroundColor3=on and theme.accent or theme.button;d.b.TextColor3=on and theme.text or theme.muted
  tw(d.c,.12,{BackgroundColor3=on and Color3.fromHex("#160B0F")or theme.element})
  tw(d.s,.12,{Color=on and theme.bright or theme.outline,Transparency=on and .18 or .56})
 end
 run(e)
end
local function card(e,i)
 local c=mk("Frame",{LayoutOrder=i,BackgroundColor3=theme.element,BackgroundTransparency=.1,BorderSizePixel=0,Parent=grid},{corn(10)})
 local s=stk(theme.outline,.56,1)s.Parent=c
 local ib=mk("Frame",{Position=UDim2.fromOffset(11,11),Size=UDim2.fromOffset(40,40),BackgroundColor3=theme.button,BackgroundTransparency=.08,BorderSizePixel=0,Parent=c},{corn(9),stk(theme.outline,.48,1)})
 im(ib,e.Icon,UDim2.fromOffset(9,9),UDim2.fromOffset(22,22),theme.text)
 mk("TextLabel",{BackgroundTransparency=1,Position=UDim2.fromOffset(61,10),Size=UDim2.new(1,-142,0,20),Text=e.Name,TextColor3=theme.text,TextSize=12,FontFace=ff(Enum.FontWeight.SemiBold),TextXAlignment=Enum.TextXAlignment.Left,TextTruncate=Enum.TextTruncate.AtEnd,Parent=c})
 mk("TextLabel",{BackgroundTransparency=1,Position=UDim2.fromOffset(61,30),Size=UDim2.new(1,-142,0,17),Text=e.Type,TextColor3=theme.muted,TextSize=9,FontFace=ff(),TextXAlignment=Enum.TextXAlignment.Left,Parent=c})
 mk("TextLabel",{Position=UDim2.fromOffset(11,65),Size=UDim2.fromOffset(math.max(54,22+#e.Cat*5),25),BackgroundColor3=theme.dialog,BackgroundTransparency=.08,Text=e.Cat,TextColor3=theme.faint,TextSize=8,FontFace=ff(Enum.FontWeight.Medium),Parent=c},{corn(7),stk(theme.outline,.64,1)})
 local fb=mk("TextButton",{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-10,0,10),Size=UDim2.fromOffset(24,24),Text="",BackgroundTransparency=1,AutoButtonColor=false,Parent=c},{corn(7)})
 local fi=im(fb,"star",UDim2.fromOffset(5,5),UDim2.fromOffset(14,14),theme.faint)
 local b=mk("TextButton",{AnchorPoint=Vector2.new(1,1),Position=UDim2.new(1,-11,1,-11),Size=UDim2.fromOffset(82,27),BackgroundColor3=theme.button,BackgroundTransparency=.04,Text="Select",TextColor3=theme.muted,TextSize=9,FontFace=ff(Enum.FontWeight.SemiBold),AutoButtonColor=false,Parent=c},{corn(8),stk(theme.outline,.44,1)})
 fb.MouseButton1Click:Connect(function()favs[e.Id]=not favs[e.Id]fi.ImageColor3=favs[e.Id]and theme.bright or theme.faint end)
 b.MouseButton1Click:Connect(function()selectCard(e)end)
 c.MouseEnter:Connect(function()if selected~=e.Id then tw(c,.1,{BackgroundColor3=theme.hover})tw(s,.1,{Transparency=.34})end end)
 c.MouseLeave:Connect(function()if selected~=e.Id then tw(c,.1,{BackgroundColor3=theme.element})tw(s,.1,{Transparency=.56})end end)
 b.MouseEnter:Connect(function()if selected~=e.Id then tw(b,.1,{BackgroundColor3=Color3.fromHex("#34141D"),TextColor3=theme.text})end end)
 b.MouseLeave:Connect(function()if selected~=e.Id then tw(b,.1,{BackgroundColor3=theme.button,TextColor3=theme.muted})end end)
 cards[e.Id]={c=c,s=s,b=b}
end
for i,e in ipairs(scripts)do card(e,i)end

local names={"All","Roblox","Universal","UI","Tools","Favorites"}
for i,n in ipairs(names)do
 local b=mk("TextButton",{LayoutOrder=i,Size=UDim2.fromOffset(math.max(46,20+#n*5),28),BackgroundColor3=theme.element,BackgroundTransparency=.14,Text=n,TextColor3=theme.muted,TextSize=9,FontFace=ff(Enum.FontWeight.Medium),AutoButtonColor=false,Parent=filters},{corn(8),stk(theme.outline,.58,1)})
 fbuttons[n]=b
end
local function match(e,q)
 local f=current=="All"or(current=="Favorites"and favs[e.Id])or norm(e.Cat)==norm(current)or norm(e.Type)==norm(current)
 if not f then return false end
 if q==""then return true end
 if has(e.Name,q)or has(e.Type,q)or has(e.Cat,q)then return true end
 for _,x in ipairs(e.Tags or{})do if has(x,q)then return true end end
 return false
end
local function refresh()
 local q=norm(sb.Text)local n=0
 for _,e in ipairs(scripts)do local v=match(e,q)cards[e.Id].c.Visible=v if v then n+=1 end end
 clear.Visible=sb.Text~="";empty.Visible=n==0;count.Text=tostring(n)..(n==1 and" script"or" scripts")
end
local function paint()
 for n,b in pairs(fbuttons)do local on=n==current;b.BackgroundColor3=on and theme.button or theme.element;b.TextColor3=on and theme.text or theme.muted;local s=b:FindFirstChildOfClass("UIStroke")s.Color=on and theme.accent or theme.outline;s.Transparency=on and .22 or .58 end
end
for n,b in pairs(fbuttons)do b.MouseButton1Click:Connect(function()current=n paint()refresh()end)b.MouseEnter:Connect(function()if current~=n then tw(b,.1,{BackgroundColor3=theme.hover,TextColor3=theme.text})end end)b.MouseLeave:Connect(function()if current~=n then tw(b,.1,{BackgroundColor3=theme.element,TextColor3=theme.muted})end end)end
sb:GetPropertyChangedSignal("Text"):Connect(refresh)
sb.Focused:Connect(function()local s=sw:FindFirstChildOfClass("UIStroke")tw(sw,.1,{BackgroundColor3=theme.hover})tw(s,.1,{Color=theme.accent,Transparency=.18})end)
sb.FocusLost:Connect(function()local s=sw:FindFirstChildOfClass("UIStroke")tw(sw,.1,{BackgroundColor3=theme.element})tw(s,.1,{Color=theme.outline,Transparency=.46})end)
clear.MouseButton1Click:Connect(function()sb.Text=""sb:CaptureFocus()end)

local minimized=false
local full=main.Size
local function mini(v)minimized=v bar.Visible=not v grid.Visible=not v empty.Visible=false if v then tw(main,.2,{Size=UDim2.new(full.X.Scale,full.X.Offset,0,60)})else tw(main,.2,{Size=full})refresh()end end
min.MouseButton1Click:Connect(function()mini(not minimized)end)
local function visible(v)gui.Enabled=v tw(blur,.14,{Size=v and 9 or 0})end
close.MouseButton1Click:Connect(function()visible(false)end)
U.InputBegan:Connect(function(i,gp)
 if i.KeyCode==Enum.KeyCode.RightShift and not gp then visible(not gui.Enabled)return end
 if i.KeyCode==Enum.KeyCode.K and(U:IsKeyDown(Enum.KeyCode.LeftControl)or U:IsKeyDown(Enum.KeyCode.RightControl))then if not gui.Enabled then visible(true)end if minimized then mini(false)end task.defer(function()sb:CaptureFocus()end)end
end)

local dragging,ds,sp=false
 top.InputBegan:Connect(function(i)if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dragging=true ds=i.Position sp=main.Position end end)
 top.InputEnded:Connect(function(i)if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dragging=false end end)
 U.InputChanged:Connect(function(i)if dragging and(i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch)then local d=i.Position-ds main.Position=UDim2.new(sp.X.Scale,sp.X.Offset+d.X,sp.Y.Scale,sp.Y.Offset+d.Y)end end)

local function resize()
 local w=grid.AbsoluteSize.X if w<=0 then return end
 local cols=w>=1050 and 4 or(w<730 and 2 or 3)local gap=9 local cw=math.floor((w-gap*(cols-1)-6)/cols)
 gl.FillDirectionMaxCells=cols gl.CellSize=UDim2.fromOffset(cw,102)
end
grid:GetPropertyChangedSignal("AbsoluteSize"):Connect(resize)
paint()refresh()task.defer(resize)
local fs=main.Size main.Size=UDim2.new(fs.X.Scale-.02,0,fs.Y.Scale-.02,0)main.GroupTransparency=1
tw(main,.22,{Size=fs,GroupTransparency=0})
task.delay(.3,function()if gui.Parent then notice("Velora Hub ready")end end)
