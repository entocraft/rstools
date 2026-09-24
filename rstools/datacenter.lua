-- Ventura RSTools : rstools/datacenter.lua (version compacte, code commente dans source/)
do end;(function()
local run={}
state.dcRun=run
local OFFLINE=45
local localBridge=bridge
local function stocks()
local r={}
for _,id in ipairs(DC.ids())do
local st=run[id]and run[id].stock
if st then r[#r+1]={id=id,s=st}end
end
return r
end
function DC.bayStock()return#stocks()>0 end
local WAIT=L"en attente du stock des controleurs de baies"
local function sum(key,m)
return function()
local list=stocks()
if#list==0 then
if localBridge and localBridge[m]then return localBridge[m]()end
return nil,WAIT
end
local t,any=0,false
for _,e in ipairs(list)do
local v=tonumber(e.s[key])
if v then t,any=t+v,true end
end
if any then return t end
end
end
local function merge(key,m)
return function(...)
local list=stocks()
if#list==0 then
if localBridge and localBridge[m]then return localBridge[m](...)end
return nil,WAIT
end
local out,idx={},{}
for _,e in ipairs(list)do
for _,it in ipairs(e.s[key]or{})do
local o=idx[it.name]
if o then
o.count=(o.count or 0)+(it.count or 0)
o.isCraftable=o.isCraftable or it.isCraftable
else
o={}
for k,v in pairs(it)do o[k]=v end
idx[it.name]=o
out[#out+1]=o
end
end
end
return out
end
end
local function owner(name,craft)
local best,bestN
for _,e in ipairs(stocks())do
if craft then
for _,it in ipairs(e.s.crafts or{})do if it.name==name then return e.id end end
end
local n=0
for _,it in ipairs(e.s.items or{})do if it.name==name then n=it.count or 0;break end end
if not best or n>bestN then best,bestN=e.id,n end
end
return best,bestN or 0
end
local proxy={
getItems=merge("items","getItems"),getCraftableItems=merge("crafts","getCraftableItems"),
getFluids=merge("fluids","getFluids"),
getUsedItemStorage=sum("used","getUsedItemStorage"),getTotalItemStorage=sum("max","getTotalItemStorage"),
getStoredEnergy=sum("energy","getStoredEnergy"),getEnergyCapacity=sum("maxEnergy","getEnergyCapacity"),
getEnergyUsage=sum("usage","getEnergyUsage"),
getUsedFluidStorage=sum("fUsed","getUsedFluidStorage"),getTotalFluidStorage=sum("fMax","getTotalFluidStorage"),
}
function proxy.isOnline()
local list=stocks()
if#list==0 then
if localBridge and localBridge.isOnline then return localBridge.isOnline()end
return nil,WAIT
end
for _,e in ipairs(list)do if e.s.online==false then return false end end
return true
end
function proxy.isItemCrafting(f)
local list=stocks()
if#list==0 then
if localBridge and localBridge.isItemCrafting then return localBridge.isItemCrafting(f)end
return false
end
for _,e in ipairs(list)do if e.s.crafting and e.s.crafting[f.name]then return true end end
return false
end
function proxy.craftItem(f)
if not DC.bayStock()then
if localBridge then return localBridge.craftItem(f)end
return nil,WAIT
end
local id=owner(f.name,true)
if not id then return nil,L"aucun controleur avec RS Bridge"end
DC.cmd(id,"craft",{name=f.name,count=f.count})
return true
end
local function exporter(fn)
return function(f,target)
if not DC.bayStock()then
if localBridge and localBridge[fn]then return localBridge[fn](f,target)end
return nil,WAIT
end
local id,n=owner(f.name,false)
if not id or n<=0 then return 0,L"item absent des controleurs"end
local c=math.min(f.count or n,n)
DC.cmd(id,"export",{fn=fn,name=f.name,count=c,target=target})
return c
end
end
proxy.exportItem=exporter("exportItem")
proxy.exportItemToPeripheral=exporter("exportItemToPeripheral")
bridge=setmetatable(proxy,{__index=function(_,k)
if localBridge and not DC.bayStock()then return localBridge[k]end
end})
local function ctrls()return store.controllers end
local function fmtKo(b)
b=b or 0
if b>=1048576 then return("%.1f Mo"):format(b/1048576)end
return("%d Ko"):format(math.floor(b/1024+0.5))
end
function DC.ids()
local r={}
for id in pairs(ctrls())do r[#r+1]=id end
table.sort(r)
return r
end
function DC.online(id)
local r=run[id]
return r~=nil and r.seen~=nil and now()-r.seen<OFFLINE
end
function DC.label(id)
local c=ctrls()[id]
return(c and c.label and c.label~=""and c.label)or(L"Controleur #"..id)
end
function DC.hasBays()
for id in pairs(ctrls())do
if run[id]and run[id].drives and next(run[id].drives)then return true end
end
return false
end
function DC.ctx(id)
local c=ctrls()[id]
if not c then return nil end
c.bays=c.bays or{}
c.grid=c.grid or{auto=true,cols=6,rows=3}
return{id=id,drives=(run[id]and run[id].drives)or{},map=c.bays,grid=c.grid}
end
local function watchList()
local w={}
for _,r in ipairs(store.rules)do w[#w+1]=r.id end
return w
end
local function confFor(id)
local c=ctrls()[id]
return{
label=c.label,grid=c.grid,bays=c.bays or{},widgets=c.widgets or{},
settings={theme=S("theme"),lang=S("lang"),rounded=S("rounded"),bayMode=S("bayMode"),
baysEvery=S("baysEvery"),repoUrl=S("repoUrl"),refresh=S("refresh")},
watch=watchList(),
}
end
function DC.pushConfig(id)if ctrls()[id]then NET.send(id,{t="config",conf=confFor(id)})end end
function DC.pushAll()for _,id in ipairs(DC.ids())do DC.pushConfig(id)end end
function DC.cmd(id,cmd,arg)NET.send(id,{t="cmd",cmd=cmd,arg=arg})end
local function needsMosaic()
for _,c in pairs(ctrls())do
for _,w in pairs(c.widgets or{})do if w.type=="mosaique"then return true end end
end
return false
end
local function slim(list,n)
local out,rest={},0
for i,g in ipairs(list)do
if i<=n then
out[#out+1]={key=g.key,label=g.label,value=g.value,delta=g.delta,mod=g.mod,dormant=g.dormant}
else rest=rest+g.value end
end
if rest>0 then out[#out+1]={key="__autres",label=L"Autres",value=rest,delta=0,other=true}end
return out
end
local cache
function DC.payload()
local d=state.data
if not d then return nil end
if cache and cache.v==state.dataVersion then return cache end
local need={}
for _,id in ipairs(store.pins)do need[id]=true end
for _,c in pairs(ctrls())do
for _,w in pairs(c.widgets or{})do if w.item then need[w.item]=true end end
end
local items={}
for id in pairs(need)do
local it=d.byId[id]
if it then items[id]={id=id,name=it.name,count=it.count}end
end
local tr={ready=(d.trends and d.trends.ready)or false,byId={},list={}}
if tr.ready then
local up,down={},{}
for _,e in ipairs(d.trends.list)do if e.delta>0 then up[#up+1]=e else down[#down+1]=e end end
table.sort(up,function(a,b)return a.delta>b.delta end)
table.sort(down,function(a,b)return a.delta<b.delta end)
local function cp(e)return{id=e.id,name=e.name,delta=e.delta,rate=e.rate,count=e.count}end
for i=1,math.min(12,#up)do tr.list[#tr.list+1]=cp(up[i])end
for i=1,math.min(12,#down)do tr.list[#tr.list+1]=cp(down[i])end
for id in pairs(need)do
local e=d.trends.byId[id]
if e then tr.byId[id]=cp(e)end
end
end
local alerts,running,log={},{},{}
for _,a in ipairs(state.alerts)do alerts[#alerts+1]={key=a.key,msg=a.msg,lvl=a.lvl}end
for _,e in ipairs(d.running or{})do running[#running+1]={id=e.id,name=e.name,count=e.count}end
for i=math.max(1,#store.log-19),#store.log do log[#log+1]=store.log[i]end
local mos
if needsMosaic()and state.mosaicGroups then
mos={}
for _,v in ipairs({"mods","cats","items"})do mos[v]=slim(state.mosaicGroups(d,v,nil),50)end
end
cache={
v=state.dataVersion,used=d.used,max=d.max,energy=d.energy,maxEnergy=d.maxEnergy,
usage=d.usage,capKnown=d.capKnown,
forecast=d.forecast and{eta=d.forecast.eta,perHour=d.forecast.perHour},
fluids=d.fluids and{used=d.fluids.used,max=d.fluids.max,total=d.fluids.total},
alerts=alerts,running=running,pins=store.pins,items=items,trends=tr,log=log,mosaic=mos,
}
return cache
end
function DC.sendData(id)
local p=DC.payload()
if not p then return end
local a=state.assign
NET.send(id,{t="data",d=p,assign=(a and a.ctx==id)and a.pos or nil})
end
function DC.onData()
for _,id in ipairs(DC.ids())do if DC.online(id)then DC.sendData(id)end end
end
function DC.afterUpdate()
for _,id in ipairs(DC.ids())do DC.cmd(id,"update")end
end
state.onAssignDone=function(id)
DC.pushConfig(id)
DC.cmd(id,"slow")
DC.sendData(id)
end
local function register(id,msg)
local c=ctrls()[id]
if not c then
c={label=msg.label,grid={auto=true,cols=6,rows=3},bays={},widgets={}}
ctrls()[id]=c
pcall(saveStore)
logEvent("systeme",L"Nouveau controleur de baies : #"..id,0)
toast(L"Nouveau controleur de baies : #"..id,1)
end
return c
end
function DC.handle(id,msg)
local t=msg.t
if t=="hello"or t=="status"then
local c=register(id,msg)
local r=run[id]or{}
local wasOff=not DC.online(id)
r.seen,r.status=now(),msg
run[id]=r
if t=="hello"or wasOff then
DC.pushConfig(id)
DC.sendData(id)
if c.wasOffline then logEvent("systeme",DC.label(id)..L" de nouveau en ligne",0)end
c.wasOffline=nil
os.queueEvent("rstools_data")
elseif state.tab=="dc"then
os.queueEvent("rstools_data")
end
elseif t=="drives"then
local r=run[id]or{}
r.seen,r.drives=now(),msg.drives or{}
run[id]=r
local a=state.assign
if a and a.ctx==id then
local before=a.pos
state.ctx=DC.ctx(id)
pcall(checkAssign,r.drives)
state.ctx=nil
if state.assign and state.assign.pos~=before then DC.sendData(id)end
end
os.queueEvent("rstools_data")
elseif t=="stock"then
local r=run[id]or{}
local first=not DC.bayStock()
r.seen,r.stock=now(),type(msg.s)=="table"and msg.s or nil
run[id]=r
if first and DC.bayStock()then state.forceRefresh=true end
elseif t=="result"then
if not msg.ok then
local what=msg.kind=="craft"and L"Craft impossible : %s (%s)"or L"Evacuation impossible : %s (%s)"
local e=what:format(tostring(msg.name),tostring(msg.err or"?"))
logEvent(msg.kind=="craft"and"craft"or"stock",DC.label(id).." : "..e,1)
toast(e,"err")
end
elseif t=="discover"then
NET.send(id,{t="central"})
end
end
function DC.alerts(A)
if not state.dcStart or now()-state.dcStart<60 then return end
for _,id in ipairs(DC.ids())do
if not DC.online(id)then
A[#A+1]={key="dcoff:"..id,lvl=1,msg=DC.label(id)..L" hors ligne"}
end
end
end
function DC.loop()
NET.open()
state.dcStart=now()
NET.broadcast({t="central"})
local lastCheck,lastResend=now(),now()
while not state.restart do
local id,msg=rednet.receive(NET.proto,5)
if id and type(msg)=="table"then
local ok,e=pcall(DC.handle,id,msg)
if not ok then notify("Data center : "..tostring(e))end
end
if now()-lastCheck>10 then
lastCheck=now()
for _,cid in ipairs(DC.ids())do
local c=ctrls()[cid]
if run[cid]and not DC.online(cid)and not c.wasOffline then
c.wasOffline=true
logEvent("systeme",DC.label(cid)..L" hors ligne",1)
os.queueEvent("rstools_data")
end
end
end
if now()-lastResend>60 then lastResend=now();pcall(DC.onData)end
end
end
local basePage=pages.bays
pages.bays=function(d)
local ids={}
for _,id in ipairs(DC.ids())do if run[id]and run[id].drives then ids[#ids+1]=id end end
local hasLocal=d.drives and next(d.drives)~=nil
if#ids==0 then return basePage(d)end
local view=state.bayView
if view~="local"and not ctrls()[view]then view=nil end
if not view or(view=="local"and not hasLocal)then view=hasLocal and"local"or ids[1]end
state.bayView=view
local views={}
if hasLocal then views[1]="local"end
for _,id in ipairs(ids)do views[#views+1]=id end
local cur=1
for i,v in ipairs(views)do if v==view then cur=i end end
local function lab(v)return v=="local"and L"Local"or DC.label(v)end
local function go(i)state.bayView=views[(i-1)%#views+1]end
local count=cur.."/"..#views
local left,right=2,W-1
if#views>1 then
button(2,5,"<",T.panel,T.text,function()go(cur-1)end)
button(W-2,5,">",T.panel,T.text,function()go(cur+1)end)
text(W-#count-3,5,count,T.dim)
left,right=6,W-#count-5
end
local first=1
local function span(a,b)
local n=0
for i=a,b do n=n+#lab(views[i])+3 end
return n
end
while first<cur and left+span(first,cur)>right do first=first+1 end
local x=left
for i=first,#views do
local v=views[i]
local l=cut(lab(v),right-left-2)
if x+#l+2>right then break end
local act=v==view
local fg=act and T.bg or((v=="local"or DC.online(v))and T.text or T.bad)
x=x+button(x,5,l,act and T.accent or T.panel,fg,function()state.bayView=v end)+1
end
withSub(1,7,W,H-7,function()
if view=="local"then return basePage(d)end
state.ctx=DC.ctx(view)
local ok,e=pcall(basePage,{drives=state.ctx.drives})
state.ctx=nil
if not ok then error(e,0)end
end)
end
local PART_COLORS={prog=T.accent,conf=colors.lime,data=colors.blue,other=colors.orange}
local function detailEntries(id)
local c=ctrls()[id]
local r=run[id]or{}
local st=r.status or{}
local function save()pcall(saveStore);DC.pushConfig(id)end
local nDrives=0
for _ in pairs(r.drives or{})do nDrives=nDrives+1 end
local on=DC.online(id)
local list={
{h=L"Controleur"},
{info=("ID %d  \183  v%s  \183  %s"):format(id,tostring(st.v or"?"),
on and L"en ligne"or(L"hors ligne"..(r.seen and(" ("..duration(now()-r.seen)..")")or"")))},
{a="x",l=L"Nom : "..DC.label(id),btn=L"Renommer",run=function()
state.input={key="dcLabel",buf=c.label or"",commit=function(v)c.label=v;save()end}
state.kb=true
end},
}
local disk=st.disk
if disk and disk.total and disk.total>0 then
list[#list+1]={h=L"Stockage de l'ordinateur"}
list[#list+1]={info=(L"%s utilises sur %s  \183  %s libres"):format(fmtKo(disk.used),fmtKo(disk.total),fmtKo(disk.free))}
local u={total=disk.total,parts={}}
for _,p in ipairs(disk.parts or{})do
u.parts[#u.parts+1]={key=p.key,label=L(p.label or p.key),size=p.size or 0,color=PART_COLORS[p.key]or colors.gray}
end
list[#list+1]={diskbar=u}
for _,p in ipairs(u.parts)do list[#list+1]={legend=p,total=u.total}end
end
c.grid=c.grid or{auto=true,cols=6,rows=3}
list[#list+1]={h=L"Grille des baies"}
list[#list+1]={l=L"Detection automatique",t="bool",get=function()return c.grid.auto end,
set=function(v)c.grid.auto=v;save()end}
list[#list+1]={l=L"Colonnes",t="num",min=1,max=16,step=1,get=function()return c.grid.cols or 6 end,
set=function(v)c.grid.cols=v;save()end}
list[#list+1]={l=L"Rangees",t="num",min=1,max=10,step=1,get=function()return c.grid.rows or 3 end,
set=function(v)c.grid.rows=v;save()end}
list[#list+1]={info=nDrives..L" drive(s) detecte(s) sur ce controleur"}
list[#list+1]={a="x",l=L"Identifier les baies",btn=L"Identifier",run=function()
state.tab,state.bayView="bays",id
state.ctx=DC.ctx(id)
startAssign({drives=state.ctx.drives})
state.ctx=nil
DC.cmd(id,"fast")
DC.sendData(id)
end}
list[#list+1]={h=L"Ecrans du controleur"}
local mons=st.monitors or{}
if#mons==0 then list[#list+1]={info=L"Aucun moniteur avance branche sur ce controleur."}end
local cols=c.grid.auto and nil or c.grid.cols
for _,m in ipairs(mons)do
c.widgets=c.widgets or{}
local entries=DC.widgetEntries(m.name,c.widgets,save,cols)
if entries[1]and entries[1].h then entries[1].h=m.name..(m.w and("  ("..m.w.."x"..m.h..")")or"")end
for _,e in ipairs(entries)do list[#list+1]=e end
end
list[#list+1]={h=L"Actions"}
list[#list+1]={a="x",l=L"Redemarrer le controleur",btn=L"Redemarrer",
run=function()DC.cmd(id,"reboot");notify(L"Redemarrage demande")end}
list[#list+1]={a="x",l=L"Mettre a jour le controleur",btn=L"Mettre a jour",
run=function()DC.cmd(id,"update");notify(L"Mise a jour demandee")end}
list[#list+1]={a="x",l=L"Oublier ce controleur",btn=L"Oublier",danger=true,run=function()
DC.cmd(id,"forget")
ctrls()[id],run[id],state.dcSel=nil,nil,nil
pcall(saveStore)
notify(L"Controleur oublie")
end}
return list
end
local function card(id,y)
local c=ctrls()[id]
local r=run[id]or{}
local st=r.status or{}
local on=DC.online(id)
roundFill(2,y,W-3,4,T.panel,on and T.ok or T.bad)
text(4,y,cut(DC.label(id),W-30),T.text,T.panel)
rightText(W-3,y,on and L"en ligne"or L"hors ligne",on and T.ok or T.bad,T.panel)
local nd=0
for _ in pairs(r.drives or{})do nd=nd+1 end
local g=c.grid or{}
local grid=g.auto and L"grille auto"or((g.cols or"?").."x"..(g.rows or"?"))
text(4,y+1,cut(("ID %d  \183  v%s  \183  %d drive(s)  \183  %s"):format(id,tostring(st.v or"?"),nd,grid),W-7),T.dim,T.panel)
local disk=st.disk
if disk and disk.total and disk.total>0 then
local bw=math.floor((W-7)/2)
local ratio=disk.used/disk.total
slimBar(4,y+2,bw,ratio,ratioColor(ratio),T.panel,T.bg)
text(6+bw,y+2,cut(fmtKo(disk.used).." / "..fmtKo(disk.total),W-bw-9),T.dim,T.panel)
end
local seen=r.seen and(L"vu il y a "..duration(now()-r.seen))or L"jamais vu"
text(4,y+3,cut(#(st.monitors or{})..L" ecran(s)  \183  "..seen,W-7),T.dim,T.panel)
addButton(2,y,W-2,y+3,function()state.dcSel=id end)
end
function DC.page()
local id=state.dcSel
if id and ctrls()[id]then
button(2,5,L"< Retour",T.accent,T.bg,function()state.dcSel=nil end)
local lab=DC.label(id)
text(14,5,cut(lab,W-18),T.text)
text(15+#lab,5,"\7",DC.online(id)and T.ok or T.bad)
listView("dc:"..id,detailEntries(id),7,H-1,2,DC.settingRow)
return
end
local ids=DC.ids()
local on=0
for _,i in ipairs(ids)do if DC.online(i)then on=on+1 end end
local b2=L"Installer..."
local x2=W-#b2-2
button(x2,5,b2,colors.purple,T.text,function()state.restart="install"end)
local b1=L"Rechercher"
button(x2-#b1-3,5,b1,T.panel,T.text,function()
NET.broadcast({t="central"});notify(L"Recherche des controleurs...")
end)
text(2,5,cut(#ids..L" controleur(s)  \183  "..on..L" en ligne",x2-#b1-6),T.dim)
if#ids==0 then
text(3,7,cut(L"Aucun controleur de baies pour l'instant.",W-4),T.dim)
text(3,8,cut(L"Installer... : installe RSTools sur les ordinateurs relies en filaire.",W-4),T.dim)
return
end
listView("dc",ids,7,H-1,5,card)
end
pages.dc=function(d)DC.page()end
function DC.settingsEntries()
local list={{h=L"Controleurs"}}
local ids=DC.ids()
for _,id in ipairs(ids)do
list[#list+1]={info=DC.label(id).."  \183  "..(DC.online(id)and L"en ligne"or L"hors ligne")}
end
if#ids==0 then list[#list+1]={info=L"Aucun controleur de baies pour l'instant."}end
list[#list+1]={a="x",l=L"Rechercher les controleurs",btn=L"Rechercher",run=function()
NET.broadcast({t="central"});notify(L"Recherche des controleurs...")
end}
list[#list+1]={a="x",l=L"Installer sur de nouveaux ordinateurs",btn=L"Installer",
run=function()state.restart="install"end}
list[#list+1]={info=L"L'installateur s'affiche sur l'ecran de l'ordinateur central."}
return list
end
end)()
