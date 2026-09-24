-- Ventura RSTools : LANCEUR
-- Assemble les fichiers du dossier rstools/ selon le role de cet ordinateur, puis lance le programme.
-- Si des fichiers manquent (premiere installation, ancienne version), il les telecharge depuis le depot.

local VERSION = "4.4.1"
-- depot GitHub (adresse "raw") : a remplacer par le tien
local REPO = "https://raw.githubusercontent.com/entocraft/rstools/main/"

local FILES = {
  standard = { "rstools/common.lua", "rstools/central.lua" },
  central  = { "rstools/common.lua", "rstools/central.lua", "rstools/datacenter.lua" },
  bay      = { "rstools/common.lua", "rstools/bay.lua" },
}

local function readAll(p)
  if not fs.exists(p) then return nil end
  local f = fs.open(p, "r")
  if not f then return nil end
  local s = f.readAll(); f.close()
  return s
end

local role = (readAll("rstools/role.txt") or "standard"):gsub("%s", "")
if not FILES[role] then role = "standard" end

-- depot : celui des reglages s'il a ete change
local conf = textutils.unserialise(readAll(role == "bay" and "rstools_bay.txt" or "rstools_config.txt") or "")
if type(conf) == "table" and type(conf.settings) == "table" and type(conf.settings.repoUrl) == "string" then
  REPO = conf.settings.repoUrl
end
if REPO:sub(-1) ~= "/" then REPO = REPO .. "/" end
RSTOOLS_REPO = REPO

-- fichiers manquants : telechargement direct
local missing = {}
for _, p in ipairs(FILES[role]) do if not fs.exists(p) then missing[#missing + 1] = p end end
if #missing > 0 then
  print("RSTools : fichiers manquants, telechargement...")
  if not http then error("HTTP desactive sur ce serveur : impossible de telecharger RSTools", 0) end
  for _, p in ipairs(missing) do
    local h = http.get(REPO .. p)
    if not h then error("Telechargement impossible : " .. REPO .. p, 0) end
    local body = h.readAll(); h.close()
    local dir = fs.getDir(p)
    if dir ~= "" and not fs.exists(dir) then fs.makeDir(dir) end
    local f = fs.open(p, "w"); f.write(body); f.close()
    print("  " .. p .. " (" .. #body .. " octets)")
  end
end

-- assemblage en un seul programme (les fichiers partagent leurs variables)
local parts, map, line = {}, {}, 1
for _, p in ipairs(FILES[role]) do
  local src = readAll(p)
  parts[#parts + 1] = src
  local n = select(2, src:gsub("\n", "\n")) + 1
  map[#map + 1] = { from = line, to = line + n - 1, file = p }
  line = line + n
end
parts[#parts + 1] = "state.start()"

-- "rstools:1234: ..." -> "rstools/central.lua:56: ..."
function RSTOOLS_MAPERR(msg)
  return (tostring(msg):gsub("rstools:(%d+):", function(n)
    n = tonumber(n)
    for _, m in ipairs(map) do
      if n >= m.from and n <= m.to then return m.file .. ":" .. (n - m.from + 1) .. ":" end
    end
  end))
end

-- environnement prive : les variables partagees entre fichiers y vivent au lieu d'etre des
-- "local" du programme principal (CC:Tweaked limite a 200 le total de locales imbriquees)
local ENV = setmetatable({}, { __index = _ENV })
local fn, err = load(table.concat(parts, "\n"), "=rstools", "t", ENV)
if not fn then error(RSTOOLS_MAPERR(err), 0) end
fn(role)
