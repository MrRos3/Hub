--// Salty

--// Stop the Timer

--// Practice + AI/Bot + 1v1 AutoStop

--// GameStationController Edition

--// VantaUI

--==================================================

-- SERVICES

--==================================================

local Players = game:GetService("Players")

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RunService = game:GetService("RunService")

local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer

local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

--==================================================

-- CLEAN OLD RUNTIME

--==================================================

local ENV =

    getgenv

    and getgenv()

    or _G

if ENV.__SALTY_STOP_TIMER then

    pcall(function()

        ENV.__SALTY_STOP_TIMER:Destroy()

    end)

end

local Runtime = {

    Alive = true,

    Connections = {},

    Window = nil,

}

function Runtime:AddConnection(connection)

    if connection then

        table.insert(

            self.Connections,

            connection

        )

    end

    return connection

end

function Runtime:Connect(signal, callback)

    local connection =

        signal:Connect(callback)

    return self:AddConnection(

        connection

    )

end

function Runtime:Destroy()

    if not self.Alive then

        return

    end

    self.Alive = false

    for _, connection in ipairs(

        self.Connections

    ) do

        pcall(function()

            connection:Disconnect()

        end)

    end

    table.clear(

        self.Connections

    )

    if self.Window then

        pcall(function()

            self.Window:Destroy()

        end)

    end

end

ENV.__SALTY_STOP_TIMER =

    Runtime

--==================================================

-- CONFIG

--==================================================

local CONFIG = {

    Enabled = true,

    Practice = true,

    Matches = true,

    Continuous = true,

    ------------------------------------------------

    -- Positive = click EARLIER.

    -- Negative = click LATER.

    --

    -- Start at 0.

    ------------------------------------------------

    TimingTrimMS = 0,

    ------------------------------------------------

    -- Final precision stage.

    --

    -- We sleep normally until close to target,

    -- then only spin for a tiny few milliseconds.

    ------------------------------------------------

    PrecisionSpinMS = 7,

    Debug = false,

}

--==================================================

-- CONTROLLERS

--==================================================

local Controllers =

    LocalPlayer

        :WaitForChild("PlayerScripts")

        :WaitForChild("Client")

        :WaitForChild("Controllers")

local GameStationModule =

    Controllers:WaitForChild(

        "GameStationController"

    )

local PracticeModule =

    Controllers:WaitForChild(

        "PracticeController"

    )

local GameStationController =

    require(

        GameStationModule

    )

--==================================================

-- UI

--==================================================

local GameUI =

    PlayerGui:WaitForChild(

        "GameUI"

    )

local GameHitbox =

    GameUI:WaitForChild(

        "Hitbox"

    )

local GameSeconds =

    GameUI:WaitForChild(

        "SecondsToSet"

    )

local PracticeUI =

    PlayerGui:WaitForChild(

        "PracticeUI"

    )

local PracticeHitbox =

    PracticeUI:WaitForChild(

        "Hitbox"

    )

local PracticeSeconds =

    PracticeUI:WaitForChild(

        "SecondsToSet"

    )

--==================================================

-- PRACTICE TIMER

--==================================================

local PracticeArea =

    Workspace:WaitForChild(

        "PracticeArea"

    )

local PracticeCore =

    PracticeArea:WaitForChild(

        "Core"

    )

local PracticeTimerRoot =

    PracticeCore:WaitForChild(

        "Timer"

    )

local PracticeViewUI =

    PracticeTimerRoot:FindFirstChild(

        "ViewUI",

        true

    )

local PracticeTimerText =

    PracticeViewUI

    and PracticeViewUI:FindFirstChild(

        "TimerText"

    )

--==================================================

-- EXECUTOR HELPERS

--==================================================

local GetUpvalues =

    debug

    and debug.getupvalues

    or getupvalues

--==================================================

-- STATE

--==================================================

