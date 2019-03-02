#cs ----------------------------------------------------------------------------

	AutoIt Version: 3.3.14.2
	Author:         Edgars Šturms

	Script Function:
	Template AutoIt script.

#ce ----------------------------------------------------------------------------

Local Const $PlayNowButtonColor = 0xBB5908
Local $restingInProgress = False
Local $exitedToLobby = False
Local $currentTimeSpentInRestingSeconds = 0

Global $CurrentTimeInCombatSeconds = 0
Global $FightingDuration
Global $RestingDuration
Global $ExitToLobbyButtonPosX
Global $ExitToLobbyButtonPosY
Global $UseResting
Global $StopResting = False
Global $IsCameraReset = False

Func SetExitToLobby()
	$mousePos = MouseGetPos()
	$ExitToLobbyButtonPosX = $mousePos[0]
	$ExitToLobbyButtonPosY = $mousePos[1]

	If (Not @error) Then
		ConsoleWrite('Exit to lobby button set with coordinates- X: ' & $ExitToLobbyButtonPosX & ' Y: ' & $ExitToLobbyButtonPosY  & @LF)
		Return True
	Else
		ConsoleWrite('Exit to lobby button not set, something went wrong..' & @LF)
		Return False
	EndIf
EndFunc

Func TakeABreak()
	If ($UseResting) Then
		ExitToLobby()
		$restingInProgress = True
		While (Not IsTimeToFightAgain() And Not $StopResting)
			$second = 1000
			$currentTimeSpentInRestingSeconds += $second
			Sleep($second)
		WEnd

		$CurrentTimeInCombatSeconds = 0
		$currentTimeSpentInRestingSeconds = 0
		$restingInProgress = False
		$StopResting = False
		$IsCameraReset = False
		LogInBack()
	EndIf
EndFunc   ;==>TakeABreakIfTime

Func IsTimeToTakeABreak()
	$isTimeToTakeBreak = ($FightingDuration * 60 * 1000) < $CurrentTimeInCombatSeconds
	Return $isTimeToTakeBreak
EndFunc   ;==>IsTimeToTakeABreak

Func IsTimeToFightAgain()
	$isTimeToFight = ($RestingDuration * 60 * 1000) < $currentTimeSpentInRestingSeconds
	Return $isTimeToFight
EndFunc   ;==>IsTimeToFightAgain

Func ExitToLobby()
	If (Not $exitedToLobby) Then
		WinActivate('RuneScape')
		$pos = WinGetPos('RuneScape')

		If (@error) Then
			ConsoleWrite('When when exitting to lobby, could not find RuneScape window!' & @LF)
		Else
			$winW = $pos[2]
			$winH = $pos[3]
			$optionsMenuColor = 0x54321E

			For $i = 1 to 5 Step 1
				Send("{esc 2}")
				Sleep(2000)

				PixelSearch($winW / 2 - 100, $winH / 3, $winW / 2 + 100, $winH - $winH / 3, $optionsMenuColor)
				If (Not @error) Then
					ConsoleWrite('Options menu found.' & @LF)
					MouseClick("left", 1274, 855)
					ConsoleWrite('Exited to Lobby Successfuly.' & @LF)
					$exitedToLobby = True
				EndIf
			Next

			If (Not $exitedToLobby) Then
				ConsoleWrite('Failed to exit to Lobby.' & @LF)
			EndIf
		EndIf

	EndIf
EndFunc   ;==>ExitToLobby

Func LogInBack()
	WinActivate('RuneScape')
	$pos = WinGetPos('RuneScape')

	If (@error) Then
		ConsoleWrite('When resting could not start playing the game again, could not find RuneScape window!' & @LF)
	Else
		$winW = $pos[2]
		$winH = $pos[3]

		$playNowBtnPosLeft = $winW / 3
		$playNowBtnPosTop = 0
		$playNowBtnPosRight = $winW - $winW / 3
		$playNowBtnPosBottom = $winH / 2
		$playNowPxls = PixelSearch($playNowBtnPosLeft, $playNowBtnPosTop, $playNowBtnPosRight, $playNowBtnPosBottom, $PlayNowButtonColor)

		If (Not @error) Then
			ConsoleWrite('Play now button found, starting the game!' & @LF)
			MouseClick("left", $playNowPxls[0], $playNowPxls[1])
			ConsoleWrite('Waiting for game to load.')
			Sleep(120000)
		Else
			ConsoleWrite('Could not find the play now button in Lobby. Exiting the bot.' & @LF)
			Exit
		EndIf
	EndIf
EndFunc   ;==>LogInBack

Func StopResting()
	$StopResting = True
EndFunc
