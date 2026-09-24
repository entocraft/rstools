-- Ventura RSTools : rstools/common.lua (version compacte, code commente dans source/)
APP="Ventura RSTools"
ROLE=(...)or"standard"
LANG=(function()
local file=(ROLE=="bay")and"rstools_bay.txt"or"rstools_config.txt"
local ok,t=pcall(function()
if not fs.exists(file)then return nil end
local f=fs.open(file,"r")
local c=f.readAll();f.close()
return textutils.unserialise(c)
end)
return(ok and type(t)=="table"and type(t.settings)=="table"and t.settings.lang)or"fr"
end)()
L=(function()
if LANG~="en"then return function(s)return s end end
local EN={}
local ok,t=pcall(function()
local fn=loadfile("rstools/lang/en.lua")
return fn and fn()
end)
if ok and type(t)=="table"then EN=t end
return function(s)return EN[s]or s end
end)()
VERSION="4.5.1"
CFG={
dataFile="rstools_data.txt",
configFile="rstools_config.txt",
oldDataFile="rsui_data.txt",
saveEvery=60,
graphEvery=30,
historyLen=240,
snapEvery=300,
snapKeep=36,
trendWindow=3600,
autoCooldown=30,
logMax=300,
baySlots=8,
updateUrl="",
repoUrl=RSTOOLS_REPO or"https://raw.githubusercontent.com/VOTRE-PSEUDO/rstools/main/",
updateEvery=3600,
}
DEF={
theme="sombre",toolbar="haut",scale=0.5,refresh=5,sounds=true,volume=1,
mainMon=nil,bayMode="slots",bayAuto=false,bayCols=6,bayRows=3,
fillAlert=24,toastDur=5,tabIcons=true,rounded=true,
storageFull=90,fluidFull=90,energyLow=20,
chatAlerts=true,redstoneSide="aucune",
anomalies=true,anomPct=40,anomMin=256,anomWindow=300,
autoOn=true,autoMaxCraft=256,maxOn=true,trash="aucune",
dormant=86400,bootAnim=true,baysEvery=30,backup=false,
lang="fr",kbSize="grand",mosView="mods",mosColor="trend",
autoUpdate=false,updateUrl=nil,repoUrl=nil,
}
THEMES={
{id="sombre",name=L"Sombre",p={0x0e1117,0x1b212b,0x7c8698,0xe6eaf0,0x2ec4b6}},
{id="ventura",name="Ventura",p={0x101014,0x1f1f2c,0x8a8aa6,0xf0f0f8,0x9b5cff}},
{id="nuit",name=L"Nuit bleue",p={0x0b1020,0x18213a,0x7d8bb0,0xe8ecff,0x6c8cff}},
{id="foret",name=L"Foret",p={0x0d140f,0x1b2a1f,0x7f9985,0xe4f0e6,0x4cc36a}},
{id="ambre",name=L"Ambre",p={0x14100b,0x2a2117,0x9c8a70,0xf3e6d0,0xf0a030}},
{id="sakura",name="Sakura",p={0x160d12,0x2b1a24,0xa08494,0xf6e8ef,0xe0569b}},
{id="clair",name=L"Clair",p={0xf2f4f7,0xdde2ea,0x667085,0x1b2230,0x0f8f85}},
{id="contraste",name=L"Contraste eleve",p={0x000000,0x2a2a2a,0xb8b8b8,0xffffff,0xffd400}},
{id="cc",name=L"CC d'origine",p=nil},
}
THEME_SLOTS={colors.black,colors.gray,colors.lightGray,colors.white,colors.cyan}
T={
bg=colors.black,panel=colors.gray,accent=colors.cyan,
text=colors.white,dim=colors.lightGray,
ok=colors.lime,warn=colors.orange,bad=colors.red,energy=colors.yellow,
}
function now()return os.epoch("utc")/1000 end
store={
rules={},maxRules={},histStorage={},histEnergy={},
bays={},log={},lastMove={},settings={},pins={},widgets={},
}
state={
tab="home",data=nil,scroll={},sort="count",search="",filter=nil,
popup=nil,input=nil,msg=nil,msgTime=0,lastUpdate="--:--:--",
dirty=false,lastSave=0,lastGraph=0,lastUpdateCheck=0,restart=false,
autoStatus={},autoLast={},autoErr={},maxStatus={},maxErr={},
launched={},prevRunning={},alerts={},alertKeys={},anom={},recent={},
autoView="min",logFilter="all",toasts={},toastLog={},stick={},
kb=false,kbUpper=false,setCat="apparence",
pool={},iconCache={},countBuf={},noCats={},dataVersion=0,lastChange="--:--",
}
buttons={}
function S(k)
local v=store.settings[k]
if v==nil then v=DEF[k]end
return v
end
function notify(m)state.msg=m;state.msgTime=os.clock()end
function bays()
local slots=CFG.baySlots
local c=state.ctx
local auto,cols,rows,drives
if c and c.grid then auto,cols,rows,drives=c.grid.auto,c.grid.cols,c.grid.rows,c.drives
else auto,cols,rows,drives=S("bayAuto"),S("bayCols"),S("bayRows"),state.drivesCache end
if auto then
local n=0
for _ in pairs(drives or{})do n=n+1 end
if n>0 then
local bc,br,best=n,1,math.huge
for r=1,n do
if n%r==0 then
local c=math.floor(n/r)
local score=math.abs(c/r-2)
if score<best then bc,br,best=c,r,score end
end
end
return{cols=bc,rows=br,slots=slots}
end
end
return{cols=cols or 6,rows=rows or 3,slots=slots}
end
function bayMap()
local c=state.ctx
return(c and c.map)or store.bays
end
lastBreath=os.clock()
function breathe()
if os.clock()-lastBreath>0.3 then
os.queueEvent("rstools_breath")
os.pullEvent("rstools_breath")
lastBreath=os.clock()
end
end
toB=colors.toBlit
function clamp(v,a,b)return math.max(a,math.min(b,v))end
function cut(s,n)s=tostring(s);if n<=0 then return""end return s:sub(1,n)end
function fmt(n)
if not n then return"?"end
local a=math.abs(n)
if a>=1e9 then return("%.2fG"):format(n/1e9)
elseif a>=1e6 then return("%.2fM"):format(n/1e6)
elseif a>=1e3 then return("%.1fk"):format(n/1e3)end
return tostring(math.floor(n+0.5))
end
function fmtMB(n)
if not n then return"?"end
if math.abs(n)<1000 then return math.floor(n).."mB"end
return fmt(n/1000).."B"
end
function fmtSigned(n)return(n>=0 and"+"or"-")..fmt(math.abs(n))end
function duration(s)
s=math.max(0,s)
if s<60 then return("%ds"):format(math.floor(s))
elseif s<3600 then return("%dmin"):format(math.floor(s/60))
elseif s<86400 then return("%gh"):format(math.floor(s/360+0.5)/10)end
return("%g"..(LANG=="en"and"d"or"j")):format(math.floor(s/8640+0.5)/10)
end
function pct(v)return v.."%"end
function pushHist(h,v)
h[#h+1]=math.floor(clamp(v,0,1)*10000+0.5)/10000
while#h>CFG.historyLen do table.remove(h,1)end
end
function ratioColor(r)
if r>0.9 then return T.bad elseif r>0.7 then return T.warn end
return T.ok
end
function camel(s)return(s:gsub("_(%a)",string.upper))end
function prettify(id)
if not id then return"?"end
local n=tostring(id):gsub("^[^:]+:",""):gsub("_"," ")
return n:sub(1,1):upper()..n:sub(2)
end
function cleanName(it)
local n=it.displayName
if type(n)~="string"or n==""then return prettify(it.name)end
return(n:gsub("^%[(.*)%]$","%1"))
end
function logRatio(v,max)
if not max or max<=0 then return 0 end
return math.log(v+1)/math.log(max+1)
end
function isType(n,t)
if peripheral.hasType then return peripheral.hasType(n,t)end
for _,x in ipairs({peripheral.getType(n)})do if x==t then return true end end
return false
end
widgets={}
OX,OY=0,0
function listMonitors()
local r={}
for _,n in ipairs(peripheral.getNames())do
if isType(n,"monitor")then r[#r+1]=n end
end
table.sort(r)
return r
end
function themeById(id)
for _,t in ipairs(THEMES)do if t.id==id then return t end end
return THEMES[1]
end
function applyPalette(w)
local th=themeById(S("theme"))
for i=0,15 do
local c=2^i
w.setPaletteColor(c,term.nativePaletteColor(c))
end
if th.p then
for i,c in ipairs(THEME_SLOTS)do w.setPaletteColor(c,th.p[i])end
end
end
function releaseMonitor(m)
if not m then return end
pcall(function()
for i=0,15 do local c=2^i;m.setPaletteColor(c,term.nativePaletteColor(c))end
m.setBackgroundColor(colors.black);m.clear()
end)
end
function isWidgetMon(n)
local c=store.widgets[n]
return c and c.type~="aucun"
end
MIN_W,MIN_H=39,19
SCALES={0.5,1,1.5,2,2.5,3}
function sizeAt(w,h,cur,sc)
return math.floor(w*6*cur/(6*sc)),math.floor(h*9*cur/(9*sc))
end
function fittingScales()
local b=state.base or{w=MIN_W,h=MIN_H}
local r={}
for _,sc in ipairs(SCALES)do
local sw,sh=sizeAt(b.w,b.h,0.5,sc)
if sw>=MIN_W and sh>=MIN_H then r[#r+1]=sc end
end
if#r==0 then r[1]=0.5 end
return r
end
function setupWidgets()
for n,w in pairs(widgets)do
releaseMonitor(w.mon)
widgets[n]=nil
end
for n,cfg in pairs(store.widgets)do
if cfg.type~="aucun"and n~=monName and peripheral.isPresent(n)and isType(n,"monitor")then
local m=peripheral.wrap(n)
if m.isColor()then
m.setTextScale(cfg.scale or 0.5)
local w,h=m.getSize()
local ww={mon=m,W=w,H=h,name=n}
ww.win=window.create(m,1,1,w,h,true)
applyPalette(ww.win)
widgets[n]=ww
end
end
end
end
function checkScreens()
if mon then
local ok,cw,ch=pcall(mon.getSize)
if ok and(cw~=W or ch~=H)then W,H=cw,ch;win.reposition(1,1,W,H);state.forceRender=true end
end
local need=false
for n,cfg in pairs(store.widgets)do
local wanted=cfg.type~="aucun"and n~=monName and peripheral.isPresent(n)and isType(n,"monitor")
local w=widgets[n]
if wanted and not w then
need=true
elseif wanted and w then
local ok,cw,ch=pcall(w.mon.getSize)
if not ok or cw~=w.W or ch~=w.H then need=true end
elseif w then
need=true
end
end
for n in pairs(widgets)do if not store.widgets[n]then need=true end end
if need then pcall(setupWidgets);state.forceRender=true end
end
function fill(x,y,w,h,bg)
if w<=0 or h<=0 then return end
win.setBackgroundColor(bg)
local s=(" "):rep(w)
for i=0,h-1 do win.setCursorPos(x,y+i);win.write(s)end
end
function text(x,y,str,fg,bg)
win.setCursorPos(x,y)
win.setBackgroundColor(bg or T.bg)
win.setTextColor(fg or T.text)
win.write(str)
end
function rightText(xEnd,y,str,fg,bg)text(xEnd-#str+1,y,str,fg,bg)end
function centerText(x,w,y,str,fg,bg)
str=cut(str,w)
text(x+math.floor((w-#str)/2),y,str,fg,bg)
end
function addButton(x1,y1,x2,y2,fn)
buttons[#buttons+1]={x1=x1+OX,y1=y1+OY,x2=x2+OX,y2=y2+OY,fn=fn}
end
function withSub(x,y,w,h,fn,...)
local sWin,sW,sH,sOX,sOY=win,W,H,OX,OY
local sub=window.create(win,x,y-4,w,h+5,false)
sub.setBackgroundColor(T.bg);sub.clear()
win,W,H=sub,w,h+5
OX,OY=sOX+x-1,sOY+y-5
local ok,err=pcall(fn,...)
sub.setVisible(true)
win,W,H,OX,OY=sWin,sW,sH,sOX,sOY
if not ok then error(err,0)end
end
function bgAt(x,y)
if not win.getLine or x<1 or y<1 or x>W or y>H then return nil end
local ok,_,_,bgs=pcall(win.getLine,y)
if not ok or type(bgs)~="string"then return nil end
local c=bgs:sub(x,x)
if c==""then return nil end
local n=tonumber(c,16)
return n and 2^n or nil
end
function corner(x,y,which,col,outside)
if not outside or outside==col then return end
win.setCursorPos(x,y)
if which=="tl"then win.blit("\129",toB(outside),toB(col))
elseif which=="tr"then win.blit("\130",toB(outside),toB(col))
elseif which=="bl"then win.blit("\144",toB(outside),toB(col))
elseif which=="br"then win.blit("\159",toB(col),toB(outside))
elseif which=="l"then win.blit("\145",toB(outside),toB(col))
elseif which=="r"then win.blit("\157",toB(col),toB(outside))end
end
function roundFill(x,y,w,h,col,colL)
if not S("rounded")or w<2 then fill(x,y,w,h,col);if colL then fill(x,y,1,h,colL)end;return end
local oTL,oTR=bgAt(x,y),bgAt(x+w-1,y)
local oBL,oBR=bgAt(x,y+h-1),bgAt(x+w-1,y+h-1)
fill(x,y,w,h,col)
if colL then fill(x,y,1,h,colL)end
local cl=colL or col
if h==1 then
corner(x,y,"l",cl,oTL);corner(x+w-1,y,"r",col,oTR)
else
corner(x,y,"tl",cl,oTL);corner(x+w-1,y,"tr",col,oTR)
corner(x,y+h-1,"bl",cl,oBL);corner(x+w-1,y+h-1,"br",col,oBR)
end
end
function button(x,y,label,bg,fg,fn)
local w=#label+2
roundFill(x,y,w,1,bg)
text(x+1,y,label,fg,bg)
addButton(x,y,x+w-1,y,fn)
return w
end
function slimBar(x,y,w,ratio,col,bgc,track)
if w<=0 then return end
local f=math.floor(clamp(ratio or 0,0,1)*w+0.5)
win.setCursorPos(x,y)
win.blit(("\140"):rep(w),toB(col):rep(f)..toB(track or T.bg):rep(w-f),toB(bgc):rep(w))
end
function sectionTitle(x,y,title,extra,x2)
x2=x2 or(W-1)
text(x,y,cut(title:upper(),x2-x+1),T.accent)
local ex=x+#title+1
if extra then text(ex,y,cut(extra,x2-ex+1),T.dim);ex=ex+#extra+1 end
if x2-ex+1>=1 then text(ex,y,("\140"):rep(x2-ex+1),T.panel)end
end
BITS={1,2,4,8,16}
function drawPixels(x,y,cw,ch,getpx)
local px={}
for cy=0,ch-1 do
local chars,fgs,bgs={},{},{}
for cx=0,cw-1 do
local cnt,order={},{}
for i=0,5 do
local c=getpx(cx*2+(i%2)+1,cy*3+math.floor(i/2)+1)
px[i+1]=c
if not cnt[c]then cnt[c]=0;order[#order+1]=c end
cnt[c]=cnt[c]+1
end
local a,b=order[1],nil
for _,c in ipairs(order)do if cnt[c]>cnt[a]then a=c end end
for _,c in ipairs(order)do
if c~=a and(not b or cnt[c]>cnt[b])then b=c end
end
if not b then
chars[#chars+1]=" ";fgs[#fgs+1]=toB(a);bgs[#bgs+1]=toB(a)
else
for i=1,6 do if px[i]~=a then px[i]=b end end
local bgc=px[6]
local fgc=(bgc==a)and b or a
local v=128
for i=1,5 do if px[i]~=bgc then v=v+BITS[i]end end
chars[#chars+1]=string.char(v);fgs[#fgs+1]=toB(fgc);bgs[#bgs+1]=toB(bgc)
end
end
win.setCursorPos(x,y+cy)
win.blit(table.concat(chars),table.concat(fgs),table.concat(bgs))
end
end
function graph(x,y,cw,ch,hist,col,bgc,crest)
local pw,ph,n=cw*2,ch*3,#hist
crest=crest or colors.white
drawPixels(x,y,cw,ch,function(px,py)
local v=hist[n-pw+px]
if not v then return bgc end
local hgt=math.floor(v*ph+0.5)
if hgt<1 then hgt=1 end
local fromBottom=ph-py
if fromBottom==hgt-1 then return crest end
if fromBottom<hgt then return col end
return bgc
end)
end
function vGauge(x,y,cw,ch,ratio,col,bgc)
local ph=ch*3
local filled=math.floor(clamp(ratio,0,1)*ph+0.5)
drawPixels(x,y,cw,ch,function(_,py)
if ph-py<filled then return col end
return bgc
end)
end
C=colors
;(function()
local SHAPES={
block={"........",".aaaaab.",".abbbbc.",".abbbbc.",".abbbbc.",
".abbbbc.",".abbbbc.",".bccccc.","........"},
ingot={"........","........","........","..aaaa..",".abbbbc.",
"abbbbbbc","bccccccc","........","........"},
gem={"........","..aaab..",".abbbbc.","abbbbbbc",".bbbbcc.",
"..bbcc..","...cc...","........","........"},
dust={"........","........","........","...aa...","..abbb..",
".abbbbc.","abbbbbbc","bbcbbcbc","........"},
nugget={"........","........","........","..aab...",".abbbc..",
".bbbcc..","..ccc...","........","........"},
ore={"ssssssss","sxxsssss","sxxssxxs","ssssxxss","ssssssss",
"sxsssxss","sxxssxxs","ssssssss","ssssssss"},
tool={".abbbbc.","a..ww..c","...ww...","...ww...","...ww...",
"...ww...","...ww...","...ww...","........"},
sword={"......ab",".....abc","....abc.","...abc..","c.abc...",
".cbc....","..w.....",".w.c....","w......."},
drop={"........","...ab...","...ab...","..abbc..",".abbbbc.",
".abbbbc.",".bbbbcc.","..bccc..","........"},
gas={"........",".aab....","abbbc.ab","bbbcc.bc",".bcc.ab.",
"....abbc","....bbcc",".....cc.","........"},
}
local FLUIDMAT={
{"lava",C.yellow,C.orange,C.red},
{"water",C.lightBlue,C.blue,C.blue},
{"milk",C.white,C.white,C.lightGray},
{"experience",C.lime,C.lime,C.green},
{"xp",C.lime,C.lime,C.green},
{"honey",C.yellow,C.orange,C.orange},
{"oil",C.lightGray,C.gray,C.black},
{"fuel",C.yellow,C.yellow,C.orange},
{"diesel",C.yellow,C.yellow,C.orange},
{"blood",C.pink,C.red,C.brown},
{"hydrogen",C.white,C.white,C.lightBlue},
{"oxygen",C.white,C.lightBlue,C.cyan},
{"chlorine",C.yellow,C.lime,C.green},
}
local MAT={
{"netherite",C.lightGray,C.gray,C.black},
{"diamond",C.white,C.lightBlue,C.cyan},
{"emerald",C.lime,C.lime,C.green},
{"redstone",C.pink,C.red,C.brown},
{"lapis",C.lightBlue,C.blue,C.blue},
{"glowstone",C.white,C.yellow,C.orange},
{"gold",C.white,C.yellow,C.orange},
{"copper",C.yellow,C.orange,C.brown},
{"iron",C.white,C.lightGray,C.gray},
{"coal",C.lightGray,C.gray,C.black},
{"quartz",C.white,C.white,C.lightGray},
{"amethyst",C.magenta,C.purple,C.purple},
{"obsidian",C.purple,C.black,C.black},
{"slime",C.lime,C.lime,C.green},
{"glass",C.white,C.lightBlue,C.lightGray},
{"sand",C.white,C.yellow,C.orange},
{"snow",C.white,C.white,C.lightGray},
{"deepslate",C.lightGray,C.gray,C.black},
{"cobble",C.white,C.lightGray,C.gray},
{"stone",C.white,C.lightGray,C.gray},
{"andesite",C.white,C.lightGray,C.gray},
{"diorite",C.white,C.white,C.lightGray},
{"granite",C.pink,C.brown,C.brown},
{"gravel",C.lightGray,C.gray,C.black},
{"clay",C.white,C.lightGray,C.gray},
{"dirt",C.orange,C.brown,C.black},
{"log",C.orange,C.brown,C.black},
{"wood",C.yellow,C.orange,C.brown},
{"plank",C.yellow,C.orange,C.brown},
{"stick",C.yellow,C.orange,C.brown},
{"leather",C.orange,C.brown,C.brown},
{"bone",C.white,C.white,C.lightGray},
{"string",C.white,C.white,C.lightGray},
{"wheat",C.yellow,C.yellow,C.orange},
{"apple",C.pink,C.red,C.brown},
}
local DYES={"light_blue","light_gray","white","orange","magenta","yellow","lime",
"pink","gray","cyan","purple","blue","brown","green","red","black"}
local DYE_SHADE={
white=C.lightGray,orange=C.brown,magenta=C.purple,lightBlue=C.blue,
yellow=C.orange,lime=C.green,pink=C.magenta,gray=C.black,
lightGray=C.gray,cyan=C.blue,purple=C.blue,blue=C.black,
brown=C.black,green=C.black,red=C.brown,black=C.gray,
}
local FALLBACK={
{C.white,C.lightBlue,C.blue},{C.pink,C.magenta,C.purple},
{C.lime,C.green,C.green},{C.yellow,C.orange,C.brown},
{C.white,C.cyan,C.blue},{C.pink,C.red,C.brown},
}
local function iconFor(id,kind)
id=id or"?"
kind=kind or"item"
local key=kind.."|"..id
local hit=state.iconCache[key]
if hit then hit.used=os.clock();return hit end
local path=id:gsub("^[^:]+:","")
local shape="block"
if kind=="fluid"then shape="drop"
elseif kind=="chem"then shape="gas"
elseif path:find("pickaxe")or path:find("_axe$")or path:find("shovel")or path:find("_hoe$")then shape="tool"
elseif path:find("sword")then shape="sword"
elseif path:find("_block$")or path:find("^block_of")then shape="block"
elseif path:find("_ore$")then shape="ore"
elseif path:find("ingot")then shape="ingot"
elseif path:find("nugget")or path:find("^raw_")then shape="nugget"
elseif path:find("dust")or path:find("powder")or path=="redstone"or path=="gunpowder"or path=="sugar"then shape="dust"
elseif path:find("diamond")or path:find("emerald")or path:find("quartz")or path:find("shard")
or path:find("lapis")or path:find("gem")or path:find("crystal")or path:find("pearl")then shape="gem"
end
local pal
if kind~="item"then
for _,m in ipairs(FLUIDMAT)do
if path:find(m[1],1,true)then pal={m[2],m[3],m[4]};break end
end
end
if not pal then
for _,d in ipairs(DYES)do
if path:sub(1,#d+1)==d.."_"then
local cc=camel(d);pal={C[cc],C[cc],DYE_SHADE[cc]};break
end
end
end
if not pal then
for _,m in ipairs(MAT)do
if path:find(m[1],1,true)then pal={m[2],m[3],m[4]};break end
end
end
if not pal then
local h=0
for i=1,#id do h=(h*31+id:byte(i))%997 end
pal=FALLBACK[h%#FALLBACK+1]
end
local ic={shape=SHAPES[shape],a=pal[1],b=pal[2],c=pal[3]}
ic.used=os.clock()
state.iconCache[key]=ic
return ic
end
function drawIcon(x,y,id,cw,ch,bgc,kind)
local ic=iconFor(id,kind)
local bmp=ic.shape
local bh,bw=#bmp,#bmp[1]
local map={
a=ic.a,b=ic.b,c=ic.c,s=C.lightGray,w=C.brown,
x=(ic.b==C.lightGray)and ic.a or ic.b,
}
local sx,sy=bw/(cw*2),bh/(ch*3)
drawPixels(x,y,cw,ch,function(px,py)
local row=bmp[math.floor((py-0.5)*sy)+1]
if not row then return bgc end
local col=math.floor((px-0.5)*sx)+1
return map[row:sub(col,col)]or bgc
end)
end
end)()
;(function()
local DISK_COLORS={
["1k"]=C.lightGray,["4k"]=C.lime,["16k"]=C.yellow,["64k"]=C.orange,
["256k"]=C.red,["1024k"]=C.magenta,["4096k"]=C.pink,["16384k"]=C.purple,
}
DISK_ORDER={"1k","4k","16k","64k","256k","1024k","4096k","16384k"}
local diskCache={}
function diskInfo(name)
name=name or"?"
if diskCache[name]then return diskCache[name]end
local path=name:gsub("^[^:]+:","")
local size=path:match("(%d+k)")
local creative=path:find("creative")~=nil
local fluid=path:find("fluid")~=nil
local chem=(path:find("chemical")or path:find("gas"))~=nil
local col
if fluid then col=C.lightBlue
elseif chem then col=C.green
elseif creative then col=C.purple
else col=DISK_COLORS[size or""]or C.white end
local di={
label=creative and"inf"or(size or"?"),
kind=fluid and"fluide"or(chem and"chimie"or"items"),
color=col,
cap=(not creative and size)and tonumber(size:match("%d+"))*1000 or nil,
}
diskCache[name]=di
return di
end
function readDrives()
local names={}
for _,n in ipairs(peripheral.getNames())do
if n:find("disk_drive")then names[#names+1]=n end
end
if#names==0 then return nil end
local res,tasks={},{}
for _,n in ipairs(names)do
tasks[#tasks+1]=function()
local ok,l=pcall(peripheral.call,n,"list")
res[n]=(ok and type(l)=="table")and l or{}
end
end
parallel.waitForAll(table.unpack(tasks))
return res
end
function posName(p)
local cols=bays().cols
return string.char(65+(p-1)%cols)..(math.floor((p-1)/cols)+1)
end
local function trailingNum(n)return tonumber(n:match("(%d+)$"))or 0 end
function bayLayout(drives)
local total=bays().cols*bays().rows
local pos,used={},{}
for p=1,total do
local n=bayMap()[p]
if n and drives[n]then pos[p]=n;used[n]=true end
end
if state.assign then return pos,0 end
local rest={}
for n in pairs(drives)do if not used[n]then rest[#rest+1]=n end end
table.sort(rest,function(a,b)return trailingNum(a)<trailingNum(b)end)
local extra=0
for _,n in ipairs(rest)do
local placed=false
for p=1,total do
if not pos[p]then pos[p]=n;placed=true;break end
end
if not placed then extra=extra+1 end
end
return pos,extra
end
local function driveSig(slots)
local t={}
for i=1,bays().slots do local sl=slots[i];t[i]=sl and sl.name or"-"end
return table.concat(t,",")
end
local function sigsOf(drives)
local r={}
for n,sl in pairs(drives or{})do r[n]=driveSig(sl)end
return r
end
function finishAssign()
local a=state.assign
state.assign=nil
pcall(saveStore)
if a and a.ctx and state.onAssignDone then pcall(state.onAssignDone,a.ctx)end
notify(L"Placement des baies enregistre")
logEvent("baie",L"Placement des baies enregistre",0)
end
function nextAssign()
local a=state.assign
a.pos=a.pos+1
if a.pos>bays().cols*bays().rows then finishAssign()end
end
function startAssign(d)
local m=bayMap()
for k in pairs(m)do m[k]=nil end
state.assign={pos=1,sig=sigsOf(d.drives),done={},ctx=state.ctx and state.ctx.id}
notify(L"Identification : commence par la baie A1")
end
function checkAssign(drives)
local a=state.assign
if not a or not drives then return end
local cur=sigsOf(drives)
for n,sg in pairs(cur)do
if not a.done[n]and a.sig[n]and a.sig[n]~=sg then
bayMap()[a.pos]=n
a.done[n]=true
notify(posName(a.pos).." = "..n)
a.sig=cur
nextAssign()
return
end
end
a.sig=cur
end
function drawDriveTile(p,name,slots,x,y,w,perRow)
local B=bays()
local target=state.assign and state.assign.pos==p
local bg=target and colors.purple or T.panel
local full=perRow<bays().slots
local h=full and(1+math.ceil(bays().slots/perRow))or 1
roundFill(x,y,w,h,bg)
text(x+1,y,posName(p),T.text,bg)
if not name then
text(x+4,y,cut(target and L"<- ici"or L"vide",w-5),target and T.text or T.dim,bg)
return
end
local nd=0
for i=1,B.slots do if slots[i]then nd=nd+1 end end
if full then rightText(x+w-2,y,nd.."/"..B.slots,T.dim,bg)end
local sx0=full and(x+1)or(x+4)
local areaW=full and(w-2)or(w-5)
local sw=math.max(1,math.floor((areaW+1)/perRow)-1)
for i=1,B.slots do
local cx=sx0+((i-1)%perRow)*(sw+1)
local cy=full and(y+1+math.floor((i-1)/perRow))or y
local sl=slots[i]
if sl then
local di=diskInfo(sl.name)
fill(cx,cy,sw,1,di.color)
if sw>=#di.label then text(cx+math.floor((sw-#di.label)/2),cy,di.label,T.bg,di.color)end
else
fill(cx,cy,sw,1,T.bg)
text(cx+math.floor((sw-1)/2),cy,"\183",T.dim,T.bg)
end
end
addButton(x,y,x+w-1,y+h-1,function()
state.popup={kind="drive",name=name,pos=p}
end)
end
end)()
function parseVer(v)
local a,b,c=tostring(v or""):match("^v?(%d+)%.?(%d*)%.?(%d*)")
if not a then return nil end
return{tonumber(a),tonumber(b)or 0,tonumber(c)or 0}
end
function cmpVer(x,y)
local a,b=parseVer(x),parseVer(y)
if not a or not b then return nil end
for i=1,3 do
if a[i]~=b[i]then return a[i]<b[i]and-1 or 1 end
end
return 0
end
function forecast(hist)
local n=#hist
if n<10 then return nil end
local m=math.min(n,math.floor(3600/CFG.graphEvery))
local sx,sy,sxx,sxy=0,0,0,0
for i=n-m+1,n do
local y=hist[i]
sx,sy,sxx,sxy=sx+i,sy+y,sxx+i*i,sxy+i*y
end
local den=m*sxx-sx*sx
if den==0 then return nil end
local perSec=((m*sxy-sx*sy)/den)/CFG.graphEvery
local last=hist[n]
local f={rate=perSec,perHour=perSec*3600}
if perSec>1e-7 then f.eta=(1-last)/perSec end
return f
end
function forecastText(f,d)
if not f then
if d and not d.capKnown then return L"capacite inconnue",T.dim end
return L"en calcul (~5 min)",T.dim
end
if f.eta then
return L"plein dans ~"..duration(f.eta),(f.eta<86400 and T.bad or(f.eta<259200 and T.warn or T.ok))
end
if f.perHour<-1e-4 then return L"en baisse",T.ok end
return L"stable",T.ok
end
NET={proto="rstools_dc"}
function NET.open()
local n=0
for _,name in ipairs(peripheral.getNames())do
if isType(name,"modem")and pcall(rednet.open,name)then n=n+1 end
end
return n
end
function NET.send(id,msg)
msg.v,msg.from=VERSION,os.getComputerID()
return pcall(rednet.send,id,msg,NET.proto)
end
function NET.broadcast(msg)
msg.v,msg.from=VERSION,os.getComputerID()
return pcall(rednet.broadcast,msg,NET.proto)
end
UPD={installedFile="rstools/installed.txt"}
function UPD.normRepo(url)
if type(url)~="string"or url==""then return nil end
url=url:gsub("^%s+",""):gsub("%s+$","")
local u,r,b=url:match("^https?://github%.com/([^/]+)/([^/]+)/tree/([^/]+)")
if u then return("https://raw.githubusercontent.com/%s/%s/%s/"):format(u,r,b)end
u,r=url:match("^https?://github%.com/([^/]+)/([^/]+)/?$")
if u then return("https://raw.githubusercontent.com/%s/%s/main/"):format(u,(r:gsub("%.git$","")))end
if url:sub(-1)~="/"then url=url.."/"end
return url
end
function UPD.repo()return UPD.normRepo(S("repoUrl")or CFG.repoUrl)end
function UPD.fetch(url)
if not http then return nil,L"HTTP desactive sur ce serveur"end
local ok,h=pcall(http.get,url.."?t="..math.floor(os.epoch("utc")/1000))
if not ok or not h then return nil,L"telechargement impossible"end
local body=h.readAll();h.close()
return body
end
function UPD.manifest()
local base=UPD.repo()
if not base then return nil,L"Aucun depot configure (Reglages)"end
local body,err=UPD.fetch(base.."manifest.lua")
if not body then return nil,err end
local fn=load(body,"=manifest","t",{})
local ok,m=pcall(fn or error)
if not ok or type(m)~="table"or type(m.files)~="table"then return nil,L"manifeste illisible"end
return m
end
function UPD.installed()
local t
if fs.exists(UPD.installedFile)then
local f=fs.open(UPD.installedFile,"r");t=textutils.unserialise(f.readAll()or"");f.close()
end
return type(t)=="table"and t or{}
end
function UPD.wanted(f,role,lang)
if f.lang then return f.lang==lang end
for _,r in ipairs(f.roles or{})do if r==role then return true end end
return false
end
function UPD.run(role,lang,force)
local m,err=UPD.manifest()
if not m then return nil,err end
local inst,todo=UPD.installed(),{}
for _,f in ipairs(m.files)do
if UPD.wanted(f,role,lang)and(force or inst[f.path]~=f.v or not fs.exists(f.path))then todo[#todo+1]=f end
end
if#todo==0 then return 0,nil,m end
local base,bodies=UPD.repo(),{}
for _,f in ipairs(todo)do
local body,e=UPD.fetch(base..f.path)
if not body then return nil,f.path.." : "..tostring(e)end
if f.path:match("%.lua$")and not load(body,"="..f.path,"t",{})then
return nil,f.path..L" : fichier invalide"
end
bodies[#bodies+1]={f=f,body=body}
end
local need,freed=0,0
for _,b in ipairs(bodies)do
need=need+#b.body
if fs.exists(b.f.path)then freed=freed+fs.getSize(b.f.path)end
end
if fs.getFreeSpace("/")+freed<need+2048 then return nil,L"disque plein"end
for _,b in ipairs(bodies)do
local p=b.f.path
local dir=fs.getDir(p)
if dir~=""and not fs.exists(dir)then fs.makeDir(dir)end
local tmp=p..".new"
if fs.exists(tmp)then fs.delete(tmp)end
local fw=fs.open(tmp,"w");fw.write(b.body);fw.close()
if fs.exists(p)then fs.delete(p)end
fs.move(tmp,p)
inst[p]=b.f.v
end
local fi=fs.open(UPD.installedFile,"w");fi.write(textutils.serialise(inst));fi.close()
return#todo,nil,m
end
function UPD.setRole(role)
if not fs.exists("rstools")then fs.makeDir("rstools")end
local f=fs.open("rstools/role.txt","w");f.write(role);f.close()
end
;(function()
local MPAL={colors.blue,colors.purple,colors.green,colors.orange,colors.magenta,colors.brown,
colors.lightBlue,colors.lime,colors.pink,colors.red,colors.yellow}
local LIGHT={[colors.lime]=true,[colors.yellow]=true,[colors.orange]=true,[colors.lightBlue]=true,
[colors.pink]=true,[colors.white]=true,[colors.lightGray]=true,[colors.cyan]=true}
local function hashColor(str)
local h=0
for i=1,#str do h=(h*31+str:byte(i))%9973 end
return MPAL[h%#MPAL+1]
end
local function trendColor(delta,dormant)
if delta and delta>0 then return colors.green end
if delta and delta<0 then return colors.red end
if dormant then return colors.brown end
return colors.gray
end
local function layoutTiles(list,x0,y0,w,h,maxTiles)
local total=0
for _,g in ipairs(list)do total=total+g.value end
if total<=0 then return{},0 end
local keep,rest={},0
for _,g in ipairs(list)do
if#keep<maxTiles-1 and(g.value/total)*w*h>=3 then keep[#keep+1]=g
else rest=rest+g.value end
end
if rest>0 then keep[#keep+1]={key="__autres",label=L("Autres"),value=rest,delta=0,other=true}end
local AR=1.5
local areas={}
for i,g in ipairs(keep)do areas[i]=g.value/total*w*h*AR end
local function worst(row,side)
local sum,mx,mn=0,0,math.huge
for _,a in ipairs(row)do sum=sum+a;mx=math.max(mx,a);mn=math.min(mn,a)end
if sum==0 or mn==0 then return math.huge end
local s2=side*side
return math.max(s2*mx/(sum*sum),(sum*sum)/(s2*mn))
end
local rects,x,y,cw,chh,i={},0,0,w,h*AR,1
while i<=#areas do
local side=math.min(cw,chh)
local row,j={areas[i]},i+1
while j<=#areas do
local test={table.unpack(row)}
test[#test+1]=areas[j]
if worst(test,side)<=worst(row,side)then row=test;j=j+1 else break end
end
local sum=0
for _,a in ipairs(row)do sum=sum+a end
if cw>=chh then
local colW,yy=sum/chh,y
for k,a in ipairs(row)do local hh=a/colW;rects[i+k-1]={x=x,y=yy,w=colW,h=hh};yy=yy+hh end
x,cw=x+colW,cw-colW
else
local rowH,xx=sum/cw,x
for k,a in ipairs(row)do local ww=a/rowH;rects[i+k-1]={x=xx,y=y,w=ww,h=rowH};xx=xx+ww end
y,chh=y+rowH,chh-rowH
end
i=j
end
local tiles={}
for k,r in ipairs(rects)do
local x1,x2=x0+math.floor(r.x+0.5),x0+math.floor(r.x+r.w+0.5)-1
local y1,y2=y0+math.floor(r.y/AR+0.5),y0+math.floor((r.y+r.h)/AR+0.5)-1
x2,y2=math.min(x2,x0+w-1),math.min(y2,y0+h-1)
if x2>=x1 and y2>=y1 then tiles[#tiles+1]={g=keep[k],x1=x1,y1=y1,x2=x2,y2=y2}end
end
return tiles,total
end
function drawMosaic(d,x0,y0,w,h,view,colorMode,zoom,interactive)
if not d or w<4 or h<2 then return end
local key=table.concat({state.dataVersion,view,colorMode,zoom and(zoom.kind..":"..zoom.key)or"-",
x0,y0,w,h,LANG},"|")
state.mosCache=state.mosCache or{}
local c=state.mosCache[key]
if not c then
local tiles,total=layoutTiles(((d.mosaic and d.mosaic[view])or(state.mosaicGroups and state.mosaicGroups(d,view,zoom))or{}),x0,y0,w,h,clamp(math.floor(w*h/14),4,60))
c={tiles=tiles,total=total}
local n=0
for _ in pairs(state.mosCache)do n=n+1 end
if n>6 then state.mosCache={}end
state.mosCache[key]=c
end
if#c.tiles==0 then text(x0+1,y0,L"Rien a afficher dans ce groupe",T.dim);return end
for _,t in ipairs(c.tiles)do
local g=t.g
local col
if g.other then col=colors.gray
elseif colorMode=="mod"then col=hashColor(g.mod or g.key)
else col=trendColor(g.delta,g.dormant)end
local fg=LIGHT[col]and colors.black or colors.white
local tw,th=t.x2-t.x1+1,t.y2-t.y1+1
local iw,ih=(tw>2)and tw-1 or tw,(th>2)and th-1 or th
roundFill(t.x1,t.y1,iw,ih,col)
if iw>=3 then
text(t.x1+1,t.y1,cut(g.label,iw-2),fg,col)
if ih>=2 then
local p=c.total>0 and(g.value/c.total*100)or 0
text(t.x1+1,t.y1+1,cut(fmt(g.value)..((iw>=13)and("  "..("%.1f%%"):format(p))or""),iw-2),fg,col)
end
if ih>=3 and g.delta~=0 then text(t.x1+1,t.y1+2,cut(fmtSigned(g.delta),iw-2),fg,col)end
end
if interactive and not g.other then
addButton(t.x1,t.y1,t.x1+iw-1,t.y1+ih-1,function()
if g.id then state.popup={kind="item",id=g.id}
else state.mosZoom={kind=(view=="mods")and"mod"or"cat",key=g.key}end
end)
end
end
end
end)()
;(function()
local FONT={
["0"]={"111","101","101","101","111"},["1"]={"010","110","010","010","111"},
["2"]={"111","001","111","100","111"},["3"]={"111","001","111","001","111"},
["4"]={"101","101","111","001","001"},["5"]={"111","100","111","001","111"},
["6"]={"111","100","111","101","111"},["7"]={"111","001","010","010","010"},
["8"]={"111","101","111","101","111"},["9"]={"111","101","111","001","111"},
["%"]={"101","001","010","100","101"},["."]={"000","000","000","000","010"},
["k"]={"100","101","110","101","101"},["M"]={"101","111","111","101","101"},
["G"]={"111","100","101","101","111"},["-"]={"000","000","111","000","000"},
["+"]={"000","010","111","010","000"},["/"]={"001","001","010","100","100"},
[":"]={"000","010","000","010","000"},[" "]={"000","000","000","000","000"},
["?"]={"111","001","011","000","010"},["O"]={"111","101","101","101","111"},
["K"]={"101","110","100","110","101"},["R"]={"110","101","110","101","101"},
["S"]={"011","100","010","001","110"},["T"]={"111","010","010","010","010"},
["L"]={"100","100","100","100","111"},["h"]={"100","100","111","101","101"},
["j"]={"001","000","001","001","110"},
["d"]={"001","001","111","101","111"},
}
function bigWidth(str,sc)return math.ceil((#str*4-1)*sc/2)end
local function bigHeight(sc)return math.ceil(5*sc/3)end
function bigText(x,y,str,col,bgc,sc)
local cw,ch=bigWidth(str,sc),bigHeight(sc)
drawPixels(x,y,cw,ch,function(px,py)
local gx,gy=math.floor((px-1)/sc),math.floor((py-1)/sc)
if gy>4 then return bgc end
local gi,cx=math.floor(gx/4)+1,gx%4
if cx==3 or gi>#str then return bgc end
local g=FONT[str:sub(gi,gi)]or FONT["?"]
return g[gy+1]:sub(cx+1,cx+1)=="1"and col or bgc
end)
return cw,ch
end
local function bigFit(str,maxW,maxH)
for sc=4,1,-1 do
if bigWidth(str,sc)<=maxW and bigHeight(sc)<=maxH then return sc end
end
end
local function bigIn(x,y,w,h,str,col,bgc)
local sc=bigFit(str,w,h)
if not sc then centerText(x,w,y+math.floor((h-1)/2),str,col,bgc);return end
local bw,bh=bigWidth(str,sc),bigHeight(sc)
bigText(x+math.floor((w-bw)/2),y+math.floor((h-bh)/2),str,col,bgc,sc)
end
local function drawBayMonitor(d,cfg)
local B=bays()
cfg=cfg or{}
local c1=clamp(cfg.colFrom or 1,1,B.cols)
local c2=clamp(cfg.colTo or B.cols,c1,B.cols)
win.setBackgroundColor(T.bg);win.clear()
local drives=d and d.drives
if not drives then centerText(1,W,math.ceil(H/2),L"Aucun disk drive detecte",T.dim);return end
local pos=bayLayout(drives)
local mode=S("bayMode")
local vals,maxCap={},0
for c=1,B.cols do
local occ,tot,cap=0,0,0
for r=1,B.rows do
local n=pos[(r-1)*B.cols+c]
tot=tot+B.slots
if n then
for i=1,B.slots do
local sl=drives[n][i]
if sl then
occ=occ+1
local di=diskInfo(sl.name)
if di.kind=="items"and di.cap then cap=cap+di.cap end
end
end
end
end
vals[c]={occ=occ,tot=tot,cap=cap}
if cap>maxCap then maxCap=cap end
end
local cw=W/(c2-c1+1)
for c=c1,c2 do
local v=vals[c]
local x1=math.floor((c-c1)*cw)+1
local w=math.floor((c-c1+1)*cw)-x1+1
local ratio,big,small
if mode=="slots"then
ratio=v.tot>0 and v.occ/v.tot or 0
big=math.floor(ratio*100+0.5).."%"
small=v.occ.."/"..v.tot
else
ratio=maxCap>0 and v.cap/maxCap or 0
big=fmt(v.cap)
small=v.occ..L" disques"
end
local col=mode=="slots"and ratioColor(ratio)or T.accent
local target=state.assign and((state.assign.pos-1)%B.cols+1)==c
local hb=target and colors.purple or T.panel
local iw=math.max(1,w-1)
fill(x1,1,iw,1,hb)
centerText(x1,iw,1,string.char(64+c),T.text,hb)
if H>=5 then
local gx,gw=x1,iw
if iw>=6 then gx,gw=x1+1,iw-2 end
vGauge(gx,2,gw,H-3,ratio,col,T.panel)
centerText(x1,iw,H-1,big,col,T.bg)
centerText(x1,iw,H,small,T.dim,T.bg)
else
if H>=2 then slimBar(x1,2,iw,ratio,col,T.bg,T.panel)end
centerText(x1,iw,1,string.char(64+c).." "..big,T.text,hb)
if H>=3 then centerText(x1,iw,3,small,T.dim,T.bg)end
end
end
end
local function wHeader(title,right,col)
local bg=col or T.panel
fill(1,1,W,1,bg)
text(2,1,cut(title,W-2),col and T.bg or T.text,bg)
if right and W-#title-4>0 then rightText(W-1,1,cut(right,W-#title-4),col and T.bg or T.dim,bg)end
end
local function bodyBig(str,col,extra)
local h=H-1-extra
if h>=1 then bigIn(1,2,W,h,str,col,T.bg)end
return 2+math.max(0,h)
end
local WIDGETS={}
WIDGETS.baies=function(d,cfg)drawBayMonitor(d,cfg)end
WIDGETS.stockage=function(d)
local r=(d and d.max and d.max>0)and d.used/d.max or 0
local col=ratioColor(r)
wHeader("STOCKAGE",d and(fmt(d.used).." / "..fmt(d.max)))
if not d then return end
local extra=H>=7 and 2 or(H>=4 and 1 or 0)
local y=bodyBig(math.floor(r*100+0.5).."%",col,extra)
if extra>=1 then slimBar(2,y,W-2,r,col,T.bg,T.panel)end
if extra>=2 then
local ft,fc=forecastText(d.forecast,d)
centerText(1,W,y+1,ft,fc)
end
end
WIDGETS.energie=function(d)
local r=(d and d.energy and d.maxEnergy and d.maxEnergy>0)and d.energy/d.maxEnergy or 0
wHeader("ENERGIE",d and d.usage and(fmt(d.usage).." FE/t"))
if not d then return end
local extra=H>=7 and 2 or(H>=4 and 1 or 0)
local y=bodyBig(math.floor(r*100+0.5).."%",r<0.2 and T.bad or T.energy,extra)
if extra>=1 then slimBar(2,y,W-2,r,r<0.2 and T.bad or T.energy,T.bg,T.panel)end
if extra>=2 then centerText(1,W,y+1,fmt(d.energy).." / "..fmt(d.maxEnergy).." FE",T.dim)end
end
WIDGETS.item=function(d,cfg)
local id=cfg.item
if not id then
wHeader("ITEM")
centerText(1,W,math.max(2,math.ceil(H/2)),L"Choisis un item (Reglages > Ecrans)",T.dim)
return
end
local it=d and d.byId[id]
wHeader((it and it.name or prettify(id)):upper())
local count=it and it.count or 0
local te=d and d.trends and d.trends.ready and d.trends.byId[id]
local extra=H>=5 and 1 or 0
local x0=1
if H>=4 and W>=24 then
drawIcon(2,2+math.max(0,math.floor((H-1-extra-3)/2)),id,4,3,T.bg)
x0=7
end
local h=H-1-extra
if h>=1 then bigIn(x0,2,W-x0+1,h,fmt(count),T.text,T.bg)end
if extra>=1 then
local tr=te and(fmtSigned(te.delta).."  ("..fmtSigned(te.rate).."/h)")or L"stable"
centerText(1,W,H,tr,te and(te.delta>=0 and T.ok or T.bad)or T.dim)
end
end
WIDGETS.alertes=function()
local A=state.alerts
if#A==0 then
wHeader("ALERTES")
local y=bodyBig("OK",T.ok,H>=5 and 1 or 0)
if H>=5 then centerText(1,W,y,L"Aucune alerte",T.dim)end
return
end
wHeader(#A..L" ALERTE"..(#A>1 and"S"or""),nil,T.bad)
for i,a in ipairs(A)do
if 1+i>H then break end
text(2,1+i,"\7",a.lvl>=2 and T.bad or T.warn)
text(4,1+i,cut(a.msg,W-4),T.text)
end
end
WIDGETS.crafts=function(d)
local run=d and d.running or{}
wHeader(L"CRAFTS EN COURS",tostring(#run))
if#run==0 then centerText(1,W,math.max(2,math.ceil(H/2)),L"Aucun craft en cours",T.dim);return end
local spin="\7"
for i,e in ipairs(run)do
local y=1+i
if y>H then break end
drawIcon(2,y,e.id,2,1,T.bg)
local right=(e.count and(fmt(e.count).." ")or"")..spin
text(5,y,cut(e.name,W-6-#right),T.text)
rightText(W-1,y,right,T.warn)
end
end
WIDGETS.journal=function()
wHeader("JOURNAL")
local LOGT=store.log
local rows=H-1
local first=math.max(1,#LOGT-rows+1)
local y=2
for i=first,#LOGT do
local e=LOGT[i]
local ts=os.date("%H:%M",math.floor(e.t))
local col=(e.l or 0)>=2 and T.bad or((e.l or 0)==1 and T.warn or T.accent)
text(2,y,ts,T.dim)
text(8,y,"\7",col)
text(10,y,cut(e.m,W-10),T.text)
y=y+1
end
end
local function bigOk(str)
for i=1,#str do if not FONT[str:sub(i,i)]then return false end end
return true
end
WIDGETS.mosaique=function(d,cfg)
wHeader(L"MOSAIQUE",((cfg.view or"mods")=="mods")and L"Mods"or((cfg.view=="cats")and L("Categories")or L("Items")))
drawMosaic(d,1,2,W,H-1,cfg.view or"mods",cfg.color or"trend",nil,false)
end
WIDGETS.horloge=function()
local t=os.date("%H:%M")
local h=H-(H>=6 and 1 or 0)
bigIn(1,1,W,h,t,T.text,T.bg)
if H>=6 then centerText(1,W,H,os.date("%d/%m/%Y"),T.dim)end
end
WIDGETS.tendances=function(d)
wHeader(L"TENDANCES")
local tr=d and d.trends
if not tr or not tr.ready then centerText(1,W,math.max(2,math.ceil(H/2)),L"Historique trop court",T.dim);return end
local up,down={},{}
for _,e in ipairs(tr.list)do if e.delta>0 then up[#up+1]=e else down[#down+1]=e end end
table.sort(up,function(a,b)return a.delta>b.delta end)
table.sort(down,function(a,b)return a.delta<b.delta end)
local function col(list,x,w,title,c)
text(x,2,cut(L(title),w-1),c)
for i=1,math.min(#list,H-2)do
local e,y=list[i],2+i
local v=fmtSigned(e.rate).."/h"
text(x,y,cut(e.name,w-#v-2),T.text)
rightText(x+w-2,y,v,c)
end
end
if W>=40 then
local hw=math.floor(W/2)
col(up,2,hw-1,L"En hausse",T.ok)
col(down,hw+1,W-hw,L"En baisse",T.bad)
else
col(#up>=#down and up or down,2,W-1,#up>=#down and L"En hausse"or L"En baisse",#up>=#down and T.ok or T.bad)
end
end
WIDGETS.epingles=function(d)
wHeader(L"ITEMS EPINGLES",tostring(#store.pins))
if#store.pins==0 then centerText(1,W,math.max(2,math.ceil(H/2)),L"Aucun item epingle",T.dim);return end
for i,id in ipairs(store.pins)do
local y=1+i
if y>H then break end
local it=d and d.byId[id]
local te=d and d.trends and d.trends.ready and d.trends.byId[id]
drawIcon(2,y,id,2,1,T.bg)
local cnt=it and fmt(it.count)or"0"
local rate=te and(fmtSigned(te.rate).."/h")or""
rightText(W-1,y,cnt,T.text)
if#rate>0 then rightText(W-3-#cnt,y,rate,te.delta>=0 and T.ok or T.bad)end
text(5,y,cut(it and it.name or prettify(id),W-9-#cnt-#rate),T.text)
end
end
WIDGETS.fluides=function(d)
local f=d and d.fluids
local r=(f and f.max and f.max>0)and f.used/f.max or 0
wHeader(L"STOCKAGE FLUIDES",f and(fmtMB(f.used)..(f.max and(" / "..fmtMB(f.max))or"")))
if not f then return end
local extra=H>=4 and 1 or 0
local y=bodyBig(math.floor(r*100+0.5).."%",colors.lightBlue,extra)
if extra>=1 then slimBar(2,y,W-2,r,colors.lightBlue,T.bg,T.panel)end
end
WIDGETS.prevision=function(d)
wHeader(L"PREVISION")
if not d then return end
local f=d.forecast
local ft,fc=forecastText(f,d)
local big=(f and f.eta)and duration(f.eta)or"OK"
local h=H-1-(H>=5 and 1 or 0)
if bigOk(big)then bigIn(1,2,W,h,big,fc,T.bg)else centerText(1,W,1+math.ceil(h/2),big,fc)end
if H>=5 then centerText(1,W,H,ft,T.dim)end
end
WIDGETS.resume=function(d)
wHeader("RSTOOLS",os.date("%H:%M"))
if not d then return end
local sR=(d.max and d.max>0)and d.used/d.max or 0
local eR=(d.energy and d.maxEnergy and d.maxEnergy>0)and d.energy/d.maxEnergy or 0
local ft,fc=forecastText(d.forecast,d)
local rows={
{L"Stockage",sR,ratioColor(sR),math.floor(sR*100+0.5).."%"},
{L"Energie",eR,eR<0.2 and T.bad or T.energy,math.floor(eR*100+0.5).."%"},
{L"Alertes",nil,#state.alerts>0 and T.bad or T.ok,tostring(#state.alerts)},
{L"Crafts",nil,T.warn,tostring(#(d.running or{}))},
{L"Prevision",nil,fc,ft},
}
local step=(H-1>=#rows*2)and 2 or 1
for i,r in ipairs(rows)do
local y=2+(i-1)*step
if y>H then break end
text(2,y,r[1],T.dim)
rightText(W-1,y,cut(r[4],W-14),r[3])
if r[2]and W>=30 then slimBar(12,y,W-14-#r[4],r[2],r[3],T.bg,T.panel)end
end
end
local function pctOf(a,b)return(a and b and b>0)and math.floor(a/b*100+0.5)or-1 end
local WKEY={
baies=function(d,cfg)return(state.drivesSig or"").."|"..tostring(state.assign and state.assign.pos)
.."|"..tostring(cfg.colFrom).."-"..tostring(cfg.colTo)
.."|"..S("bayMode").."|"..bays().cols.."x"..bays().rows end,
stockage=function(d)return d and(pctOf(d.used,d.max).."|"..fmt(d.used).."|"..fmt(d.max).."|"..(forecastText(d.forecast,d)))end,
energie=function(d)return d and(pctOf(d.energy,d.maxEnergy).."|"..fmt(d.usage).."|"..fmt(d.energy))end,
item=function(d,cfg)
local it=d and cfg.item and d.byId[cfg.item]
local te=d and d.trends and d.trends.ready and cfg.item and d.trends.byId[cfg.item]
return tostring(cfg.item).."|"..(it and fmt(it.count)or"-").."|"..(te and fmtSigned(te.rate)or"=")
end,
alertes=function()
local p={}
for _,a in ipairs(state.alerts)do p[#p+1]=a.msg end
return table.concat(p,"|")
end,
crafts=function(d)
local p={}
for _,e in ipairs(d and d.running or{})do p[#p+1]=e.id..(e.count or"")end
return table.concat(p,"|")
end,
journal=function()local e=store.log[#store.log];return#store.log.."|"..(e and e.t or 0)end,
mosaique=function(d,cfg)return state.dataVersion.."|"..(cfg.view or"")..(cfg.color or"")..LANG end,
horloge=function()return os.date("%H:%M")end,
tendances=function(d)return state.dataVersion end,
epingles=function(d)
local p={#store.pins}
for _,id in ipairs(store.pins)do local it=d and d.byId[id];p[#p+1]=it and it.count or 0 end
return table.concat(p,"|").."|"..state.dataVersion
end,
fluides=function(d)local f=d and d.fluids;return f and(fmtMB(f.used).."|"..fmtMB(f.max))or"-"end,
prevision=function(d)return d and(forecastText(d.forecast,d))or"-"end,
resume=function(d)
if not d then return"-"end
return pctOf(d.used,d.max).."|"..pctOf(d.energy,d.maxEnergy).."|"..#state.alerts.."|"
..#(d.running or{}).."|"..(forecastText(d.forecast,d)).."|"..os.date("%H:%M")
end,
}
function renderWidgets(d)
for n,w in pairs(widgets)do
local cfg=store.widgets[n]
local fn=cfg and WIDGETS[cfg.type]
local kf=cfg and WKEY[cfg.type]
local key=kf and tostring(kf(d,cfg))or tostring(state.dataVersion)
key=key.."|"..tostring(d~=nil)
if fn and w.lastKey~=key then
w.lastKey=key
local sWin,sW,sH,sB,sOX,sOY=win,W,H,buttons,OX,OY
win,W,H,buttons,OX,OY=w.win,w.W,w.H,{},0,0
win.setVisible(false)
win.setBackgroundColor(T.bg);win.clear()
local ok,err=pcall(fn,d,cfg)
win.setVisible(true)
win,W,H,buttons,OX,OY=sWin,sW,sH,sB,sOX,sOY
if not ok then notify(L"Widget "..n.." : "..tostring(err))end
end
end
end
end)()
