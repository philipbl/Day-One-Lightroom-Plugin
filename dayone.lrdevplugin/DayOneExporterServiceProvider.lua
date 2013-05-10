
local random = math.random
local function uuid()
    local template ='xxxxxxxxxxxx4xxxyxxxxxxxxxxxxxxx'
    return string.gsub(template, '[xy]', function (c)
        local v = (c == 'x') and random(0, 0xf) or random(8, 0xb)
        return string.format('%x', v)
    end)
end

local LrPathUtils = import 'LrPathUtils'


return {
    hideSections = { 'exportLocation', 'fileNaming' },
    allowFileFormats = { 'JPEG' },

    exportPresetFields = {
        { key = 'use_time', default = true},
        { key = 'use_keywords', default = false},
        { key = 'use_specific_tags', default = false},
        { key = 'tags', default = ""},
        { key = 'journal_type', default = 'icloud'},
        { key = 'custom', default = false},
        { key = 'icloud_path', default = LrPathUtils.standardizePath('~/Library/Mobile Documents/5U8NS4GX82~com~dayoneapp~dayone/Documents/Journal_dayone')},
        { key = 'dropbox_path', default = LrPathUtils.standardizePath('~/Dropbox/Apps/Day One/Journal.dayone')},
        { key = 'custom_path', default = ''},
        { key = 'path', default = LrPathUtils.standardizePath('~/Library/Mobile Documents/5U8NS4GX82~com~dayoneapp~dayone/Documents/Journal_dayone')},
    },

    sectionsForTopOfDialog = function ( viewFactory, propertyTable )
        local LrDialogs = import "LrDialogs"
        local LrView = import "LrView"

        local bind = LrView.bind
        local share = LrView.share

        return {
            {
                title = "Journal Location",
                -- synopsis = ""

                viewFactory:row {
                    spacing = viewFactory:control_spacing(),
                    viewFactory:radio_button {
                        title = 'iCloud',
                        value = bind 'journal_type',
                        checked_value = 'icloud',
                        action = function ()
                            propertyTable.custom = false
                            propertyTable.journal_type = 'icloud'
                            propertyTable.path = propertyTable.icloud_path
                        end,
                    },
                },

                viewFactory:row {
                    spacing = viewFactory:control_spacing(),
                    viewFactory:radio_button {
                        title = 'Dropbox',
                        value = bind 'journal_type',
                        checked_value = 'dropbox',
                        action = function ()
                            propertyTable.custom = false
                            propertyTable.journal_type = 'dropbox'
                            propertyTable.path = propertyTable.dropbox_path
                        end,
                    },
                },

                viewFactory:row {
                    spacing = viewFactory:control_spacing(),
                    viewFactory:radio_button {
                        title = 'Custom',
                        value = bind 'journal_type',
                        checked_value = 'custom',
                        action = function ()
                            propertyTable.custom = true
                            propertyTable.journal_type = 'custom'
                            propertyTable.path = propertyTable.custom_path
                        end,
                    },

                    viewFactory:push_button {
                        title = "Browse",
                        enabled = bind 'custom',
                        action = function ()
                            --local LrLogger = import 'LrLogger'
                            --local logger = LrLogger( 'myPlugin' )
                            --logger:enable("logfile")

                            --logger:warn(propertyTable.journal_type)

                            local location = LrDialogs.runOpenPanel({
                                title = "Day One Journal Location",
                                canChooseDirectories = false,
                                canChooseFiles = true,
                                allowsMultipleSelection = false,
                            })[1]

                            propertyTable.custom_path = location
                            propertyTable.path = propertyTable.custom_path
                        end
                    },

                },

                viewFactory:row {
                    spacing = viewFactory:control_spacing(),
                    viewFactory:static_text {
                        title = 'Path: ',
                    },

                    viewFactory:static_text {
                        title = bind { key = 'path', object = propertyTable },
                        width = 500,
                        truncation = 'head',
                    },
                },
            },

            {
                title = "Entry Settings",

                viewFactory:row {
                    spacing = viewFactory:control_spacing(),
                    viewFactory:checkbox {
                        title = "Use picture's time",
                        value = bind 'use_time'
                    },
                },

                viewFactory:row {
                    spacing = viewFactory:control_spacing(),
                    viewFactory:checkbox {
                        title = "Use picture's keywords as tags",
                        value = bind 'use_keywords'
                    },
                },

                viewFactory:row {
                    spacing = viewFactory:control_spacing(),
                    viewFactory:checkbox {
                        title = "Apply specific tags:",
                        value = bind 'use_specific_tags'
                    },
                    viewFactory:edit_field {
                        value = bind 'tags', -- bound to property
                        enabled = bind 'use_specific_tags',
                        immediate = true,
                    },
                },
            },
        }
    end,

    processRenderedPhotos = function ( functionContext, exportContext )
        local LrFileUtils = import 'LrFileUtils'
        local LrPathUtils = import 'LrPathUtils'
        local LrDialogs = import 'LrDialogs'
        local LrTasks = import 'LrTasks'
        local LrDate = import 'LrDate'

        local exportSession = exportContext.exportSession
        local exportParams = exportContext.propertyTable

        local nPhotos = exportSession:countRenditions()
        local progressScope = exportContext:configureProgress {
                                title = nPhotos > 1
                                        and "Adding " .. nPhotos .. " photos to Day One"
                                        or "Adding one photo to Day One",
        }

        -- Iterate through photo renditions.

        local failures = {}

        for _, rendition in exportContext:renditions{ stopIfCanceled = true } do

            -- Wait for next photo to render.
            local success, pathOrMessage = rendition:waitForRender()

            -- Check for cancellation again after photo has been rendered.
            if progressScope:isCanceled() then break end

            if success then
                local filename = LrPathUtils.leafName( pathOrMessage )

                local date = exportParams.use_time
                             and rendition.photo:getRawMetadata("dateTimeOriginal")
                             or LrDate.currentTime()

                local old_keywords = exportParams.use_keywords
                                     and rendition.photo:getFormattedMetadata("keywordTags")
                                     or ''
                local new_keywords = exportParams.use_specific_tags
                                     and exportParams.tags
                                     or ''
                local keywords = old_keywords == ''
                                 and new_keywords
                                 or old_keywords .. ',' .. new_keywords

                local uuid = uuid()

                -- add support for keywords
                -- check to make sure file does not exist
                -- get location of journal


                local entries = LrPathUtils.child( exportParams.path, 'entries' )
                local photos = LrPathUtils.child( exportParams.path, 'photos' )

                -- create photo
                LrFileUtils.copy( pathOrMessage, LrPathUtils.child(LrPathUtils.standardizePath(photos), uuid .. '.jpg') )

                -- create entry
                local f = io.open(LrPathUtils.child(LrPathUtils.standardizePath(entries), uuid .. '.doentry'),"w")
                f:write('<?xml version="1.0" encoding="UTF-8"?>\n')
                f:write('<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">\n')
                f:write('<plist version="1.0">\n')
                f:write('   <dict>\n')
                f:write('    <key>Creation Date</key>\n')
                f:write('    <date>' .. LrDate.timeToW3CDate(date) .. 'Z</date>\n')
                f:write('    <key>Entry Text</key>\n')
                f:write('    <string></string>\n')
                f:write('    <key>Starred</key>\n')
                f:write('    <false/>\n')

                if exportParams.use_keywords or exportParams.use_specific_tags then
                    f:write('<key>Tags</key>\n')

                    f:write('<array>\n')
                    f:write('    <string>' .. keywords .. '</string>\n')
                    f:write('</array>\n')
                end

                f:write('    <key>UUID</key>\n')
                f:write('    <string>' .. uuid .. '</string>\n')

                f:write('</dict>\n')
                f:write('</plist>\n')
                f:close()


                if not success then
                    table.insert( failures, filename )
                end

                LrFileUtils.delete( pathOrMessage )
            end

        end

        if #failures > 0 then
            local message
            if #failures == 1 then
                message = "1 file failed to upload correctly."
            else
                message = #failures .. " files failed to upload correctly."
            end
            LrDialogs.message( message, table.concat( failures, "\n" ) )
        end

    end
}
