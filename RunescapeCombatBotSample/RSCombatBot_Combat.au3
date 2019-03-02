#cs ----------------------------------------------------------------------------

	AutoIt Version: 3.3.14.2
	Author:         Edgars Šturms

	Script Function:
	Template AutoIt script.

#ce ----------------------------------------------------------------------------
#include <RSCombatBot_Health.au3>
#include <RSCombatBot_Rest.au3>

Local Const $targetRedCircleColor = 0xB71E16
Local Const $targetYellowCircleColor = 0xC5BB18
Local $attackAreaPosLeft
Local $attackAreaPosTop
Local $attackAreaPosRight
Local $attackAreaPosBottom

Local $attacks[5] = ["2", _ ; Dismember
					 "c", _ ; Hovac
					 "1", _ ; Slice
					 "3", _ ; Fury
					 "f"] ; Sever

Global $EnemyTargetColor
Global $FullEnergyColor
Global $UseConstitHealthRestore
Global $EnemiesKilled = 0
Global $IsAttackAreaInitialized = False

Func InitializeAttackArea()
	$pos = WinGetPos('RuneScape')
	If (@error) Then
		ConsoleWrite('When initializing attack area, could not found RuneScape window!' & @LF)
		$IsAttackAreaInitialized = False
	Else
		$winW = $pos[2]
		$winH = $pos[3]

		;$areaRadius = 350
		$areaRadius = 450

		$attackAreaPosLeft = $winW / 2 - ($areaRadius + 100)
		$attackAreaPosTop = $winH / 2 - $areaRadius
		$attackAreaPosRight = $winW / 2 + ($areaRadius + 100)
		$attackAreaPosBottom = $winH / 2 + $areaRadius
		$IsAttackAreaInitialized = True

	EndIf
EndFunc   ;==>InitializeAttackArea

Func AttackNewTarget()
	; Adds human behaviour
	$attackDelay = Random(2000, 3000, 1)

	If ($UseResting) Then
		$CurrentTimeInCombatSeconds += $attackDelay
	EndIf

	$targetPxls = PixelSearch($attackAreaPosLeft, $attackAreaPosTop, $attackAreaPosRight, $attackAreaPosBottom, $EnemyTargetColor)
	If (Not @error) Then
		MouseClick("left", $targetPxls[0], $targetPxls[1], 1, 5)
		$EnemiesKilled += 1
	Else
		ConsoleWrite('No target found.' & @LF)
	EndIf

	Sleep($attackDelay)
EndFunc   ;==>AttackNewTarget

Func Fight()
	If (GetHealthStatus() == $LOW_HEALTH) Then
		EatFood()
	Else
		For $i = 0 To UBound($attacks, $UBOUND_ROWS) -1 Step 1
			Send($attacks[$i])
		Next

		; Simulate human behaviour
		$randomDelay = Random(500, 1000)

		If ($UseResting) Then
			$CurrentTimeInCombatSeconds += $randomDelay
		EndIf

		Sleep($randomDelay)
	EndIf
EndFunc

Func IsInCombat()
	Return IsTargetAttacked() Or IsTargetLocked()
EndFunc   ;==>IsInCombat

Func IsTargetAttacked()
	$redCombatCircleResults = 0
	For $i = 1 To 10 Step 1
		PixelSearch($attackAreaPosLeft, $attackAreaPosTop, $attackAreaPosRight, $attackAreaPosBottom, $targetRedCircleColor)
		If (Not @error) Then
			$redCombatCircleResults += 1
			ExitLoop
		EndIf
	Next
	Return $redCombatCircleResults > 0
EndFunc

Func IsTargetLocked()
	$yellowCombatCircleResults = 0
	For $i = 1 To 10 Step 1
		PixelSearch($attackAreaPosLeft, $attackAreaPosTop, $attackAreaPosRight, $attackAreaPosBottom, $targetYellowCircleColor)
		If (Not @error) Then
			$yellowCombatCircleResults += 1
			ExitLoop
		EndIf
	Next
	Return $yellowCombatCircleResults > 0
EndFunc

Func SetEnemy()
	$mousePos = MouseGetPos()
	$EnemyTargetColor = PixelGetColor($mousePos[0], $mousePos[1])
	If (Not @error) Then
		ConsoleWrite('Enemy target set.' & @LF)
		Return True
	Else
		ConsoleWrite('Enemy target not set, something went wrong..' & @LF)
		Return False
	EndIf
EndFunc   ;==>SetEnemy

Func IsFullEnergyBar()
	$fullEnergyBarResults = 0
	$pos = WinGetPos('RuneScape')
	For $i = 1 To 5 Step 1
		$mouse = PixelSearch($statusBarAreaPosLeft, $statusBarAreaPosTop, $statusBarAreaPosRight, $statusBarAreaPosBottom, $FullEnergyColor)
		If (Not @error) Then
			$fullEnergyBarResults += 1
			ExitLoop
		EndIf
	Next
	Return $fullEnergyBarResults > 0
EndFunc

Func UseConstitutionHealthRestore()
	If (IsFullEnergyBar() And Not IsHealthRegenActive()) Then
		; Adds human behaviour
		$healthRegenConfirmDelay = Random(500, 1000, 1)
		$randomDelay = Random(500, 1000, 1)
		$healthRegenDelay = 10000 + 5000 + $randomDelay + $healthRegenConfirmDelay

		If ($UseResting) Then
			$CurrentTimeInCombatSeconds += $healthRegenDelay
		EndIf

		MouseClick("right", $HearthIconPosLeft, $HearthIconPosTop, 1, 5)
		Sleep($healthRegenConfirmDelay)
		MouseClick("left", $HearthIconPosLeft, $HearthIconPosTop + 20, 1, 5)

		Sleep($healthRegenDelay)
	EndIf
EndFunc

Func ResetCamera()
	If (Not $IsCameraReset) Then
		Send("{UP down}")
		$cameraResetDelay = 1000

		If ($UseResting) Then
			$CurrentTimeInCombatSeconds += $cameraResetDelay
		EndIf

		Sleep($cameraResetDelay)
		Send("{UP up}")
		$IsCameraReset = True
	EndIf
EndFunc

Func Output($_key)
	$attackType = ''
	Switch($_key)
		Case '1'
			$attackType = 'Slice'
		Case '2'
			$attackType = 'Dismember'
		Case '3'
			$attackType = 'Fury'
		Case 'c'
			$attackType = 'Hovac'
		Case 'f'
			$attackType = 'Sever'
	EndSwitch

	ConsoleWrite('Attacked using: ' & $attackType & ' spell' & @LF)
EndFunc