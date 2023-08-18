' Calls a batch script to call the powershell script. This is the easiest way
' to run a powershell script without a command window

' set working directory
Set WinScriptHost = CreateObject("WScript.Shell")
Set fso = CreateObject("Scripting.FileSystemObject")
GetCurrentFolder= fso.GetParentFolderName(WScript.ScriptFullName)
WinScriptHost.CurrentDirectory = GetCurrentFolder

' call the batch script
WinScriptHost.Run Chr(34) & "discord compressor.bat" & Chr(34) & Chr(34) & WScript.Arguments.item(0) & Chr(34), 0
Set WinScriptHost = Nothing