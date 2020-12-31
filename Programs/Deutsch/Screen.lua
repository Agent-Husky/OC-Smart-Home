local component = require("component")
local modem = component.modem
local gpu = component.gpu
local event = require("event")
local unicode = require("unicode")
local computer = require("computer")

local conf = {}
local button = {}
local light = {}
local door = {}
local alarm = {}
local lightbutton = {}
local doorbutton = {}
local button2 = {}
local lock = {}
local code = {}

gpu.setResolution(80, 40)

Port = 4 -- The port on which the communication will happen, please use the same in all devices that you want to communicate with this server
Green = 0x33DB00
Green2 = 0x33B600
Red = 0xFF0000
Black = 0x000000
White = 0xFFFFFF
Timeout = 10
Timeoutcodepad = 10

-- Configuration of the top menu

function conf.setmenu()
    button.setTable("Lichter", "lights", 2, 3, 7, 26, Green)
    button.setTable("Türen", "doors",2, 29, 7, 52, Green)
    button.setTable("Alarmanlage", "alarm", 2, 55, 7, 78, Green)
end

-- Configuration of the light buttons

function conf.setlights()
    button.draw(2, 3, 7, 26, "Lichter", Red)
    button.setTable("Türen", "doors", 2, 29, 7, 52, Green)
    button.setTable("Alarmanlage", "alarm", 2, 55, 7, 78, Green)

    lightbutton.setTable("Garage", "garage", 8, 4, 11, 17, "Das Licht in der Garage ist eingeschaltet!", "Das Licht in der Garage ist ausgeschaltet!", Green)
    lightbutton.setTable("Küche", "kitchen", 8, 19, 11, 32, "Das Licht in der Küche ist eingeschaltet!", "Das Licht in der Küche ist ausgeschaltet!", Green)
    lightbutton.setTable("Esszimmer", "dining room", 8, 34, 11, 48, "Das Licht im Esszimmer ist eingeschaltet!", "Das Licht im Esszimmer ist ausgeschaltet!", Green)
    lightbutton.setTable("Bad unten", "bathroom down", 8, 50, 11, 63, "Das Licht im Bad unten ist eingeschaltet!", "Das Licht im Bad unten ist ausgeschaltet!", Green)
    lightbutton.setTable("Büro", "office", 8, 65, 11, 77, "Das Licht im Büro ist eingeschaltet!", "Das Licht im Büro ist ausgeschaltet!", Green)
    lightbutton.setTable("Bad oben", "bathroom up", 11, 22, 14, 39, "Das Licht im Bad oben ist eingeschaltet!", "Das Licht im Bad oben ist ausgeschaltet!", Green)
    lightbutton.setTable("Kleiderschrank", "wardrobe", 11, 42, 14, 59, "Das Licht im Kleiderschrank ist eingeschaltet!", "Das Licht im Kleiderschrank ist ausgeschaltet!", Green)
    button.setTable("in allen ausschalten", "turn all off", 14, 29, 17, 52, Green)
end

function conf.statelights(state, room)
    if state == "on" then
        button.draw(18, 15, 21, 65, button2[room]["stateonsentence"], Green, "Möchten sie es ausschalten?")
        button.setTable("Ja", "turn off", 22, 22, 25, 39, Green)
    end
    if state == "off" then
        button.draw(18, 15, 21, 65, button2[room]["stateoffsentence"], Red, "Möchten sie es einschalten?")
        button.setTable("Ja", "turn on", 22, 22, 25, 39, Green)
    end
    button.setTable("Nein", "no", 22, 42, 25, 59, Green)
end

function conf.lightscheck(check)
    if check == "turned on" then button.draw(25, 15, 28, 65, "Das Licht wurde eingeschaltet!", Green) end
    if check == "turned off" then button.draw(25, 15, 28, 65, "Das Licht wurde ausgeschaltet!", Green) end
end

-- Configuration of the door buttons

function conf.setdoors()
    button.setTable("Lichter", "lights", 2, 3, 7, 26, Green)
    button.draw(2, 29, 7, 52, "Türen", Red)
    button.setTable("Alarmanlage", "alarm", 2, 55, 7, 78, Green)

    doorbutton.setTable("Haustür", "front door", 8, 15, 11, 38, "Die Haustür ist geöffnet!", "Die Haustür ist geschlossen!", Green)
    doorbutton.setTable("Garagentor", "garage door", 8, 43, 11, 66, "Das Garagentor ist geöffnet!", "Das Garagentor ist geschlossen!", Green)
    doorbutton.setTable("Haus abschließen", "lock house", 11, 29, 14, 52, "Das Haus wurde abgeschlossen und der Alarm aktiviert!", nil, Green)
