# Properties
Requires [HttpService](https://create.roblox.com/docs/reference/engine/classes/HttpService).

Retrieves the Properties from an Instance by referencing [MaximumADHD API Dump Repository](https://github.com/MaximumADHD/Roblox-Client-Tracker/tree/roblox).

Specifying 'FullAPIDump' (string) or 'APIDump' (string) when using Properties.new() will determine which dumpfile to read.

Properties:GetPropertiesFilterDefault(...) will not return any Properties that match the default values of the Instance, however Properties:GetPropertiesNoFilter(...) will.

Properties.PropertyToString(...) converts a PropertyName (passed as a string of the type), given a PropertyValue, into a string i.e CFrame.new(...) or Color3.fromRGB(...)
