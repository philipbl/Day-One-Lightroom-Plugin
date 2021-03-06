-- Copyright (c) 2013, Philip Lundrigan
-- All rights reserved.
-- BSD License

return {

    LrSdkVersion = 3.0,
    LrToolkitIdentifier = 'com.philiplundrigan.dayone_export',

    LrPluginName = LOC "$$$/DayOneExport/PluginName=Day One Exporter",
    LrPluginInfoUrl = 'https://github.com/philipbl/Day-One-Lightroom-Plugin',

    LrExportServiceProvider = {
        title = "Day One",
        file = 'ServiceProvider.lua',
    },

    VERSION = { major=1, minor=2, revision=1},

}