end

function conf.statedoors(state, door)
    if state == "opened" then
        button.draw(14, 20, 17, 60, button2[door]["opensentence"], Red, "Möchten sie die Tür schließen?")
        button.setTable("Ja", "close", 18, 22, 21, 39, Green)
    end
    if state == "closed" then
        button.draw(14, 20, 17, 60, button2[door]["closesentence"], Green, "Möchten sie die Tür öffnen?")
        button.setTable("Ja", "open", 18, 22, 21, 39, Green)
    end
    button.setTable("Nein", "no", 18, 42, 21, 59, Green)
end

function conf.checkdooraction(check, miny)
    if check == "was opened" then button.draw(miny + 13, 25, miny + 16, 55, "Die Tür wurde geöffnet!", Green) end
    if check == "was closed" then button.draw(miny + 13, 25, miny + 16, 55, "Die Tür wurde geschlossen!", Green) end
end

-- Configuration of the alarm buttons

function conf.setalarm()
    button.setTable("Lichter", "lights", 2, 3, 7, 26, Green)
    button.setTable("Türen", "doors",2, 29, 7, 52, Green)
    button.draw(2, 55, 7, 78, "Alarmanlage", Red)
end

function conf.statealarm(state)
    if state == "alarm not triggered" then
        button.draw(7, 15, 12, 65, "Es wurde kein Alarm ausgelöst!", Green)
    end

    if state == "alarm triggered" then
        button.draw(7, 15, 12, 65, "Es wurde ein Alarm ausgelöst!", Red)
        button.setTable("Alarm zurücksetzen", "reset alarm", 12, 17, 15, 39, Green)
        button.setTable("Alarm deaktivieren", "disable alarm", 12, 41, 15, 63, Green)
        Touch()
        if Timeout2 then
            return
        end
        lock.alarmcode(Func, 15, 34)
    end
end

function conf.checkalarm(check, miny)
    if check == "alarm disabled" then button.draw(miny + 13, 20, miny + 16, 60, "Der Alarm wurde deaktiviert!", Green) end
    if check == "alarm reset" then button.draw(miny + 13, 20, miny + 16, 60, "Der Alarm wurde zurückgesetzt!", Green) end
end

-- Program itself, Nothing to configure below

function Clear()
    gpu.setBackground(Black)
    local x, y = gpu.getResolution()
    gpu.fill(1, 1, x, y, " ")
    button.clear()
end

Timeout = Timeout - 2
Timeoutcodepad = Timeoutcodepad - 2

::checkserv::
modem.open(Port)
modem.broadcast(Port, "check server")
local _, _, server, _, _, servok = event.pull("modem_message")
if servok ~= "server ok" then goto checkserv end

function button.clear()
    button2 = {}
end

