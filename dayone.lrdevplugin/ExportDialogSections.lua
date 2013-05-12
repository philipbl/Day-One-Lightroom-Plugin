
ExportDialogSections = {}

function ExportDialogSections.sectionsForTopOfDialog( viewFactory, propertyTable )
    local LrDialogs = import "LrDialogs"
    local LrView = import "LrView"

    local bind = LrView.bind
    local share = LrView.share

    return {
        {
            title = "Journal Location",

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
                    value = bind 'tags',
                    enabled = bind 'use_specific_tags',
                    immediate = true,
                },
                viewFactory:static_text {
                    title = "(comma separated)",
                },
            },
        },
    }
end
