--this is a module script
local PointsManager = {}

local Teams = game:GetService("Teams")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Create a RemoteEvent to signal game end
local GameFinishedEvent = ReplicatedStorage:FindFirstChild("GameFinished")
if not GameFinishedEvent then
	GameFinishedEvent = Instance.new("RemoteEvent")
	GameFinishedEvent.Name = "GameFinished"
	GameFinishedEvent.Parent = ReplicatedStorage
end

-- ✅ Global counter for treasures collected
PointsManager.TotalTreasuresCollected = 0

-- Initialize leaderstats for each player when they join
local function setupPlayerLeaderstats(player)
	local leaderstats = player:FindFirstChild("leaderstats")
	if not leaderstats then
		leaderstats = Instance.new("Folder")
		leaderstats.Name = "leaderstats"
		leaderstats.Parent = player
	end

	-- Create or find Score value
	local scoreValue = leaderstats:FindFirstChild("Score")
	if not scoreValue then
		scoreValue = Instance.new("IntValue")
		scoreValue.Name = "Score"
		scoreValue.Parent = leaderstats
	end

	scoreValue.Value = 0
end

-- Initialize team scores at match start
function PointsManager.InitializeTeams()
	PointsManager.TotalTreasuresCollected = 0  -- Reset counter

	for _, player in pairs(Players:GetPlayers()) do
		setupPlayerLeaderstats(player)
	end

	Players.PlayerAdded:Connect(setupPlayerLeaderstats)
end

-- Add points and update leaderboard
function PointsManager.AddPoints(team, points)
	if team then
		local newScore = (team:GetAttribute("Score") or 0) + points
		team:SetAttribute("Score", newScore)

		-- Update all players in the team
		for _, player in pairs(team:GetPlayers()) do
			local leaderstats = player:FindFirstChild("leaderstats")
			if leaderstats then
				local scoreValue = leaderstats:FindFirstChild("Score")
				if scoreValue then
					scoreValue.Value = newScore
				end
			end
		end

		print("" .. points .. " points added to " .. team.Name .. ". New score: " .. newScore)
	end
end


local function freezeAllPlayers()
	for _, player in pairs(Players:GetPlayers()) do
		if player.Character then
			local humanoid = player.Character:FindFirstChild("Humanoid")
			if humanoid then
				humanoid.WalkSpeed = 0  -- Disable movement
				humanoid.JumpPower = 0  -- Disable jumping
			end
		end
	end
end


function PointsManager.IncrementTreasureCounter()
	PointsManager.TotalTreasuresCollected += 1
	print("Total Treasures Collected: " .. PointsManager.TotalTreasuresCollected)

	-- If 3 treasures are collected, fire GameFinished event
	if PointsManager.TotalTreasuresCollected >= 3 then
		-- Determine Winning Team
		local redScore = Teams:FindFirstChild("TeamRed"):GetAttribute("Score") or 0
		local blueScore = Teams:FindFirstChild("TeamBlue"):GetAttribute("Score") or 0
		local winningTeam = "tie"

		if redScore > blueScore then
			winningTeam = "TeamRed"
		elseif blueScore > redScore then
			winningTeam = "TeamBlue"
		end

		-- Find MVP (Player who found the most treasures)
		local highestTreasureCount = 0
		local MVP = "tie"
		for _, player in pairs(Players:GetPlayers()) do
			local leaderstats = player:FindFirstChild("leaderstats")
			if leaderstats then
				local personalScore = leaderstats:FindFirstChild("Score")
				if personalScore and personalScore.Value > highestTreasureCount then
					highestTreasureCount = personalScore.Value
					MVP = player.Name
				elseif personalScore and personalScore.Value == highestTreasureCount then
					MVP = "tie"
				end
			end
		end

		-- Debug Prints
		print("Game Over! Winning Team:", winningTeam)
		print("MVP:", MVP)

		-- Freeze all players before firing event
		freezeAllPlayers()

		-- Fire event to all clients
		GameFinishedEvent:FireAllClients(winningTeam, MVP)
	end
end

return PointsManager