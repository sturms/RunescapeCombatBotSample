#cs ----------------------------------------------------------------------------

	AutoIt Version: 3.3.14.2
	Author:         Edgars Šturms

	Script Function:
	Template AutoIt script.

#ce ----------------------------------------------------------------------------

Global $TeleportTabletColor
Global $UseHomeTeleport

Func SetHomeTeleport()
	$mousePos = MouseGetPos()
	$TeleportTabletColor = PixelGetColor($mousePos[0], $mousePos[1])

	If (Not @error) Then
		ConsoleWrite('Home teleport set.' & @LF)
		Return True
	Else
		ConsoleWrite('Home teleport not set, something went wrong..' & @LF)
		Return False
	EndIf
EndFunc   ;==>SetHomeTeleport

Func TeleportToHome()
	If ($UseHomeTeleport) Then
		$pos = WinGetPos('RuneScape')
		$winW = $pos[2]
		$winH = $pos[3]
		$homeTeleportPxls = PixelSearch($winW / 2, $winH / 2, $winW, $winH, $TeleportTabletColor)
		If (Not @error) Then
			ConsoleWrite('Teleporting to home' & @LF)
			MouseClick("left", $homeTeleportPxls[0], $homeTeleportPxls[1])
		Else
			ConsoleWrite('Could not teleport to home.' & @LF)
		EndIf
		ConsoleWrite('Exitting bot.')
		Exit
	EndIf
EndFunc