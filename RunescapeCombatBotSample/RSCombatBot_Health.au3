#cs ----------------------------------------------------------------------------

	AutoIt Version: 3.3.14.2
	Author:         Edgars Šturms

	Script Function:
	Template AutoIt script.

#ce ----------------------------------------------------------------------------
#include <Array.au3>

; Area where to search food
Local $BackpackLeftPos
Local $BackpackRightPos
Local $BackpackTopPos
Local $BackpackBottomPos
Local $FullEnergyColor = 0xDEC97D

; Status bar area where all useful info is shown
Local $statusBarAreaPosLeft
local $statusBarAreaPosTop
Local $statusBarAreaPosRight
Local $statusBarAreaPosBottom
Global $statusBarAreaInitialized = False

; Health bar area
Local Const $hearthIconColor = 0x422C24
Local Const $hearthIconRegenColor = 0xF4C674
Local Const $healthMissingColor = 0x23292C
Local $healthBarAreaPosLeft
local $healthBarAreaPosTop
Local $healthBarAreaPosRight
Local $healthBarAreaPosBottom
Local $lowHealthPosLeft
Local $medHealthPosLeft
Local $fullHealthPosLeft
Global $HearthIconPosLeft
Global $HearthIconPosTop
Global $HealthBarAreaInitialized = False

Global $FoodColor
Global Enum $LOW_HEALTH, $MED_HEALTH, $FULL_HEALTH
Local $HealthStatus = $FULL_HEALTH
Local $healthStatuses[3][2] = [[$LOW_HEALTH, 0], _ ; Low health left position
							   [$MED_HEALTH, 0], _ ; Medium health left position
							   [$FULL_HEALTH, 0]]  ; Full health left position
Global $IsBackpackInitialized = False

Func InitializeBackpack()
	$pos = WinGetPos('RuneScape')

	If (@error) Then
		ConsoleWrite('When initializing backpack search area, could not find RuneScape window!' & @LF)
		$IsBackpackInitialized = False
	Else
		$winW = $pos[2]
		$winH = $pos[3]

		$BackpackLeftPos = $winW / 2
		$BackpackRightPos = $winW
		$BackpackTopPos = $winH / 2
		$BackpackBottomPos = $winH
		$IsBackpackInitialized = True
	EndIf
EndFunc   ;==>InitializeBackpack

Func InitializeStatusBarArea()
	$pos = WinGetPos('RuneScape')

	If (@error) Then
		ConsoleWrite('When initializing attack area, could not found RuneScape window!' & @LF)
		$statusBarAreaInitialized = False
	Else
		$winW = $pos[2]
		$winH = $pos[3]

		$statusBarAreaPosLeft = $winW / 3
		$statusBarAreaPosTop = $winH - $winH / 3
		$statusBarAreaPosRight = $winW - $winW / 3
		$statusBarAreaPosBottom = $winH
		$statusBarAreaInitialized = True
	EndIf
EndFunc

Func InitializeHealthBarArea()
	$pos = WinGetPos('RuneScape')
	If (@error) Then
		ConsoleWrite('When initializing health bar area, could not found RuneScape window!' & @LF)
		$HealthBarAreaInitialized = False
	Else
		$winW = $pos[2]
		$winH = $pos[3]

		If ($statusBarAreaInitialized) Then
			; ConsoleWrite('statusBarAreaPosLeft: ' & $statusBarAreaPosLeft & ' statusBarAreaPosTop: ' & $statusBarAreaPosTop & ' statusBarAreaPosRight: ' & $statusBarAreaPosRight & ' statusBarAreaPosBottom: ' & $statusBarAreaPosBottom & @LF)

			$hearthIconPxls = PixelSearch($statusBarAreaPosLeft, $statusBarAreaPosTop, $statusBarAreaPosRight, $statusBarAreaPosBottom, $hearthIconColor)
			If (Not @error) Then
				$HearthIconPosLeft = $hearthIconPxls[0]
				$HearthIconPosTop = $hearthIconPxls[1]

				$healthBarAreaPosLeft = $HearthIconPosLeft + 18
				$healthBarAreaPosTop = $HearthIconPosTop + 11
				$healthBarAreaPosRight =  $HearthIconPosLeft + 90
				$healthBarAreaPosBottom = $HearthIconPosTop + 26

				; Sets low health left coordinates
				$healthStatuses[$LOW_HEALTH][1] = $healthBarAreaPosLeft + 45
				; Sets medium health left coordinates
				$healthStatuses[$MED_HEALTH][1] = $healthBarAreaPosLeft + 55
				; Sets full health left coordinates
				$healthStatuses[$FULL_HEALTH][1] = $healthBarAreaPosLeft + 65

				$HealthBarAreaInitialized = True
			Else
				ConsoleWrite('Could not find hearth icon!' & @LF)
			EndIf
		Else
			ConsoleWrite('Status bar search area is not initialized!' & @LF)
		EndIf
	EndIf
