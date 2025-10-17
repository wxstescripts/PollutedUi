local GuiSystem = {}
local Twen = game:GetService('TweenService');
local RunService = game:GetService('RunService');
local CurrentCamera = workspace.CurrentCamera;

function GuiSystem:Hash()
	local success, result = pcall(function()
		return string.reverse(string.gsub(game:GetService('HttpService'):GenerateGUID(false),'..',function(aa)
			return string.reverse(aa)
		end))
	end)
	if not success then
		warn("GuiSystem:Hash Error:", result)
		return tostring(math.random(1,1e9))
	end
	return result
end

local function Hiter(planePos, planeNormal, rayOrigin, rayDirection)
	local success, result, a = pcall(function()
		local n = planeNormal
		local d = rayDirection
		local v = rayOrigin - planePos

		local num = (n.x*v.x) + (n.y*v.y) + (n.z*v.z)
		local den = (n.x*d.x) + (n.y*d.y) + (n.z*d.z)
		local a = -num / den

		return rayOrigin + (a * rayDirection), a
	end)
	if not success then
		warn("Hiter Error:", result)
		return Vector3.new(), 0
	end
	return result, a
end

function GuiSystem.new(frame,NoAutoBackground)
	local success, result = pcall(function()
		local Part = Instance.new('Part',workspace);
		local DepthOfField = Instance.new('DepthOfFieldEffect',game:GetService('Lighting'));
		local SurfaceGui = Instance.new('SurfaceGui',Part);
		local BlockMesh = Instance.new("BlockMesh");

		BlockMesh.Parent = Part;

		Part.Material = Enum.Material.Glass;
		Part.Transparency = 1;
		Part.Reflectance = 1;
		Part.CastShadow = false;
		Part.Anchored = true;
		Part.CanCollide = false;
		Part.CanQuery = false;
		Part.CollisionGroup = GuiSystem:Hash();
		Part.Size = Vector3.new(1, 1, 1) * 0.01;
		Part.Color = Color3.fromRGB(0,0,0);

		Twen:Create(Part,TweenInfo.new(1,Enum.EasingStyle.Quint,Enum.EasingDirection.In),{
			Transparency = 0.8;
		}):Play()

		DepthOfField.Enabled = true;
		DepthOfField.FarIntensity = 1;
		DepthOfField.FocusDistance = 0;
		DepthOfField.InFocusRadius = 500;
		DepthOfField.NearIntensity = 1;

		SurfaceGui.AlwaysOnTop = true;
		SurfaceGui.Adornee = Part;
		SurfaceGui.Active = true;
		SurfaceGui.Face = Enum.NormalId.Front;
		SurfaceGui.ZIndexBehavior = Enum.ZIndexBehavior.Global;

		DepthOfField.Name = GuiSystem:Hash();
		Part.Name = GuiSystem:Hash();
		SurfaceGui.Name = GuiSystem:Hash();

		local C4 = {
			Update = nil,
			Collection = SurfaceGui,
			Enabled = true,
			Instances = {
				BlockMesh = BlockMesh,
				Part = Part,
				DepthOfField = DepthOfField,
				SurfaceGui = SurfaceGui,
			},
			Signal = nil
		};

		local Update = function()
			local ok, err = pcall(function()
				if not C4.Enabled then
					Twen:Create(Part,TweenInfo.new(1,Enum.EasingStyle.Quint),{
						Transparency = 1;
					}):Play()
				end;

				Twen:Create(Part,TweenInfo.new(1,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),{
					Transparency = 0.8;
				}):Play()

				local corner0 = frame.AbsolutePosition;
				local corner1 = corner0 + frame.AbsoluteSize;

				local ray0 = CurrentCamera.ScreenPointToRay(CurrentCamera,corner0.X, corner0.Y, 1);
				local ray1 = CurrentCamera.ScreenPointToRay(CurrentCamera,corner1.X, corner1.Y, 1);

				local planeOrigin = CurrentCamera.CFrame.Position + CurrentCamera.CFrame.LookVector * (0.05 - CurrentCamera.NearPlaneZ);

				local planeNormal = CurrentCamera.CFrame.LookVector;

				local pos0 = Hiter(planeOrigin, planeNormal, ray0.Origin, ray0.Direction);
				local pos1 = Hiter(planeOrigin, planeNormal, ray1.Origin, ray1.Direction);

				pos0 = CurrentCamera.CFrame:PointToObjectSpace(pos0);
				pos1 = CurrentCamera.CFrame:PointToObjectSpace(pos1);

				local size   = pos1 - pos0;
				local center = (pos0 + pos1) / 2;

				BlockMesh.Offset = center
				BlockMesh.Scale  = size / 0.0101;
				Part.CFrame = CurrentCamera.CFrame;

				if not NoAutoBackground then
					local _,updatec = pcall(function()
						local userSettings = UserSettings():GetService("UserGameSettings")
						local qualityLevel = userSettings.SavedQualityLevel.Value

						if qualityLevel < 8 then
							Twen:Create(frame,TweenInfo.new(1),{
								BackgroundTransparency = 0
							}):Play()
						else
							Twen:Create(frame,TweenInfo.new(1),{
								BackgroundTransparency = 0.4
							}):Play()
						end;
					end)
				end
			end)
			if not ok then warn("GuiSystem.Update Error:", err) end
		end

		C4.Update = Update;
		C4.Signal = RunService.RenderStepped:Connect(Update);

		local ok, err = pcall(function()
			C4.Signal2 = CurrentCamera:GetPropertyChangedSignal('CFrame'):Connect(function()
				Part.CFrame = CurrentCamera.CFrame;
			end);
		end)
		if not ok then warn("GuiSystem.Signal2 Connection Error:", err) end

		C4.Destroy = function()
			local ok, err = pcall(function()
				if C4.Signal then C4.Signal:Disconnect() end
				if C4.Signal2 then C4.Signal2:Disconnect() end
				C4.Update = function() end;
				Twen:Create(Part,TweenInfo.new(1),{
					Transparency = 1
				}):Play();
				DepthOfField:Destroy();
				Part:Destroy()
			end)
			if not ok then warn("GuiSystem.Destroy Error:", err) end
		end;

		return C4;
	end)
	if not success then
		warn("GuiSystem.new Error:", result)
		return {
			Update = function() end,
			Destroy = function() end,
			Instances = {},
			Enabled = false,
			Collection = nil,
			Signal = nil
		}
	end
	return result
end

return GuiSystem