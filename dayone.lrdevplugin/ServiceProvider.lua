-- Copyright (c) 2013, Philip Lundrigan
-- All rights reserved.
-- BSD License

require "ExportDialogSections"
require "ExportTask"

local LrPathUtils = import 'LrPathUtils'

return {
    -- Settings for what should go into the dialog
    hideSections = { 'exportLocation', 'fileNaming' },
    allowFileFormats = { 'JPEG' },

    -- Settings
    exportPresetFields = {
        { key = 'separate_entries', default = false },
        { key = 'use_time', default = true },
        { key = 'use_location', default = true },
        { key = 'star', default = false },
        { key = 'use_keywords', default = false },
        { key = 'use_specific_tags', default = false },
        { key = 'tags', default = "" },
        { key = 'journal', default = ""},
        -- time zone?
    },

    -- Called when dialog comes up
    -- Check if dayone2 is in the path, if not bring up an error
    -- startDialog =

    -- View
    sectionsForTopOfDialog = ExportDialogSections.sectionsForTopOfDialog,

    -- Action when pictures are exported
    processRenderedPhotos = ExportTask.processRenderedPhotos,
}
