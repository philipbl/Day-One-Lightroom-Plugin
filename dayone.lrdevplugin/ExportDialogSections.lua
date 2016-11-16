-- Copyright (c) 2013, Philip Lundrigan
-- All rights reserved.
-- BSD License

ExportDialogSections = {}

LrPathUtils = import 'LrPathUtils'
dayOne2Path = LrPathUtils.standardizePath('~/Library/Group Containers/5U8NS4GX82.dayoneapp2/Data/Auto Import/Default Journal.dayone')
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
