-- Ventura RSTools : INSTALLATEUR
--   wget run https://raw.githubusercontent.com/entocraft/rstools/main/install.lua
-- Arguments (installation automatique) : install <role> [id du central] [langue] [depot]
--   role : standard | central | bay        install remote : installer sur d'autres ordinateurs

local REPO = "https://raw.githubusercontent.com/entocraft/rstools/main/"
local args = { ... }
local PROTO = "rstools_dc"

local lang = "fr"
local function T(fr, en) return lang == "en" and en or fr end

local function readTable(p)
  if not fs.exists(p) then return nil end
  local f = fs.open(p, "r"); local t = textutils.unserialise(f.readAll() or ""); f.close()
  return type(t) == "table" and t or nil
end
local function writeTable(p, t)
  local f = fs.open(p, "w"); f.write(textutils.serialise(t)); f.close()
end

-- depot : argument, reglages existants, ou valeur par defaut
if args[4] then REPO = args[4] end
local existing = readTable("rstools_config.txt")
if not args[4] and existing and existing.settings and type(existing.settings.repoUrl) == "string" then
  REPO = existing.settings.repoUrl
end
if REPO:sub(-1) ~= "/" then REPO = REPO .. "/" end

local function color(c) if term.isColor() then term.setTextColor(c) end end
local function title(s) color(colors.cyan); print(s); color(colors.white) end

local function ask(q, choices)
  while true do
    color(colors.yellow); write(q .. " "); color(colors.white)
    local r = (read() or ""):lower():gsub("%s", "")
    for _, c in ipairs(choices) do if r == c then return r end end
  end
end

local function fetch(path)
  local h = http.get(REPO .. path .. "?t=" .. math.floor(os.epoch("utc") / 1000))
  if not h then return nil end
  local b = h.readAll(); h.close()
  return b
end

local function installFiles(role)
  if not http then error(T("HTTP est desactive sur ce serveur.", "HTTP is disabled on this server."), 0) end
  local mb = fetch("manifest.lua")
  if not mb then error(T("Depot introuvable : ", "Repository not found: ") .. REPO, 0) end
  local m = load(mb, "=manifest", "t", {})()
  local inst = {}
  for _, f in ipairs(m.files) do
    local want = false
    if f.lang then want = (f.lang == lang)
    else for _, r in ipairs(f.roles or {}) do if r == role then want = true end end end
    if want then
      write("  " .. f.path .. " ... ")
      local body = fetch(f.path)
      if not body then error(T("echec du telechargement de ", "download failed: ") .. f.path, 0) end
      local dir = fs.getDir(f.path)
      if dir ~= "" and not fs.exists(dir) then fs.makeDir(dir) end
      local fw = fs.open(f.path, "w"); fw.write(body); fw.close()
      inst[f.path] = f.v
      color(colors.lime); print("ok"); color(colors.white)
    end
  end
  if not fs.exists("rstools") then fs.makeDir("rstools") end
  writeTable("rstools/installed.txt", inst)
  local fr = fs.open("rstools/role.txt", "w"); fr.write(role); fr.close()
  -- demarrage automatique
  local fs_ = fs.open("startup.lua", "w")
  fs_.write('shell.run("rstools.lua")\n'); fs_.close()
  return m.version
end

local function saveLang(role, central)
  if role == "bay" then
    local c = readTable("rstools_bay.txt") or {}
    c.settings = c.settings or {}
    c.settings.lang = lang
    c.settings.repoUrl = REPO
    if central then c.central = central end
    writeTable("rstools_bay.txt", c)
  else
    local c = readTable("rstools_config.txt") or {}
    c.settings = c.settings or {}
    c.settings.lang = lang
    c.settings.repoUrl = REPO
    writeTable("rstools_config.txt", c)
  end
end