local State = {

    Mode = "Idle",

    Target = nil,

    Deadline = nil,

    CurrentTimer = nil,

    Fired = false,

    Fires = 0,

    CurrentToken = 0,

    ContinuousIndex = nil,

    ContinuousCount = nil,

    LastErrorMS = nil,

    LastMethod = "None",

    LastStatus =

        "Waiting for a turn",

    LastSource =

        "None",

}

--==================================================

-- HELPERS

--==================================================

local function StripRichText(text)

    return tostring(

        text or ""

    ):gsub(

        "<.->",

        ""

    )

end

local function ParseTargetText(object)

    if not object then

        return nil

    end

    local text =

        StripRichText(

            object.Text

        )

    local number =

        text:match(

            "(%d+%.%d+)"

        )

    return number

        and tonumber(number)

        or nil

end

local function ParsePracticeTimer()

    if not PracticeTimerText then

        return nil

    end

    return tonumber(

        PracticeTimerText.Text

    )

end

--==================================================

-- EXACT HITBOX PRESS

--==================================================

local function TriggerHitbox(

    hitbox,

    mode

)

    if not Runtime.Alive

        or not hitbox

        or not hitbox.Parent

    then

        return false

    end

    ------------------------------------------------

    -- First choice:

    -- fire the exact GUI signal used by the game.

    ------------------------------------------------

    if firesignal then

        local success, err =

            pcall(

                firesignal,

                hitbox.MouseButton1Down

            )

        if success then

            State.Fires += 1

            State.LastMethod =

                mode

                    .. " Hitbox"

            State.LastStatus =

                "Button fired"

            return true

        end

        if CONFIG.Debug then

            warn(

                "[Salty] firesignal failed:",

                err

            )

        end

    end

    ------------------------------------------------

    -- Fallback:

    -- invoke the game's connected callback.

    ------------------------------------------------

    if getconnections then

        local success,

            connections =

            pcall(

                getconnections,

                hitbox.MouseButton1Down

            )

        if success

            and type(connections)

                == "table"

        then

            for _, connection in ipairs(

                connections

            ) do

                if connection.Function then

                    local ok, err =

                        pcall(

                            connection.Function

                        )

                    if ok then

                        State.Fires += 1

                        State.LastMethod =

                            mode

                                .. " Connection"

                        State.LastStatus =

                            "Button fired"

                        return true

                    end

                    if CONFIG.Debug then

                        warn(

                            "[Salty] callback failed:",

                            err

                        )

                    end

                end

            end

        end

    end

    State.LastMethod =

        "Failed"

    State.LastStatus =

        "Could not trigger hitbox"

    return false

end

--==================================================

-- PRECISION SCHEDULER

--==================================================

local function WaitUntil(

    absoluteTime,

    token

)

    local trim =

        CONFIG.TimingTrimMS

        / 1000

    local fireAt =

        absoluteTime

        - trim

    ------------------------------------------------

    -- Normal sleeping while we're far away.

    ------------------------------------------------

    while Runtime.Alive

        and token

            == State.CurrentToken

    do

        local now =

            Workspace:GetServerTimeNow()

        local remaining =

            fireAt - now

        if remaining <= 0 then

            return true

        end

        local spinWindow =

            CONFIG.PrecisionSpinMS

            / 1000

        if remaining

            > spinWindow + 0.010

        then

            task.wait(

                math.min(

                    0.05,

                    remaining

                        - spinWindow

                )

            )

        else

            break

        end

    end

    if not Runtime.Alive

        or token

            ~= State.CurrentToken

    then

        return false

    end

    ------------------------------------------------

    -- Tiny final precision section.

    --

    -- This only runs for a few milliseconds,

    -- not continuously.

    ------------------------------------------------

    while Runtime.Alive

        and token

            == State.CurrentToken

        and Workspace:GetServerTimeNow()

            < fireAt

    do

    end

    return Runtime.Alive

        and token

            == State.CurrentToken

end

--==================================================

