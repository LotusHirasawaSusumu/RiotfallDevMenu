--[[
    PlayersPage.lua
    Builds and dynamically updates the Players tab.
]]

local Components    = require("ui/Components")
local Theme         = require("ui/Theme")
local Services      = require("core/Services")
local TeamUtil      = require("util/TeamUtil")
local Loadout       = require("util/Loadout")

local PlayersPage   = {}

local cardRegistry  = {}   -- { [playerName] = { card, labels... } }
local containerRef  = nil

local function buildCard(player)
    if not containerRef then return end
    if cardRegistry[player.Name] then return end

    local enemy     = TeamUtil.isEnemy(player)
    local dotColor  = enemy and Theme.Accent or Theme.OnColor

    local card = Components.frame(containerRef,
        UDim2.new(1, 0, 0, 70), nil, Theme.Panel)
    Components.corner(card)
    Components.padding(card, 6, 6, 8, 8)
    Components.listLayout(card, nil, 2)

    -- Name row
    local nameRow = Components.frame(card,
        UDim2.new(1, 0, 0, 16), nil, Theme.Transparent, 1)

    local dot = Components.label(nameRow,
        "●  ", UDim2.new(0, 16, 1, 0), dotColor, true, Theme.SizeTiny)

    local nameLbl = Components.label(nameRow,
        player.Name,
        UDim2.new(1, -20, 1, 0),
        Theme.White, true, Theme.SizeBody)
    nameLbl.Position = UDim2.new(0, 16, 0, 0)

    local teamLbl = Components.label(card,
        "Team: " .. TeamUtil.getPlayerTeam(player),
        UDim2.new(1, 0, 0, 12), Theme.TextDim, false, Theme.SizeSmall)

    local ld        = Loadout.parse(player)
    local primLbl   = Components.label(card,
        "Primary: " .. (ld and ld.primary or "?"),
        UDim2.new(1, 0, 0, 12), Theme.TextDim, false, Theme.SizeTiny)

    local secLbl    = Components.label(card,
        "Secondary: " .. (ld and ld.secondary or "?"),
        UDim2.new(1, 0, 0, 12), Theme.TextDim, false, Theme.SizeTiny)

    cardRegistry[player.Name] = {
        card     = card,
        dot      = dot,
        teamLbl  = teamLbl,
        primLbl  = primLbl,
        secLbl   = secLbl,
    }
end

function PlayersPage.build(scroll)
    -- Container for cards
    local container = Components.frame(scroll,
        UDim2.new(1, -12, 0, 10), nil, Theme.Transparent, 1)
    container.LayoutOrder      = 1
    container.AutomaticSize    = Enum.AutomaticSize.Y
    Components.listLayout(container, nil, 4)
    containerRef = container

    -- Build initial cards
    for _, player in ipairs(Services.Players:GetPlayers()) do
        if player ~= Services.LP then
            buildCard(player)
        end
    end
end

-- Called by RenderLoop when on Players tab
function PlayersPage.refresh()
    for _, player in ipairs(Services.Players:GetPlayers()) do
        if player == Services.LP then continue end

        if not cardRegistry[player.Name] then
            buildCard(player)
            continue
        end

        local card      = cardRegistry[player.Name]
        local enemy     = TeamUtil.isEnemy(player)
        card.dot.TextColor3 = enemy and Theme.Accent or Theme.OnColor
        card.teamLbl.Text   = "Team: " .. TeamUtil.getPlayerTeam(player)

        local ld = Loadout.parse(player)
        if ld then
            card.primLbl.Text = "Primary: " .. ld.primary
            card.secLbl.Text  = "Secondary: " .. ld.secondary
        end
    end
end

function PlayersPage.removeCard(playerName)
    local card = cardRegistry[playerName]
    if card then
        card.card:Destroy()
        cardRegistry[playerName] = nil
    end
end

-- Called when new player joins
function PlayersPage.onPlayerAdded(player)
    task.delay(2, function()
        if player and player.Parent then
            buildCard(player)
        end
    end)
end

return PlayersPage