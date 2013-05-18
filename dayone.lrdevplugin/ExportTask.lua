-- Copyright (c) 2013, Philip Lundrigan
-- All rights reserved.
-- BSD License

local random = math.random
local LrPathUtils = import 'LrPathUtils'
local LrFileUtils = import 'LrFileUtils'
local LrDialogs = import 'LrDialogs'
local LrDate = import 'LrDate'
local LrStringUtils = import 'LrStringUtils'


local function uuid()
    local template ='xxxxxxxxxxxx4xxxyxxxxxxxxxxxxxxx'
    return string.gsub(template, '[xy]', function (c)
        local v = (c == 'x') and random(0, 0xf) or random(8, 0xb)
        return LrStringUtils.upper(string.format('%x', v))
    end)
end

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

local function validJournalPath( path )
    return LrFileUtils.exists( path ) and
           LrFileUtils.exists( LrPathUtils.child(path, 'entries')) and
           LrFileUtils.exists( LrPathUtils.child(path, 'photos'))
end

local function getUniqueUUID( path )
    local fileName = uuid()

    while LrFileUtils.exists( LrPathUtils.child( path, fileName )) do
        fileName = uuid()
    end

    return fileName
end

local function createEntry( exportParams, photo, uuid )
    local date = exportParams.use_time
                 and photo:getRawMetadata("dateTimeOriginal")
                 or LrDate.currentTime()

    local entries = LrPathUtils.child( exportParams.path, 'entries' )

    local oldKeywords = split( photo:getFormattedMetadata("keywordTags"), ',' )
    local newKeywords = split( exportParams.tags, ',' )

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

    if exportParams.use_location then
        f:write('    <key>Location</key>\n')
        f:write('    <dict>\n')
        f:write('        <key>Latitude</key>\n')
        f:write('        <real>40.510755786435737</real>\n')
        f:write('        <key>Longitude</key>\n')
        f:write('        <real>-111.90233324107737</real>\n')
        f:write('    </dict>')
    end

    if exportParams.star then
        f:write('    <true/>\n')
    else
        f:write('    <false/>\n')
    end

    if exportParams.use_keywords or exportParams.use_specific_tags then
        f:write('   <key>Tags</key>\n')
        f:write('   <array>\n')
    end

    if exportParams.use_keywords and oldKeywords[1] ~= '' then
        for key,value in pairs(oldKeywords) do
            f:write('       <string>' .. value .. '</string>\n')
        end
    end

    if exportParams.use_specific_tags and newKeywords[1] ~= '' then
        for key,value in pairs(newKeywords) do
            f:write('       <string>' .. value .. '</string>\n')
        end
    end

    if exportParams.use_keywords or exportParams.use_specific_tags then
        f:write('   </array>\n')
    end

    f:write('    <key>UUID</key>\n')
    f:write('    <string>' .. uuid .. '</string>\n')

    f:write('</dict>\n')
    f:write('</plist>\n')
    f:close()
end

local function createPhoto( exportParams, photoPath, uuid )
    local photos = LrPathUtils.child( exportParams.path, 'photos' )
    LrFileUtils.copy( photoPath, LrPathUtils.child(LrPathUtils.standardizePath(photos), uuid .. '.jpg') )
end


ExportTask = {}

function ExportTask.processRenderedPhotos( functionContext, exportContext )

    local exportSession = exportContext.exportSession
    local exportParams = exportContext.propertyTable

    local nPhotos = exportSession:countRenditions()
    local progressScope = exportContext:configureProgress {
                            title = nPhotos > 1
                                    and "Adding " .. nPhotos .. " photos to Day One"
                                    or "Adding one photo to Day One",
    }

    -- Check if selected journal location exists
    if not validJournalPath( exportParams.path ) then
        LrDialogs.showError( "Selected journal location \n(" .. exportParams.path .. ")\ndoes not exist. Please select a different location." )
        return
    end

     -- Iterate through photo renditions.
    for _, rendition in exportContext:renditions{ stopIfCanceled = true } do

        -- Wait for next photo to render.
        local success, pathOrMessage = rendition:waitForRender()

        if progressScope:isCanceled() then break end

        if success then
            local uuid = getUniqueUUID( exportParams.path )

            createPhoto( exportParams, pathOrMessage, uuid )
            createEntry( exportParams, rendition.photo, uuid )

            -- clean up
            LrFileUtils.delete( pathOrMessage )

        else
            LrDialogs.message( pathOrMessage )
        end

    end
end
