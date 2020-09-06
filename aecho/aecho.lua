
_addon.name = 'AEcho'
_addon.command = 'aecho'

require('tables')
require('strings')
require('logger')
require('sets')
config = require('config')
chat = require('chat')
res = require('resources')

defaults = {}
defaults.buffs = S{	"light arts","addendum: white","penury","celerity","accession","perpetuance","rapture",
                    "dark arts","addendum: black","parsimony","alacrity","manifestation","ebullience","immanence",
                    "stun","petrified","silence","stun","sleep","slow","paralyze"
                }
defaults.alttrack = true
defaults.sitrack = true

settings = config.load(defaults)

autoecho = true

windower.register_event('gain buff', function(id)
    local name = res.buffs[id].english
    for key,val in pairs(settings.buffs) do
        if key:lower() == name:lower() then
            if name:lower() == 'silence' and autoecho then
                windower.send_command('input /item "Echo Drops" '..windower.ffxi.get_player()["name"])
            end
            if name:lower() == 'paralyze' and autoecho then
                windower.send_command('input /item "Remedy" '..windower.ffxi.get_player()["name"])
            end
            if settings.alttrack then
                windower.send_command('send @others atc '..windower.ffxi.get_player()["name"]..' - '..name)
            end
        end
    end
end)

windower.register_event('incoming text', function(old,new,color)
    if settings.sitrack then
        local sta,ea,txt = string.find(new,'The effect of ([%w]+) is about to wear off.')
        if sta ~= nil then 
            windower.send_command('@send @others atc '..windower.ffxi.get_player()['name']..' - '..txt..' wearing off.')
        end
    end
    return new,color
end)

windower.register_event('addon command', function(...)
    local args = {...}
    if args[1] ~= nil then
        local comm = args[1]:lower()
        if comm == 'help' then
            local helptext = [[AEcho - Command List:
 1. aecho watch <buffname> --adds buffname to the tracker
 2. aecho unwatch <buffname> --removes buffname from the tracker
 3. aecho trackalt --Toggles alt buff/debuff messages on main (this requires send addon)
 4. aecho sitrack --When sneak/invis begin wearing passes this message to your alts
 5. aecho list --lists buffs being tracked
 6. aecho toggle --Toggles off automatic echo drop usage (in case you need this off. does not remain off across loads.)]]
            for _, line in ipairs(helptext:split('\n')) do
                windower.add_to_chat(207, line..chat.controls.reset)
            end
        elseif S{'watch','trackalt','unwatch','sitrack'}:contains(comm) then
            local list = ''
            local spacer = ''
            if comm == 'watch' then
                for i = 2, #args do
                    if i > 2 then spacer = ' ' end
                    list = list..spacer..args[i]
                end
                if settings.buffs[list] == nil then
                    settings.buffs:add(list:lower())
                    notice(list..' added to buffs list.')
                end
            elseif comm == 'unwatch' then
                for i = 2, #args do
                    if i > 2 then spacer = ' ' end
                    list = list..spacer..args[i]
                end
                if settings.buffs[list] ~= nil then
                    settings.buffs:remove(list:lower())
                    notice(list..' removed from buffs list.')
                end
            elseif comm == 'trackalt' then
                settings.alttrack = not settings.alttrack
            elseif comm == 'sitrack' then
                settings.sitrack = not settings.sitrack
            end
            settings:save()
        elseif comm == 'list' then
            settings.buffs:print()
        elseif comm == 'toggle' then
            autoecho = not autoecho
        else
            return
        end
    end
end)
