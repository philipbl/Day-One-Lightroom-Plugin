
return {
    hideSections = { 'exportLocation', 'fileNaming' },

    sectionsForTopOfDialog = function ( viewFactory, propertyTable )
        local LrDialogs = import "LrDialogs"
        local LrView = import "LrView"

        local bind = LrView.bind
        local share = LrView.share

        propertyTable.use_time = true
        propertyTable.use_location = true
        propertyTable.use_keywords = false
        propertyTable.use_specific_tags = false
        propertyTable.tags = ""

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
                        immediate = true,
                    },
                },
            },
        }
    end,

    processRenderedPhotos = function ( functionContext, exportContext )
        local LrPathUtils = import 'LrPathUtils'
        local LrFtp = import 'LrFtp'
        local LrFileUtils = import 'LrFileUtils'
        local LrErrors = import 'LrErrors'
        local LrDialogs = import 'LrDialogs'
        local LrTasks = import 'LrTasks'
        local LrDate = import 'LrDate'

        -- Make a local reference to the export parameters.

        local exportSession = exportContext.exportSession
        local exportParams = exportContext.propertyTable

        -- Set progress title.

        local nPhotos = exportSession:countRenditions()

        local progressScope = exportContext:configureProgress {
                            title = nPhotos > 1
                                   and LOC( "$$$/FtpUpload/Upload/Progress=Adding ^1 photos to Day One", nPhotos )
                                   or LOC "$$$/FtpUpload/Upload/Progress/One=Adding one photo to Day One",
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
                local date = rendition.photo:getRawMetadata(nil)["dateTimeOriginal"]
                local command = "/usr/local/bin/dayone -d=\\\"" .. LrDate.timeToW3CDate(date) .. "\\\" -p=" .. pathOrMessage .. " new"

                local success = LrTasks.execute(command)

                if not success then

                    -- If we can't upload that file, log it.  For example, maybe user has exceeded disk
                    -- quota, or the file already exists and we don't have permission to overwrite, or
                    -- we don't have permission to write to that directory, etc....

                    table.insert( failures, filename )
                end

                -- When done with photo, delete temp file. There is a cleanup step that happens later,
                -- but this will help manage space in the event of a large upload.

                LrFileUtils.delete( pathOrMessage )

            end

        end

        if #failures > 0 then
            local message
            if #failures == 1 then
                message = LOC "$$$/FtpUpload/Upload/Errors/OneFileFailed=1 file failed to upload correctly."
            else
                message = LOC ( "$$$/FtpUpload/Upload/Errors/SomeFileFailed=^1 files failed to upload correctly.", #failures )
            end
            LrDialogs.message( message, table.concat( failures, "\n" ) )
        end

    end

}
