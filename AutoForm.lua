script_properties('work-in-pause')
-- ============= LIBS ============== --
local ev = require('lib.samp.events')
-- =========== VARIABLES =========== --
local status = false
local switchPause = false
local isPause = false
local notf = import 'imgui_notf.lua'
local dlstatus = require("moonloader").download_status
local inicfg = require "inicfg"

update_state = false

local script_vers = 1
local script_vers_text = "1.00"

local update_url = "https://raw.githubusercontent.com/isonotIce/AF/main/update.ini"
local update_path = getWorkingDirectory() .. "/update.ini"

local script_url = ""
local script_path = thisScript().path

local withoutBy = {
    "fv",
    "slap",
    "plveh",
    "hp",
    "skin",
    "delvi",
    "tveh",
    "auninvite",
    "auninviteoff",
    "glip",
    "lip",
    "offget",
    "get",
    "prespawn",
    "unwarn",
    "unwarnoff",
    "unban",
    "skick",
    "dslap",
    "slap",
    "freeze",
    "unfreeze",
    "money",
    "offmoney",
    "setfuel"
}
local withBy = {
    "msg",
    "warn",
    "ban",
    "offban",
    "offwarn",
    "rmute",
    "offrmute",
    "mute",
    "offmute",
    "jail",
    "sjail",
    "offjail",
    "soffjail",
    "dmute",
    "offdmute",
    "unoffdmute",
    "unjail",
    "kick",
    "unoffmute",
    "undmute"
}
colors = {0x8048F8, 0xffffff}
local tag = '[AutoForm]: '
local draw = 'AF'
-- =========== FUNCTIONS =========== --
function main()
    if not isSampLoaded() or not isSampfuncsLoaded() then return end
    while not isSampAvailable() do wait(100) end

    sampRegisterChatCommand('af', toggleGive)
    sampRegisterChatCommand('updaf', cmd_update)
    downloadUrlToFile(update_url, update_path, function(id, status)
        if status == dlstatus.STATUS_ENDDOWNLOADDATA then
            updateIni = inicfg.load(nil, update_path)
            if tonumber(updateIni.info.vers) > script_vers then
                notf.addNotification(string.format("Обновление!\n\n\nДоступно обновление: ".. updateIni.info.vers_text .."\n\nДля установки обновления введите /updaf", os.date()), 5)
            end
            os.remove(update_path)
        end

    end) 
    while true do
        if isGamePaused() and not switchPause then
            switchPause = true
            isPause = true
        elseif not isGamePaused() and switchPause then
            switchPause = false
            lua_thread.create(function()
                wait(2000)
                isPause = false
            end)
        end
        wait(500)
        if update_state then
            downloadUrlToFile(script_url, script_path, function(id, status)
                if status == dlstatus.STATUS_ENDDOWNLOADDATA then
                    sampAddChatMessage('Скрипт успешно обновлен!', -1)
                    thisScript():reload()
                end
            end)
            break
        end
    end
    wait(-1)
end

function toggleGive()
    status = not status
    addOneOffSound(0.0, 0.0, 0.0, status and 1052 or 1053)
    if status == true then 
    notf.addNotification(string.format("AutoForm\n\n\nСкрипт автоматической выдачи админских форм запущен!\n\nДля деактивации скрипта введите /af", os.date()), 5)
    sampTextdrawCreate(999, draw, 10, 432)
    if tonumber(updateIni.info.vers) > script_vers then
        notf.addNotification(string.format("Обновление!\n\n\nДоступно обновление: ".. updateIni.info.vers_text .."\n\nДля установки обновления введите /updaf", os.date()), 5)
    end
    else 
        notf.addNotification(string.format("AutoForm\n\n\nСкрипт автоматической выдачи админских форм выключен!\n\nДля активации скрипта введите /af", os.date()), 5)
        sampTextdrawCreate(999, "", 580, 430)
    end
end
function cmd_update()
    update_status = true
end

function formatName(name)
    local firstInitial, lastName = name:match("(%a)%a*_(%a+)")
    return "> " .. firstInitial .. ". " .. lastName
end

function autogive(player, id, message)
    lua_thread.create(function()
        local command, aarg = message:match("^/?([%a]+)(.*)")
        if aarg ~= '' then
            for i, v in ipairs(withoutBy) do
                if v == command then
                    if message:sub(1, 1) ~= "/" then
                        message = "/" ..message
                    end
                    sampSendChat(message)
                    wait(100)
                    addOneOffSound(0.0, 0.0, 0.0, status and 1057)
                    wait(100)
                    notf.addNotification(string.format("AutoForm\n\n\nЗапрошенна форма " .. message .. " выдана!\n\nЗапросил " ..formatName(player), os.date()), 5)
                    wait(600)
                    sampSendChat('/a +')
                end
            end
            for i, v in ipairs(withBy) do
                if v == command then
                    if message:sub(1, 1) ~= "/" then
                        message = "/" ..message
                    end
                    sampSendChat(message.. ' ' ..formatName(player))
                    wait(100)
                    addOneOffSound(0.0, 0.0, 0.0, status and 1057)
                    wait(100)
                    notf.addNotification(string.format("AutoForm\n\n\nЗапрошенна форма " .. message .. " выдана!\n\nЗапросил " ..formatName(player), os.date()), 5)
                    wait(600)
                    sampSendChat('/a +')
                end
            end
        end
    end)
end
-- =========== HOOKS =========== --
function ev.onServerMessage(color, text)
    lua_thread.create(function()
        _, id = sampGetPlayerIdByCharHandle(PLAYER_PED)
        nick = sampGetPlayerNickname(id)
        local player, id, message = text:match('^%[A%] (%S+)%[(%d+)%]: (.+)')
        if player and status and not isPause and nick ~= player then
            wait(50)
            autogive(player, id, message)
        end
    end)
end
