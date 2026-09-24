-- Ventura RSTools : liste des fichiers du depot et de leur version.
-- Chaque ordinateur ne telecharge que les fichiers de son role (et de sa langue) dont la version a change.
return {
  version = "4.5.1",
  files = {
    { path = "rstools.lua",            v = "4.5.1", roles = { "standard", "central", "bay" } },
    { path = "rstools/common.lua",     v = "4.5.1", roles = { "standard", "central", "bay" } },
    { path = "rstools/central.lua",    v = "4.5.1", roles = { "standard", "central" } },
    { path = "rstools/datacenter.lua", v = "4.5.1", roles = { "central" } },
    { path = "rstools/bay.lua",        v = "4.5.1", roles = { "bay" } },
    { path = "install.lua",            v = "4.5.1", roles = { "standard", "central" } },
    { path = "rstools/lang/en.lua",    v = "4.5.1", lang = "en" },
  },
}
