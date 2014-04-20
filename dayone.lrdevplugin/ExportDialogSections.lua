-- Copyright (c) 2013, Philip Lundrigan
-- All rights reserved.
-- BSD License

ExportDialogSections = {}

LrPathUtils = import 'LrPathUtils'
icloudPath = LrPathUtils.standardizePath('~/Library/Mobile Documents/5U8NS4GX82~com~dayoneapp~dayone/Documents/Journal_dayone')
dropboxPath = LrPathUtils.getStandardFilePath('home') .. LrPathUtils.standardizePath('/Dropbox/Apps/Day One/Journal.dayone')
activityList = {'Stationary', 'Walking', 'Running', 'Biking', 'Eating', 'Automotive', 'Flying'}

function ExportDialogSections.sectionsForTopOfDialog( viewFactory, propertyTable )
    local LrDialogs = import "LrDialogs"
    local LrView = import "LrView"
    local LrPathUtils = import 'LrPathUtils'
    local LrFileUtils = import 'LrFileUtils'

    local bind = LrView.bind
    local share = LrView.share

    local function iCloudExists()
        return LrFileUtils.exists( icloudPath )
    end

    return {
        {
            title = "Journal Location",
            synopsis = bind 'journal_type',

            viewFactory:row {
                spacing = viewFactory:control_spacing(),
                viewFactory:radio_button {
                    title = 'iCloud',
                    value = bind 'journal_type',
                    checked_value = 'iCloud',
                    enabled = iCloudExists(),
                    action = function ()
                        propertyTable.custom = false
                        propertyTable.journal_type = 'iCloud'
                        propertyTable.path = icloudPath
                    end,
                },
            },

            viewFactory:row {
                spacing = viewFactory:control_spacing(),
                viewFactory:radio_button {
                    title = 'Dropbox',
                    value = bind 'journal_type',
                    checked_value = 'Dropbox',
                    action = function ()
                        propertyTable.custom = false
                        propertyTable.journal_type = 'Dropbox'
                        propertyTable.path = dropboxPath
                    end,
                },
            },

            viewFactory:row {
                spacing = viewFactory:control_spacing(),
                viewFactory:radio_button {
                    title = 'Custom',
                    value = bind 'journal_type',
                    checked_value = 'Custom',
                    action = function ()
                        propertyTable.custom = true
                        propertyTable.journal_type = 'Custom'
                        propertyTable.path = propertyTable.custom_path
                    end,
                },

                viewFactory:push_button {
                    title = "Browse",
                    enabled = bind 'custom',
                    action = function ()
                        local location = LrDialogs.runOpenPanel({
                            title = "Day One Journal Location",
                            canChooseDirectories = true,
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
                    title = "Use picture's location",
                    value = bind 'use_location'
                },
                viewFactory:static_text {
                    title = "(if GPS coordinates are present)",
                    enabled = false,
                },
            },

            viewFactory:row {
                spacing = viewFactory:control_spacing(),
                viewFactory:checkbox {
                    title = "Add weather to entry",
                    value = bind 'use_weather'
                },
                viewFactory:static_text {
                    title = "(if GPS coordinates are present -- learn more at developer.forecast.io)",
                    enabled = false,
                },
            },

            viewFactory:row {
                spacing = viewFactory:control_spacing(),
                viewFactory:static_text {
                    title = "     API Key for forcast.io:",
                    enabled = bind 'use_weather',
                },
                viewFactory:edit_field {
                    value = bind 'forcast_api_key',
                    enabled = bind 'use_weather',
                    immediate = true,
                    width_in_chars = 25,
                },
            },

            viewFactory:row {
                spacing = viewFactory:control_spacing(),
                viewFactory:checkbox {
                    title = "Star entry",
                    value = bind 'star'
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
                    value = bind 'tags',
                    enabled = bind 'use_specific_tags',
                    immediate = true,
                },
                viewFactory:static_text {
                    title = "(comma separated)",
                    enabled = false,
                },
            },

            viewFactory:row {
                spacing = viewFactory:control_spacing(),
                viewFactory:checkbox {
                    title = "Apply motion activity:",
                    value = bind 'use_activity'
                },
                viewFactory:combo_box {
                    value = bind 'activity',
                    items = activityList,
                    auto_completion = true,
                    enabled = bind 'use_activity',
                    immediate = false,
                    validate = function( view, value )
                        for _, v in pairs( activityList ) do
                            if v == value then
                                return true, value, ""
                            end
                        end
                        return false, value, "Must be valid activity:\nStationary, Walking, Running, Biking, Eating, Automotive, Flying"
                    end
                },
            },
        },
    }
end
