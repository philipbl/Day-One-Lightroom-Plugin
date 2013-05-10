return {
    sectionsForTopOfDialog = function ( viewFactory, propertyTable )
        local LrDialogs = import "LrDialogs"
        local LrView = import "LrView"

        local bind = LrView.bind
        local share = LrView.share

        propertyTable.journal_type = 'icloud'
        propertyTable.custom = false

        propertyTable.icloud_path = 'icloud path'
        propertyTable.dropbox_path = 'dropbox path'
        propertyTable.custom_path = ''
        propertyTable.path = propertyTable.icloud_path

        return {
            {
                title = "Journal Location",

                viewFactory:row {
                    spacing = viewFactory:control_spacing(),
                    viewFactory:radio_button {
                        title = 'iCloud',
                        value = bind { key = 'journal_type', object = propertyTable },
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
                        value = bind { key = 'journal_type', object = propertyTable },
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
                        value = bind { key = 'journal_type', object = propertyTable },
                        checked_value = 'custom',
                        action = function ()
                            propertyTable.custom = true
                            propertyTable.journal_type = 'custom'
                            propertyTable.path = propertyTable.custom_path
                        end,
                    },

                    viewFactory:push_button {
                        title = "Browse",
                        enabled = bind { key = 'custom', object = propertyTable },
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
                        width = 400,
                        truncation = 'head',
                    },
                },
            },
        }
    end,
}