-- SCHEDULE A MATCH CLICK

--==================================================

local function ScheduleMatchClick(

    deadline,

    token,

    index,

    total

)

    task.spawn(function()

        if not WaitUntil(

            deadline,

            token

        ) then

            return

        end

        if not CONFIG.Enabled

            or not CONFIG.Matches

        then

            return

        end

        ------------------------------------------------

        -- The game's click handler itself checks

        -- handcuffs / duplicate presses / validity.

        ------------------------------------------------

        local now =

            Workspace:GetServerTimeNow()

        State.LastErrorMS =

            (

                now

                    - deadline

            ) * 1000

        State.Deadline =

            deadline

        State.ContinuousIndex =

            index

        State.ContinuousCount =

            total

        local success =

            TriggerHitbox(

                GameHitbox,

                "Match"

            )

        if CONFIG.Debug then

            print(

                "[Salty] MATCH FIRE"

            )

            print(

                "  deadline:",

                string.format(

                    "%.6f",

                    deadline

                )

            )

            print(

                "  actual:",

                string.format(

                    "%.6f",

                    now

                )

            )

            print(

                "  error:",

                string.format(

                    "%+.3fms",

                    State.LastErrorMS

                )

            )

            print(

                "  hit:",

                index,

                "/",

                total,

                success

            )

        end

    end)

end

--==================================================

-- GAMESTATION PLAYER TURN

--==================================================

local MatchConnection =

    GameStationController

        .PlayerTurnEvent

        :Connect(

            function(data)

                if not Runtime.Alive

                    or not CONFIG.Matches

                    or type(data)

                        ~= "table"

                then

                    return

                end

                ------------------------------------------------

                -- GameStationController:

                --

                -- data[1] = player whose turn it is

                ------------------------------------------------

                if data[1]

                    ~= LocalPlayer

                then

                    return

                end

                State.CurrentToken += 1

                local token =

                    State.CurrentToken

                State.Mode =

                    "AI / Bot / 1v1"

                State.Fired =

                    false

                State.LastSource =

                    "GameStationController.PlayerTurnEvent"

                ------------------------------------------------

                -- Decompiled mapping:

                --

                -- u14 = data[2]

                -- u15 = data[3]

                -- u16 = data[4]

                -- u17 = data[5]

                --

                -- continuousTargets = data[8]

                -- continuousWindow  = data[9]

                ------------------------------------------------

                local anchorTime =

                    tonumber(

                        data[2]

                    )

                local target =

                    tonumber(

                        data[3]

                    )

                local speed =

                    tonumber(

                        data[4]

                    )

                    or 1

                local continuousTargets =

                    data[8]

                if not anchorTime

                    or not target

                then

                    State.LastStatus =

                        "Invalid turn data"

                    return

                end

                State.Target =

                    target

                ------------------------------------------------

                -- CONTINUOUS MODE

                --

                -- ourTurnContinuous:

                --

                -- start = p1 - p2

                --

                -- perfect[i] =

                -- start + targetTimes[i]

                ------------------------------------------------

                if type(continuousTargets)

                    == "table"

                then

                    if not CONFIG.Continuous then

                        State.LastStatus =

                            "Continuous disabled"

                        return

                    end

                    local startTime =

                        anchorTime

                        - target

                    local count =

                        #continuousTargets

                    State.Mode =

                        "Continuous"

                    State.ContinuousIndex =

                        0

                    State.ContinuousCount =

                        count

                    State.LastStatus =

                        "Continuous targets acquired"

                    if CONFIG.Debug then

                        print(

                            "[Salty] CONTINUOUS TURN"

                        )

                        print(

                            "start:",

                            startTime

                        )

                        print(

                            "targets:",

                            count

                        )

                    end

                    for index,

                        targetOffset

                    in ipairs(

                        continuousTargets

                    ) do

                        if type(targetOffset)

                            == "number"

                        then

                            local deadline =

                                startTime

                                + targetOffset

                            ScheduleMatchClick(

                                deadline,

                                token,

                                index,

                                count

                            )

                        end

                    end

                    return

                end

                ------------------------------------------------

                -- NORMAL MODE

                --

                -- displayTime:

                --

                -- displayed =

                -- (

                --   now - (anchor-target)

                -- ) * speed

                --

                -- displayed == target when:

                --

                -- now =

                -- anchor-target

                -- + target/speed

                ------------------------------------------------

                local startTime =

                    anchorTime

                    - target

                local perfectDeadline =

                    startTime

                    + (

                        target

                        / speed

                    )

                State.Deadline =

                    perfectDeadline

                State.LastStatus =

                    "Exact match deadline acquired"

                State.ContinuousIndex =

                    nil

                State.ContinuousCount =

                    nil

                if CONFIG.Debug then

                    print("")

                    print(

                        "=============================="

                    )

                    print(

                        "[Salty] YOUR MATCH TURN"

                    )

                    print(

                        "target:",

                        target

                    )

                    print(

                        "speed:",

                        speed

                    )

                    print(

                        "anchor:",

                        anchorTime

                    )

                    print(

                        "start:",

                        startTime

                    )

                    print(

                        "perfect:",

                        perfectDeadline

                    )

                    print(

                        "remaining:",

                        perfectDeadline

                            - Workspace:GetServerTimeNow()

                    )

                end

                ScheduleMatchClick(

                    perfectDeadline,

                    token,

                    1,

                    1

                )

            end

        )

