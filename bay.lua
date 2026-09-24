-- Ventura RSTools : rstools/bay.lua (version compacte, code commente dans source/)
local BAY={file="rstools_bay.txt"}
;(function()
local conf={settings={},widgets={},bays={},grid={auto=true,cols=6,rows=3}}
local function loadConf()
if not fs.exists(BAY.file)then return end
local f=fs.open(BAY.file,"r")
local t=textutils.unserialise(f.readAll()or"")
f.close()
if type(t)=="table"then for k,v in pairs(t)do conf[k]=v end end
end
local function saveConf()
local tmp=BAY.file..".tmp"
local f=fs.open(tmp,"w")
f.write(textutils.serialise(conf,{compact=true}))
f.close()
if fs.exists(BAY.file)then fs.delete(BAY.file)end
fs.move(tmp,BAY.file)
end
local function applyConf()
store.settings=conf.settings or{}
store.widgets=conf.widgets or{}
conf.bays=conf.bays or{}
conf.grid=conf.grid or{auto=true,cols=6,rows=3}
state.ctx={id="self",drives=state.drivesCache or{},map=conf.bays,grid=conf.grid}
end
local central=nil
local function toCentral(msg)if central then NET.send(central,msg)end end
local function diskStatus()
local sizes={prog=0,conf=0,other=0}
local function walk(dir)
local ok,names=pcall(fs.list,dir)
if not ok then return end
for _,n in ipairs(names)do
local path=fs.combine(dir,n)
if n~="rom"and(not fs.getDrive or fs.getDrive(path)=="hdd")then
if fs.isDir(path)then walk(path)
else
local k="other"
if path=="rstools.lua"or path:match("^rstools/")then k="prog"
elseif path==BAY.file then k="conf"end
sizes[k]=sizes[k]+fs.getSize(path)
end
end
end
end
walk("")
local used=sizes.prog+sizes.conf+sizes.other
local free=fs.getFreeSpace("/")
local total=(fs.getCapacity and fs.getCapacity("/"))or(used+free)
if total<used+free then total=used+free end
return{used=used,free=free,total=total,parts={
{key="prog",label="Programme",size=sizes.prog},
{key="conf",label="Reglages",size=sizes.conf},
{key="other",label="Autres fichiers",size=sizes.other},
}}
end
local function monitorsList()
local r={}
for _,n in ipairs(listMonitors())do
local m=peripheral.wrap(n)
if m and m.isColor()then
local w=widgets[n]
local cw,ch=m.getSize()
r[#r+1]={name=n,w=w and w.W or cw,h=w and w.H or ch}
end
end
return r
end
local function status(kind)
local n=0
for _ in pairs(state.drivesCache or{})do n=n+1 end
return{t=kind,label=conf.label or os.getComputerLabel(),disk=diskStatus(),monitors=monitorsList(),nDrives=n}
end
local lastSig
local function sendDrives(force)
local p,light={},{}
for n,sl in pairs(state.drivesCache or{})do
local slots={}
p[#p+1]=n
for i=1,CFG.baySlots do
p[#p+1]=sl[i]and sl[i].name or"-"
if sl[i]then slots[i]={name=sl[i].name}end
end
light[n]=slots
end
table.sort(p)
local sig=table.concat(p,",")
state.drivesSig=sig
if force or sig~=lastSig then
lastSig=sig
toCentral({t="drives",drives=light})
state.redraw=true
os.queueEvent("rstools_bay")
end
end
local function readNow()
state.drivesCache=readDrives()or{}
if state.ctx then state.ctx.drives=state.drivesCache end
end
local function termInfo()
term.setBackgroundColor(colors.black);term.clear();term.setCursorPos(1,1)
term.setTextColor(colors.cyan);print(APP.." v"..VERSION)
term.setTextColor(colors.white);print(L"Controleur de baies".." #"..os.getComputerID()..(conf.label and(" - "..conf.label)or""))
print("")
local nd,nw=0,0
for _ in pairs(state.drivesCache or{})do nd=nd+1 end
for _ in pairs(widgets)do nw=nw+1 end
term.setTextColor(central and colors.lime or colors.orange)
print(central and(L"Central : #"..central)or L"Recherche de l'ordinateur central...")
term.setTextColor(colors.lightGray)
print(nd..L" drive(s)  -  "..nw..L" ecran(s) avec widget")
print("")
print(L"Reglages : depuis l'ordinateur central (onglet Data center).")
print(L"Ctrl+T pour arreter.")
end
local function buildD()
local p=state.remote
local d={}
if p then
for k,v in pairs(p)do d[k]=v end
d.byId=p.items or{}
d.trends=p.trends or{ready=false,byId={},list={}}
d.running=p.running or{}
state.alerts=p.alerts or{}
store.pins=p.pins or{}
store.log=p.log or{}
state.dataVersion=p.v or 0
end
d.drives=state.drivesCache
state.assign=state.assignPos and{pos=state.assignPos}or nil
return d
end
local function handle(id,msg)
if msg.t=="central"and(central==nil or central==id)then
if central~=id then central=id;conf.central=id;pcall(saveConf);termInfo()end
toCentral(status("hello"))
sendDrives(true)
elseif id==central then
if msg.t=="config"and type(msg.conf)=="table"then
local oldLang=(conf.settings or{}).lang or"fr"
for _,k in ipairs({"label","grid","bays","widgets","settings"})do conf[k]=msg.conf[k]end
pcall(saveConf)
applyConf()
pcall(setupWidgets)
state.forceRender=true
os.queueEvent("rstools_bay")
termInfo()
if((conf.settings or{}).lang or"fr")~=oldLang then state.restart=true end
elseif msg.t=="data"then
state.remote,state.assignPos=msg.d,msg.assign
state.redraw=true
os.queueEvent("rstools_bay")
elseif msg.t=="cmd"then
local c=msg.cmd
if c=="reboot"then os.reboot()
elseif c=="update"then
local n=UPD.run("bay",LANG,false)
if n and n>0 then state.restart=true end
elseif c=="fast"then state.fast=true
elseif c=="slow"then state.fast=false;state.assignPos=nil;state.redraw=true
elseif c=="read"then state.forceRead=true
elseif c=="forget"then central=nil;conf.central=nil;pcall(saveConf);termInfo()
end
end
end
end
local function netLoop()
NET.open()
if central then toCentral(status("hello"))else NET.broadcast({t="discover"})end
local last=now()
while not state.restart do
local id,msg=rednet.receive(NET.proto,3)
if id and type(msg)=="table"then
local ok,e=pcall(handle,id,msg)
if not ok then printError(e)end
end
if now()-last>=10 or state.statusNow then
last,state.statusNow=now(),false
if central then toCentral(status("status"))else NET.broadcast({t="discover"})end
end
end
end
local function driveLoop()
local nextRead=0
while not state.restart do
if state.fast or state.forceRead or now()>=nextRead then
state.forceRead=false
readNow()
sendDrives(false)
nextRead=now()+(S("baysEvery")or 30)
end
sleep(1)
end
end
local function uiLoop()
local tick=os.startTimer(1)
local lastClock=os.date("%H:%M")
state.forceRender=true
while not state.restart do
if state.redraw or state.forceRender then
state.redraw,state.forceRender=false,false
renderWidgets(buildD())
end
local e={os.pullEvent()}
if e[1]=="timer"and e[2]==tick then
tick=os.startTimer(1)
checkScreens()
local clock=os.date("%H:%M")
if clock~=lastClock then lastClock=clock;state.redraw=true end
elseif e[1]=="monitor_resize"or e[1]=="peripheral"or e[1]=="peripheral_detach"then
pcall(setupWidgets)
state.forceRender,state.statusNow=true,true
end
end
end
function BAY.main()
loadConf()
central=conf.central
applyConf()
readNow()
pcall(setupWidgets)
termInfo()
parallel.waitForAny(netLoop,driveLoop,uiLoop)
end
end)()
state.start=function()
local ok,err=pcall(BAY.main)
for _,w in pairs(widgets)do releaseMonitor(w.mon)end
if not ok and err~="Terminated"then printError(RSTOOLS_MAPERR and RSTOOLS_MAPERR(err)or err)end
if state.restart then
print(L"Redemarrage...")
sleep(1)
shell.run(shell.getRunningProgram())
end
end
