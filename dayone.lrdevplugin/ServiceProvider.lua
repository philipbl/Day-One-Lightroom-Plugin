-- Copyright (c) 2013, Philip Lundrigan
-- All rights reserved.
-- BSD License

require "ExportDialogSections"
require "ExportTask"

local LrPathUtils = import 'LrPathUtils'

return {
    hideSections = { 'exportLocation', 'fileNaming' },
    allowFileFormats = { 'JPEG' },

    exportPresetFields = {
        { key = 'use_time', default = true },
        { key = 'use_location', default = true },
        { key = 'star', default = false },
        { key = 'use_keywords', default = false },
        { key = 'use_specific_tags', default = false },
        { key = 'tags', default = "" },
        { key = 'journal_type', default = 'Dropbox' },
        { key = 'custom', default = false },
        { key = 'custom_path', default = '' },
        { key = 'path', default = dropboxPath },
    },

    sectionsForTopOfDialog = ExportDialogSections.sectionsForTopOfDialog,

    processRenderedPhotos = ExportTask.processRenderedPhotos,
}