Runtime:AddConnection(

    MatchConnection

)

--==================================================

-- PRACTICE DEADLINE SCANNER

--==================================================

local function FindPracticeDeadline()

    if not getgc

        or not GetUpvalues

        or not PracticeTimerText

    then

        return nil

    end

    local target =

        ParseTargetText(

            PracticeSeconds

        )

    if not target then

        return nil

    end

    local now =

        Workspace:GetServerTimeNow()

    local ok, objects =

        pcall(

            getgc,

            true

        )

    if not ok

        or type(objects)

            ~= "table"

    then

        return nil

    end

    ------------------------------------------------

    -- Practice displayTime spawned function has:

    --

    -- p2        = target duration

    -- p1        = exact deadline

    -- TimerText = practice timer label

    ------------------------------------------------

    for _, object in ipairs(

        objects

    ) do

        if type(object)

            ~= "function"

        then

            continue

        end

        local success,

            upvalues =

            pcall(

                GetUpvalues,

                object

            )

        if not success

            or type(upvalues)

                ~= "table"

        then

            continue

        end

        local foundTimer =

            false

        local foundTarget =

            false

        local deadline =

            nil

        for _, value in pairs(

            upvalues

        ) do

            if value

                == PracticeTimerText

            then

                foundTimer =

                    true

            elseif type(value)

                == "number"

            then

                if math.abs(

                    value - target

                ) < 0.01

                then

                    foundTarget =

                        true

                end

                ------------------------------------------------

                -- Absolute server timestamp candidate.

                ------------------------------------------------

                if value > now

                    and value

                        < now

                            + target

                            + 2

                then

                    if not deadline

                        or value

                            > deadline

                    then

                        deadline =

                            value

                    end

                end

            end

        end

        if foundTimer

            and foundTarget

            and deadline

        then

            return deadline

        end

    end

    return nil

end

--==================================================

-- PRACTICE ROUND

--==================================================

