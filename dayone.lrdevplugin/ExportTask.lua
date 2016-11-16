-- Copyright (c) 2013, Philip Lundrigan
-- All rights reserved.
-- BSD License

local LrPathUtils = import 'LrPathUtils'
local LrFileUtils = import 'LrFileUtils'
local LrDialogs = import 'LrDialogs'
local LrDate = import 'LrDate'
local LrStringUtils = import 'LrStringUtils'
local LrLogger = import 'LrLogger'

local logger = LrLogger( 'libraryLogger' )
logger:enable( "logfile" )



local function split( str, delimiter )
    local result = { }
    local from  = 1
    local delim_from, delim_to = string.find( str, delimiter, from  )
    while delim_from do
        table.insert( result, LrStringUtils.trimWhitespace( string.sub( str, from , delim_from-1 ) ) )
        from  = delim_to + 1
        delim_from, delim_to = string.find( str, delimiter, from  )
    end
    table.insert( result, LrStringUtils.trimWhitespace( string.sub( str, from  ) ) )
    return result
end

local function formatTime( time )
    tz, ds = LrDate.timeZone()
    if ds then
        time = time - tz - 3600
    else
        time = time - tz
    end

    local date = LrDate.timeToUserFormat( time, "%Y-%m-%d" )
    local time = LrDate.timeToUserFormat( time, "%H:%M:%S" )
    return date .. 'T' .. time .. 'Z'
end

local function joinList( list1, list2 )
    -- Join two lists together
    local tags = {}
    for _, l in ipairs(oldKeywords) do
        if l ~= "" then
            tags[l] = true
        end
    end

    for _, l in ipairs(newKeywords) do
        if l ~= "" then
            tags[l] = true
        end
    end
end

local function createEntry( exportParams, photos )
    -- Get date of photo
    local date = exportParams.use_time and
                 photo:getRawMetadata("dateTimeOriginal") or
                 LrDate.currentTime()

    -- Get the keywords of photo
    local oldKeywords = exportParams.use_keywords and
                        split( photo:getFormattedMetadata("keywordTags"), ',' ) or
                        {}

    -- Add new keywords if specified
    local newKeywords = exportParams.use_specific_tags and
                        split( exportParams.tags, ',' ) or
                        {}

    tags = joinList( oldKeywords, newKeywords )

    -- Get location
    local location = nil
    if exportParams.use_location and photo:getRawMetadata("gps") then
        location = photo:getRawMetadata("gps")
    end

    -- Save entry
    -- Call command

end

ExportTask = {}

function ExportTask.outputToLog( message )
    logger:trace( message )
end

function ExportTask.processRenderedPhotos( functionContext, exportContext )
    local exportSession = exportContext.exportSession
    local exportParams = exportContext.propertyTable

    local nPhotos = exportSession:countRenditions()
    local progressScope = exportContext:configureProgress {
                            title = nPhotos > 1 and
                                    "Adding " .. nPhotos .. " photos to Day One" or
                                    "Adding one photo to Day One",
    }

    ExportTask.outputToLog("Starting to export")
    ExportTask.outputToLog("Exporting " .. nPhotos .. " photos")

    --  -- Iterate through photo renditions
    -- for _, rendition in exportContext:renditions{ stopIfCanceled = true } do

    --     -- Wait for next photo to render
    --     local success, pathOrMessage = rendition:waitForRender()

    --     if progressScope:isCanceled() then
    --         break
    --     end

    --     if success then
    --         createEntry( exportParams, rendition.photo )

    --         -- Clean up
    --         LrFileUtils.delete( pathOrMessage )
    --     else
    --         -- Show error message
    --         LrDialogs.message( pathOrMessage )
    --     end

    -- end
end
