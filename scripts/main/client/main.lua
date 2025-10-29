local function WaitForActor(tag, handler, delay)
    local actors = UE.TArray(UE.AActor)
    UE.UGameplayStatics.GetAllActorsWithTag(HWorld, tag, actors)
    local actor = actors[1]
    if actor then 
        handler(actor)
    else
        Timer.SetTimeout(function()
            WaitForActor(tag, handler, delay)
        end, delay or 500)
    end
end

local function GetActorWithTag(tag)
    local actors = UE.TArray(UE.AActor)
    UE.UGameplayStatics.GetAllActorsWithTag(HWorld, tag, actors)
    print(tostring(actors))
    return actors[1]
end

local Dispatcher
local Host
local Widgets = {}

local function Destroy(widget)
    for i = 1, #Widgets do
        if Widgets[i] == widget then 
            table.remove(Widgets, i) 
            break 
        end
    end
    Host:DestroyWidget(widget)
    if #Widgets == 0 then Host:SetInputMode(0) end
end

local function DestroyLast()
    Host:DestroyWidget(Widgets[#Widgets])
    table.remove(Widgets, #Widgets)
    if #Widgets == 0 then Host:SetInputMode(0) end
end

local function Create()
    widget = Host:CreateWidget('main/client/ui/widget.html', '')
    table.insert(Widgets, widget)
    Host:SetInputMode(1)
    widget:SendEvent('resetDialog', UE.UJsonLibraryHelpers.ConstructNull())

    widget.OnEventReceive:Add(widget, function(_, widget, name, data, callback)
        if name == 'create' then 
            Create()
            UE.UWebInterfaceHelpers.WebInterfaceCallback_Call(callback, UE.UJsonLibraryHelpers.FromInteger(999))
        elseif name == 'close' then Destroy(widget)
        elseif name == 'unfocus' then 
            Host:SetInputMode(0)
            if UE.UJsonLibraryHelpers.JsonValue_IsValid(data) then
                Timer.SetTimeout(function()
                    Host:SetInputMode(1)
                end, UE.UJsonLibraryHelpers.ToInteger(data))
            end
        else
            print('Unknown event "' .. name .. '": ' .. UE.UJsonLibraryHelpers.JsonValue_Stringify(data, true))
        end
    end)
end

--WaitForActor('HInputDispatcher', function(dispatcher) WaitForActor('HWebUI', function(host)
--    Dispatcher = dispatcher
--    Host = host

    Dispatcher = GetActorWithTag('HInputDispatcher')
    Host = GetActorWithTag('HWebUI')

    print('!!! LUA: ')
    print(tostring(Dispatcher))
    print(tostring(Host))
    print(tostring(HPlayer))

    Dispatcher.OnKeyPressed:Add(Dispatcher, function(dispatcher, key)
        if key.KeyName == 'Z' then Host:SetInputMode(0)
        elseif key.KeyName == 'X' then DestroyLast()
        elseif key.KeyName == 'C' then Create()
        end

        local numKeyNames = {'One', 'Two', 'Three', 'Four', 'Five', 'Six', 'Seven', 'Eight', 'Nine'}
        for i = 1, #numKeyNames do if numKeyNames[i] == key.KeyName then 
            if Widgets[i] then Host:BringToFront(Widgets[i]) end
        end end
    end)

    Create()

--end) end)

function onShutdown()
    for i = 1, #Widgets do
        if Widgets[i] then Widgets[i]:Destroy() end
    end
end