local function AcquirePracticeRound()

    if not CONFIG.Enabled

        or not CONFIG.Practice

    then

        return

    end

    local target =

        ParseTargetText(

            PracticeSeconds

        )

    if not target then

        return

    end

    State.CurrentToken += 1

    local token =

        State.CurrentToken

    State.Mode =

        "Practice"

    State.Target =

        target

    State.Deadline =

        nil

    State.LastSource =

        "PracticeController displayTime"

    State.LastStatus =

        "Finding practice deadline"

    task.spawn(function()

        local deadline =

            nil

        ------------------------------------------------

        -- bindInteraction/displayTime is created just

        -- after SecondsToSet changes.

        ------------------------------------------------

        for _ = 1, 30 do

            if not Runtime.Alive

                or token

                    ~= State.CurrentToken

            then

                return

            end

            deadline =

                FindPracticeDeadline()

            if deadline then

                break

            end

            task.wait(

                0.02

            )

        end

        if not deadline then

            State.LastStatus =

                "Practice deadline not found"

            if CONFIG.Debug then

                warn(

                    "[Salty] Practice deadline not found"

                )

            end

            return

        end

        State.Deadline =

            deadline

        State.LastStatus =

            "Exact practice deadline acquired"

        if CONFIG.Debug then

            print(

                "[Salty] PRACTICE"

            )

            print(

                "target:",

                target

            )

            print(

                "deadline:",

                deadline

            )

        end

        if not WaitUntil(

            deadline,

            token

        ) then

            return

        end

        if not CONFIG.Enabled

            or not CONFIG.Practice

        then

            return

        end

        local now =

            Workspace:GetServerTimeNow()

        State.LastErrorMS =

            (

                now

                    - deadline

            ) * 1000

        TriggerHitbox(

            PracticeHitbox,

            "Practice"

        )

    end)

end

--==================================================

-- PRACTICE TARGET WATCHER

--==================================================

Runtime:Connect(

    PracticeSeconds:GetPropertyChangedSignal(

        "Text"

    ),

    function()

        if not CONFIG.Practice then

            return

        end

        local target =

            ParseTargetText(

                PracticeSeconds

            )

        if target then

            AcquirePracticeRound()

        end

    end

)

--==================================================

-- PRACTICE TIMER STATUS

--==================================================

if PracticeTimerText then

    Runtime:Connect(

        PracticeTimerText:GetPropertyChangedSignal(

            "Text"

        ),

        function()

            if State.Mode

                ~= "Practice"

            then

                return

            end

            local timer =

                ParsePracticeTimer()

            if timer then

                State.CurrentTimer =

                    timer

            end

        end

    )

end

--==================================================

-- MATCH TIMER STATUS

--==================================================

task.spawn(function()

    while Runtime.Alive do

        task.wait(

            0.05

        )

        if State.Mode == "Practice" then

            continue

        end

        ------------------------------------------------

        -- We don't use this value for timing.

        -- This is STATUS DISPLAY ONLY.

        ------------------------------------------------

        local best =

            nil

        for _, object in ipairs(

            Workspace:GetDescendants()

        ) do

            if object.Name == "TimerText"

                and object:IsA(

                    "TextLabel"

                )

            then

                local numeric =

                    tonumber(

                        object.Text

                    )

                if numeric

                    and numeric >= 0

                then

                    if not best

                        or numeric > best

                    then

                        best =

                            numeric

                    end

                end

            end

        end

        if best then

            State.CurrentTimer =

                best

        end

    end

end)

--==================================================

-- VANTA UI

--==================================================

local VantaUI =

    loadstring(

        game:HttpGet(

            "https://raw.githubusercontent.com/MrRos3/VantaUI/main/main.lua"

        )

    )()

