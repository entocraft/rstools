-- Ventura RSTools : rstools/central.lua (version compacte, code commente dans source/)
DC={}
CHANGELOG={
{"4.5.1",{
"Ecrans secondaires : l'interface complete sur d'autres moniteurs, avec leur propre navigation",
"Baies : fleches pour passer d'un controleur de baies a l'autre",
}},
{"4.5.0",{
"Data center : le central n'a plus besoin de RS Bridge, le stock est lu par les controleurs de baies",
"Chaque controleur avec un RS Bridge envoie son stock, le central additionne les reseaux",
"Crafts et evacuations envoyes au controleur qui gere l'item",
}},
{"4.4.1",{
"Correctif : limite de 200 variables locales depassee en mode data center",
}},
{"4.4.0",{
"Data Center Update : des controleurs de baies relies a l'ordinateur central",
"Chaque controleur gere un ensemble de baies (jusqu'a 3x6) et ses propres ecrans",
"Les widgets des controleurs se reglent depuis l'ordinateur central",
"Onglet Data center : etat, disque et ecrans de chaque controleur",
"Widget des baies : choix des colonnes affichees (aligne avec les baies)",
"Fichiers separes : lanceur, commun, central, data center, controleur, langue",
"Mise a jour par fichier depuis un depot GitHub (manifest.lua)",
"Installateur : detecte les ordinateurs relies et propose d'y installer les controleurs",
}},
{"4.3.1",{
"Mosaique : la place de chaque item, mod ou categorie d'un coup d'oeil",
"Mosaique : toucher un groupe pour zoomer, couleurs selon la tendance ou le mod",
"Nouveaux widgets : mosaique, horloge, tendances, items epingles, fluides, prevision",
"Anglais ou francais au choix (Reglages > Apparence)",
"Clavier virtuel plus grand (3 tailles), AZERTY ou QWERTY selon la langue",
}},
{"4.3.0",{
"Efficiency update : l'ecran n'est redessine que quand quelque chose change",
"Widgets redessines seulement si leurs propres chiffres ont change",
"Historique des tendances compresse aussi en memoire",
"Moins de dechets : les items sont reutilises d'une lecture a l'autre",
"Caches nettoyes automatiquement quand ils ne servent plus",
"Deux sauvegardes : reglages (rstools_config.txt) et donnees (rstools_data.txt)",
"Copie de secours des mises a jour : optionnelle, desactivee par defaut",
"Programme allege (version compacte)",
"Reglages > Donnees : stockage de l'ordinateur facon iPhone/Mac",
"Horloge en heure reelle (moins de redessins)",
}},
{"4.2.7",{
"Correctif 'out of space' : sauvegarde beaucoup plus compacte (teste avec 5000 types d'items)",
"Gros reseaux : calculs decoupes pour ne jamais bloquer l'ordinateur",
"Moins de memoire utilisee pour la detection d'anomalies",
"Si le disque est presque plein, l'historique le plus ancien est allege automatiquement",
"Une sauvegarde ratee ne fait plus planter le programme",
"Nettoyage automatique des anciens fichiers (sauvegarde < 4.2, fichier temporaire)",
"Reglages > Donnees : espace disque libre et taille de la sauvegarde",
}},
{"4.2.6",{
"Correctif : les ecrans externes s'affichent des le demarrage",
"Ecrans surveilles en continu : reconnectes ou redimensionnes automatiquement",
"Correctif : la prevision fonctionne meme si le bridge ne donne pas la capacite",
"Capacite calculee a partir des disques des baies si besoin",
}},
{"4.2.5",{
"Mode secours : si un item bloque la liste (ex. item a usage infini), lecture item par item",
"L'item fautif est identifie, ignore et signale (alerte + marque BLOQUE)",
"Les autres items, le stock min/max et les tendances continuent de fonctionner",
}},
{"4.2.4",{
"Si la lecture des items echoue, les dernieres donnees sont conservees",
"Securite : pas de craft automatique ni d'anomalie sur une lecture ratee",
"Nouvel essai de lecture avec un filtre vide (certaines versions d'Advanced Peripherals)",
}},
{"4.2.3",{
"Correctif : le programme se charge a nouveau dans CC:Tweaked (limite de 200 variables)",
"Mise a jour : message d'erreur detaille si le fichier distant est invalide",
}},
{"4.2.2",{
"Reglages : icones sobres, sans pastille de couleur",
"Taille du texte : seules les tailles qui tiennent sur l'ecran sont proposees",
"Si la taille est trop grande, elle est reduite automatiquement au demarrage",
"Ecran 'trop petit' : toucher l'ecran remet la taille par defaut",
}},
{"4.2.1",{
"Correctif : l'ecran ne revient plus a l'accueil a chaque rafraichissement",
"Reglages : icones de couleur et categories regroupees (Personnalisation, Reseau, Systeme)",
"Options classees par sections dans chaque categorie",
"Graphismes : coins arrondis, boutons en pastille, icones dans les onglets",
"Graphiques avec une ligne de crete plus lisible",
}},
{"4.2.0",{
"Nouveau nom : Ventura RSTools",
"Themes de couleurs (Reglages > Apparence)",
"Barre d'onglets en haut, en bas, a gauche ou a droite",
"Clavier virtuel : touche la barre de recherche",
"Graphique du stock dans la fiche de chaque item",
"Prevision de remplissage du stockage + alerte",
"Widgets pour les ecrans externes : baies, stockage, energie, item, alertes...",
"Reglages organises par categories",
"Grille des baies configurable ou detectee automatiquement",
"Journal : les messages les plus recents en bas",
"Alertes et erreurs en notifications en bas a droite, avec un son",
}},
{"4.1.0",{
"Animation et son au demarrage (desactivable dans les reglages)",
"Mise a jour auto : n'installe que les versions plus recentes",
"Ecran des nouveautes apres chaque mise a jour",
"Baies lues toutes les 30 s (reglable) + bouton Actualiser",
"Les appuis sur l'ecran ne sont plus perdus pendant la lecture du reseau",
"Items epingles : bouton dans la fiche, affiches sur l'accueil",
}},
{"4.0.0",{
"Reglages a l'ecran, journal, ecran au-dessus des baies",
"Stock maximum, items dormants, filtres par tags et par mod",
"Detection d'anomalies, sons d'interface, mise a jour auto",
}},
}
bridge=peripheral.find("rsBridge")or peripheral.find("rs_bridge")
if not bridge and ROLE~="central"then error(L"Aucun RS Bridge trouve (Advanced Peripherals requis)",0)end
Snap={ns={},nsIdx={},ids={},codes={},idx={},s={},last={}}
function Snap.reset()
Snap.ns,Snap.nsIdx,Snap.ids,Snap.codes,Snap.idx={},{},{},{},{}
Snap.s,Snap.last,Snap.refCache,Snap.serCache={},{},nil,{}
end
Snap.reset()
function Snap.id(id)
local i=Snap.idx[id]
if i then return i end
local mod,path=id:match("^([^:]+):(.*)$")
if not mod then mod,path="",id end
local m=Snap.nsIdx[mod]
if not m then Snap.ns[#Snap.ns+1]=mod;m=#Snap.ns;Snap.nsIdx[mod]=m end
i=#Snap.ids+1
Snap.ids[i],Snap.codes[i],Snap.idx[id]=id,m..":"..path,i
return i
end
function Snap.count()return#Snap.s end
function Snap.lastTime()local e=Snap.s[#Snap.s];return e and e.t end
function Snap.add(t,counts)
local d,seen,last={},{},Snap.last
for id,n in pairs(counts)do
local i=Snap.id(id)
seen[i]=true
local old=last[i]or 0
if old~=n then d[#d+1]=i;d[#d+1]=n-old;last[i]=n end
breathe()
end
for i,old in pairs(last)do
if not seen[i]then d[#d+1]=i;d[#d+1]=-old;last[i]=nil end
end
Snap.s[#Snap.s+1]={t=math.floor(t),d=d}
Snap.refCache,Snap.serCache=nil,{}
end
function Snap.dropOldest()
local s=Snap.s
if#s<=1 then Snap.s,Snap.last={},{};Snap.refCache,Snap.serCache=nil,{};return end
local st={}
for _,e in ipairs({s[1],s[2]})do
for k=1,#e.d,2 do local i=e.d[k];st[i]=(st[i]or 0)+e.d[k+1]end
end
local d={}
for i,n in pairs(st)do if n~=0 then d[#d+1]=i;d[#d+1]=n end end
s[2].d=d
table.remove(s,1)
Snap.refCache,Snap.serCache=nil,{}
end
function Snap.decode(k)
local st={}
for j=1,k do
local d=Snap.s[j].d
for m=1,#d,2 do
local i=d[m]
local n=(st[i]or 0)+d[m+1]
st[i]=(n~=0)and n or nil
end
breathe()
end
local c={}
for i,n in pairs(st)do c[Snap.ids[i]]=n end
return c
end
function Snap.ref(target)
local k=1
for j,e in ipairs(Snap.s)do if e.t<=target then k=j end end
local e=Snap.s[k]
if not(Snap.refCache and Snap.refCache.t==e.t and Snap.refCache.k==k)then
Snap.refCache={t=e.t,k=k,c=Snap.decode(k)}
end
return e.t,Snap.refCache.c
end
function Snap.series(id)
local key=id.."|"..#Snap.s
if Snap.serCache[key]then return Snap.serCache[key]end
local i,out,v=Snap.idx[id],{},0
for j,e in ipairs(Snap.s)do
if i then
local d=e.d
for m=1,#d,2 do if d[m]==i then v=v+d[m+1]end end
end
out[j]=v
end
Snap.serCache={[key]=out}
return out
end
function Snap.lastIds()
local r={}
for i in pairs(Snap.last)do r[#r+1]=Snap.ids[i]end
return r
end
function Snap.pack()
local base=Snap.s[1]and Snap.s[1].t or 0
local out={}
for j,e in ipairs(Snap.s)do out[j]={t=e.t-base,d=e.d}end
return{v=2,base=base,ns=Snap.ns,ids=Snap.codes,s=out}
end
function Snap.load(p)
Snap.reset()
if type(p)~="table"then return{}end
local full={}
if p.v==2 then
for i,code in ipairs(p.ids or{})do
local m,path=code:match("^(%d+):(.*)$")
local mod=(p.ns or{})[tonumber(m)]or""
full[i]=mod==""and path or(mod..":"..path)
end
else
full=p.ids or{}
end
for _,id in ipairs(full)do Snap.id(id)end
local cur={}
for _,e in ipairs(p.s or{})do
local d={}
for k=1,#e.d,2 do
local i,n=e.d[k],e.d[k+1]
local new=(p.v==2)and((cur[i]or 0)+n)or n
local old=cur[i]or 0
if new~=old then d[#d+1]=i;d[#d+1]=new-old end
cur[i]=(new~=0)and new or nil
end
Snap.s[#Snap.s+1]={t=(p.base or 0)+e.t,d=d}
breathe()
end
Snap.last=cur
return full
end
function Snap.fromPlain(snaps)
Snap.reset()
for _,sn in ipairs(snaps or{})do Snap.add(sn.t,sn.c)end
end
;(function()
local CONFIG_KEYS={"settings","rules","maxRules","pins","widgets","bays","seenVersion","controllers"}
local function readFile(path)
if not fs.exists(path)then return nil end
local f=fs.open(path,"r")
if not f then return nil end
local s=f.readAll();f.close()
local t=textutils.unserialise(s or"")
return type(t)=="table"and t or nil
end
function loadStore()
for _,p in ipairs({CFG.dataFile..".tmp",CFG.configFile..".tmp"})do
if fs.exists(p)then pcall(fs.delete,p)end
end
if not fs.exists(CFG.dataFile)and fs.exists(CFG.oldDataFile)then pcall(fs.move,CFG.oldDataFile,CFG.dataFile)end
if fs.exists(CFG.dataFile)and fs.exists(CFG.oldDataFile)then pcall(fs.delete,CFG.oldDataFile)end
local data=readFile(CFG.dataFile)or{}
local conf=readFile(CFG.configFile)
for k,v in pairs(data)do store[k]=v end
if conf then for _,k in ipairs(CONFIG_KEYS)do store[k]=conf[k]end end
local ids={}
if type(store.snapsPacked)=="table"then
ids=Snap.load(store.snapsPacked)
elseif type(store.snaps)=="table"then
Snap.fromPlain(store.snaps)
end
if type(store.lastMovePacked)=="table"then
local lm=store.lastMovePacked
local v2=type(store.snapsPacked)=="table"and store.snapsPacked.v==2
local at=store.savedAt or 0
store.lastMove={}
for k=1,#lm,2 do
local id=ids[lm[k]]
if id then store.lastMove[id]=v2 and(at-lm[k+1]*60)or lm[k+1]end
end
end
store.snaps,store.snapsPacked,store.lastMovePacked,store.savedAt=nil,nil,nil,nil
for _,k in ipairs({"rules","maxRules","histStorage","histEnergy",
"bays","log","lastMove","settings","pins","widgets","controllers"})do
if type(store[k])~="table"then store[k]={}end
end
if store.autoOn==false then store.settings.autoOn=false end
store.autoOn=nil
local st=store.settings
if st.theme==true then st.theme=nil elseif st.theme==false then st.theme="cc"end
if st.bayMon and st.bayMon~="aucun"and not store.widgets[st.bayMon]then
store.widgets[st.bayMon]={type="baies",scale=st.bayScale or 0.5}
end
st.bayMon,st.bayScale=nil,nil
state.needConfigSave=not conf
end
local function serializeData()
local copy={}
for k,v in pairs(store)do copy[k]=v end
for _,k in ipairs(CONFIG_KEYS)do copy[k]=nil end
copy.lastMove=nil
local at=math.floor(now())
local lm={}
for id,t in pairs(store.lastMove)do
lm[#lm+1]=Snap.id(id);lm[#lm+1]=math.max(0,math.floor((at-t)/60))
breathe()
end
copy.snapsPacked,copy.lastMovePacked,copy.savedAt=Snap.pack(),lm,at
return textutils.serialise(copy,{compact=true})
end
local function trimStore()
local function drop(t)for _=1,math.max(1,math.floor(#t/4))do table.remove(t,1)end end
if Snap.count()>2 then for _=1,math.max(1,math.floor(Snap.count()/4))do Snap.dropOldest()end end
if#store.histStorage>20 then drop(store.histStorage)end
if#store.histEnergy>20 then drop(store.histEnergy)end
while#store.log>80 do table.remove(store.log,1)end
end
function freeSpace()
local dir=fs.getDir(CFG.dataFile)
return fs.getFreeSpace(dir==""and"/"or dir)
end
local function writeFile(path,s)
local tmp=path..".tmp"
if fs.exists(tmp)then fs.delete(tmp)end
local direct=#s+1024>freeSpace()
local target=direct and path or tmp
local f=fs.open(target,"w")
if not f then error(L"impossible d'ecrire "..target,0)end
local ok,err=pcall(f.write,s)
f.close()
if not ok then
if not direct then pcall(fs.delete,tmp)end
error(L"disque plein : "..tostring(err),0)
end
if not direct then
if fs.exists(path)then fs.delete(path)end
fs.move(tmp,path)
end
end
function saveStore()
local conf={}
for _,k in ipairs(CONFIG_KEYS)do conf[k]=store[k]end
writeFile(CFG.configFile,textutils.serialise(conf,{compact=true}))
end
function saveData()
local cur=fs.exists(CFG.dataFile)and fs.getSize(CFG.dataFile)or 0
local s=serializeData()
local tries=0
local prog=shell and shell.getRunningProgram and shell.getRunningProgram()
local reserve=20000+((prog and fs.exists(prog))and fs.getSize(prog)or 100000)
while#s+reserve>freeSpace()+cur and tries<12 do
trimStore();s=serializeData();tries=tries+1
end
if tries>0 then state.trimmed=(state.trimmed or 0)+1 end
writeFile(CFG.dataFile,s)
state.dirty=false
state.lastSave=now()
end
end)()
function setS(k,v)
store.settings[k]=v
pcall(saveStore)
end
function removeBackups()
local prog=shell and shell.getRunningProgram and shell.getRunningProgram()or"rstools.lua"
for _,p in ipairs({prog..".bak","rstools.lua.bak","rsui.lua.bak"})do
if fs.exists(p)then pcall(fs.delete,p)end
end
end
function call(...)
for _,name in ipairs({...})do
if bridge[name]then
local ok,res,err=pcall(bridge[name])
if ok and res~=nil then return res end
lastErr=name..": "..tostring(ok and err or res)
end
end
end
function setupMain()
local mons=listMonitors()
local want,name=S("mainMon"),nil
for _,n in ipairs(mons)do if n==want then name=n end end
if not name then
local best,bestA=nil,-1
for _,n in ipairs(mons)do
if not isWidgetMon(n)then
local m=peripheral.wrap(n)
if m.isColor()then
m.setTextScale(0.5)
local w,h=m.getSize()
if w*h>bestA then best,bestA=n,w*h end
end
end
end
name=best
end
if not name then error(L"Aucun moniteur avance trouve",0)end
if monName and monName~=name then releaseMonitor(mon)end
mon,monName=peripheral.wrap(name),name
if not mon.isColor()then error(L"Le moniteur "..name..L" n'est pas AVANCE",0)end
mon.setTextScale(0.5)
local bw,bh=mon.getSize()
state.base={w=bw,h=bh}
mon.setTextScale(S("scale"))
W,H=mon.getSize()
if(W<MIN_W or H<MIN_H)and S("scale")>0.5 then
local cur=S("scale")
local best=0.5
for _,sc in ipairs(fittingScales())do if sc<cur and sc>best then best=sc end end
store.settings.scale=best~=0.5 and best or nil
mon.setTextScale(best)
W,H=mon.getSize()
state.scaleFixed=best
pcall(saveStore)
end
win=window.create(mon,1,1,W,H,true)
applyPalette(win)
end
SOUNDS={
click={{"hat",0.5,12}},
ok={{"bell",0.8,12},{"bell",0.8,19}},
err={{"bass",1,4}},
alert={{"bit",1,18},{"bit",1,12}},
done={{"chime",1,14},{"chime",1,21}},
toast={{"pling",1,20},{"pling",0.8,13}},
toastErr={{"didgeridoo",1,6},{"bass",1,1}},
}
function sfx(kind)
if not S("sounds")then return end
local sp=peripheral.find("speaker")
if not sp then return end
for _,n in ipairs(SOUNDS[kind]or{})do
pcall(sp.playNote,n[1],math.min(3,n[2]*S("volume")),n[3])
end
end
function toast(msg,lvl)
local t=os.clock()
for _,x in ipairs(state.toasts)do
if x.msg==msg and t-x.t<10 then return end
end
local e={msg=msg,lvl=lvl or 1,t=t,at=now()}
state.toasts[#state.toasts+1]=e
while#state.toasts>3 do table.remove(state.toasts,1)end
state.toastLog[#state.toastLog+1]=e
while#state.toastLog>15 do table.remove(state.toastLog,1)end
sfx(lvl=="err"and"toastErr"or"toast")
end
function logEvent(cat,msg,lvl)
local LOGT=store.log
LOGT[#LOGT+1]={t=math.floor(now()),c=cat,m=msg,l=lvl or 0}
while#LOGT>CFG.logMax do table.remove(LOGT,1)end
state.dirty=true
end
function isPinned(id)
for _,p in ipairs(store.pins)do if p==id then return true end end
return false
end
function togglePin(it)
for i,p in ipairs(store.pins)do
if p==it.id then
table.remove(store.pins,i);state.fsBust=(state.fsBust or 0)+1;pcall(saveStore)
notify(L"Desepingle : "..it.name)
return
end
end
store.pins[#store.pins+1]=it.id
state.fsBust=(state.fsBust or 0)+1
pcall(saveStore)
notify(L"Epingle : "..it.name)
end
;(function()
CATS={
{L"Minerais",{"ores","raw_materials"}},
{L"Lingots",{"ingots"}},
{L"Pepites",{"nuggets"}},
{L"Gemmes",{"gems"}},
{L"Poudres",{"dusts"}},
{L"Blocs de stockage",{"storage_blocks"}},
{L"Bois",{"logs","planks","wooden_slabs","wooden_stairs"}},
{L"Pierres",{"stone","stones","cobblestone","cobblestones"}},
{L"Nourriture",{"foods","food"}},
{L"Cultures",{"crops","seeds"}},
{L"Outils",{"tools","pickaxes","axes","shovels","hoes"}},
{L"Armes",{"swords","weapons"}},
{L"Armures",{"armors","armor"}},
{L"Teintures",{"dyes"}},
{L"Laine",{"wool"}},
{L"Verre",{"glass","glass_blocks","glass_panes"}},
}
function tagList(t)
local r={}
if type(t)~="table"then return r end
for k,v in pairs(t)do
local s=(type(k)=="string"and k)or(type(v)=="string"and v)or nil
if s then r[#r+1]=(s:gsub("^#",""))end
end
return r
end
function catsOf(tags)
local r={}
for _,c in ipairs(CATS)do
for _,tg in ipairs(tags)do
local path=tg:gsub("^[^:]+:","")
local head=path:match("^[^/]+")or path
local hit=false
for _,k in ipairs(c[2])do if head==k then hit=true;break end end
if hit then r[c[1]]=true;break end
end
end
return r
end
end)()
function parseDisks(raw)
if type(raw)~="table"then return nil end
local out={}
for i,dk in ipairs(raw)do
if type(dk)=="table"then
local nm=dk.displayName or dk.name or dk.item or dk.type or dk.cellType
if type(nm)=="table"then nm=nm.displayName or nm.name end
nm=nm and tostring(nm)or(L"Disque "..i)
if nm:find(":")then nm=prettify(nm)end
out[#out+1]={
name=nm,
used=tonumber(dk.stored or dk.used or dk.usedBytes or dk.usage or dk.amount),
total=tonumber(dk.capacity or dk.total or dk.totalBytes or dk.maxStorage or dk.storage),
}
end
end
return out
end
function collectRes(listFns,usedFns,totalFns)
local raw=call(table.unpack(listFns))
local list,total={},0
if type(raw)=="table"then
for _,it in ipairs(raw)do
if type(it)=="table"then
local n=it.amount or it.count or 0
list[#list+1]={id=it.name or"?",name=cleanName(it),count=n}
total=total+n
end
end
end
return{list=list,total=total,used=call(table.unpack(usedFns))or total,
max=call(table.unpack(totalFns))}
end
function present(res)
return res and((res.max and res.max>0)or#res.list>0)
end
function readItemsOneByOne()
local set,ids={},{}
local function add(id)if id and not set[id]then set[id]=true;ids[#ids+1]=id end end
if state.lastGood then for _,it in ipairs(state.lastGood.items)do add(it.id)end end
for id in pairs(store.lastMove)do add(id)end
for _,id in ipairs(Snap.lastIds())do add(id)end
for _,r in ipairs(store.rules)do add(r.id)end
for _,r in ipairs(store.maxRules)do add(r.id)end
for _,id in ipairs(store.pins)do add(id)end
local okC,rawC=pcall(bridge.getCraftableItems or function()end)
if okC and type(rawC)=="table"then for _,it in ipairs(rawC)do add(it.name)end end
if#ids==0 then return nil end
local out,blocked,tasks={},{},{}
for _,id in ipairs(ids)do
tasks[#tasks+1]=function()
local ok,r=pcall(bridge.getItem,{name=id})
if ok then
if type(r)=="table"and(r.count or r.amount or 0)>0 then out[#out+1]=r end
elseif tostring(r):find("must be positive")then
blocked[#blocked+1]={id=id,err=tostring(r)}
end
end
end
for i=1,#tasks,40 do
parallel.waitForAll(table.unpack(tasks,i,math.min(#tasks,i+39)))
end
return out,blocked
end
function poolItem(it,stamp)
local id=it.name or"?"
local e=state.pool[id]
if not e then
local cats=catsOf(tagList(it.tags))
e={id=id,lid=id:lower(),mod=id:match("^([^:]+):")or"?",cats=next(cats)and cats or state.noCats}
state.pool[id]=e
end
if e.rawName~=it.displayName or not e.name then
e.rawName=it.displayName
e.name=cleanName(it)
e.lname=e.name:lower()
end
e.seen,e.blocked=stamp,nil
return e
end
function collect()
local stamp=now()
local hash=0
local raw=call("getItems","listItems")
if raw==nil and bridge.getItems then
local ok2,r2=pcall(bridge.getItems,{})
if ok2 and type(r2)=="table"then raw=r2 end
end
local listError=raw==nil and(lastErr or L"lecture impossible")or nil
local degraded,blocked
if raw==nil and bridge.getItem then
local r3,bl=readItemsOneByOne()
if r3 then raw,degraded,blocked=r3,true,bl end
end
local readError=raw==nil and listError or nil
raw=raw or{}
local items,byId,total={},{},0
for _,it in ipairs(raw)do
local n=it.count or it.amount or 0
local e=poolItem(it,stamp)
e.count,e.maxStack=n,it.maxStackSize
e.craftable=it.isCraftable and true or false
local id=e.id
hash=(hash*31+n+#items)%2147483647
items[#items+1]=e
byId[id]=byId[id]or e
total=total+n
breathe()
end
for _,b in ipairs(blocked or{})do
local old=state.lastGood and state.lastGood.byId[b.id]
local nm=old and old.name or prettify(b.id)
local e={id=b.id,name=nm,lname=nm:lower(),lid=b.id:lower(),count=old and old.count or 0,
maxStack=old and old.maxStack,craftable=old and old.craftable or false,
cats=old and old.cats or{},mod=b.id:match("^([^:]+):")or"?",blocked=true}
items[#items+1]=e
byId[b.id]=byId[b.id]or e
total=total+e.count
end
local crafts={}
local rawC=call("getCraftableItems","listCraftableItems")
if type(rawC)=="table"then
for _,it in ipairs(rawC)do
local e=byId[it.name]
if not e then
e=poolItem(it,stamp)
e.count,e.maxStack=0,it.maxStackSize
byId[e.id]=e
end
e.craftable=true
crafts[#crafts+1]=e
end
else
for _,e in ipairs(items)do if e.craftable then crafts[#crafts+1]=e end end
end
return{
readError=readError,degraded=degraded,blocked=blocked,listError=listError,hash=hash,
items=items,crafts=crafts,byId=byId,types=#items,total=total,
used=call("getUsedItemStorage")or total,
max=call("getTotalItemStorage","getMaxItemDiskStorage"),
energy=call("getStoredEnergy","getEnergyStorage"),
maxEnergy=call("getEnergyCapacity","getMaxEnergyStorage"),
usage=call("getEnergyUsage"),
online=call("isOnline","isConnected"),
disks=parseDisks(call("getCells","listCells","getDisks","listDisks","getStorages")),
fluids=collectRes({"getFluids","listFluids"},{"getUsedFluidStorage"},
{"getTotalFluidStorage","getMaxFluidDiskStorage"}),
chems=collectRes({"getChemicals","listChemicals","getGases","listGases"},
{"getUsedChemicalStorage"},{"getTotalChemicalStorage"}),
}
end
function passesFilter(it)
local f=state.filter
if not f then return true end
if f.kind=="dormant"then return it.dormant end
if f.kind=="cat"then return it.cats and it.cats[f.key]end
if f.kind=="mod"then return it.mod==f.key end
if f.kind=="pinned"then return isPinned(it.id)end
return true
end
function filterSort(list,useFilter)
local f=state.filter
local key=state.search.."|"..state.sort.."|"..tostring(useFilter).."|"
..(f and(f.kind..":"..tostring(f.key))or"").."|"..(state.fsBust or 0)
state.fsCache=state.fsCache or setmetatable({},{__mode="k"})
local c=state.fsCache[list]
if c and c.key==key then return c.res end
local q,res=state.search:lower(),{}
for _,it in ipairs(list)do
local ln=it.lname or it.name:lower()
local li=it.lid or it.id:lower()
if(q==""or ln:find(q,1,true)or li:find(q,1,true))
and(not useFilter or passesFilter(it))then
res[#res+1]=it
end
end
if state.sort=="name"then
table.sort(res,function(a,b)return(a.lname or a.name)<(b.lname or b.name)end)
else
table.sort(res,function(a,b)return a.count>b.count end)
end
state.fsCache[list]={key=key,res=res}
return res
end
function countsOf(d)
local c=state.countBuf
for k in pairs(c)do c[k]=nil end
for _,it in ipairs(d.items)do c[it.id]=(c[it.id]or 0)+it.count;breathe()end
return c
end
function takeSnapshot(cur)
Snap.add(now(),cur)
while Snap.count()>CFG.snapKeep do Snap.dropOldest()end
state.dirty=true
end
function computeTrends(d,cur)
if Snap.count()==0 then return{ready=false,span=0,list={},byId={}}end
local refT,refC=Snap.ref(now()-CFG.trendWindow)
local span=now()-refT
local tr={ready=span>=60,span=span,list={},byId={}}
if not tr.ready then return tr end
local function add(id,delta,n)
local it=d.byId[id]
local e={id=id,delta=delta,count=n,rate=delta/span*3600,
name=it and it.name or prettify(id)}
tr.list[#tr.list+1]=e
tr.byId[id]=e
end
for id,n in pairs(cur)do
local old=refC[id]or 0
if n~=old then add(id,n-old,n)end
breathe()
end
for id,old in pairs(refC)do
if cur[id]==nil and old~=0 then add(id,-old,0)end
end
return tr
end
function updateDormancy(d,cur)
local t,LM=now(),store.lastMove
for _,it in ipairs(d.items)do
if not it.blocked then
local id=it.id
if not LM[id]or(it.prevCount and it.prevCount~=it.count)then LM[id]=math.floor(t);state.dirty=true end
it.prevCount=it.count
end
breathe()
end
for id in pairs(LM)do if cur[id]==nil then LM[id]=nil end end
local lim,nd=S("dormant"),0
for _,it in ipairs(d.items)do
it.idle=t-(LM[it.id]or t)
it.dormant=it.idle>=lim
if it.dormant then nd=nd+1 end
end
d.dormantCount=nd
end
function detectAnomalies(d,cur)
local t,R,window=now(),state.recent,S("anomWindow")
if#R==0 or t-R[#R].t>=30 then
local copy={}
for k,v in pairs(cur)do copy[k]=v end
R[#R+1]={t=t,c=copy}
end
while#R>1 and R[1].t<t-window do table.remove(R,1)end
for k,a in pairs(state.anom)do if a.untilT<t then state.anom[k]=nil end end
if not S("anomalies")or#R<2 then return end
local ref=R[1]
if t-ref.t<math.min(60,window/2)then return end
local p,minA=S("anomPct")/100,S("anomMin")
for id,old in pairs(ref.c)do
breathe()
local drop=old-(cur[id]or 0)
if old>=minA and drop>=minA and drop/old>=p and not state.anom[id]then
local it=d.byId[id]
local msg=(L"Chute anormale : %s %s en %s"):format(it and it.name or prettify(id),
fmtSigned(-drop),duration(t-ref.t))
state.anom[id]={msg=msg,untilT=t+600}
logEvent("anomalie",msg,2)
end
end
end
function findRule(list,id)
for i,r in ipairs(list)do if r.id==id then return r,i end end
end
function stepOf(it)
return(it and it.maxStack and it.maxStack>=1)and it.maxStack or 64
end
function addRule(kind,it)
local list=kind=="max"and store.maxRules or store.rules
if findRule(list,it.id)then return end
local step=stepOf(it)
local r={id=it.id,name=it.name,step=step}
if kind=="max"then r.max=math.max(step,math.ceil(it.count/step)*step)
else r.min=step end
list[#list+1]=r
pcall(saveStore)
logEvent("stock",(L"Stock %s ajoute : %s"):format(kind=="max"and"max"or"min",it.name),0)
notify(L"Stock "..(kind=="max"and"max"or"min")..L" ajoute : "..it.name)
end
function removeRule(kind,id)
local list=kind=="max"and store.maxRules or store.rules
local r,i=findRule(list,id)
if i then
table.remove(list,i)
pcall(saveStore)
logEvent("stock",(L"Stock %s retire : %s"):format(kind,r.name),0)
end
if kind=="max"then state.maxStatus[id]=nil else state.autoStatus[id]=nil end
end
function isCrafting(id)
if not bridge.isItemCrafting then return nil end
local ok,b=pcall(bridge.isItemCrafting,{name=id})
if ok then return b and true or false end
end
function craft(it,n)
local ok,res,err=pcall(bridge.craftItem,{name=it.id,count=n})
if ok and res then
state.launched[it.id]=now()
logEvent("craft",(L"Craft lance : %dx %s"):format(n,it.name),0)
notify((L"Craft lance : %dx %s"):format(n,it.name))
sfx("ok")
else
local e=tostring(ok and(err or L"ressources ?")or res)
logEvent("craft",(L"Craft impossible : %s (%s)"):format(it.name,e),1)
toast(L"Craft impossible : "..it.name.." ("..e..")","err")
sfx("err")
end
end
function runAuto(d)
for _,r in ipairs(store.rules)do
local it=d.byId[r.id]
local count=it and it.count or 0
local before=state.autoStatus[r.id]
local st
if count>=r.min then st="ok"
elseif not S("autoOn")then st="pause"
elseif isCrafting(r.id)then st="craft"
elseif(state.autoLast[r.id]or 0)+CFG.autoCooldown>now()then
st=before=="fail"and"fail"or"craft"
else
local n=math.min(r.min-count,S("autoMaxCraft"))
local ok,res,err=pcall(bridge.craftItem,{name=r.id,count=n})
state.autoLast[r.id]=now()
if ok and res then
st="craft";state.launched[r.id]=now()
logEvent("auto",(L"Stock min : craft de %dx %s"):format(n,r.name),0)
else
st="fail";state.autoErr[r.id]=tostring(ok and(err or L"ressources ?")or res)
if before~="fail"then
logEvent("auto",(L"Stock min impossible : %s (%s)"):format(r.name,state.autoErr[r.id]),1)
end
end
end
state.autoStatus[r.id]=st
end
end
DIRS={"up","down","north","south","east","west"}
function exportTo(id,n)
local target=S("trash")
if target=="aucune"then return nil,L"aucune poubelle (Reglages)"end
local isDir=false
for _,dname in ipairs(DIRS)do if dname==target then isDir=true end end
local ok,res,err
if isDir then
if not bridge.exportItem then return nil,L"exportItem absent"end
ok,res,err=pcall(bridge.exportItem,{name=id,count=n},target)
else
if not bridge.exportItemToPeripheral then return nil,L"export vers peripherique absent"end
ok,res,err=pcall(bridge.exportItemToPeripheral,{name=id,count=n},target)
end
if not ok then return nil,tostring(res)end
if not res or res==0 then return nil,tostring(err or L"rien exporte (poubelle pleine ?)")end
return tonumber(res)or n
end
function runMax(d)
for _,r in ipairs(store.maxRules)do
local it=d.byId[r.id]
local count=it and it.count or 0
local before=state.maxStatus[r.id]
local st
if count<=r.max then
st="ok"
if(r.pending or 0)>0 then
logEvent("stock",(L"Surplus evacue : %s x%s"):format(r.name,fmt(r.pending)),0)
r.pending=0;state.dirty=true
end
elseif not S("maxOn")then st="pause"
else
local moved,err=exportTo(r.id,math.min(count-r.max,4096))
if moved then
st="evac";r.pending=(r.pending or 0)+moved;r.total=(r.total or 0)+moved
state.dirty=true
else
st="fail";state.maxErr[r.id]=err
if before~="fail"then logEvent("stock",(L"Surplus non evacue : %s (%s)"):format(r.name,err),1)end
end
end
state.maxStatus[r.id]=st
end
end
function collectRunning(d)
local out={}
local tasks=call("getCraftingTasks","getCraftingJobs","listCraftingTasks")
if type(tasks)=="table"then
for _,t in ipairs(tasks)do
if type(t)=="table"then
local o=t.item or t.output or t.resource or t.stack or t
if type(o)~="table"then o={name=tostring(o)}end
out[#out+1]={id=o.name or"?",name=cleanName(o),
count=t.amount or t.count or t.quantity or o.count or o.amount}
end
end
return out
end
for id,t0 in pairs(state.launched)do
local it=d.byId[id]
local busy=isCrafting(id)
if now()-t0>1800 or busy==false then state.launched[id]=nil
elseif busy or now()-t0<120 then out[#out+1]={id=id,name=it and it.name or prettify(id)}end
end
return out
end
function detectFinished(d,running)
local cur={}
for _,e in ipairs(running)do cur[e.id]=e.name end
for id,name in pairs(state.prevRunning)do
if not cur[id]then
logEvent("craft",L"Craft termine : "..name,0)
notify(L"Craft termine : "..name)
sfx("done")
end
end
state.prevRunning=cur
end
function computeAlerts(d)
local A={}
if d.online==false then A[#A+1]={key="offline",msg=L"Reseau RS hors ligne",lvl=2}end
if d.readError then A[#A+1]={key="readerr",msg=L"Lecture des items impossible : "..d.readError,lvl=2}end
if d.degraded then
if#(d.blocked or{})==0 then
A[#A+1]={key="degraded",lvl=1,msg=L"Mode secours : un item inconnu bloque la liste (nouveaux items non detectes)"}
end
for _,b in ipairs(d.blocked or{})do
local it=d.byId[b.id]
A[#A+1]={key="blocked:"..b.id,lvl=1,
msg=L"Item bloquant ignore : "..(it and it.name or b.id)..L" - sors-le du reseau RS"}
end
end
if d.max and d.max>0 and d.used/d.max*100>=S("storageFull")then
A[#A+1]={key="full",lvl=2,msg=(L"Stockage items a %d%%"):format(math.floor(d.used/d.max*100))}
end
local f=d.fluids
if f and f.max and f.max>0 and f.used/f.max*100>=S("fluidFull")then
A[#A+1]={key="ffull",lvl=2,msg=(L"Stockage fluides a %d%%"):format(math.floor(f.used/f.max*100))}
end
if d.energy and d.maxEnergy and d.maxEnergy>0 and d.energy/d.maxEnergy*100<=S("energyLow")then
A[#A+1]={key="energy",lvl=2,msg=(L"Energie basse (%d%%)"):format(math.floor(d.energy/d.maxEnergy*100))}
end
for _,r in ipairs(store.rules)do
if state.autoStatus[r.id]=="fail"then
A[#A+1]={key="auto:"..r.id,lvl=1,msg=L"Stock min impossible : "..r.name}
end
end
for _,r in ipairs(store.maxRules)do
if state.maxStatus[r.id]=="fail"then
A[#A+1]={key="max:"..r.id,lvl=1,msg=L"Surplus bloque : "..r.name}
end
end
for id,a in pairs(state.anom)do A[#A+1]={key="anom:"..id,lvl=1,msg=a.msg}end
local fa=S("fillAlert")
if fa>0 and d.forecast and d.forecast.eta and d.forecast.eta<fa*3600 then
A[#A+1]={key="fill",lvl=1,msg=L"Stockage plein dans ~"..duration(d.forecast.eta)}
end
if DC.alerts then DC.alerts(A)end
return A
end
function updateAlerts(d)
local A=computeAlerts(d)
local keys,grave={},false
for _,a in ipairs(A)do
keys[a.key]=a.msg
if not state.alertKeys[a.key]then
toast(a.msg,a.lvl)
if a.lvl>=2 then grave=true end
if not a.key:find("^anom:")then logEvent("alerte",a.msg,a.lvl)end
local chat=peripheral.find("chatBox")
if chat and S("chatAlerts")then pcall(chat.sendMessage,a.msg,"RSTools")end
end
end
for k,msg in pairs(state.alertKeys)do
if not keys[k]and not k:find("^anom:")then logEvent("alerte",L"Resolu : "..msg,0)end
end
if grave then sfx("alert")end
state.alertKeys,state.alerts=keys,A
local side=S("redstoneSide")
if side~="aucune"then pcall(redstone.setOutput,side,#A>0)end
end
function logBayChanges(drives)
if not drives then return end
local prev,snap=state.prevDrives,{}
for n,sl in pairs(drives)do
local copy={}
for i=1,bays().slots do copy[i]=sl[i]and sl[i].name or false end
snap[n]=copy
end
state.prevDrives=snap
if not prev then return end
local pos,where=bayLayout(drives),{}
for p,n in pairs(pos)do where[n]=posName(p)end
for n,copy in pairs(snap)do
local old=prev[n]
if old then
for i=1,bays().slots do
if old[i]~=copy[i]then
local label=where[n]or n
if copy[i]and old[i]then
logEvent("baie",(L"%s empl. %d : %s remplace par %s"):format(label,i,diskInfo(old[i]).label,diskInfo(copy[i]).label),0)
elseif copy[i]then
logEvent("baie",(L"%s empl. %d : disque %s ajoute"):format(label,i,diskInfo(copy[i]).label),0)
else
logEvent("baie",(L"%s empl. %d : disque %s retire"):format(label,i,diskInfo(old[i]).label),1)
end
end
end
end
end
end
function normUrl(url)return UPD.normRepo(url)end
function checkUpdate(manual)
state.lastUpdateCheck=now()
local n,err,m=UPD.run(ROLE,LANG,false)
if not n then
toast(L"Mise a jour : "..tostring(err),"err")
return
end
if n==0 then
if manual then notify(L"Deja a jour (v"..VERSION..")")end
return
end
logEvent("systeme",L"Mise a jour installee : v"..VERSION.." -> v"..tostring(m.version),0)
pcall(saveStore);pcall(saveData)
notify(L"Mise a jour installee, redemarrage...")
if DC.afterUpdate then pcall(DC.afterUpdate)end
state.restart=true
end
function card(x,y,w,label,value,col,ratio,sub,fn)
roundFill(x,y,w,3,T.panel,col)
text(x+2,y,cut(label,w-3),T.dim,T.panel)
text(x+2,y+1,cut(value,w-3),T.text,T.panel)
if ratio then slimBar(x+2,y+2,w-4,ratio,col,T.panel,T.bg)
elseif sub then text(x+2,y+2,cut(sub,w-3),T.dim,T.panel)end
if fn then addButton(x,y,x+w-1,y+2,fn)end
end
function cardGrid(y,cards,maxCols)
local cols=clamp(math.floor((W-2)/16),1,maxCols)
local cw=math.floor((W-2)/cols)
for i,c in ipairs(cards)do
local cx=2+((i-1)%cols)*cw
local cy=y+math.floor((i-1)/cols)*4
card(cx,cy,cw-1,c[1],c[2],c[3],c[4],c[5],c[6])
end
return y+math.ceil(#cards/cols)*4
end
function listView(key,items,y1,y2,rowH,renderRow,stickBottom)
local h=y2-y1+1
if h<1 then return end
local rows=math.max(1,math.floor(h/rowH))
local maxS=math.max(0,#items-rows)
local s
if stickBottom then
if state.stick[key]==nil then state.stick[key]=true end
s=state.stick[key]and maxS or clamp(state.scroll[key]or maxS,0,maxS)
else
s=clamp(state.scroll[key]or 0,0,maxS)
end
state.scroll[key]=s
if#items==0 then text(3,y1,L"Rien a afficher",T.dim)end
for r=1,rows do
local it=items[r+s]
if it then renderRow(it,y1+(r-1)*rowH)end
end
if maxS>0 and h>=3 then
for yy=y1+1,y2-1 do text(W,yy,"\149",T.panel)end
local th=math.max(1,math.floor((h-2)*rows/#items))
local tp=y1+1+math.floor((h-2-th)*s/maxS)
for yy=tp,math.min(y2-1,tp+th-1)do text(W,yy,"\149",T.accent)end
text(W,y1,"\30",T.text);text(W,y2,"\31",T.text)
local mid=y1+math.floor(h/2)
addButton(W-1,y1,W,mid-1,function()
state.scroll[key]=math.max(0,s-rows);state.stick[key]=false
end)
addButton(W-1,mid,W,y2,function()
state.scroll[key]=math.min(maxS,s+rows);state.stick[key]=(s+rows>=maxS)
end)
end
end
function itemRow(maxCount,opt)
opt=opt or{}
local f=opt.fmt or fmt
local kind=opt.kind or"item"
return function(it,y)
local x2=W-2
roundFill(2,y,x2-1,3,T.panel)
drawIcon(3,y,it.id,4,3,T.panel,kind)
local c=f(it.count)
local nm=(kind=="item"and isPinned(it.id))and("\4 "..it.name)or it.name
text(8,y,cut(nm,x2-#c-9),T.text,T.panel)
rightText(x2-1,y,c,T.text,T.panel)
local sub=it.id
if kind=="item"then
if it.maxStack and it.maxStack>0 then sub=sub.."  \183 "..math.ceil(it.count/it.maxStack)..L" stack(s)"end
local tr=state.data and state.data.trends
local te=tr and tr.ready and tr.byId[it.id]
if te then sub=sub.."  \183 "..fmtSigned(te.rate).."/h"end
if it.dormant then sub=sub..L"  \183 dormant "..duration(it.idle)end
end
local tag,tagCol
if kind=="item"then
if it.blocked then tag,tagCol="BLOQUE",T.bad
elseif findRule(store.maxRules,it.id)and findRule(store.rules,it.id)then tag,tagCol="MIN+MAX",colors.purple
elseif findRule(store.rules,it.id)then tag,tagCol="MIN",colors.purple
elseif findRule(store.maxRules,it.id)then tag,tagCol="MAX",colors.magenta
elseif it.craftable then tag,tagCol="CRAFT",T.accent end
end
text(8,y+1,cut(sub,x2-9-(tag and#tag+1 or 0)),it.dormant and T.warn or T.dim,T.panel)
if tag then rightText(x2-1,y+1,tag,tagCol,T.panel)end
slimBar(8,y+2,x2-8,logRatio(it.count,maxCount),T.accent,T.panel,T.bg)
if kind=="item"and opt.click~=false then
addButton(2,y,x2,y+2,function()state.popup={kind="item",id=it.id}end)
end
end
end
function searchBar(y)
local x2=W-2
fill(2,y,x2-1,1,T.panel)
text(3,y,"\16",T.accent,T.panel)
local bx=x2+1
local function seg(label,key)
local active=state.sort==key
bx=bx-(#label+2)
button(bx,y,label,active and T.accent or T.panel,active and T.bg or T.dim,
function()state.sort=key end)
end
seg("A-Z","name");seg(L"Qte","count")
local avail=bx-5-5
addButton(2,y,bx-5,y,function()state.kb=true;state.input=nil end)
if state.search==""then
text(5,y,cut(L"Rechercher (touche ici pour le clavier)",avail),T.dim,T.panel)
else
local q=state.search.."_"
if avail>0 then text(5,y,q:sub(-avail),T.text,T.panel)end
button(bx-4,y,"x",T.bad,T.text,function()state.search="";state.scroll={}end)
end
end
function maxOf(list)
local m=0
for _,it in ipairs(list)do if it.count>m then m=it.count end end
return m
end
pages={}
;(function()
pages.home=function(d)
local y=5
if#state.alerts>0 then
local a=state.alerts[1]
fill(2,y,W-3,1,T.bad)
local s="! "..a.msg..(#state.alerts>1 and("   (+"..(#state.alerts-1)..")")or"")
text(3,y,cut(s,W-5),T.text,T.bad)
addButton(2,y,W-2,y,function()state.popup={kind="alerts"}end)
y=y+2
end
local sR=(d.max and d.max>0)and d.used/d.max or nil
local eR=(d.energy and d.maxEnergy and d.maxEnergy>0)and d.energy/d.maxEnergy or nil
local cards={
{L"Stockage",sR and("%.1f%%  %s/%s"):format(sR*100,fmt(d.used),fmt(d.max))or fmt(d.used),
sR and ratioColor(sR)or T.accent,sR},
{L"Energie",eR and("%.0f%%"):format(eR*100)or"?",T.energy,eR},
{L"Prevision",(forecastText(d.forecast,d)),select(2,forecastText(d.forecast,d)),nil,
d.forecast and(L"%+.2f%% par heure"):format(d.forecast.perHour*100)or L"historique court",
function()state.tab="usage"end},
{L"Items",fmt(d.total),T.accent,nil,d.types..L" types"},
{L"Dormants",tostring(d.dormantCount or 0),T.warn,nil,L"inactifs > "..duration(S("dormant")),
function()state.tab="items";state.filter={kind="dormant"};state.scroll={}end},
{L"Auto",#store.rules..L" min  \183  "..#store.maxRules.." max",colors.purple,nil,
(S("autoOn")and L"min actif"or L"min en pause").." \183 "..(S("maxOn")and L"max actif"or L"max en pause"),
function()state.tab="auto"end},
}
if present(d.fluids)then
local f=d.fluids
local fR=(f.max and f.max>0)and f.used/f.max or nil
cards[#cards+1]={L"Fluides",fmtMB(f.used)..(f.max and(" / "..fmtMB(f.max))or""),
colors.lightBlue,fR,#f.list..L" types"}
end
y=cardGrid(y,cards,3)+1
if#store.pins>0 then
sectionTitle(2,y,L"Epingles",tostring(#store.pins))
y=y+1
local maxRows=math.max(1,math.min(#store.pins,math.floor((H-1-y)/2)))
for i=1,maxRows do
local id,yy=store.pins[i],y+i-1
local it=d.byId[id]
local name=it and it.name or prettify(id)
local count=it and it.count or 0
drawIcon(2,yy,id,2,1,T.bg)
local te=d.trends and d.trends.ready and d.trends.byId[id]
local rate=te and(fmtSigned(te.rate).."/h")or L"stable"
local cnt=fmt(count)
rightText(W-1,yy,cnt,it and T.text or T.dim)
rightText(W-3-#cnt,yy,rate,te and(te.delta>=0 and T.ok or T.bad)or T.dim)
text(5,yy,cut(name,W-10-#cnt-#rate),it and T.text or T.dim)
if it then addButton(2,yy,W-1,yy,function()state.popup={kind="item",id=id}end)end
end
if#store.pins>maxRows then text(5,y+maxRows,"+"..(#store.pins-maxRows)..L" autre(s) - filtre Epingles dans Items",T.dim);maxRows=maxRows+1 end
y=y+maxRows+1
end
sectionTitle(2,y,L"Top items")
y=y+2
local top={}
for i,it in ipairs(d.items)do top[i]=it end
table.sort(top,function(a,b)return a.count>b.count end)
local maxC=top[1]and top[1].count or 1
local barW=math.floor((W-2)*0.3)
local barX=W-1-7-barW
for i=1,math.min(#top,H-1-y)do
local it,yy=top[i],y+i-1
drawIcon(2,yy,it.id,2,1,T.bg)
text(5,yy,cut(it.name,barX-6),T.text)
slimBar(barX,yy,barW,logRatio(it.count,maxC),T.accent,T.bg,T.panel)
rightText(W-1,yy,fmt(it.count),T.dim)
addButton(2,yy,W-1,yy,function()state.popup={kind="item",id=it.id}end)
end
end
pages.items=function(d)
searchBar(5)
local list=filterSort(d.items,true)
local f=state.filter
local label=L"Filtre : "..(not f and L"Tout"or(f.kind=="dormant"and L"Dormants")
or(f.kind=="pinned"and L"Epingles")or f.key)
local x=2+button(2,6,"\25 "..label,f and colors.purple or T.panel,T.text,
function()state.popup={kind="filters"}end)+1
if f then
x=x+button(x,6,"x",T.bad,T.text,function()state.filter=nil;state.scroll={}end)+1
end
text(x,6,#list..L" resultat(s)",T.dim)
listView("items",list,8,H-1,4,itemRow(maxOf(list)))
end
local function resPage(res,key,kind)
local r=(res.max and res.max>0)and res.used/res.max or nil
text(2,5,L"Stockage",T.dim)
local info=fmtMB(res.used)..(res.max and(" / "..fmtMB(res.max))or"")
..(r and("  %d%%"):format(math.floor(r*100+0.5))or"")
rightText(W-1,5,info,r and ratioColor(r)or T.dim)
slimBar(2,6,W-2,r or 0,r and ratioColor(r)or T.panel,T.bg,T.panel)
searchBar(8)
local list=filterSort(res.list,false)
text(3,9,#list..L" resultat(s)",T.dim)
listView(key,list,10,H-1,4,itemRow(maxOf(list),{kind=kind,fmt=fmtMB,click=false}))
end
pages.fluids=function(d)resPage(d.fluids,"fluids","fluid")end
pages.chems=function(d)resPage(d.chems,"chems","chem")end
pages.usage=function(d)
local sR=(d.max and d.max>0)and d.used/d.max or nil
local eR=(d.energy and d.maxEnergy and d.maxEnergy>0)and d.energy/d.maxEnergy or nil
local reserve
if d.usage and d.usage>0 and d.energy then reserve=L"reserve ~"..duration(d.energy/(d.usage*20))end
local y=cardGrid(5,{
{L"Energie",eR and(fmt(d.energy).." / "..fmt(d.maxEnergy).." FE")or"?",T.energy,eR},
{L"Consommation",d.usage and(fmt(d.usage).." FE/t")or"?",colors.orange,nil,reserve},
{L"Stockage",sR and(fmt(d.used).." / "..fmt(d.max))or fmt(d.used),
sR and ratioColor(sR)or T.accent,sR},
{L"Prevision",(forecastText(d.forecast,d)),select(2,forecastText(d.forecast,d)),nil,
d.forecast and(L"%+.2f%% par heure"):format(d.forecast.perHour*100)or L"il faut ~5 min d'historique"},
},4)+1
local span="~"..duration(math.max(#store.histEnergy,#store.histStorage)*CFG.graphEvery)
local gh=clamp(math.floor((H-y)/4),3,8)
if W>=50 then
local gw=math.floor((W-4)/2)
text(2,y,L"Energie  "..span,T.dim)
graph(2,y+1,gw,gh,store.histEnergy,T.energy,T.panel)
text(gw+3,y,L"Remplissage  "..span,T.dim)
graph(gw+3,y+1,W-gw-3,gh,store.histStorage,sR and ratioColor(sR)or T.accent,T.panel)
y=y+gh+2
else
text(2,y,L"Energie  "..span,T.dim)
graph(2,y+1,W-2,gh,store.histEnergy,T.energy,T.panel)
y=y+gh+2
text(2,y,L"Remplissage  "..span,T.dim)
graph(2,y+1,W-2,gh,store.histStorage,sR and ratioColor(sR)or T.accent,T.panel)
y=y+gh+2
end
sectionTitle(2,y,L"Disques",d.disks and tostring(#d.disks)or nil)
if not d.disks then
text(3,y+2,cut(L"Remplissage par disque non fourni par ta version",W-4),T.dim)
text(3,y+3,cut(d.drives and L"d'Advanced Peripherals : voir l'onglet Baies."or L"d'Advanced Peripherals.",W-4),T.dim)
return
end
listView("disks",d.disks,y+2,H-1,2,function(dk,yy)
local x2=W-2
local r=(dk.used and dk.total and dk.total>0)and dk.used/dk.total or nil
local info=r and("%s / %s  %3d%%"):format(fmt(dk.used),fmt(dk.total),math.floor(r*100+0.5))
or(dk.total and fmt(dk.total)or"?")
text(3,yy,cut(dk.name,x2-#info-4),T.text)
rightText(x2,yy,info,r and ratioColor(r)or T.dim)
slimBar(3,yy+1,x2-2,r or 0,r and ratioColor(r)or T.panel,T.bg,T.panel)
end)
end
pages.crafts=function(d)
local y=5
local run=d.running or{}
if#run>0 then
sectionTitle(2,y,L"En cours",tostring(#run))
local spin="\7"
local k=math.min(#run,4)
for i=1,k do
local e,yy=run[i],y+i
drawIcon(2,yy,e.id,2,1,T.bg)
text(5,yy,cut(e.name,W-16),T.text)
rightText(W-1,yy,(e.count and(fmt(e.count).." ")or"")..spin,T.warn)
end
if#run>k then text(5,y+k+1,"+"..(#run-k)..L" autre(s)",T.dim);k=k+1 end
y=y+k+2
end
searchBar(y)
local list=filterSort(d.crafts,false)
text(3,y+1,#list..L" recette(s)",T.dim)
listView("crafts",list,y+2,H-1,4,itemRow(maxOf(list)))
end
local STATUS_MIN={
ok={"OK",T.ok},craft={L"EN CRAFT",T.warn},fail={"ECHEC",T.bad},pause={"PAUSE",T.dim},
}
local STATUS_MAX={
ok={"OK",T.ok},evac={"EVACUATION",T.warn},fail={"ECHEC",T.bad},pause={"PAUSE",T.dim},
}
pages.auto=function(d)
local y=5
local isMax=state.autoView=="max"
local x=2
x=x+button(x,y,L"Stock min ("..#store.rules..")",not isMax and T.accent or T.panel,
not isMax and T.bg or T.dim,function()state.autoView="min"end)+1
x=x+button(x,y,L"Stock max ("..#store.maxRules..")",isMax and T.accent or T.panel,
isMax and T.bg or T.dim,function()state.autoView="max"end)+2
local key=isMax and"maxOn"or"autoOn"
local on=S(key)
x=x+button(x,y,on and"ACTIF"or"PAUSE",on and T.ok or T.bad,T.bg,function()setS(key,not on)end)+1
local hint=isMax and(L"poubelle : "..S("trash"))or L"ajoute des items depuis leur fiche"
text(x,y,cut(hint,W-x-1),T.dim)
local list=isMax and store.maxRules or store.rules
local ST=isMax and STATUS_MAX or STATUS_MIN
local statusT=isMax and state.maxStatus or state.autoStatus
local errT=isMax and state.maxErr or state.autoErr
listView(isMax and"automax"or"automin",list,y+2,H-1,4,function(r,yy)
local x2=W-2
local it=d.byId[r.id]
local count=it and it.count or 0
local limit=isMax and r.max or r.min
local st=statusT[r.id]
local s=ST[st]or{"?",T.dim}
fill(2,yy,x2-1,3,T.panel)
drawIcon(3,yy,r.id,4,3,T.panel)
text(8,yy,cut(r.name,x2-8-#s[1]-2),T.text,T.panel)
rightText(x2-1,yy,s[1],s[2],T.panel)
local bx=x2-11
local info=fmt(count).." / "..(isMax and L"max "or L"min ")..fmt(limit)..L"  (pas "..r.step..")"
if isMax and(r.total or 0)>0 then info=info..L"  \183 evacue "..fmt(r.total)end
if st=="fail"and errT[r.id]then info=errT[r.id]end
text(8,yy+1,cut(info,bx-9),st=="fail"and T.bad or T.dim,T.panel)
local field=isMax and"max"or"min"
button(bx,yy+1,"-",T.bg,T.text,function()r[field]=math.max(isMax and 0 or 1,r[field]-r.step);pcall(saveStore)end)
button(bx+4,yy+1,"+",T.bg,T.text,function()r[field]=r[field]+r.step;pcall(saveStore)end)
button(bx+8,yy+1,"x",T.bad,T.text,function()removeRule(isMax and"max"or"min",r.id)end)
local ratio=isMax and(limit>0 and count/limit or 1)or(limit>0 and count/limit or 1)
local barCol=isMax and(count>limit and T.warn or T.ok)or(count>=limit and T.ok or s[2])
slimBar(8,yy+2,x2-8,ratio,barCol,T.panel,T.bg)
end)
end
local LOGCATS={
{"all",L"Tout"},{"craft",L"Crafts"},{"stock",L"Stock"},{"alerte",L"Alertes"},
{"anomalie",L"Anomalies"},{"baie",L"Baies"},{"systeme",L"Systeme"},
}
pages.journal=function()
local x=2
for _,c in ipairs(LOGCATS)do
local active=state.logFilter==c[1]
if x+#c[2]+2>W then break end
x=x+button(x,5,c[2],active and T.accent or T.panel,active and T.bg or T.dim,
function()state.logFilter=c[1];state.stick.journal=true end)+1
end
local list={}
for i=1,#store.log do
local e=store.log[i]
local cat=e.c=="auto"and"craft"or e.c
if state.logFilter=="all"or state.logFilter==cat then list[#list+1]=e end
end
text(2,6,#list..L" evenement(s)  \183  les plus recents en bas",T.dim)
listView("journal",list,8,H-1,1,function(e,y)
local ts=os.date("%d/%m %H:%M",math.floor(e.t))
text(2,y,ts,T.dim)
local col=(e.l or 0)>=2 and T.bad or((e.l or 0)==1 and T.warn or T.accent)
text(3+#ts,y,"\7",col)
text(5+#ts,y,cut((e.c or""):upper(),9),T.dim)
text(15+#ts,y,cut(e.m,W-#ts-17),T.text)
end,true)
end
end)()
;(function()
local function mainCat(it)
if it.catMain==nil then
local names={}
for c in pairs(it.cats or{})do names[#names+1]=c end
table.sort(names)
it.catMain=names[1]or L("Autres")
end
return it.catMain
end
local function groups(d,view,zoom)
local tr=(d.trends and d.trends.ready and d.trends.byId)or{}
local out={}
if view=="items"or zoom then
for _,it in ipairs(d.items)do
local ok=it.count>0
if ok and zoom then
ok=(zoom.kind=="mod"and it.mod==zoom.key)or(zoom.kind=="cat"and mainCat(it)==zoom.key)
end
if ok then
local te=tr[it.id]
out[#out+1]={key=it.id,label=it.name,value=it.count,delta=te and te.delta or 0,
id=it.id,dormant=it.dormant,mod=it.mod}
end
breathe()
end
else
local agg={}
for _,it in ipairs(d.items)do
if it.count>0 then
local k=(view=="mods")and it.mod or mainCat(it)
local g=agg[k]
if not g then g={key=k,label=k,value=0,delta=0,mod=k};agg[k]=g;out[#out+1]=g end
g.value=g.value+it.count
local te=tr[it.id]
if te then g.delta=g.delta+te.delta end
end
breathe()
end
end
table.sort(out,function(a,b)return a.value>b.value end)
return out
end
state.mosaicGroups=groups
pages.mosaic=function(d)
local x=2
for _,v in ipairs({{"items",L"Items"},{"mods",L"Mods"},{"cats",L"Categories"}})do
local active=S("mosView")==v[1]
x=x+button(x,5,v[2],active and T.accent or T.panel,active and T.bg or T.dim,function()
setS("mosView",v[1]);state.mosZoom=nil
end)+1
end
local cm=S("mosColor")
x=x+1
button(x,5,L"Couleur : "..(cm=="mod"and L("par mod")or L("tendance")),T.panel,T.text,function()
setS("mosColor",cm=="mod"and"trend"or"mod")
end)
if state.mosZoom then
button(W-11,5,L"< Retour",T.accent,T.bg,function()state.mosZoom=nil end)
text(2,6,cut(L"dans "..state.mosZoom.key,W-3),T.accent)
elseif cm=="trend"then
local lx=2
for _,lg in ipairs({{colors.green,L"En hausse"},{colors.red,L"En baisse"},{colors.gray,L"stable"},{colors.brown,L"Dormants"}})do
text(lx,6,"\7",lg[1])
local lab=L(lg[2])
text(lx+2,6,lab,T.dim)
lx=lx+#lab+5
end
else
text(2,6,cut(L"Mosaique : taille = quantite, touche pour zoomer",W-3),T.dim)
end
drawMosaic(d,2,7,W-2,H-7,S("mosView"),cm,state.mosZoom,true)
end
end)()
;(function()
local TOOLBAR={"haut","bas","gauche","droite"}
local TOOLBAR_NAMES={haut=L"En haut",bas=L"En bas",gauche=L"A gauche",droite=L"A droite"}
local WIDGET_TYPES={"aucun","ecran","mosaique","baies","stockage","energie","fluides","prevision","item",
"epingles","tendances","alertes","crafts","journal","horloge","resume"}
local WIDGET_NAMES={
aucun=L"Aucun",ecran=L"Ecran secondaire (interface)",baies=L"Baies de disques",stockage=L"Stockage",energie=L"Energie",
item=L"Item suivi",alertes=L"Alertes",crafts=L"Crafts en cours",journal=L"Journal",resume=L"Resume",
mosaique=L"Mosaique",horloge=L"Horloge",tendances=L"Tendances",epingles=L"Epingles (liste)",
fluides=L"Fluides",prevision=L"Prevision de remplissage",
}
local function opt(k,l,t,extra)
local e={k=k,l=l,t=t}
for kk,v in pairs(extra or{})do e[kk]=v end
e.get=e.get or function()return S(k)end
e.set=e.set or function(v)setS(k,v)end
return e
end
local function widgetEntries(n,tbl,onSave,maxCols)
tbl=tbl or store.widgets
local cfg=tbl[n]or{type="aucun",scale=0.5}
local function save()
tbl[n]=cfg
if onSave then onSave()else pcall(saveStore);setupWidgets()end
end
local types=WIDGET_TYPES
if tbl~=store.widgets then
types={}
for _,t in ipairs(WIDGET_TYPES)do if t~="ecran"then types[#types+1]=t end end
end
local list={
{h=n},
{l=L"Affichage",t="choice",c=types,f=function(v)return WIDGET_NAMES[v]or v end,
get=function()return cfg.type end,set=function(v)cfg.type=v;save()end},
}
if cfg.type=="ecran"then
list[#list+1]={info=L"Interface complete, navigation independante de l'ecran principal."}
end
if cfg.type~="aucun"then
list[#list+1]={l=L"Taille du texte",t="choice",c={0.5,1,1.5,2,3},
get=function()return cfg.scale or 0.5 end,set=function(v)cfg.scale=v;save()end}
end
if cfg.type=="item"then
local c={}
for _,id in ipairs(store.pins)do c[#c+1]=id end
if#c==0 then
list[#list+1]={info=L"Epingle d'abord un item depuis sa fiche."}
else
list[#list+1]={l=L"Item (parmi les epingles)",t="choice",c=c,
f=function(v)
if not v then return"?"end
local it=state.data and state.data.byId[v]
return it and it.name or prettify(v)
end,
get=function()return cfg.item end,set=function(v)cfg.item=v;save()end}
end
end
if cfg.type=="mosaique"then
list[#list+1]={l=L"Vue de la mosaique",t="choice",c={"mods","cats","items"},
f=function(v)return v=="mods"and L"Mods"or(v=="cats"and L("Categories")or L("Items"))end,
get=function()return cfg.view or"mods"end,set=function(v)cfg.view=v;save()end}
list[#list+1]={l=L"Couleurs de la mosaique",t="choice",c={"trend","mod"},
f=function(v)return v=="mod"and L("par mod")or L("tendance")end,
get=function()return cfg.color or"trend"end,set=function(v)cfg.color=v;save()end}
end
if cfg.type=="baies"then
local mc=maxCols or bays().cols
list[#list+1]={l=L"Premiere colonne affichee",t="num",min=1,max=mc,step=1,
f=function(v)return string.char(64+v)end,
get=function()return cfg.colFrom or 1 end,set=function(v)cfg.colFrom=v;save()end}
list[#list+1]={l=L"Derniere colonne affichee",t="num",min=1,max=mc,step=1,
f=function(v)return string.char(64+v)end,
get=function()return cfg.colTo or mc end,set=function(v)cfg.colTo=v;save()end}
list[#list+1]=opt("bayMode",L"Mesure affichee","choice",{c={"slots","capacity"},
f=function(v)return v=="slots"and L"emplacements"or L"capacite"end})
end
return list
end
local function trashChoices()
local c={"aucune"}
for _,dname in ipairs(DIRS)do c[#c+1]=dname end
for _,n in ipairs(peripheral.getNames())do
if isType(n,"inventory")and not n:find("disk_drive")then c[#c+1]=n end
end
return c
end
local function fmtKo(b)
if b>=1048576 then return("%.1f Mo"):format(b/1048576)end
return("%d Ko"):format(math.floor(b/1024+0.5))
end
local function diskUsage(fresh)
local c=state.diskCache
if c and not fresh and os.clock()-c.at<10 then return c end
local prog=shell and shell.getRunningProgram and shell.getRunningProgram()or""
local parts={
{key="prog",label=L"Programme",color=T.accent,size=0,always=true},
{key="bak",label=L"Copie de secours",color=colors.purple,size=0},
{key="data",label=L"Historique et journal",color=colors.blue,size=0,always=true},
{key="conf",label=L"Reglages",color=colors.lime,size=0,always=true},
{key="other",label=L"Autres fichiers",color=colors.orange,size=0},
}
local byKey={}
for _,p in ipairs(parts)do byKey[p.key]=p end
local function walk(dir)
local okL,names=pcall(fs.list,dir)
if not okL then return end
for _,n in ipairs(names)do
local path=fs.combine(dir,n)
local hdd=not fs.getDrive or fs.getDrive(path)=="hdd"
if n~="rom"and hdd then
if fs.isDir(path)then walk(path)else
local sz=fs.getSize(path)
local k="other"
if path==prog then k="prog"
elseif path:match("%.bak$")then k="bak"
elseif path==CFG.dataFile or path==CFG.dataFile..".tmp"then k="data"
elseif path==CFG.configFile or path==CFG.configFile..".tmp"then k="conf"end
byKey[k].size=byKey[k].size+sz
end
end
breathe()
end
end
walk("")
local used=0
for _,p in ipairs(parts)do used=used+p.size end
local free=freeSpace()
local total=(fs.getCapacity and fs.getCapacity("/"))or(used+free)
if total<used+free then total=used+free end
local r={parts=parts,used=used,free=free,total=total,at=os.clock()}
state.diskCache=r
return r
end
local CAT_STYLE={
apparence={"\15",colors.purple,L"Couleurs, disposition et demarrage"},
sons={"\14",colors.pink,L"Haut-parleur et volume"},
ecrans={"\8",colors.blue,L"Ecran principal et widgets externes"},
baies={"\127",colors.orange,L"Grille et lecture des disk drives"},
stock={"\18",colors.green,L"Stock minimum, maximum et dormance"},
alertes={"!",colors.red,L"Seuils et notifications"},
anomalies={"\19",colors.yellow,L"Detection des chutes anormales"},
maj={"\24",colors.lightBlue,L"Mise a jour automatique"},
donnees={"\164",colors.brown,L"Journal, historique et reinitialisation"},
apropos={"i",colors.magenta,APP.." v"..VERSION},
datacenter={"\22",colors.cyan,L"Controleurs de baies et installation"},
}
local CAT_GROUPS={
{L"Personnalisation",{"apparence","sons","ecrans"}},
{L"Reseau",{"baies","datacenter","stock","alertes","anomalies"}},
{L"Systeme",{"maj","donnees","apropos"}},
}
local CATEGORIES={
{id="datacenter",name=L"Data center",entries=function()
local list={
{h=L"Mode"},
{l=L"Role de cet ordinateur",t="choice",c={"standard","central"},
f=function(v)return v=="central"and L"Central (data center)"or L"Standard"end,
get=function()return ROLE end,
set=function(v)
if v==ROLE then return end
UPD.setRole(v)
local n,err=UPD.run(v,LANG,false)
if not n then toast(L"Telechargement impossible : "..tostring(err),"err")end
notify(L"Changement de role : redemarrage...")
state.restart=true
end},
{info=L"Central : gere des controleurs de baies relies en filaire."},
}
if DC.settingsEntries then
for _,e in ipairs(DC.settingsEntries())do list[#list+1]=e end
end
return list
end},
{id="apparence",name=L"Apparence",entries=function()
local ids={}
for _,t in ipairs(THEMES)do ids[#ids+1]=t.id end
return{
{h=L"Couleurs"},
opt("theme",L"Theme de couleurs","choice",{c=ids,f=function(v)return themeById(v).name end,apply="palette"}),
opt("rounded",L"Coins arrondis","bool"),
{h=L"Disposition"},
opt("toolbar",L"Barre d'onglets","choice",{c=TOOLBAR,f=function(v)return TOOLBAR_NAMES[v]or v end}),
opt("tabIcons",L"Icones dans les onglets","bool"),
opt("scale",L"Taille du texte","choice",{c=fittingScales(),apply="main"}),
{h=L"Demarrage et rythme"},
opt("bootAnim",L"Animation au demarrage","bool"),
{h=L"Langue"},
opt("lang",L"Langue","choice",{c={"fr","en"},apply="lang",
f=function(v)return v=="en"and"English"or"Francais"end}),
{h=L"Clavier virtuel"},
opt("kbSize",L"Taille du clavier","choice",{c={"normal","grand","tres grand"}}),
opt("refresh",L"Rafraichissement","choice",{c={2,5,10,30},f=function(v)return v.." s"end}),
}
end},
{id="sons",name=L"Sons",entries=function()return{
{h=L"Haut-parleur"},
opt("sounds",L"Sons d'interface","bool"),
opt("volume",L"Volume","choice",{c={0.3,0.6,1,2,3}}),
{a="testSound",l=L"Tester les sons"},
{info=peripheral.find("speaker")and L"Haut-parleur detecte."or L"Aucun haut-parleur detecte."},
}end},
{id="ecrans",name=L"Ecrans",entries=function()
local mons=listMonitors()
local list={
{h=L"Ecran principal"},
{l=L"Moniteur",t="choice",c=mons,get=function()return monName end,
set=function(v)
setS("mainMon",v)
if store.widgets[v]then store.widgets[v].type="aucun"end
setupMain();setupWidgets()
end},
}
local others=0
for _,n in ipairs(mons)do
if n~=monName then
others=others+1
for _,e in ipairs(widgetEntries(n))do list[#list+1]=e end
end
end
if others==0 then list[#list+1]={info=L"Branche d'autres moniteurs avances pour ajouter des widgets."}end
return list
end},
{id="baies",name=L"Baies",entries=function()return{
{h=L"Grille"},
opt("bayAuto",L"Detection automatique","bool",{apply="grid"}),
opt("bayCols",L"Colonnes","num",{min=1,max=16,step=1,apply="grid"}),
opt("bayRows",L"Rangees","num",{min=1,max=10,step=1,apply="grid"}),
{info=L"Grille actuelle : "..bays().cols.." x "..bays().rows..L" (changer = refaire l'identification)"},
{h=L"Lecture"},
opt("baysEvery",L"Lire les baies toutes les","choice",{c={10,30,60,120},f=duration}),
{a="identify",l=L"Identifier les baies"},
}end},
{id="stock",name=L"Stock",entries=function()return{
{h=L"Stock minimum"},
opt("autoOn",L"Actif","bool"),
opt("autoMaxCraft",L"Quantite max par craft","choice",{c={64,256,1024,4096}}),
{h=L"Stock maximum"},
opt("maxOn",L"Actif","bool"),
opt("trash",L"Poubelle pour le surplus","choice",{c=trashChoices()}),
{h=L"Dormance"},
opt("dormant",L"Item dormant apres","choice",{c={3600,21600,86400,259200,604800},f=duration}),
}end},
{id="alertes",name=L"Alertes",entries=function()return{
{h=L"Seuils"},
opt("storageFull",L"Stockage items plein a","num",{min=50,max=100,step=5,f=pct}),
opt("fluidFull",L"Stockage fluides plein a","num",{min=50,max=100,step=5,f=pct}),
opt("energyLow",L"Energie basse sous","num",{min=0,max=90,step=5,f=pct}),
opt("fillAlert",L"Plein dans moins de","choice",{c={0,6,24,72,168},
f=function(v)return v==0 and L"desactivee"or duration(v*3600)end}),
{h=L"Notifications"},
opt("toastDur",L"Duree a l'ecran","choice",{c={3,5,8,12},f=function(v)return v.." s"end}),
opt("chatAlerts",L"Dans le chat (Chat Box)","bool"),
opt("redstoneSide",L"Sortie redstone","choice",
{c={"aucune","top","bottom","left","right","front","back"}}),
}end},
{id="anomalies",name=L"Anomalies",entries=function()return{
{h=L"Detection"},
opt("anomalies",L"Chutes anormales","bool"),
opt("anomPct",L"Chute minimale","num",{min=10,max=95,step=5,f=pct}),
opt("anomMin",L"Quantite minimale perdue","choice",{c={64,256,1024,4096,16384}}),
opt("anomWindow",L"Sur une periode de","choice",{c={60,300,600,1800},f=duration}),
}end},
{id="maj",name=L"Mise a jour",entries=function()return{
{h=L"Automatique"},
opt("autoUpdate",L"Mise a jour automatique","bool"),
{a="url",l=L"Depot"},
{info=L"Adresse du depot GitHub (ex. github.com/pseudo/rstools)"},
{a="check",l=L"Verifier maintenant"},
opt("backup",L"Copie de secours avant mise a jour","bool",{apply="backup"}),
{info=L"Desactivee : economise la taille du programme sur le disque."},
{h=L"Nouveautes"},
{a="news",l=L"Voir les nouveautes"},
}end},
{id="donnees",name=L"Donnees",entries=function()
local u=diskUsage(true)
local list={
{h=L"Stockage de l'ordinateur"},
{info=(L"%s utilises sur %s  \183  %s libres"):format(fmtKo(u.used),fmtKo(u.total),fmtKo(u.free))},
{diskbar=u},
}
for _,p in ipairs(u.parts)do
if p.size>0 or p.always then list[#list+1]={legend=p,total=u.total}end
end
if state.trimmed then list[#list+1]={info=L"Historique allege automatiquement (manque de place)"}end
list[#list+1]={h=L"Nettoyage"}
list[#list+1]={a="clearLog",l=L"Vider le journal"}
list[#list+1]={a="clearHist",l=L"Effacer historique, tendances et dormance"}
list[#list+1]={h=L"Reinitialisation"}
list[#list+1]={a="resetSettings",l=L"Remettre les reglages par defaut"}
return list
end},
{id="apropos",name=L"A propos",entries=function()return{
{h=APP},
{info=L"Version "..VERSION},
{info=L"Tableau de bord pour les reseaux Refined Storage"},
{info=L"Concu et edite par Ventura"},
{info=L"Necessite CC:Tweaked et Advanced Peripherals"},
{h=L"Nouveautes"},
{a="news",l=L"Voir les nouveautes"},
}end},
}
local function catById(id)
for _,c in ipairs(CATEGORIES)do if c.id==id then return c end end
end
local function catBadge(x,y,id,fg,bg)
local st=CAT_STYLE[id]or{"?"}
text(x+1,y,st[1],fg or T.accent,bg or T.bg)
end
local function changeSetting(e,v)
local old=e.get()
e.set(v)
if e.k=="redstoneSide"and old~="aucune"then pcall(redstone.setOutput,old,false)end
if e.apply=="palette"then
applyPalette(win)
for _,w in pairs(widgets)do applyPalette(w.win)end
elseif e.apply=="main"then
setupMain();setupWidgets()
elseif e.apply=="grid"then
notify(L"Grille "..bays().cols.." x "..bays().rows..L" : pense a refaire l'identification")
end
if e.k=="autoUpdate"and v then state.lastUpdateCheck=0 end
if e.apply=="backup"and not v then removeBackups()end
if e.apply=="lang"and v~=LANG then
if v=="en"and not fs.exists("rstools/lang/en.lua")then pcall(UPD.run,ROLE,"en",false)end
if DC.pushAll then pcall(DC.pushAll)end
notify(L"Langue changee : redemarrage...")
state.restart=true
end
end
local function stepSetting(e,dir)
if e.t=="num"then
changeSetting(e,clamp((e.get()or e.min)+dir*e.step,e.min,e.max))
return
end
local c=e.c
if not c or#c==0 then return end
local v=e.get()
local idx=0
for i,x in ipairs(c)do if tostring(x)==tostring(v)then idx=i end end
local ni=idx==0 and 1 or((idx-1+dir)%#c)+1
changeSetting(e,c[ni])
end
local ACTIONS={
check=function()
local ok,err=pcall(checkUpdate,true)
if not ok then toast(L"Mise a jour : "..tostring(err),"err")end
end,
news=function()state.popup={kind="news",all=true}end,
testSound=function()sfx("ok");sleep(0.3);sfx("toast");sleep(0.3);sfx("done")end,
identify=function()
if state.data and state.data.drives then state.tab="bays";startAssign(state.data)
else notify(L"Aucun disk drive detecte")end
end,
clearLog=function()store.log={};pcall(saveData);notify(L"Journal vide")end,
clearHist=function()
store.histStorage,store.histEnergy,store.lastMove={},{},{}
Snap.reset()
state.recent={}
pcall(saveData);notify(L"Historique efface")
end,
resetSettings=function()
store.settings={}
pcall(saveStore);setupMain();setupWidgets();notify(L"Reglages par defaut")
end,
}
local function settingRow(e,y)
local x2=W-2
if e.h then
text(2,y,cut(e.h:upper(),x2-2),T.accent)
if x2-#e.h-3>0 then text(3+#e.h,y,("\140"):rep(x2-#e.h-2),T.panel)end
return
end
if e.info then text(3,y,cut(e.info,x2-3),T.dim);return end
if e.diskbar then
local u,bw=e.diskbar,x2-2
roundFill(3,y,bw,1,T.panel)
local x=3
for _,p in ipairs(u.parts)do
local w=math.floor(p.size/u.total*bw+0.5)
if p.size>0 and w<1 then w=1 end
w=math.min(w,3+bw-x)
if w>0 then fill(x,y,w,1,p.color);x=x+w end
end
if S("rounded")then
corner(3,y,"l",u.parts[1].color,T.bg)
corner(3+bw-1,y,"r",(x>3+bw-1)and u.parts[#u.parts].color or T.panel,T.bg)
end
return
end
if e.legend then
local p=e.legend
text(3,y,"\7",p.color)
text(5,y,cut(p.label,x2-20),T.text)
local pctv=e.total>0 and math.floor(p.size/e.total*100+0.5)or 0
rightText(x2,y,fmtKo(p.size).."  "..pctv.."%",T.dim)
return
end
roundFill(2,y,x2-1,1,T.panel)
if e.a=="url"then
local editing=state.input and state.input.key=="repoUrl"
local v=editing and(state.input.buf.."_")or(S("repoUrl")or CFG.repoUrl)
if v==""then v="(aucune)"end
local bl=editing and L"Valider"or L"Modifier"
local bx=x2-#bl-2
text(3,y,e.l,T.text,T.panel)
local room=bx-9
text(8,y,editing and v:sub(-room)or cut(v,room),editing and T.warn or T.accent,T.panel)
button(bx,y,bl,T.accent,T.bg,function()
if editing then
setS("repoUrl",normUrl(state.input.buf));state.input=nil;state.kb=false;notify(L"URL enregistree")
else
state.input={key="repoUrl",buf=S("repoUrl")or CFG.repoUrl or""}
state.kb=true
end
end)
return
end
text(3,y,cut(e.l,x2-30),T.text,T.panel)
if e.a then
local bl=e.btn or L"Lancer"
button(x2-#bl-2,y,bl,e.danger and T.bad or T.accent,T.bg,e.run or ACTIONS[e.a])
elseif e.t=="bool"then
local v=e.get()
button(x2-5,y,v and"OUI"or"NON",v and T.ok or T.bg,v and T.bg or T.dim,function()changeSetting(e,not v)end)
else
local v=e.get()
local shown=cut(v==nil and"-"or(e.f and e.f(v)or tostring(v)),24)
button(x2-3,y,e.t=="num"and"+"or"\16",T.bg,T.text,function()stepSetting(e,1)end)
rightText(x2-5,y,shown,T.accent,T.panel)
button(x2-8-#shown,y,e.t=="num"and"-"or"\17",T.bg,T.text,function()stepSetting(e,-1)end)
end
end
pages.settings=function()
local sw=clamp(math.floor(W*0.28),18,24)
local cat=catById(state.setCat)or CATEGORIES[1]
local rx=sw+3
withSub(rx,8,W-rx+1,H-8,function()
listView("settings:"..cat.id,cat.entries(),5,H-1,2,settingRow)
end)
fill(1,5,sw,H-5,T.panel)
local y=6
local roomy=H-6>=#CATEGORIES+#CAT_GROUPS*2
for _,g in ipairs(CAT_GROUPS)do
if y>H-1 then break end
text(3,y,cut(g[1]:upper(),sw-3),T.dim,T.panel)
y=y+1
for _,id in ipairs(g[2])do
if y>H-1 then break end
local c=catById(id)
local active=id==cat.id
if active then roundFill(2,y,sw-2,1,T.accent)end
catBadge(3,y,id,active and T.bg or T.accent,active and T.accent or T.panel)
text(7,y,cut(c.name,sw-8),active and T.bg or T.text,active and T.accent or T.panel)
addButton(1,y,sw,y,function()state.setCat=id end)
y=y+1
end
if roomy then y=y+1 end
end
fill(rx,5,W-rx+1,3,T.bg)
catBadge(rx,5,cat.id,T.accent,T.bg)
text(rx+4,5,cat.name:upper(),T.text)
local st=CAT_STYLE[cat.id]
text(rx+4,6,cut(st and st[3]or"",W-rx-5),T.dim)
rightText(W-1,5,L"sauvegarde auto",T.dim)
end
DC.settingRow,DC.widgetEntries=settingRow,widgetEntries
end)()
function trendList(x,w,y1,y2,title,list,col)
sectionTitle(x,y1,title,tostring(#list),x+w-1)
local rows=y2-y1
for i=1,math.min(#list,rows)do
local e,yy=list[i],y1+i
local x2=x+w-1
drawIcon(x,yy,e.id,2,1,T.bg)
local rate=fmtSigned(e.rate).."/h"
local delta=fmtSigned(e.delta)
rightText(x2,yy,delta,col)
local rx=x2-#delta-#rate-1
local nameMax=rx-(x+3)-1
if nameMax>=6 then
rightText(x2-#delta-1,yy,rate,T.dim)
else
nameMax=x2-#delta-(x+3)-1
end
text(x+3,yy,cut(e.name,nameMax),T.text)
addButton(x,yy,x2,yy,function()state.popup={kind="item",id=e.id}end)
end
if#list==0 then text(x+1,y1+1,L"Rien",T.dim)end
end
pages.stats=function(d)
local tr=d.trends
if not tr or not tr.ready then
text(2,5,L"Collecte des donnees en cours...",T.dim)
text(2,6,cut(L"Les tendances apparaissent apres ~"..duration(math.max(60,CFG.snapEvery))..".",W-2),T.dim)
return
end
local up,down,sumUp,sumDown={},{},0,0
for _,e in ipairs(tr.list)do
if e.delta>0 then up[#up+1]=e;sumUp=sumUp+e.delta
else down[#down+1]=e;sumDown=sumDown+e.delta end
end
table.sort(up,function(a,b)return a.delta>b.delta end)
table.sort(down,function(a,b)return a.delta<b.delta end)
local net=sumUp+sumDown
local y=cardGrid(5,{
{L"Periode",duration(tr.span),T.accent,nil,L"fenetre "..duration(CFG.trendWindow)},
{L"Entrees",fmtSigned(sumUp),T.ok,nil,fmtSigned(sumUp/tr.span*3600).."/h"},
{L"Sorties",fmtSigned(sumDown),T.bad,nil,fmtSigned(sumDown/tr.span*3600).."/h"},
{L"Bilan",fmtSigned(net),net>=0 and T.ok or T.bad,nil,#tr.list..L" items bougent"},
},4)+1
if W>=60 then
local cw=math.floor((W-3)/2)
trendList(2,cw,y,H-1,L"En hausse",up,T.ok)
trendList(3+cw,W-3-cw,y,H-1,L"En baisse",down,T.bad)
else
local mid=y+math.floor((H-1-y)/2)
trendList(2,W-2,y,mid-1,L"En hausse",up,T.ok)
trendList(2,W-2,mid,H-1,L"En baisse",down,T.bad)
end
end
pages.bays=function(d)
local B=bays()
local drives=d.drives or{}
local pos,extra=bayLayout(drives)
local nDrives,nDisks,capItems,slotsTotal,present_=0,0,0,0,{}
for _,slots in pairs(drives)do
nDrives=nDrives+1
slotsTotal=slotsTotal+B.slots
for i=1,B.slots do
local sl=slots[i]
if sl then
nDisks=nDisks+1
local di=diskInfo(sl.name)
present_[di.kind=="items"and di.label or di.kind]=di.color
if di.kind=="items"and di.cap then capItems=capItems+di.cap end
end
end
end
local y=5
if state.assign then
fill(2,y,W-3,1,colors.purple)
local msg=L"Retire ou ajoute un disque dans la baie "..posName(state.assign.pos)
text(3,y,cut(msg,W-26),T.text,colors.purple)
button(W-12,y,L"Terminer",T.ok,T.bg,finishAssign)
button(W-21,y,L"Passer",T.panel,T.text,nextAssign)
else
local info=nDrives..L" drive(s)  \183  "..nDisks.."/"..slotsTotal
..L" disques  \183  capacite items "..fmt(capItems)
..(extra>0 and("  \183  "..extra..L" hors grille")or"")
if state.drivesAt then info=info.."  \183  lu il y a "..duration(now()-state.drivesAt)end
text(2,y,cut(info,W-29),T.dim)
button(W-26,y,L"Actualiser",T.panel,T.text,function()
state.forceDrives=true;state.forceRefresh=true;notify(L"Lecture des baies...")
end)
button(W-13,y,L"Identifier",colors.purple,T.text,function()startAssign(d)end)
end
local lx=2
local legend={}
for _,k in ipairs(DISK_ORDER)do if present_[k]then legend[#legend+1]={k,present_[k]}end end
for _,k in ipairs({"inf","fluide","chimie","?"})do if present_[k]then legend[#legend+1]={k,present_[k]}end end
legend[#legend+1]={L"vide",T.bg}
for _,l in ipairs(legend)do
if lx+#l[1]+3>W-1 then break end
fill(lx,y+1,2,1,l[2])
if l[1]==L"vide"then text(lx,y+1,"\183",T.dim,T.bg)end
text(lx+3,y+1,l[1],T.dim)
lx=lx+#l[1]+5
end
local gy=y+3
local avail=H-1-gy+1
local rowH=math.floor((avail+1)/B.rows)
local cw=math.floor((W-1)/B.cols)
if rowH<2 or cw<10 then
text(2,gy,L"Ecran trop petit pour la grille (baisse CFG.scale)",T.bad)
return
end
local perRow
if rowH>=2+math.ceil(B.slots/2)then perRow=2
elseif rowH>=2+math.ceil(B.slots/4)then perRow=4
else perRow=B.slots end
for p=1,B.cols*B.rows do
local c=(p-1)%B.cols
local r=math.floor((p-1)/B.cols)
local n=pos[p]
drawDriveTile(p,n,n and drives[n],2+c*cw,gy+r*rowH,cw-1,perRow)
end
end
;(function()
local function popupFrame(title,pw,ph,titleCol,anchor)
addButton(1,1,W,H,function()state.popup=nil end)
pw,ph=math.min(W-4,pw),math.min(H-2,ph)
local px,py
if anchor=="br"then
px,py=W-pw,H-ph
else
px,py=math.floor((W-pw)/2)+1,math.floor((H-ph)/2)+1
end
addButton(px,py,px+pw-1,py+ph-1,function()end)
titleCol=titleCol or T.accent
local oTL,oTR=bgAt(px,py),bgAt(px+pw-1,py)
local oBL,oBR=bgAt(px,py+ph-1),bgAt(px+pw-1,py+ph-1)
fill(px,py,pw,ph,T.panel)
fill(px,py,pw,1,titleCol)
if S("rounded")then
corner(px,py,"tl",titleCol,oTL);corner(px+pw-1,py,"tr",titleCol,oTR)
corner(px,py+ph-1,"bl",T.panel,oBL);corner(px+pw-1,py+ph-1,"br",T.panel,oBR)
end
text(px+1,py,cut(title,pw-5),T.bg,titleCol)
button(px+pw-3,py,"x",titleCol,T.bg,function()state.popup=nil end)
return px,py,pw,ph
end
local function itemGraph(x,y,cw,ch,id,count,col,bgc)
local series={}
for _,v in ipairs(Snap.series(id))do series[#series+1]=v end
series[#series+1]=count
local lo,hi=math.huge,-math.huge
for _,v in ipairs(series)do lo=math.min(lo,v);hi=math.max(hi,v)end
local pw,ph,n=cw*2,ch*3,#series
drawPixels(x,y,cw,ch,function(px,py)
local idx=math.floor((px-1)/pw*n)+1
local v=series[idx]
if not v then return bgc end
local r=(hi>lo)and(0.08+0.92*(v-lo)/(hi-lo))or 0.5
local hgt=math.max(1,math.floor(r*ph+0.5))
local fromBottom=ph-py
if fromBottom==hgt-1 then return colors.white end
if fromBottom<hgt then return col end
return bgc
end)
return lo,hi,n
end
function itemPopup(id)
local d=state.data
local it=d and d.byId[id]
if not it then state.popup=nil;return end
local px,py,pw,ph=popupFrame(it.name,52,22)
local pinned=isPinned(it.id)
local pl=pinned and L"\4 Epingle"or L"Epingler"
button(px+pw-4-#pl-2,py,pl,pinned and colors.yellow or T.panel,pinned and T.bg or T.text,
function()togglePin(it)end)
drawIcon(px+2,py+2,it.id,8,6,T.panel)
local tx=px+12
text(tx,py+2,cut(it.id,pw-13),T.dim,T.panel)
local stacks=(it.maxStack and it.maxStack>0)
and(math.ceil(it.count/it.maxStack).." x "..it.maxStack)or"?"
local te=d.trends and d.trends.ready and d.trends.byId[it.id]
local cats={}
for c in pairs(it.cats or{})do cats[#cats+1]=c end
table.sort(cats)
local busy=it.craftable and isCrafting(it.id)
local lines={
{L"Quantite",fmt(it.count)..(it.count>=1000 and(" ("..it.count..")")or"")},
{L"Stacks",stacks},
{L"Part",d.total>0 and("%.2f%%"):format(it.count/d.total*100)or"?"},
{L"Craftable",it.craftable and(busy and L"oui - craft en cours"or L"oui")or L"non",busy and T.warn},
{L"Tendance",te and(fmtSigned(te.delta).." ("..fmtSigned(te.rate).."/h)")or L"stable",
te and(te.delta>=0 and T.ok or T.bad)},
{L"Inactif",it.idle and duration(it.idle)or"?",it.dormant and T.warn},
{L"Categories",#cats>0 and table.concat(cats,", ")or"-"},
}
for i,l in ipairs(lines)do
text(tx,py+3+i,l[1],T.dim,T.panel)
text(tx+11,py+3+i,cut(l[2],pw-24),l[3]or T.text,T.panel)
end
local function ruleLine(y,kind,label)
local list=kind=="max"and store.maxRules or store.rules
local r=findRule(list,it.id)
local field=kind=="max"and"max"or"min"
text(px+2,y,label,T.dim,T.panel)
if r then
local v=fmt(r[field])
text(px+13,y,v,T.text,T.panel)
local bx=px+13+#v+1
bx=bx+button(bx,y,"-",T.bg,T.text,function()
r[field]=math.max(kind=="max"and 0 or 1,r[field]-r.step);pcall(saveStore)end)+1
bx=bx+button(bx,y,"+",T.bg,T.text,function()r[field]=r[field]+r.step;pcall(saveStore)end)+1
button(bx,y,L"retirer",T.bad,T.text,function()removeRule(kind,it.id)end)
else
button(px+13,y,L"+ definir",kind=="max"and colors.magenta or colors.purple,T.text,
function()addRule(kind,it)end)
end
end
local gTop,gBot=py+12,py+ph-7
if gBot-gTop>=1 then
local gh=gBot-gTop
local lo,hi,n=itemGraph(px+2,gTop+1,pw-4,gh,it.id,it.count,T.accent,T.bg)
local span=n>1 and duration((n-1)*CFG.snapEvery)or"-"
text(px+2,gTop,cut(L"Stock sur "..span..L"  \183  min "..fmt(lo)..L"  \183  max "..fmt(hi),pw-4),T.dim,T.panel)
end
if it.craftable then ruleLine(py+ph-5,"min",L"Stock min")end
ruleLine(py+ph-4,"max",L"Stock max")
local by=py+ph-2
if it.craftable then
text(px+2,by,L"Crafter",T.dim,T.panel)
local bx=px+13
for _,n in ipairs({1,16,64})do
bx=bx+button(bx,by,"x"..n,T.accent,T.bg,function()craft(it,n)end)+1
end
else
text(px+2,by,cut(L"Pas de pattern pour cet item",pw-4),T.dim,T.panel)
end
end
function alertsPopup()
local A,TLOG=state.alerts,state.toastLog
local nRecent=math.min(#TLOG,6)
local ph=4+math.max(1,#A)+(nRecent>0 and nRecent+2 or 0)
local px,py,pw,ph2=popupFrame(L"Centre des alertes ("..#A..")",56,ph,#A>0 and T.bad or T.accent,"br")
local y=py+2
if#A==0 then text(px+2,y,L"Aucune alerte en cours",T.ok,T.panel);y=y+1 end
for _,a in ipairs(A)do
if y>py+ph2-2 then break end
text(px+2,y,"\7",a.lvl>=2 and T.bad or T.warn,T.panel)
text(px+4,y,cut(a.msg,pw-6),T.text,T.panel)
y=y+1
end
if nRecent>0 and y+2<=py+ph2-1 then
y=y+1
text(px+2,y,L"Notifications recentes",T.dim,T.panel)
y=y+1
for i=#TLOG,#TLOG-nRecent+1,-1 do
if y>py+ph2-1 then break end
local e=TLOG[i]
local ts=os.date("%H:%M",math.floor(e.at))
text(px+2,y,ts,T.dim,T.panel)
text(px+8,y,cut(e.msg,pw-10),e.lvl=="err"and T.bad or T.text,T.panel)
y=y+1
end
end
end
function filtersPopup()
local d=state.data
local catCount,modCount={},{}
for _,it in ipairs(d.items)do
for c in pairs(it.cats or{})do catCount[c]=(catCount[c]or 0)+1 end
modCount[it.mod]=(modCount[it.mod]or 0)+1
end
local general={{L"Tout",nil,#d.items},{L"Epingles",{kind="pinned"},#store.pins},
{L"Dormants",{kind="dormant"},d.dormantCount or 0}}
local catOpts={}
for _,c in ipairs(CATS)do
if catCount[c[1]]then catOpts[#catOpts+1]={c[1],{kind="cat",key=c[1]},catCount[c[1]]}end
end
local mods={}
for m,n in pairs(modCount)do mods[#mods+1]={m,{kind="mod",key=m},n}end
table.sort(mods,function(a,b)return a[3]>b[3]end)
local px,py,pw,ph=popupFrame(L"Filtrer les items",64,H-4)
local y=py+2
local function flow(title,list)
if#list==0 or y>py+ph-2 then return end
text(px+2,y,title,T.dim,T.panel);y=y+1
local x=px+2
for _,o in ipairs(list)do
local lab=o[1].." "..o[3]
if x+#lab+2>px+pw-1 then x=px+2;y=y+1 end
if y>py+ph-2 then break end
local f=state.filter
local active=(not f and not o[2])or(f and o[2]and f.kind==o[2].kind and f.key==o[2].key)
x=x+button(x,y,lab,active and T.accent or T.bg,active and T.bg or T.text,function()
state.filter=o[2];state.scroll={};state.popup=nil
end)+1
end
y=y+2
end
flow(L"General",general)
if#catOpts==0 then
text(px+2,y,L"Aucune categorie (ta version ne fournit pas les tags ?)",T.dim,T.panel);y=y+2
else
flow(L"Categories (tags)",catOpts)
end
flow(L"Mods",mods)
end
function drivePopup(pp)
local d=state.data
local slots=d.drives and d.drives[pp.name]
if not slots then state.popup=nil;return end
local B=bays()
local px,py,pw,ph=popupFrame(L"Baie "..posName(pp.pos),46,B.slots+6)
text(px+2,py+2,cut(pp.name,pw-4),T.dim,T.panel)
local cap,n=0,0
for i=1,B.slots do
local sl,yy=slots[i],py+3+i
text(px+2,yy,tostring(i),T.dim,T.panel)
if sl then
n=n+1
local di=diskInfo(sl.name)
fill(px+5,yy,6,1,di.color)
text(px+5+math.floor((6-#di.label)/2),yy,cut(di.label,6),T.bg,di.color)
text(px+13,yy,cut(prettify(sl.name),pw-15),T.text,T.panel)
if di.kind=="items"and di.cap then cap=cap+di.cap end
else
text(px+5,yy,L"vide",T.dim,T.panel)
end
end
text(px+2,py+ph-2,cut(n.."/"..B.slots..L" disques  \183  capacite items "..fmt(cap),pw-4),T.dim,T.panel)
end
function wrap(str,width)
local lines,line={},""
for word in str:gmatch("%S+")do
if#line==0 then line=word
elseif#line+1+#word<=width then line=line.." "..word
else lines[#lines+1]=line;line=word end
end
if#line>0 then lines[#lines+1]=line end
return lines
end
function newsPopup(pp)
local blocks={}
for _,v in ipairs(CHANGELOG)do
if pp.all or(pp.from and cmpVer(v[1],pp.from)==1)or(not pp.from and v[1]==VERSION)then
blocks[#blocks+1]=v
end
end
local px,py,pw,ph=popupFrame(L"Nouveautes - v"..VERSION,60,H-4)
local y,bottom=py+2,py+ph-3
for _,b in ipairs(blocks)do
if y>bottom then break end
text(px+2,y,L"Version "..b[1],T.accent,T.panel)
y=y+1
for _,item in ipairs(b[2])do
for i,l in ipairs(wrap(item,pw-7))do
if y>bottom then break end
if i==1 then text(px+2,y,"\7",T.ok,T.panel)end
text(px+4,y,l,T.text,T.panel)
y=y+1
end
end
y=y+1
end
button(px+math.floor((pw-9)/2),py+ph-2,L"Compris",T.accent,T.bg,function()state.popup=nil end)
end
end)()
;(function()
function tabsList(d)
local t={{"home",L"Accueil"},{"items",L"Items"}}
if d and present(d.fluids)then t[#t+1]={"fluids",L"Fluides"}end
if d and present(d.chems)then t[#t+1]={"chems",L"Chimie"}end
t[#t+1]={"mosaic",L"Mosaique"}
t[#t+1]={"usage",L"Usage"}
if d and(d.drives or(DC.hasBays and DC.hasBays()))then t[#t+1]={"bays",L"Baies"}end
if DC.page then t[#t+1]={"dc",L"Data center"}end
t[#t+1]={"crafts",L"Crafts"}
t[#t+1]={"auto",L"Auto"}
t[#t+1]={"stats",L"Stats"}
t[#t+1]={"journal",L"Journal"}
return t
end
local TAB_ICONS={
dc="\22",home="\30",items="\4",fluids="\9",chems="\5",usage="\18",bays="\8",mosaic="\127",
crafts="\15",auto="\23",stats="\24",journal="\20",
}
local function sideWidth(tabs)
local m=0
for _,tb in ipairs(tabs)do m=math.max(m,#tb[2])end
return m+4+(S("tabIcons")and 2 or 0)
end
function layout(tabs)
local pos=S("toolbar")
if pos=="bas"then return{x=1,y=3,w=W,h=H-6,pos=pos}end
if pos=="gauche"or pos=="droite"then
local sw=sideWidth(tabs)
if pos=="gauche"then return{x=sw+2,y=3,w=W-sw-1,h=H-3,pos=pos,sw=sw}end
return{x=1,y=3,w=W-sw-1,h=H-3,pos=pos,sw=sw}
end
return{x=1,y=5,w=W,h=H-5,pos="haut"}
end
local function tabClick(id)
return function()if state.tab~=id then state.tab=id;state.popup=nil end end
end
function drawTabs(tabs,LY)
if LY.pos=="haut"or LY.pos=="bas"then
local icons=S("tabIcons")
local function width(ic,short)
local t=0
for _,tb in ipairs(tabs)do t=t+(short and 4 or#tb[2])+3+(ic and 2 or 0)end
return t
end
local short=false
if icons and width(true,false)>W-1 then icons=false end
if width(icons,false)>W-1 then short=true end
local top=LY.pos=="haut"
local ly,uy=top and 2 or H-1,top and 3 or H-2
local line=top and"\131"or"\140"
fill(1,ly,W,1,T.bg)
text(1,uy,line:rep(W),T.panel,T.bg)
local x=2
for _,tb in ipairs(tabs)do
local id=tb[1]
local label=short and tb[2]:sub(1,4)or tb[2]
if icons then label=(TAB_ICONS[id]or"\7").." "..label end
local active=id==state.shownTab
local w=#label+2
if x+w-1>W then break end
if active then
roundFill(x,ly,w,1,T.panel)
text(x+1,ly,label,T.text,T.panel)
if icons then text(x+1,ly,TAB_ICONS[id]or"\7",T.accent,T.panel)end
text(x,uy,line:rep(w),T.accent,T.bg)
else
text(x+1,ly,label,T.dim,T.bg)
end
addButton(x,math.min(ly,uy),x+w-1,math.max(ly,uy),tabClick(id))
x=x+w+1
end
else
local sw,left=LY.sw,LY.pos=="gauche"
local x0=left and 1 or(W-sw+1)
local sep=left and(sw+1)or(W-sw)
fill(x0,2,sw,H-2,T.panel)
for yy=2,H-1 do
if left then text(sep,yy,"\149",T.panel,T.bg)else text(sep,yy,"\149",T.bg,T.panel)end
end
local icons=S("tabIcons")
local step=(#tabs*2<=H-3)and 2 or 1
for i,tb in ipairs(tabs)do
local y=3+(i-1)*step
if y>H-1 then break end
local id=tb[1]
local active=id==state.shownTab
local bg=active and T.accent or T.panel
if active then roundFill(x0+1,y,sw-2,1,bg)end
local tx=x0+2
if icons then
text(tx,y,TAB_ICONS[id]or"\7",active and T.bg or T.accent,bg)
tx=tx+2
end
text(tx,y,cut(tb[2],sw-(tx-x0)-1),active and T.bg or T.text,bg)
addButton(x0,y,x0+sw-1,y,tabClick(id))
end
end
end
function drawHeader(d)
fill(1,1,W,1,T.panel)
text(2,1,"\4",T.accent,T.panel)
text(4,1,"RSTools",T.text,T.panel)
text(12,1,"by Ventura",T.dim,T.panel)
local inSettings=state.tab=="settings"
button(W-2,1,"\15",inSettings and T.accent or T.panel,inSettings and T.bg or T.text,function()
state.tab=inSettings and"home"or"settings";state.popup=nil
end)
local t=os.date("%H:%M")
rightText(W-4,1,t,T.dim,T.panel)
local on=d and d.online
local st=on==nil and"?"or(on and L"en ligne"or L"hors ligne")
local sc=on==nil and T.dim or(on and T.ok or T.bad)
local sx=W-4-#t-#st-4
if sx>24 then text(sx,1,"\7 "..st,sc,T.panel)end
end
function drawFooter(d)
fill(1,H,W,1,T.panel)
local n=#state.alerts
local lab=n>0 and("! "..n..L" alerte"..(n>1 and"s"or""))or L"\7 aucune alerte"
local bw=#lab+2
button(W-bw+1,H,lab,n>0 and T.bad or T.panel,n>0 and T.text or T.dim,
function()state.popup={kind="alerts"}end)
if state.input then
text(2,H,cut(L"Saisie en cours : clavier virtuel ou clavier de l'ordi, Entree = valider",W-bw-3),T.warn,T.panel)
return
end
local left=L"Dernier changement "..state.lastChange..(d and("  \183  "..d.types..L" types")or"")
if d and d.stale then left=L"LECTURE EN ECHEC - donnees de "..state.lastUpdate
elseif d and d.degraded then left=L"MODE SECOURS (item par item)  \183  "..state.lastChange end
text(2,H,cut(left,W-bw-3),T.dim,T.panel)
if state.msg and os.clock()-state.msgTime<6 then
local m=cut(state.msg,W-bw-#left-8)
if#m>0 then rightText(W-bw-2,H,m,T.warn,T.panel)end
end
end
function drawToasts()
local t,dur=os.clock(),S("toastDur")
local live={}
for _,x in ipairs(state.toasts)do if t-x.t<dur then live[#live+1]=x end end
state.toasts=live
local tw=math.min(46,W-4)
local tx=W-tw
local y=H-1
for i=#live,1,-1 do
local x=live[i]
local col=(x.lvl=="err"or x.lvl==2)and T.bad or T.warn
local lines=wrap(x.msg,tw-4)
local nl=math.min(2,#lines)
local h=nl+2
local top=y-h+1
if top<3 then break end
roundFill(tx,top,tw,h,T.panel,col)
text(tx+2,top,x.lvl=="err"and"ERREUR"or"ALERTE",col,T.panel)
rightText(tx+tw-2,top,L"toucher = details",T.dim,T.panel)
for k=1,nl do text(tx+2,top+k,cut(lines[k],tw-3),T.text,T.panel)end
slimBar(tx+2,top+h-1,tw-4,1-(t-x.t)/dur,col,T.panel,T.bg)
addButton(tx,top,tx+tw-1,top+h-1,function()state.popup={kind="alerts"}end)
y=top-1
end
end
end)()
;(function()
local KB_ROWS=LANG=="en"
and{"1234567890","qwertyuiop","asdfghjkl-","zxcvbnm._/:"}
or{"1234567890","azertyuiop","qsdfghjklm","wxcvbn.-_/:"}
local function kbType(ch)
if state.input then state.input.buf=state.input.buf..ch
else state.search=state.search..ch;state.scroll={}end
end
local function kbBack()
if state.input then state.input.buf=state.input.buf:sub(1,-2)
else state.search=state.search:sub(1,-2);state.scroll={}end
end
local function kbClear()
if state.input then state.input.buf=""else state.search="";state.scroll={}end
end
local function kbOk()
if state.input then
local inp=state.input
if inp.commit then inp.commit(inp.buf)
else setS(inp.key,inp.key=="repoUrl"and normUrl(inp.buf)or inp.buf)end
state.input=nil
notify(L"Enregistre")
end
state.kb=false
end
function drawKeyboard()
local kh=({normal=1,grand=2,["tres grand"]=3})[S("kbSize")]or 2
local maxW=({normal=5,grand=7,["tres grand"]=9})[S("kbSize")]or 7
while kh>1 and 6+5*kh>H-8 do kh=kh-1 end
local total=6+5*kh
local ky=H-total
if ky<4 then return end
fill(1,ky,W,total,T.panel)
addButton(1,ky,W,H-1,function()end)
local label=state.input and"URL"or L"Recherche"
local cur=(state.input and state.input.buf or state.search).."_"
text(2,ky,label.." :",T.dim,T.panel)
local room=W-#label-11
if room>0 then text(#label+5,ky,cur:sub(-room),T.text,T.panel)end
button(W-4,ky,"x",T.bad,T.text,function()state.kb=false end)
local keyW=clamp(math.floor((W-2+1)/11)-1,3,maxW)
local mid=math.floor((kh-1)/2)
local y=ky+2
for _,row in ipairs(KB_ROWS)do
local x=math.floor((W-(#row*(keyW+1)-1))/2)+1
for i=1,#row do
local ch=row:sub(i,i)
if state.kbUpper then ch=ch:upper()end
roundFill(x,y,keyW,kh,T.bg)
centerText(x,keyW,y+mid,ch,T.text,T.bg)
addButton(x,y,x+keyW-1,y+kh-1,function()kbType(ch)end)
x=x+keyW+1
end
y=y+kh+1
end
local keys_={
{LANG=="en"and"shift"or"maj",function()state.kbUpper=not state.kbUpper end,state.kbUpper and T.accent or T.bg,1},
{L"    espace    ",function()kbType(" ")end,T.bg,3},
{L"\27 effacer",kbBack,T.bg,2},
{L"vider",kbClear,T.bg,1},
{"OK",kbOk,T.ok,1},
}
local weights=0
for _,k in ipairs(keys_)do weights=weights+k[4]end
local avail=W-2-(#keys_-1)
local x=2
for i,k in ipairs(keys_)do
local w=(i==#keys_)and(W-1-x+1)or math.max(#k[1]+2,math.floor(avail*k[4]/weights))
roundFill(x,y,w,kh,k[3])
centerText(x,w,y+mid,k[1],k[3]==T.bg and T.text or T.bg,k[3])
addButton(x,y,x+w-1,y+kh-1,k[2])
x=x+w+1
end
end
end)()
function render(sub)
buttons={}
OX,OY=0,0
win.setVisible(false)
win.setBackgroundColor(T.bg);win.clear()
if sub and(W<MIN_W or H<MIN_H)then
text(1,1,L"Ecran trop petit",T.bad)
text(1,2,L"Reduis la taille",T.text)
text(1,3,L"du texte",T.text)
win.setVisible(true)
return
end
if W<MIN_W or H<MIN_H then
text(1,1,L"Ecran trop petit",T.bad)
text(1,2,L"Toucher pour",T.text)
text(1,3,L"reinitialiser",T.text)
text(1,4,L"la taille",T.text)
addButton(1,1,math.max(W,1),math.max(H,1),function()
store.settings.scale=nil
pcall(saveStore)
setupMain();setupWidgets()
notify(L"Taille du texte reinitialisee")
end)
win.setVisible(true)
return
end
local d=state.data
local tabs=tabsList(d)
local shown=state.tab
if shown~="settings"then
local found=false
for _,tb in ipairs(tabs)do if tb[1]==shown then found=true end end
if not found then shown="home"end
end
state.shownTab=shown
local LY=layout(tabs)
if d then
local ok,err=pcall(withSub,LY.x,LY.y,LY.w,LY.h,pages[shown],d)
if not ok then text(LY.x+1,LY.y,cut(L"Erreur : "..tostring(err),LY.w-2),T.bad)end
else
text(LY.x+1,LY.y,L"Chargement...",T.dim)
end
drawHeader(d)
drawTabs(tabs,LY)
drawFooter(d)
if state.kb then
local okK,errK=pcall(drawKeyboard)
if not okK then state.kb=false;notify(tostring(errK))end
end
if d and state.popup then
local ok2,err2=pcall(function()
local k=state.popup.kind
if k=="alerts"then alertsPopup()
elseif k=="drive"then drivePopup(state.popup)
elseif k=="filters"then filtersPopup()
elseif k=="news"then newsPopup(state.popup)
else itemPopup(state.popup.id)end
end)
if not ok2 then state.popup=nil;notify(tostring(err2))end
end
pcall(drawToasts)
win.setVisible(true)
if not sub then renderWidgets(d)end
end
function pruneCaches()
local c,t=os.clock(),now()
for k,ic in pairs(state.iconCache)do if c-(ic.used or 0)>600 then state.iconCache[k]=nil end end
for id,e in pairs(state.pool)do if t-(e.seen or 0)>600 then state.pool[id]=nil end end
Snap.serCache={}
state.fsCache,state.mosCache=nil,nil
state.lastPrune=t
end
function refresh()
local ok,d=pcall(collect)
if not ok then toast(L"Erreur de lecture : "..tostring(d),"err");return end
if d.readError then
if not state.readFailing then
logEvent("systeme",L"Lecture des items impossible : "..d.readError,2)
toast(L"Lecture des items impossible ("..d.readError..L") - dernieres donnees conservees","err")
end
state.readFailing=true
local good=state.lastGood
if good then
for _,k in ipairs({"items","crafts","byId","types","total"})do d[k]=good[k]end
end
d.stale=true
else
state.lastGood=d
if d.degraded then
local names={}
for _,b in ipairs(d.blocked or{})do names[#names+1]=d.byId[b.id].name end
local key=table.concat(names,",")
if state.degradedKey~=key then
local msg=#names>0 and(L"Item ignore (bloque la lecture) : "..table.concat(names,", ")
..L" - sors-le du reseau")or L"Lecture en mode secours (item bloquant inconnu)"
logEvent("systeme",msg,1)
toast(msg,1)
state.degradedKey=key
end
elseif state.degradedKey then
logEvent("systeme",L"Liste complete de nouveau lisible, fin du mode secours",0)
state.degradedKey=nil
end
if state.readFailing then logEvent("systeme",L"Lecture des items retablie",0)end
state.readFailing=false
state.lastUpdate=os.date("%H:%M:%S")
if d.types==0 then notify(L"0 item lu - reseau vide ?")end
end
local t=now()
local fresh=false
if state.assign or state.forceDrives or not state.drivesAt or t-state.drivesAt>=S("baysEvery")then
state.drivesCache=readDrives()
state.drivesAt,state.forceDrives,fresh=t,false,true
end
d.drives=state.drivesCache
if fresh and d.drives then
local p={}
for n,sl in pairs(d.drives)do
p[#p+1]=n
for i=1,CFG.baySlots do p[#p+1]=sl[i]and sl[i].name or"-"end
end
table.sort(p)
state.drivesSig=table.concat(p,",")
end
if(not d.max or d.max<=0)and d.drives then
local cap=0
for _,slots in pairs(d.drives)do
for _,sl in pairs(slots)do
local di=diskInfo(sl.name)
if di.kind=="items"and di.cap then cap=cap+di.cap end
end
end
if cap>0 then d.max,d.maxFromDrives=cap,true end
end
d.capKnown=d.max and d.max>0
if t-state.lastGraph>=CFG.graphEvery then
if d.max and d.max>0 then pushHist(store.histStorage,d.used/d.max)end
if d.energy and d.maxEnergy and d.maxEnergy>0 then pushHist(store.histEnergy,d.energy/d.maxEnergy)end
state.lastGraph=t
state.dirty=true
end
local cur=countsOf(d)
if d.types>0 and not d.stale then
updateDormancy(d,cur)
if Snap.count()==0 or t-Snap.lastTime()>=CFG.snapEvery then takeSnapshot(cur)end
detectAnomalies(d,cur)
end
d.trends=computeTrends(d,cur)
if t-(state.lastPrune or t)>=300 or not state.lastPrune then
if state.lastPrune then pruneCaches()else state.lastPrune=t end
end
d.forecast=forecast(store.histStorage)
if fresh then
checkAssign(d.drives)
if not state.assign then logBayChanges(d.drives)end
end
if not d.stale then
local okA,errA=pcall(runAuto,d)
if not okA then toast(L"Erreur stock min : "..tostring(errA),"err")end
local okM,errM=pcall(runMax,d)
if not okM then toast(L"Erreur stock max : "..tostring(errM),"err")end
end
d.running=collectRunning(d)
detectFinished(d,d.running)
state.data=d
updateAlerts(d)
local parts={d.types,d.total,d.hash,tostring(d.used),tostring(d.max),tostring(d.usage),tostring(d.online),
d.maxEnergy and d.maxEnergy>0 and math.floor(d.energy/d.maxEnergy*200)or"-",
d.dormantCount or 0,(forecastText(d.forecast,d)),tostring(d.stale),tostring(d.degraded),
state.drivesSig or"",d.fluids and d.fluids.total or 0,d.chems and d.chems.total or 0}
for _,a in ipairs(state.alerts)do parts[#parts+1]=a.key end
for _,e in ipairs(d.running)do parts[#parts+1]=e.id..(e.count or"")end
local sig=table.concat(parts,"|")
if sig~=state.lastSig then
state.lastSig=sig
state.dataVersion=state.dataVersion+1
state.lastChange=os.date("%H:%M:%S")
state.dataChanged=true
end
if S("autoUpdate")and t-state.lastUpdateCheck>=CFG.updateEvery then pcall(checkUpdate,false)end
if state.dirty and t-state.lastSave>=CFG.saveEvery then
local okS,errS=pcall(saveData)
if not okS then toast(L"Erreur de sauvegarde : "..tostring(errS),"err")end
end
end
function handleKey(e)
if state.input then
local inp=state.input
if e[1]=="char"or e[1]=="paste"then inp.buf=inp.buf..e[2]
elseif e[1]=="key"and e[2]==keys.backspace then inp.buf=inp.buf:sub(1,-2)
elseif e[1]=="key"and(e[2]==keys.enter or e[2]==keys.numPadEnter)then
if inp.commit then inp.commit(inp.buf)else setS(inp.key,inp.key=="repoUrl"and normUrl(inp.buf)or inp.buf)end
state.input=nil;state.kb=false;notify(L"Enregistre")
end
return
end
if e[1]=="char"or e[1]=="paste"then
state.search=state.search..e[2];state.scroll={}
elseif e[1]=="key"then
if e[2]==keys.backspace then state.search=state.search:sub(1,-2);state.scroll={}
elseif e[2]==keys.enter then state.search="";state.scroll={}end
end
end
;(function()
local LOGO={
".......aa.......",".....aaaaaa.....","...aaaaaaaaaa...",".aaaaaaaaaaaaaa.",
"baaaaaaaaaaaaaac","bbbaaaaaaaaaaccc","bbbbbaaaaaaccccc","bbbbbbbaaccccccc",
"bbbbbbbbcccccccc","bbbbbbbbcccccccc","bbbbbbbbcccccccc","bbbbbbbbcccccccc",
"bbbbbbbbcccccccc",".bbbbbbbccccccc.","...bbbbbccccc...",".....bbbccc.....",
".......bc.......","................",
}
local boot={reveal=18,letters=7}
function drawBoot(prog,label)
win.setVisible(false)
win.setBackgroundColor(T.bg);win.clear()
local ly=math.max(1,math.floor(H/2)-8)
local lx=math.floor(W/2)-3
local map={a=colors.white,b=T.accent,c=colors.blue}
drawPixels(lx,ly,8,6,function(px,py)
if py>boot.reveal then return T.bg end
local row=LOGO[py]
return row and map[row:sub(px,px)]or T.bg
end)
if boot.letters>0 then centerText(1,W,ly+7,"V  E  N  T  U  R  A",T.dim)end
local title="RSTOOLS"
local bx=math.floor((W-bigWidth(title,1))/2)+1
local shown=title:sub(1,boot.letters)
if#shown>0 then bigText(bx,ly+8,shown,T.text,T.bg,1)end
if boot.letters>=#title then centerText(1,W,ly+11,L"Tableau de bord Refined Storage  \183  v"..VERSION,T.dim)end
if prog then
local bw=math.min(40,W-10)
local bx2=math.floor((W-bw)/2)+1
slimBar(bx2,ly+13,bw,prog,T.accent,T.bg,T.panel)
centerText(1,W,ly+14,label or"",T.dim)
end
win.setVisible(true)
end
local function drawBootBay(k)
for n,wd in pairs(widgets)do
if store.widgets[n]and store.widgets[n].type=="baies"then
local sWin,sW,sH=win,W,H
win,W,H=wd.win,wd.W,wd.H
win.setVisible(false)
win.setBackgroundColor(T.bg);win.clear()
local cols=bays().cols
local cw=W/cols
for c=1,cols do
local x1=math.floor((c-1)*cw)+1
local w=math.max(1,math.floor(c*cw)-x1)
local bgc=(c==k)and T.accent or((c<k)and T.panel or T.bg)
fill(x1,1,w,H,bgc)
centerText(x1,w,math.ceil(H/2),string.char(64+c),c==k and T.bg or(c<k and T.text or T.panel),bgc)
end
win.setVisible(true)
win,W,H=sWin,sW,sH
end
end
end
function bootNotes(list)
if not S("sounds")then return end
local sp=peripheral.find("speaker")
if not sp then return end
for _,n in ipairs(list)do pcall(sp.playNote,n[1],math.min(3,n[2]*S("volume")),n[3])end
end
function bootAnimation()
if not S("bootAnim")or W<39 or H<19 then return false end
local arpeggio={6,10,13,18}
boot.reveal,boot.letters=0,0
for f=1,12 do
boot.reveal=math.floor(f/12*#LOGO+0.5)
drawBoot()
drawBootBay(math.floor(f/12*bays().cols+0.5))
if f%3==0 then bootNotes({{"bell",0.8,arpeggio[math.floor(f/3)]}})end
sleep(0.05)
end
for i=1,7 do boot.letters=i;drawBoot();sleep(0.05)end
drawBoot(0,L"Demarrage...")
return true
end
end)()
function dataLoop()
local nextRefresh=now()+S("refresh")
while not state.restart do
sleep(1)
if state.forceRefresh or now()>=nextRefresh or state.assign then
local full=state.forceRefresh or now()>=nextRefresh
state.forceRefresh=false
if full then
local ok,err=pcall(refresh)
if not ok then toast(L"Erreur : "..tostring(err),"err");state.dataChanged=true end
nextRefresh=now()+S("refresh")
else
local dr=readDrives()
state.drivesCache,state.drivesAt=dr,now()
if state.data then state.data.drives=dr end
checkAssign(dr)
state.dataChanged=true
end
if state.dataChanged then
state.dataChanged=false
os.queueEvent("rstools_data")
if DC.onData then pcall(DC.onData)end
end
end
end
end
VIEW_KEYS={"tab","popup","input","search","scroll","sort","filter","kb","kbUpper","stick","mosZoom",
"bayView","dcSel","logFilter","autoView","setCat","shownTab"}
screens={}
function isScreen(n)
local c=store.widgets[n]
return c and c.type=="ecran"and widgets[n]~=nil
end
function inScreen(n,fn)
local w=widgets[n]
local v=screens[n]
if not v then
v={tab="home",scroll={},search="",sort="count",stick={},kb=false,kbUpper=false,
logFilter="all",autoView="min",setCat="apparence"}
screens[n]=v
end
local sWin,sW,sH,sB=win,W,H,buttons
win,W,H,buttons=w.win,w.W,w.H,w.buttons or{}
for _,k in ipairs(VIEW_KEYS)do state[k],v[k]=v[k],state[k]end
local ok,err=pcall(fn)
for _,k in ipairs(VIEW_KEYS)do state[k],v[k]=v[k],state[k]end
w.buttons=buttons
win,W,H,buttons=sWin,sW,sH,sB
if not ok then notify(n.." : "..tostring(err))end
end
function renderScreens()
for n in pairs(widgets)do
if isScreen(n)then inScreen(n,function()render(true)end)end
end
end
function uiLoop()
checkScreens()
render()
renderScreens()
state.lastClock=os.date("%H:%M")
local tick=os.startTimer(1)
while not state.restart do
local e={os.pullEvent()}
local dirty=false
if e[1]=="timer"and e[2]==tick then
tick=os.startTimer(1)
checkScreens()
local clock=os.date("%H:%M")
if clock~=state.lastClock then state.lastClock=clock;dirty=true end
if#state.toasts>0 or state.toastsShown then dirty=true end
if state.msgShown and os.clock()-state.msgTime>=6 then dirty=true end
if state.msg and state.msgTime~=state.msgDrawn and os.clock()-state.msgTime<6 then dirty=true end
elseif e[1]=="rstools_data"then
dirty=true
elseif e[1]=="monitor_touch"and e[2]==monName then
local x,y=e[3],e[4]
for i=#buttons,1,-1 do
local b=buttons[i]
if x>=b.x1 and x<=b.x2 and y>=b.y1 and y<=b.y2 then sfx("click");b.fn();break end
end
dirty=true
elseif e[1]=="monitor_touch"and isScreen(e[2])then
local x,y=e[3],e[4]
inScreen(e[2],function()
for i=#buttons,1,-1 do
local b=buttons[i]
if x>=b.x1 and x<=b.x2 and y>=b.y1 and y<=b.y2 then sfx("click");b.fn();break end
end
end)
dirty=true
elseif e[1]=="char"or e[1]=="paste"or e[1]=="key"then
handleKey(e)
dirty=true
elseif e[1]=="monitor_resize"then
if e[2]==monName then W,H=mon.getSize();win.reposition(1,1,W,H)
elseif widgets[e[2]]then setupWidgets()end
dirty=true
elseif e[1]=="peripheral"or e[1]=="peripheral_detach"then
if e[2]==monName and e[1]=="peripheral_detach"then pcall(setupMain)end
if isType(e[2]or"","monitor")or widgets[e[2]]or store.widgets[e[2]]then pcall(setupWidgets)end
dirty=true
end
if dirty or state.forceRender then
state.forceRender=false
render()
renderScreens()
state.toastsShown=#state.toasts>0
state.msgShown=state.msg~=nil and os.clock()-state.msgTime<6
state.msgDrawn=state.msgTime
state.renders=(state.renders or 0)+1
end
end
end
function main()
term.clear();term.setCursorPos(1,1)
local hadSave=fs.exists(CFG.dataFile)or fs.exists(CFG.oldDataFile)
local okL,errL=pcall(loadStore)
if not S("backup")then pcall(removeBackups)end
if state.needConfigSave then pcall(saveStore)end
setupMain()
setupWidgets()
print(APP.." v"..VERSION..L" sur "..monName.." ("..W.."x"..H..")")
for n in pairs(widgets)do print(L"Widget "..store.widgets[n].type..L" sur "..n)end
if not okL then print(L"Sauvegarde illisible : "..tostring(errL))end
print(#store.rules..L" stock(s) min, "..#store.maxRules..L" stock(s) max")
print(L"Clavier : recherche / saisie. Ctrl+T pour quitter.")
local anim=bootAnimation()
local function step(p,label)if anim then drawBoot(p,label)end end
step(0.15,L"Recherche de mises a jour...")
if S("autoUpdate")then pcall(checkUpdate,false)end
if state.restart then return end
local seen=store.seenVersion or(hadSave and"4.0.0"or nil)
if seen and cmpVer(VERSION,seen)==1 then state.popup={kind="news",from=seen}end
if store.seenVersion~=VERSION then
if seen and cmpVer(VERSION,seen)==1 then
logEvent("systeme",L"Passage de v"..seen.." a v"..VERSION,0)
end
store.seenVersion=VERSION
end
logEvent("systeme",L"Demarrage v"..VERSION,0)
if state.scaleFixed then
toast(L"Taille du texte trop grande pour cet ecran : ramenee a "..state.scaleFixed,1)
end
step(0.35,L"Lecture du reseau et des baies...")
refresh()
step(0.85,L"Preparation de l'interface...")
if anim then sleep(0.2)end
step(1,L"Pret")
if anim then
bootNotes({{"chime",1,18},{"chime",1,22},{"bell",0.6,6}})
sleep(0.4)
end
pcall(saveStore);pcall(saveData)
local loops={uiLoop,dataLoop}
if DC.loop then loops[#loops+1]=DC.loop end
parallel.waitForAny(table.unpack(loops))
end
state.start=function()
local ok,err=pcall(main)
pcall(saveStore);pcall(saveData)
local side=S("redstoneSide")
if side~="aucune"then pcall(redstone.setOutput,side,false)end
releaseMonitor(mon)
for _,w in pairs(widgets)do releaseMonitor(w.mon)end
if not ok and err~="Terminated"then printError(RSTOOLS_MAPERR and RSTOOLS_MAPERR(err)or err)end
if state.restart=="install"then
shell.run("install.lua","remote")
shell.run(shell.getRunningProgram())
elseif state.restart then
print(L"Redemarrage apres mise a jour...")
sleep(1)
shell.run(shell.getRunningProgram())
end
end
