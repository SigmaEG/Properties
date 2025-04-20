-- { Written by SigmaHelios } --

-- { Services } --

local HttpService = game:GetService("HttpService");

-- { Properties } --

local Properties = {
  FullAPIDumpContent = "https://raw.githubusercontent.com/MaximumADHD/Roblox-Client-Tracker/refs/heads/roblox/Full-API-Dump.json";
  APIDumpContent = "https://raw.githubusercontent.com/MaximumADHD/Roblox-Client-Tracker/refs/heads/roblox/API-Dump.json"
};
Properties.__index = Properties;

function Properties.new(Type: "FullAPIDump" | "APIDump")
  local self = {};
  self.APIDump = if (Type == "FullAPIDump") then Properties.GetFullAPIDump() else Properties.GetAPIDump();

  if (not self.APIDump) then
    return nil;
  end

  local function RecurseProperties(
    ReadProperties: {[string]: boolean},
    PropertiesToReturn: {[string]: any},
    OriginalInstance: Instance,
    ClassName: string,
    CheckDefault: boolean,
    PropertyValueAsString: boolean
  )
    for _, InstanceClass in ipairs(self.APIDump.Classes) do
      if (InstanceClass.Name == ClassName) then
        for _, Property in ipairs(InstanceClass.Members) do
          if (
            ReadProperties[string.lower(Property.Name)] or
            Property.MemberType ~= "Property" or
            (
              Property.Tags and (
                table.find(Property.Tags, "ReadOnly") or
                table.find(Property.Tags, "Hidden") or
                table.find(Property.Tags, "NotScriptable")
              )
            ) or (
              Property.Security and (
                Property.Security.Read ~= "None" or
                Property.Security.Write ~= "None"
              )
            )
          ) then
            continue;
          end

          local Success, Error = pcall(function()
            local PropertyValue: any = OriginalInstance[Property.Name];

            if (CheckDefault) then
              local CheckInstance: Instance = Instance.new(OriginalInstance.ClassName);

              if (CheckInstance[Property.Name] == PropertyValue) then
                CheckInstance:Destroy();

                return;
              end

              CheckInstance:Destroy();
            end
            
            if (Property.ValueType.Category == "DataType") then
              if (PropertyValueAsString) then
                PropertyValue = Properties.PropertyToString(Property.ValueType.Name, PropertyValue);
              end
            elseif (Property.ValueType.Category == "Class") then
              if (PropertyValueAsString) then
                PropertyValue = string.format("game.%s", PropertyValue:GetFullName());
              end
            elseif (Property.ValueType.Name == "string") then
              PropertyValue = string.format("\"%s\"", PropertyValue);
            end

            PropertiesToReturn[Property.Name] = PropertyValue;

            ReadProperties[string.lower(Property.Name)] = true;
          end)
          
          if (not Success) then
            warn("Failed to read property \"" .. Property.Name .. "\": ", Property.Security);
          end
        end
      
        if (InstanceClass.Superclass ~= "<<<ROOT>>>") then
          RecurseProperties(ReadProperties, PropertiesToReturn, OriginalInstance, InstanceClass.Superclass, CheckDefault, PropertyValueAsString);
        end

        break;
      end
    end
  end

    -- Gets all the Properties, and their values, that are different to the Default Object values from the Instance Class
  function self:GetPropertiesFilterDefault(Instance: Instance, PropertyValueAsString: boolean): {[string]: any}
    if (not self.APIDump) then
      return nil :: any;
    end

    local ReadProperties: {[string]: boolean} = {};
    local PropertiesToReturn: {[string]: any} = {};

    RecurseProperties(ReadProperties, PropertiesToReturn, Instance, Instance.ClassName, true, PropertyValueAsString);

    local Attributes: {[string]: any} = Instance:GetAttributes();

    for AttributeName, AttributeValue in pairs(Attributes) do
      if (not PropertiesToReturn["Attributes"]) then
        PropertiesToReturn["Attributes"] = {};
      end

      if (PropertyValueAsString) then
        PropertiesToReturn["Attributes"][AttributeName] = Properties.PropertyToString(typeof(AttributeValue), AttributeValue);
      else
        PropertiesToReturn["Attributes"][AttributeName] = AttributeValue;
      end
    end

    PropertiesToReturn["Tags"] = Instance:GetTags();

    return PropertiesToReturn;
  end

  -- Gets all the Properties, and their values, from the Instance Class
  function self:GetPropertiesNoFilter(Instance: Instance, PropertyValueAsString: boolean): {[string]: any}
    if (not self.APIDump) then
      return nil :: any;
    end

    local ReadProperties: {[string]: boolean} = {};
    local PropertiesToReturn: {[string]: any} = {};

    RecurseProperties(ReadProperties, PropertiesToReturn, Instance, Instance.ClassName, false, PropertyValueAsString);

    local Attributes: {[string]: any} = Instance:GetAttributes();

    for AttributeName, AttributeValue in pairs(Attributes) do
      if (not PropertiesToReturn["Attributes"]) then
        PropertiesToReturn["Attributes"] = {};
      end

      if (PropertyValueAsString) then
        PropertiesToReturn["Attributes"][AttributeName] = Properties.PropertyToString(typeof(AttributeValue), AttributeValue);
      else
        PropertiesToReturn["Attributes"][AttributeName] = AttributeValue;
      end
    end

    PropertiesToReturn["Tags"] = Instance:GetTags();

    return PropertiesToReturn;
  end

  function self:Destroy()
    if (self.Destroying) then
      return;
    end

    self.Destroying = true;

    setmetatable(self, nil);
    table.freeze(self);
  end

  return setmetatable(self, Properties);