function button.draw(miny, minx, maxy, maxx, text, color, text2)
    gpu.setBackground(Black)
    if text2 ~= nil then Maxy2 = maxy + 1
    else Maxy2 = maxy end
    gpu.set(minx, miny, unicode.char(0x2552))
    gpu.set(minx + 1, miny, string.rep(unicode.char(0x2550), maxx - minx - 1))
    gpu.set(maxx, miny, unicode.char(0x2555))
    local frameheight = Maxy2 - miny - 2
    gpu.fill(minx, miny + 1, 1, frameheight, unicode.char(0x2502))
    gpu.fill(maxx, miny + 1, 1, frameheight, unicode.char(0x2502))
    gpu.set(minx, Maxy2 - 1, unicode.char(0x2514))
    gpu.set(minx + 1, Maxy2 - 1, string.rep(unicode.char(0x2500), maxx - minx - 1))
    gpu.set(maxx, Maxy2 - 1, unicode.char(0x2518))
    gpu.setBackground(color)
    local width = maxx - minx - 1
    local height = Maxy2 - miny - 2
    gpu.fill(minx + 1, miny + 1, width, height, " ")
    local y = (miny + maxy) / 2
    local x = math.ceil((maxx - minx - #text) / 2) + minx
    gpu.set(x, y, text)
    if text2 ~= nil then
        local y2 = y+1
        local x2 = math.ceil((maxx - minx - #text2) / 2) + minx
        gpu.set(x2, y2, text2)
    end
    gpu.setBackground(Black)
end

function button.setTable(name, func, miny, minx, maxy, maxx, color)
    button.draw(miny, minx, maxy, maxx, name, color)
    button2[func] = {}
    button2[func]["name"] = name
    button2[func]["func"] = func
    button2[func]["miny"] = miny
    button2[func]["minx"] = minx
    button2[func]["maxy"] = maxy
    button2[func]["maxx"] = maxx
end

function lightbutton.setTable(name, func, miny, minx, maxy, maxx, stateonsentence, stateoffsentence, color)
    button.draw(miny, minx, maxy, maxx, name, color)
    button2[func] = {}
    button2[func]["name"] = name
    button2[func]["func"] = func
    button2[func]["miny"] = miny
    button2[func]["minx"] = minx
    button2[func]["maxy"] = maxy
    button2[func]["maxx"] = maxx
    button2[func]["stateonsentence"] = stateonsentence
    button2[func]["stateoffsentence"] = stateoffsentence
end

function doorbutton.setTable(name, door, miny, minx, maxy, maxx, stateopensentence, stateclosesentence, color)
    button.draw(miny, minx, maxy, maxx, name, color)
    button2[door] = {}
    button2[door]["name"] = name
    button2[door]["func"] = door
    button2[door]["miny"] = miny
    button2[door]["minx"] = minx
    button2[door]["maxy"] = maxy
    button2[door]["maxx"] = maxx
    button2[door]["opensentence"] = stateopensentence
    button2[door]["closesentence"] = stateclosesentence
end

function Touch(usecase)
    if not usecase then
        _, _, X, Y, _, _ = event.pull(Timeout, "touch")
        if not X and not Y then
            Timeout2 = true
            Func = nil
            return
        else
            Timeout2 = false
        end
    else
        _, _, X, Y, _, _ = event.pull("touch")
    end
    for _, data in pairs(button2) do
        if Y >= data["miny"] and  Y <= data["maxy"] then
            if X >= data["minx"] and X <= data["maxx"] then
                button.draw(data["miny"], data["minx"], data["maxy"], data["maxx"], data["name"], Red)
                Func = data["func"]
            end
        end
    end
end

function light()
    Clear()
    conf.setlights()
    Touch()
    if Timeout2 then
        return
    end
    modem.send(server, Port, "light", Func)
    if Func == "turn all off" then
    else Room = Func
        _, _, _, _, _, State = event.pull("modem_message")
        conf.statelights(State, Room)
        Touch()
        if Func == "turn off" or Func == "turn on" then modem.send(server, Port, "light", Room, Func)
            local _, _, _, _, _, check = event.pull("modem_message")
            conf.lightscheck(check)
        end
        Func, State, Room = nil, nil, nil
    end
end

function door()
    Clear()
    conf.setdoors()
    Touch()
    if Timeout2 then
        return
    end
    if Func == "lock house" then
        lock.code(15, 34, Green)
        modem.send(server, Port, "door", Func, nil, Pass)
        local _, _, _, _, _, codecheck = event.pull("modem_message")
        if codecheck == "correct" then
            lock.codecheck(codecheck, 15, 34)
            for _, data in pairs(button2) do
                if Func == data["func"] then
                    button.draw(28, 10, 31, 70, data["opensentence"], Green)
                end
            end
        elseif codecheck == "wrong" then lock.codecheck(codecheck, 15, 34) end
    else
        modem.send(server, Port, "door", Func)
        Doorname = Func
        local _, _, _, _, _, status = event.pull("modem_message")
        conf.statedoors(status, Doorname)
        Touch()
        if Timeout2 then
            return
        end
        if Func == "no" then
        else lock.doorcode(Func, 22, 34)
        end
    end
end

function alarm()
    Clear()
    conf.setalarm()
    modem.broadcast(Port, "alarm")
    local _, _, _, _, _, status = event.pull("modem_message")
    conf.statealarm(status)
end

function lock.code(miny, minx, color)
    local maxx = minx + 12
    local maxy = miny + 11
    Backx = minx + 9
    Backy = miny + 9
    gpu.setBackground(Black)
    gpu.set(minx, miny, unicode.char(0x2552))
    gpu.set(minx + 1, miny, string.rep(unicode.char(0x2550), maxx - minx - 1))
    gpu.set(maxx, miny, unicode.char(0x2555))
    local frameheight = maxy - miny - 1
    gpu.fill(minx, miny + 1, 1, frameheight, unicode.char(0x2502))
    gpu.fill(maxx, miny + 1, 1, frameheight, unicode.char(0x2502))
    gpu.set(minx, maxy, unicode.char(0x2514))
    gpu.set(minx + 1, maxy, string.rep(unicode.char(0x2500), maxx - minx - 1))
    gpu.set(maxx, maxy, unicode.char(0x2518))
    gpu.setBackground(color)
    local width = maxx - minx - 1
    local height = maxy - miny - 1
    gpu.fill(minx + 1, miny + 1, width, height, " ")
    lock.setTable(minx + 3, miny + 3, "1")
    lock.setTable(minx + 6, miny + 3, "2")
    lock.setTable(minx + 9, miny + 3, "3")
    lock.setTable(minx + 3, miny + 5, "4")
    lock.setTable(minx + 6, miny + 5, "5")
    lock.setTable(minx + 9, miny + 5, "6")
    lock.setTable(minx + 3, miny + 7, "7")
    lock.setTable(minx + 6, miny + 7, "8")
    lock.setTable(minx + 9, miny + 7, "9")
    lock.setTable(minx + 6, miny + 9, "0")
    gpu.setBackground(Black)
    lock.Touch(minx, miny)
end
function lock.setTable(x, y, number)
    code[number] = {}
    code[number]["number"] = number
    code[number]["y"] = y
    code[number]["x"] = x
    gpu.set(x, y, number)
end
function lock.digit(x2, y2)
    while true do
        Num = nil
        _, _, X, Y, _, _ = event.pull(Timeoutcodepad, "touch")
        if X == nil and Y == nil then
            Timeout2 = true
            return
        else
            Timeout2 = false
        end
        gpu.setBackground(Green2)
        for _, data in pairs(code) do
            if X == data["x"] and Y == data["y"] then
                Num = data["number"]
                gpu.set(data["x"], data["y"], data["number"])
            end
        end
        if Num ~= nil or X == Backx and Y == Backy then break end
    end
    if X == Backx and Y == Backy then gpu.set(Backx, Backy, unicode.char(0x2190)) end
    gpu.setBackground(Green)
    if X == Backx and Y == Backy then os.sleep(0.5) gpu.set(Backx, Backy, unicode.char(0x2190)) else gpu.set(x2, y2, "*") end
    if Num ~= nil then
        os.sleep(0.5)
        gpu.set(X, Y, Num)
    end
end
function lock.Touch(minx, miny)
    ::GetD1::
    lock.digit(minx+ 3, miny + 1)
    if Timeout2 then return end
    D1 = Num
    gpu.set(Backx, Backy, unicode.char(0x2190))
    ::GetD2::
    lock.digit(minx + 5, miny + 1)
    if Timeout2 then return end
    D2 = Num
    if X == Backx and Y == Backy then gpu.set(minx + 3, miny + 1, " ") goto GetD1 end
    ::GetD3::
    lock.digit(minx+ 7, miny + 1)
    if Timeout2 then return end
    D3 = Num
    if X == Backx and Y == Backy then gpu.set(minx + 5, miny + 1, " ") goto GetD2 end
    lock.digit(minx+ 9, miny + 1)
    if Timeout2 then return end
    D4 = Num
    if X == Backx and Y == Backy then gpu.set(minx + 7, miny + 1, " ") goto GetD3 end
    Pass = D1..D2..D3..D4
end
function lock.codecheck(check, miny, minx)
    gpu.setBackground(Green)
    if check == "correct" then gpu.setForeground(Green2) computer.beep(500) computer.beep(1000) end
    if check == "wrong" then gpu.setForeground(Red) computer.beep(200) computer.beep(100) end
    gpu.set(minx + 3, miny + 1, "* * * *")
    Num, D1, D2, D3, D4, Pass = nil, nil, nil, nil, nil, nil
    gpu.setForeground(White)
end

function lock.doorcode(action, miny, minx)
    lock.code(miny, minx, Green)
    if Timeout2 then return end
    modem.send(server, Port, "door", Doorname, action, Pass)
    local _, _, _, _, _, codecheck, check = event.pull("modem_message")
    lock.codecheck(codecheck, miny, minx)
    if codecheck == "correct" then
        conf.checkdooraction(check, miny)
    end
    if codecheck == "wrong" then 
        os.sleep(1) 
        lock.doorcode(action, miny, minx) 
    end
end

function lock.alarmcode(action, miny, minx)
    lock.code(miny, minx, Green)
    if Timeout2 then return end
    modem.send(server, Port, "alarm", nil, action, Pass)
    local _, _, _, _, _, codecheck, check = event.pull("modem_message")
    lock.codecheck(codecheck, miny, minx)
    if codecheck == "correct" then
        conf.checkalarm(check, miny)
    end
    if codecheck == "wrong" then
        os.sleep(1)
        lock.alarmcode(action, miny, minx)
    end
end

while true do
    Clear()
    conf.setmenu()
    Touch()
    if Func == "lights" then
        light()
    end
    if Func == "doors" then
        door()
    end
    if Func == "alarm" then
        alarm()
    end
    os.sleep(2)
end
