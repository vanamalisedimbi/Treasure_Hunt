local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Teams = game:GetService("Teams")
local PointsManager = require(game.ServerScriptService:WaitForChild("PointsManager"))

local GameFinishedEvent = ReplicatedStorage:WaitForChild("GameFinished")

-- Function to freeze all players
local function freezePlayers()
	for _, player in pairs(Players:GetPlayers()) do
		if player.Character then
			local humanoid = player.Character:FindFirstChild("Humanoid")
			if humanoid then
				humanoid.WalkSpeed = 0
				humanoid.JumpPower = 0
			end
		end
	end
end

-- Function to determine the winning team
local function getWinningTeam()
	local redScore = Teams.TeamRed:GetAttribute("Score") or 0
	local blueScore = Teams.TeamBlue:GetAttribute("Score") or 0

	if redScore > blueScore then
		return Teams.TeamRed
	elseif blueScore > redScore then
		return Teams.TeamBlue
	else
		return nil  -- It's a tie
	end
end

-- Function to determine the MVP
local function getMVP()
	local highestScore = 0
	local mvpPlayer = nil
	local isTie = false

	for _, player in pairs(Players:GetPlayers()) do
		local leaderstats = player:FindFirstChild("leaderstats")
		if leaderstats then
			local scoreValue = leaderstats:FindFirstChild("Score")
			if scoreValue then
				if scoreValue.Value > highestScore then
					highestScore = scoreValue.Value
					mvpPlayer = player
					isTie = false
				elseif scoreValue.Value == highestScore and highestScore > 0 then
					isTie = true
				end
			end
		end
	end

	if isTie then
		return "Great joint effort team!"
	elseif mvpPlayer then
		return mvpPlayer.Name
	else
		return nil
	end
end

-- Function to handle game end
local function onGameFinished()
	freezePlayers()
	local winningTeam = getWinningTeam()
	local mvpName = getMVP()

	if winningTeam then
		-- Fire event to all players with winning team name and MVP
		GameFinishedEvent:FireAllClients(winningTeam.Name, winningTeam.TeamColor.Color, mvpName)
	else
		-- Fire event for a tie game
		GameFinishedEvent:FireAllClients("Tie", Color3.new(1, 1, 1), "Great joint effort team!")
	end
end

-- Connect the event
GameFinishedEvent.OnServerEvent:Connect(onGameFinished)