local Window =

    VantaUI:CreateWindow({

        Title =

            "Salty",

        Icon =

            "timer",

        Theme =

            "Salty Special",

        StartupTab =

            "Auto",

        HideSearchBar =

            true,

        ToggleKey =

            Enum.KeyCode.RightShift,

        Branding = {

            Name =

                "SALTY",

            Image =

                VantaUI.Brand.Image,

            Folder =

                "SaltyStopTimer",

            IconSize =

                24,

            IconRadius =

                7,

            OpenButtonIconRadius =

                8,

            Intro =

                false,

        },

        OpenButton = {

            Title =

                "Open Salty",

            Enabled =

                true,

            Draggable =

                true,

            OnlyMobile =

                false,

            OnlyIcon =

                true,

            CornerRadius =

                UDim.new(

                    0,

                    11

                ),

            StrokeThickness =

                2,

            ImageZoom =

                1,

            Color =

                ColorSequence.new({

                    ColorSequenceKeypoint.new(

                        0,

                        Color3.new(

                            0,

                            0,

                            0

                        )

                    ),

                    ColorSequenceKeypoint.new(

                        1,

                        Color3.new(

                            0,

                            0,

                            0

                        )

                    ),

                }),

        },

    })

Runtime.Window =

    Window

Window:Tag({

    Title =

        "STOP TIMER",

    Icon =

        "crosshair",

    Color =

        Color3.fromHex(

            "#151116"

        ),

    Border =

        true,

})

--==================================================

-- TABS

--==================================================

local Auto =

    Window:Tab({

        Title =

            "Auto",

        Icon =

            "timer",

    })

local Settings =

    Window:Tab({

        Title =

            "Settings",

        Icon =

            "settings",

    })

--==================================================

-- STATUS

--==================================================

local Status =

    Auto:Section({

        Title =

            "Perfect AutoStop",

        Desc =

            "Waiting for a turn...",

        Icon =

            "activity",

        Box =

            true,

    })

Auto:Paragraph({

    Title =

        "Native Timing",

    Desc =

        "Practice uses PracticeController. AI, bots and player matches use GameStationController.PlayerTurnEvent. No screen timing is used for the actual stop.",

})

--==================================================

-- AUTO CONTROLS

--==================================================

Auto:Toggle({

    Title =

        "Auto Stop",

    Desc =

        "Automatically stop at the exact target.",

    Icon =

        "target",

    Value =

        CONFIG.Enabled,

    Callback = function(value)

        CONFIG.Enabled =

            value

    end,

})

Auto:Toggle({

    Title =

        "Practice",

    Desc =

        "Enable AutoStop on the Practice machine.",

    Icon =

        "dumbbell",

    Value =

        CONFIG.Practice,

    Callback = function(value)

        CONFIG.Practice =

            value

    end,

})

Auto:Toggle({

    Title =

        "AI / Bot / 1v1",

    Desc =

        "Uses GameStationController timing data for real matches.",

    Icon =

        "swords",

    Value =

        CONFIG.Matches,

    Callback = function(value)

        CONFIG.Matches =

            value

    end,

})

Auto:Toggle({

    Title =

        "Continuous Mode",

    Desc =

        "Automatically hit every requested time in continuous rounds.",

    Icon =

        "list-checks",

    Value =

        CONFIG.Continuous,

    Callback = function(value)

        CONFIG.Continuous =

            value

    end,

})

Auto:Slider({

    Title =

        "Timing Trim",

    Desc =

        "Milliseconds. Positive = earlier, negative = later.",

    Value = {

        Min = -20,

        Max = 20,

        Default =

            CONFIG.TimingTrimMS,

    },

    Step =

        1,

    Callback = function(value)

        CONFIG.TimingTrimMS =

            tonumber(value)

    end,

})

Auto:Button({

    Title =

        "Test Current Hitbox",

    Desc =

        "Trigger whichever game button is currently active.",

    Icon =

        "mouse-pointer-click",

    Callback = function()

        if GameHitbox.Visible then

            TriggerHitbox(

                GameHitbox,

                "Match Test"

            )

        elseif PracticeHitbox.Visible then

            TriggerHitbox(

                PracticeHitbox,

                "Practice Test"

            )

        else

            VantaUI:Notify({

                Content =

                    "No active button hitbox.",

                Icon =

                    "triangle-alert",

            })

        end

    end,

})

--==================================================

-- SETTINGS

--==================================================