end

-- Converts a property into a Source string i.e "Vector3.new(...)" or "Color3.fromRGB(...)"
function Properties.PropertyToString(PropertyName: string, PropertyValue: any): string
  local PropertyValueString: string = tostring(PropertyValue);

  local ClassString: string = string.format("%s.new(%s)", PropertyName, "%s");

  if (PropertyName == "Axes") then
    local PropertyAxes: Axes = PropertyValue;

    local XString: string = "";

    if (PropertyAxes.Left and PropertyAxes.Right) then
      XString = tostring(Enum.NormalId.Left) .. ", " .. tostring(Enum.NormalId.Right);
    else
      if (PropertyAxes.Left) then
        XString = tostring(Enum.NormalId.Left);
      elseif (PropertyAxes.Right) then
        XString = tostring(Enum.NormalId.Right)
      end
    end

    local YString: string = "";

    if (PropertyAxes.Top and PropertyAxes.Bottom) then
      YString = tostring(Enum.NormalId.Top) .. ", " .. tostring(Enum.NormalId.Bottom);
    else
      if (PropertyAxes.Top) then
        YString = tostring(Enum.NormalId.Top);
      elseif (PropertyAxes.Bottom) then
        YString = tostring(Enum.NormalId.Bottom)
      end
    end

    local ZString: string = "";

    if (PropertyAxes.Front and PropertyAxes.Back) then
      ZString = tostring(Enum.NormalId.Front) .. ", " .. tostring(Enum.NormalId.Back);
    else
      if (PropertyAxes.Front) then
        ZString = tostring(Enum.NormalId.Front);
      elseif (PropertyAxes.Back) then
        ZString = tostring(Enum.NormalId.Back)
      end
    end

    return string.format(
      ClassString,
      PropertyValueString
        :gsub("X", XString)
        :gsub("Y", YString)
        :gsub("Z", ZString)
    );
  elseif (PropertyName == "Faces") then
    return string.format(
      ClassString,
      PropertyValueString
        :gsub("Right", tostring(Enum.NormalId.Right))
        :gsub("Top", tostring(Enum.NormalId.Top))
        :gsub("Back", tostring(Enum.NormalId.Back))
        :gsub("Left", tostring(Enum.NormalId.Left))
        :gsub("Bottom", tostring(Enum.NormalId.Bottom))
        :gsub("Front", tostring(Enum.NormalId.Front))
    );
  elseif (PropertyName == "Color3") then
    local PropertyColor3: Color3 = PropertyValue;

    return string.format(
      "Color3.fromRGB(%s)",
      tostring(math.round(PropertyColor3.R * 255)).. ", "
      .. tostring(math.round(PropertyColor3.G * 255)) .. ", "
      .. tostring(math.round(PropertyColor3.B * 255))
    );
  elseif (PropertyName == "Font") then
    local PropertyFont: Font = PropertyValue;

    return string.format(
      ClassString,
      string.format("\"%s\", %s, %s",
        tostring(PropertyFont.Family),
        tostring(PropertyFont.Weight),
        tostring(PropertyFont.Style)
      )
    );
  elseif (PropertyName == "ColorSequence") then
    local PropertyColorSequence: ColorSequence = PropertyValue;

    local Keypoints: {ColorSequenceKeypoint} = PropertyColorSequence.Keypoints;
    local KeypointsString = "";

    for Index: number, Keypoint: ColorSequenceKeypoint in ipairs(Keypoints) do
      KeypointsString ..= Properties.PropertyToString("ColorSequenceKeypoint", Keypoint);

      if (Index < #Keypoints) then
        KeypointsString ..= ", "
      end
    end

    return string.format(ClassString, "{" .. KeypointsString .. "}");
  elseif (PropertyName == "ContentId") then
    return "\"" .. PropertyValueString .. "\"";
  elseif (PropertyName == "ColorSequenceKeypoint") then
    local PropertyColorSequenceKeypoint: ColorSequenceKeypoint = PropertyValue;

    return string.format(
      ClassString,
      string.format("%i, %s",
        PropertyColorSequenceKeypoint.Time,
        Properties.PropertyToString("Color3", PropertyColorSequenceKeypoint.Value)
      )
    );
  elseif (PropertyName == "BrickColor") then
    return string.format(ClassString, "\"" .. PropertyValueString .. "\"");
  elseif (PropertyName == "UDim2") then
    return string.format(ClassString, PropertyValueString:gsub("{", ""):gsub("}", ""));
  elseif (PropertyName == "UDim") then
    return string.format(ClassString, PropertyValueString:gsub("{", ""):gsub("}", ""));
  end

  return tostring(PropertyValueString);
end

-- Retrieves a full API dump of ROBLOX Classes, alongside default values/properties
function Properties.GetFullAPIDump(): {[string]: any}
  local Success, Data = pcall(function()
    local Response: any = HttpService:GetAsync(Properties.FullAPIDumpContent);
    local JSONDecoded: {[string]: any} | any = HttpService:JSONDecode(Response);

    return JSONDecoded;
  end)

  if (Success) then
    return Data;
  end

  error(Data);

  return nil :: any;
end

-- Retrieves an API dump of ROBLOX Classes
function Properties.GetAPIDump(): {[string]: any}
  local Success, Data = pcall(function()
    local Response: any = HttpService:GetAsync(Properties.APIDumpContent);
    local JSONDecoded: {[string]: any} | any = HttpService:JSONDecode(Response);

    return JSONDecoded;
  end)

  if (Success) then
    return Data;
  end

  error(Data);

  return nil :: any;
end

return Properties;