------------------------------------------------------------------ installation sur d'autres ordinateurs
local function computers()
  local r = {}
  for _, n in ipairs(peripheral.getNames()) do
    if peripheral.getType(n) == "computer" then
      local ok, id = pcall(peripheral.call, n, "getID")
      local okL, label = pcall(peripheral.call, n, "getLabel")
      local okO, on = pcall(peripheral.call, n, "isOn")
      if ok and id ~= os.getComputerID() then
        r[#r + 1] = { name = n, id = id, label = okL and label or nil, on = okO and on }
      end
    end
  end
  table.sort(r, function(a, b) return a.id < b.id end)
  return r
end

local function findFloppy()
  for _, n in ipairs(peripheral.getNames()) do
    if peripheral.getType(n) == "drive" and disk.hasData(n) then return n, disk.getMountPath(n) end
  end
end

local BOOT = [[
-- RSTools : installation automatique d'un controleur de baies (disquette)
if fs.exists("rstools.lua") and fs.exists("rstools/role.txt") then return end
local dir = fs.getDir(shell.getRunningProgram())
local f = fs.open(fs.combine(dir, "rstools_dc.txt"), "r")
local cfg = textutils.unserialise(f.readAll()); f.close()
print("RSTools : installation du controleur de baies...")
local h = http and http.get(cfg.repo .. "install.lua?t=" .. math.floor(os.epoch("utc") / 1000))
if not h then print("Telechargement impossible") return end
local code = h.readAll(); h.close()
local fn = load(code, "=install", "t", _ENV)
fn("bay", tostring(cfg.central), cfg.lang or "fr", cfg.repo)
os.reboot()
]]

local function remoteInstall()
  title(T("== Installation des controleurs de baies ==", "== Bay controller installation =="))
  local list = computers()
  if #list == 0 then
    print(T("Aucun ordinateur relie en filaire.", "No computer connected by cable."))
    print(T("Active leur modem filaire d'un clic droit (il devient rouge).", "Right-click their wired modem to activate it (it turns red)."))
    return
  end
  local chosen = {}
  for _, c in ipairs(list) do
    local lab = "#" .. c.id .. (c.label and (" (" .. c.label .. ")") or "") .. (c.on and "" or T(" [eteint]", " [off]"))
    if ask(T("Installer le controleur de baies sur ", "Install the bay controller on ") .. lab .. " ? (o/n)", { "o", "n", "y" }) ~= "n" then
      chosen[#chosen + 1] = c
    end
  end
  if #chosen == 0 then return end
  local drive, mount = findFloppy()
  while not drive do
    print(T("Il faut une disquette dans un lecteur de disquette CC relie au meme reseau.",
            "Put a floppy disk in a CC disk drive connected to the same network."))
    print(T("Insere-la maintenant (ou Ctrl+T pour annuler)...", "Insert it now (or Ctrl+T to cancel)..."))
    os.pullEvent("disk")
    drive, mount = findFloppy()
  end
  local fb = fs.open(fs.combine(mount, "startup.lua"), "w"); fb.write(BOOT); fb.close()
  writeTable(fs.combine(mount, "rstools_dc.txt"), { central = os.getComputerID(), repo = REPO, lang = lang })
  for _, n in ipairs(peripheral.getNames()) do
    if peripheral.getType(n) == "modem" then pcall(rednet.open, n) end
  end
  local waiting = {}
  for _, c in ipairs(chosen) do
    waiting[c.id] = c
    pcall(peripheral.call, c.name, c.on and "reboot" or "turnOn")
    print(T("Demarrage de #", "Starting #") .. c.id .. "...")
  end
  print(T("Installation en cours (jusqu'a 2 minutes)...", "Installing (up to 2 minutes)..."))
  local deadline = os.clock() + 120
  local left = #chosen
  while left > 0 and os.clock() < deadline do
    local id, msg = rednet.receive(PROTO, 5)
    if id and waiting[id] and type(msg) == "table" and (msg.t == "hello" or msg.t == "status" or msg.t == "discover") then
      waiting[id] = nil
      left = left - 1
      rednet.send(id, { t = "central", from = os.getComputerID() }, PROTO)
      color(colors.lime); print("  #" .. id .. T(" : controleur installe et connecte", " : controller installed and connected")); color(colors.white)
    end
  end
  fs.delete(fs.combine(mount, "startup.lua"))
  fs.delete(fs.combine(mount, "rstools_dc.txt"))
  for id in pairs(waiting) do
    color(colors.orange)
    print("  #" .. id .. T(" : pas de reponse (il a peut-etre deja un programme de demarrage)",
                           " : no answer (it may already have a startup program)"))
    color(colors.white)
  end
end

------------------------------------------------------------------ programme
if args[1] == "remote" then
  local c = readTable("rstools_config.txt")
  lang = (c and c.settings and c.settings.lang) or "fr"
  remoteInstall()
  print(T("Appuie sur une touche pour revenir a RSTools.", "Press any key to go back to RSTools."))
  os.pullEvent("key")
  return
end

if args[1] then
  -- installation automatique (depuis la disquette d'un central)
  lang = args[3] or "fr"
  local central = tonumber(args[2])
  installFiles(args[1])
  saveLang(args[1], central)
  return
end

term.clear(); term.setCursorPos(1, 1)
title("== Ventura RSTools : installation ==")
print("1) Francais   2) English")
lang = ask(">", { "1", "2" }) == "2" and "en" or "fr"
print("")
print(T("Role de cet ordinateur :", "Role of this computer:"))
print(T("1) Standard : un seul ordinateur (le plus courant)", "1) Standard: a single computer (most common)"))
print(T("2) Data center : ordinateur central", "2) Data center: central computer"))
print(T("3) Data center : controleur de baies", "3) Data center: bay controller"))
local r = ask(">", { "1", "2", "3" })
local role = ({ "standard", "central", "bay" })[tonumber(r)]
print("")
print(T("Depot : ", "Repository: ") .. REPO)
local v = installFiles(role)
saveLang(role)
color(colors.lime); print(T("RSTools v", "RSTools v") .. tostring(v) .. T(" installe.", " installed.")); color(colors.white)
if role == "central" then
  print("")
  remoteInstall()
end
print("")
if ask(T("Redemarrer maintenant ? (o/n)", "Reboot now? (y/n)"), { "o", "n", "y" }) ~= "n" then os.reboot() end