Settings:Toggle({

    Title =

        "Debug",

    Desc =

        "Print target/deadline/error information.",

    Icon =

        "terminal",

    Value =

        CONFIG.Debug,

    Callback = function(value)

        CONFIG.Debug =

            value

    end,

})

Settings:Slider({

    Title =

        "Precision Spin",

    Desc =

        "Final few milliseconds reserved for precise timing.",

    Value = {

        Min = 2,

        Max = 12,

        Default =

            CONFIG.PrecisionSpinMS,

    },

    Step =

        1,

    Callback = function(value)

        CONFIG.PrecisionSpinMS =

            tonumber(value)

    end,

})

Settings:Button({

    Title =

        "Salty Special",

    Icon =

        "sparkles",

    Callback = function()

        VantaUI:SetTheme(

            "Salty Special"

        )

    end,

})

Settings:Button({

    Title =

        "Vanta Dark",

    Icon =

        "moon",

    Callback = function()

        VantaUI:SetTheme(

            "Vanta Dark"

        )

    end,

})

Settings:Button({

    Title =

        "Vanta AMOLED",

    Icon =

        "circle-dot",

    Callback = function()

        VantaUI:SetTheme(

            "Vanta AMOLED"

        )

    end,

})

Settings:Button({

    Title =

        "Stop Script",

    Icon =

        "power",

    Callback = function()

        CONFIG.Enabled =

            false

        State.CurrentToken += 1

        Runtime:Destroy()

    end,

})

--==================================================

-- STATUS UPDATE

--==================================================

task.spawn(function()

    local lastText =

        nil

    while Runtime.Alive do

        task.wait(

            0.20

        )

        local remaining =

            nil

        if State.Deadline then

            remaining =

                State.Deadline

                - Workspace:GetServerTimeNow()

        end

        local targetText =

            State.Target

            and string.format(

                "%.2f",

                State.Target

            )

            or "--"

        local timerText =

            State.CurrentTimer

            and string.format(

                "%.2f",

                State.CurrentTimer

            )

            or "--"

        local deadlineText =

            State.Deadline

            and string.format(

                "%.6f",

                State.Deadline

            )

            or "--"

        local remainingText =

            remaining

            and string.format(

                "%.3f s",

                remaining

            )

            or "--"

        local errorText =

            State.LastErrorMS

            and string.format(

                "%+.3f ms",

                State.LastErrorMS

            )

            or "--"

        local continuousText =

            ""

        if State.ContinuousCount then

            continuousText =

                "\nContinuous: "

                .. tostring(

                    State.ContinuousIndex

                    or 0

                )

                .. "/"

                .. tostring(

                    State.ContinuousCount

                )

        end

        local text =

            "Mode: "

            .. tostring(

                State.Mode

            )

            .. "\n"

            .. "Timer: "

            .. timerText

            .. "\n"

            .. "Target: "

            .. targetText

            .. "\n"

            .. "Deadline: "

            .. deadlineText

            .. "\n"

            .. "Remaining: "

            .. remainingText

            .. continuousText

            .. "\n"

            .. "Last timing error: "

            .. errorText

            .. "\n"

            .. "Auto presses: "

            .. tostring(

                State.Fires

            )

            .. "\n"

            .. "Method: "

            .. tostring(

                State.LastMethod

            )

            .. "\n"

            .. "Status: "

            .. tostring(

                State.LastStatus

            )

            .. "\n\n"

            .. "Source:\n"

            .. tostring(

                State.LastSource

            )

        if text ~= lastText then

            lastText =

                text

            Status:SetDesc(

                text

            )

        end

    end

end)

--==================================================

-- READY

--==================================================

VantaUI:Notify({

    Title =

        "Salty",

    Content =

        "Practice + AI/Bot/1v1 AutoStop loaded 🩵",

    Icon =

        "target",

})

print(

    "[Salty] GameStationController:",

    GameStationModule:GetFullName()

)

print(

    "[Salty] PlayerTurnEvent connected"

)