EndFunc

Func SetFood()
	$mousePos = MouseGetPos()
	$FoodColor = PixelGetColor($mousePos[0], $mousePos[1])

	If (Not @error) Then
		ConsoleWrite('Food set.' & @LF)
		Return True
	Else
		ConsoleWrite('Food not set, something went wrong..' & @LF)
		Return False
	EndIf

EndFunc   ;==>SetFood

Func GetHealthStatus()
	$HealthStatus = $LOW_HEALTH
	$isFullHealth = False
	$isMediumHealth = False
	$isLowhealth = False

	For $i = 0 To UBound($healthStatuses, $UBOUND_ROWS) -1 Step 1
		$status = $healthStatuses[$i][0]
		$leftPos = $healthStatuses[$i][1]
		$color = PixelGetColor($leftPos, $healthBarAreaPosTop)

		If ($status == $LOW_HEALTH And $color == $healthMissingColor) Then
			$isLowhealth = True
		ElseIf ($status == $MED_HEALTH And $color == $healthMissingColor) Then
			$isMediumHealth = True
		ElseIf ($status == $FULL_HEALTH And Not ($color == $healthMissingColor)) Then
			$isFullHealth = True
		EndIf
	Next

	If ($isFullHealth) Then
		$HealthStatus = $FULL_HEALTH
	ElseIf (Not $isMediumHealth Or ($isMediumHealth And Not $isLowhealth)) Then
		$HealthStatus = $MED_HEALTH
	Else
		$HealthStatus = $LOW_HEALTH
	EndIf

	ConsoleWrite('isFullHealth: ' & $isFullHealth & ' isMediumHealth: ' & $isMediumHealth & ' isLowhealth: ' & $isLowhealth & ' Health status: ' & $HealthStatus &@LF)

	Return $HealthStatus

EndFunc   ;==>GetHealthStatus

Func EatFood()
	$foodPixels = PixelSearch($BackpackLeftPos, $BackpackTopPos, $BackpackRightPos, $BackpackBottomPos, $FoodColor)
	If (Not @error) Then
		MouseClick("left", $foodPixels[0], $foodPixels[1], 1, 0)
		ConsoleWrite("Restored some health. " & @LF)
	Else
		ConsoleWrite("Failed to restore health. " & @LF)
	EndIf
EndFunc   ;==>EatFood

Func IsAnyFoodLeft()
	$foodPixels = PixelSearch($BackpackLeftPos, $BackpackTopPos, $BackpackRightPos, $BackpackBottomPos, $FoodColor)
	If (Not @error) Then
		Return True
	Else
		ConsoleWrite("Out of food! " & @LF)
		Return False
	EndIf
EndFunc

Func IsHealthRegenActive()
	$activeHealthRegenPxls = PixelSearch($HearthIconPosLeft - 20, $HearthIconPosTop - 20, $HearthIconPosLeft + 20, $HearthIconPosTop + 20, $hearthIconRegenColor)
	If (Not @error) Then
		ConsoleWrite('Health regeneration already active.' & @LF)
		Return True
	Else
		Return False
	EndIf
EndFunc