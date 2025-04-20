# Properties v1.0.0
[Wally Package](https://wally.run/package/sigmaeg/properties)

- Requires [HttpService](https://create.roblox.com/docs/reference/engine/classes/HttpService).

- Retrieves the Properties from an Instance by referencing [MaximumADHD API Dump Repository](https://github.com/MaximumADHD/Roblox-Client-Tracker/tree/roblox).

- Specifying 'FullAPIDump' (string) or 'APIDump' (string) when using Properties.new() will determine which dumpfile to read.
`Properties.new("FullAPIDump") -- retrieves Full-API-Dump.json and returns a new Properties object with the dump in self.APIDump as a Dictionary`
`Properties.new("APIDump") -- retrieves API-Dump.json and returns a new Properties object with the dump in self.APIDump as a Dictionary`

- `Properties:GetPropertiesFilterDefault(...)` will not return any Properties that match the default values of the Instance, however `Properties:GetPropertiesNoFilter(...)` will.

- Properties.PropertyToString(...) converts a PropertyName (passed as a string of the type), given a PropertyValue, into a string i.e `CFrame.new(...)` or `Color3.fromRGB(...)`
`Properties.PropertyToString("CFrame", CFrame.new()) -- returns CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1) as a string`

- If you wish to interface with either API Dump yourself, you can either create a Properties object and access `self.APIDump`, or use `Properties.GetAPIDump()` or `Properties.GetFullAPIDump`

This package was originally created for my personal-use Reactify ( [GitHub](https://github.com/SigmaEG/Reactify), [Roblox Plugin](https://create.roblox.com/store/asset/103884846776749/Reactify) ) plugin, however I decided to release it as a Wally package as I have seen numerous DevForums where people have wanted to interface this capability in the past. It is also used inside of the plugin itself.
