; RSCombatBot libraries
#include <RSCombatBot_Combat.au3>
#include <RSCombatBot_Escape.au3>

; GUI libraries
#include <ButtonConstants.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>

; XML wrapper libraries
#include <File.au3>
#include <Array.au3>
#include "_XMLDomWrapper.au3"

#Region ### START Koda GUI section ### Form=d:\users\edgars\documents\scripts\runesscapecombatbot\rscombatbotgui.kxf
$Form1_1 = GUICreate("RSCombat bot V1", 676, 438, 587, 700)
$Label1 = GUICtrlCreateLabel("Food", 32, 80, 49, 28, $SS_RIGHT)
GUICtrlSetFont(-1, 16, 400, 0, "MS Sans Serif")
$Label2 = GUICtrlCreateLabel("Enemy", 32, 120, 64, 28, $SS_RIGHT)
GUICtrlSetFont(-1, 16, 400, 0, "MS Sans Serif")
$lblEnemiesKilled = GUICtrlCreateLabel("Enemies killled: ", 32, 8, 79, 17)
$lblStartDateTime = GUICtrlCreateLabel("Start date/time: ", 224, 8, 80, 17)
$BtnChooseFood = GUICtrlCreateButton("Choose", 224, 80, 75, 25)
$BtnChooseEnemy = GUICtrlCreateButton("Choose", 224, 120, 75, 25)
$BtnStartStop = GUICtrlCreateButton("Start", 24, 392, 75, 25)
$BtnUploadParams = GUICtrlCreateButton("Upload", 104, 392, 75, 25)
$BtnExportParams = GUICtrlCreateButton("Export", 184, 392, 75, 25)
$BtnExit = GUICtrlCreateButton("Exit", 264, 392, 75, 25)
$Label5 = GUICtrlCreateLabel("Exit to lobby btn", 328, 160, 137, 28, $SS_RIGHT)
GUICtrlSetFont(-1, 16, 400, 0, "MS Sans Serif")
$BtnExitToLobby = GUICtrlCreateButton("Choose", 488, 160, 75, 25)
$Label7 = GUICtrlCreateLabel("Time in combat", 328, 80, 134, 28, $SS_RIGHT)
GUICtrlSetFont(-1, 16, 400, 0, "MS Sans Serif")
$TxtMaxTimeInCombat = GUICtrlCreateInput("", 488, 80, 73, 21)
$Label9 = GUICtrlCreateLabel("Resting duration", 328, 120, 140, 28, $SS_RIGHT)
GUICtrlSetFont(-1, 16, 400, 0, "MS Sans Serif")
$TxtMaxRestingDuration = GUICtrlCreateInput("", 488, 120, 73, 21)
$Label3 = GUICtrlCreateLabel("Teleport to home", 32, 200, 148, 28, $SS_RIGHT)
GUICtrlSetFont(-1, 16, 400, 0, "MS Sans Serif")
$BtnChooseHomeTeleport = GUICtrlCreateButton("Choose", 224, 200, 75, 25)
$ChbxUseTeleport = GUICtrlCreateCheckbox("Use teleport", 32, 240, 169, 17)
GUICtrlSetState(-1, $GUI_CHECKED)
$ChbxUseConstitutionHealthRestore = GUICtrlCreateCheckbox("Use constitution health restore", 32, 160, 169, 33)
GUICtrlSetState(-1, $GUI_CHECKED)
$LblEnemiesKilledCount = GUICtrlCreateLabel("0", 112, 8, 100, 17)
$LblStartDateTim = GUICtrlCreateLabel("None", 304, 8, 100, 17)
$BtnStopResting = GUICtrlCreateButton("Stop resting", 488, 200, 75, 25)
$Label4 = GUICtrlCreateLabel("Rest after while parameters", 328, 40, 229, 28)
GUICtrlSetFont(-1, 16, 400, 0, "MS Sans Serif")
GUICtrlSetColor(-1, 0x0000FF)
$Label6 = GUICtrlCreateLabel("Combat parameters", 32, 40, 168, 28)
GUICtrlSetFont(-1, 16, 400, 0, "MS Sans Serif")
GUICtrlSetColor(-1, 0x0000FF)
$ChbxUseResting = GUICtrlCreateCheckbox("Use resting", 336, 208, 97, 17)
GUICtrlSetState(-1, $GUI_CHECKED)
$Label8 = GUICtrlCreateLabel("min", 568, 80, 35, 28, $SS_RIGHT)
GUICtrlSetFont(-1, 16, 400, 0, "MS Sans Serif")
$Label10 = GUICtrlCreateLabel("min", 568, 120, 35, 28, $SS_RIGHT)
GUICtrlSetFont(-1, 16, 400, 0, "MS Sans Serif")
GUISetState(@SW_SHOW)
#EndRegion ### END Koda GUI section ###

HotKeySet("{space}", PerformChooseAction)
HotKeySet("{f1}", ExitRSBot)
HotKeySet("{f2}", ToggleStartStop)
HotKeySet("{f3}", StopResting)

Local Enum $NONE, _
		$CHOOSE_FOOD, _
		$CHOOSE_ENEMY, _
		$CHOOSE_LOW_HEALTH_POS, _
		$CHOOSE_MED_HEALTH_POS, _
		$CHOOSE_FULL_HEALTH_POS, _
		$CHOOSE_FULL_ENERGY_POS, _
		$CHOOSE_HOME_TELEPORT, _
		$CHOOSE_EXIT_TO_LOBBY

Local $CurrentAction = $NONE
Local $IsBotPaused = True ;
Local $IsFoodChosen = False ;
Local $IsEnemyChosen = False ;
Local $IsHomeTeleportChosen = False ;
Local $IsTakeBreakAfterTimeChosen = False ;

Sleep(1000)
ConsoleWrite('Initializing window..' & @LF)
#Region Initialize default parameters
InitializeBackpack()
Sleep(1000)
InitializeAttackArea()
Sleep(1000)
InitializeStatusBarArea()
Sleep(1000)
InitializeHealthBarArea()
#EndRegion Initialize default parameters
Sleep(1000)
ConsoleWrite('Window inicialized.' & @LF)

While 1
	SelectOperation()

	;If (Not $IsBotPaused) Then
		;ConsoleWrite('IsBotPaused: ' & $IsBotPaused & ' IsFoodChosen: ' & $IsFoodChosen & ' IsEnemyChosen: ' & $IsEnemyChosen & ' UseHomeTeleport: ' & $UseHomeTeleport & ' IsHomeTeleportChosen: ' & $IsHomeTeleportChosen & ' UseResting: ' & $UseResting & ' IsTakeBreakAfterTimeChosen: ' & $IsTakeBreakAfterTimeChosen & @LF)
		; TODO: remove this delay after testing is made
		;Sleep(2000)
	;EndIf

	If (IsBotActive()) Then
		WinActivate("RuneScape")
		ResetCamera()

		If (IsInCombat()) Then
			If (IsAnyFoodLeft()) Then
				Fight()
			Else
				TeleportToHome()
			EndIf
		Else
			If (IsTimeToTakeABreak()) Then
				TakeABreak()
			ElseIf (GetHealthStatus() = $MED_HEALTH) Then
				UseConstitutionHealthRestore()
			EndIf

			If (IsAnyFoodLeft()) Then
				If (GetHealthStatus() == $LOW_HEALTH) Then
					EatFood()
				EndIf
				AttackNewTarget()
				UpdateEnemiesKilledCount()
			Else
				TeleportToHome()
			EndIf
		EndIf
	EndIf
WEnd

Func IsBotActive()
	Return (Not $IsBotPaused _
			And $IsFoodChosen _
			And $IsEnemyChosen _
			And ($UseHomeTeleport ? $IsHomeTeleportChosen : True) _
			And ($UseResting ? $IsTakeBreakAfterTimeChosen : True))
EndFunc   ;==>IsBotActive

Func UpdateEnemiesKilledCount()
	GUICtrlSetData($LblEnemiesKilledCount, $EnemiesKilled)
EndFunc

Func SelectOperation()
	$nMsg = GUIGetMsg()

	Switch $nMsg
		Case $BtnChooseFood
			$CurrentAction = $CHOOSE_FOOD
		Case $BtnChooseEnemy
			$CurrentAction = $CHOOSE_ENEMY
		Case $BtnChooseHomeTeleport
			$CurrentAction = $CHOOSE_HOME_TELEPORT
		Case $BtnExitToLobby
			$CurrentAction = $CHOOSE_EXIT_TO_LOBBY
		Case $TxtMaxTimeInCombat
			SetMaxTimeInCombat()
		Case $TxtMaxRestingDuration
			SetMaxRestingDuration()
		Case $ChbxUseConstitutionHealthRestore
			SetUseConstitutionHealthRestore()
		Case $ChbxUseTeleport
			SetUseHomeTeleport()
		Case $ChbxUseResting
			SetUseResting()
		Case $BtnStartStop
			ToggleStartStop()
		Case $BtnUploadParams
			ImportBotParams()
		Case $BtnExportParams
			ExportBotCurrentParams()
		Case $BtnExit, $GUI_EVENT_CLOSE
			Exit
	EndSwitch
EndFunc   ;==>SelectOperation

Func PerformChooseAction()
	Switch $CurrentAction
		Case $CHOOSE_FOOD
			$IsFoodChosen = SetFood()
		Case $CHOOSE_ENEMY
			$IsEnemyChosen = SetEnemy()
		Case $CHOOSE_HOME_TELEPORT
			$IsHomeTeleportChosen = SetHomeTeleport()
		Case $CHOOSE_EXIT_TO_LOBBY
			$IsExitToLobbyChosen = SetExitToLobby()
	EndSwitch

	; Enable/Disable controls depending on specified data
	EnableDisableMainButtons()
	; Reset current action
	$CurrentAction = $NONE
EndFunc   ;==>PerformChooseAction

Func SetMaxTimeInCombat()
	$FightingDuration = GUICtrlRead($TxtMaxTimeInCombat, 1)
EndFunc

Func SetMaxRestingDuration()
	$RestingDuration = GUICtrlRead($TxtMaxRestingDuration, 1)
EndFunc

Func SetUseConstitutionHealthRestore()
	$UseConstitHealthRestore = GUICtrlRead($ChbxUseConstitutionHealthRestore, 1)
EndFunc

Func SetUseHomeTeleport()
	$UseTeleport = GUICtrlRead($ChbxUseTeleport, 1)
EndFunc

Func SetUseResting()
	$UseResting = GUICtrlRead($ChbxUseResting)
EndFunc

Func ToggleStartStop()
	$IsBotPaused = Not $IsBotPaused
	GUICtrlSetData($BtnStartStop, $IsBotPaused ? "Start" : "Stop")
EndFunc   ;==>ToggleStartStop

Func EnableDisableMainButtons()
	; TODO:
EndFunc   ;==>EnableDisableMainButtons

Func SetControlsAfterDataImport()
	GUICtrlSetData($ChbxUseConstitutionHealthRestore, $UseConstitHealthRestore)
	GUICtrlSetData($ChbxUseTeleport, $UseHomeTeleport)
	GUICtrlSetData($ChbxUseResting, $UseResting)
	GUICtrlSetData($TxtMaxTimeInCombat, $FightingDuration)
	GUICtrlSetData($TxtMaxRestingDuration, $RestingDuration)
EndFunc

Func ImportBotParams()
	;_XMLFileOpen("C:\Program Files\AutoIt3\scripts\workbench_proj.xml")
	$sXmlFile = FileOpenDialog("", @ScriptDir, "XML (*.xml)", 1)

	If @error Then
		;MsgBox(4096, "File Open", "No file chosen")
		Exit
	Else
		$oOXml = _XMLFileOpen($sXmlFile)
		If @error Then
			MsgBox(4096, "File Open Error", "Error Opening File.  Exiting program")
			Exit
		EndIf
	EndIf

	;get first node attribs  note: using optional query string
	$nodeCount = _XMLGetNodeCount("//RSCombatBot/Params/Param")

	Local $aAttName[1]
	Local $aAttVal[1]
	Local $nameAttrValue

	For $i = 1 To $nodeCount Step 1
		$ret2 = _XMLGetChildren("//RSCombatBot/Params/Param[" & ($i) & "]")
		$ret3 = _XMLGetAllAttrib("//RSCombatBot/Params/Param[" & ($i) & "]", $aAttName, $aAttVal)

		$nameAttrValue = $aAttVal[0]

		Switch $nameAttrValue
			Case "FoodColor"
				$FoodColor = $ret2[1][1]
				$IsFoodChosen = True
			Case "EnemyTarget"
				$EnemyTargetColor = $ret2[1][1]
				$IsEnemyChosen = True
			Case "TeleportToHome"
				$TeleportTabletColor = $ret2[1][1]
				$UseHomeTeleport = $ret2[2][1]
				$IsHomeTeleportChosen = True
			Case "TakeABreakAfterSomeTime"
				$FightingDuration = $ret2[1][1]
				$RestingDuration = $ret2[2][1]
				$ExitToLobbyButtonPosX = $ret2[3][1]
				$ExitToLobbyButtonPosY = $ret2[4][1]
				$UseResting = $ret2[5][1]

				If ($UseResting _
					And Not $FightingDuration = "" _
					And Not $RestingDuration = "" _
					And Not $ExitToLobbyButtonPosX = "" _
					And Not $ExitToLobbyButtonPosY = "") Then
					$IsTakeBreakAfterTimeChosen = True
				Else
					$IsTakeBreakAfterTimeChosen = False
				EndIf
		EndSwitch
	Next

	SetControlsAfterDataImport()

EndFunc   ;==>ImportBotParams

Func ExportBotCurrentParams()
	;Create file (force overwrite existing file)
	$sXmlFile = FileSaveDialog("", @ScriptDir, "XML (*.xml)", 16, "RSCombatBotDefault.xml")

	Switch @error
		Case 0
			ConsoleWrite("No error" & @CRLF)
		Case 1
			ConsoleWrite("Failed to create file" & @CRLF)
		Case 2
			ConsoleWrite("No object" & @CRLF)
		Case 3
			ConsoleWrite("File creation failed MSXML error" & @CRLF)
		Case 4
			ConsoleWrite("File exists" & @CRLF)
	EndSwitch

	$result = _XMLCreateFile($sXmlFile, "RSCombatBot", 1)

	;Open created file
	_XMLFileOpen($sXmlFile)
	_XMLCreateRootChild("Params", "")
	;Create param 1
	_XMLCreateChildWAttr("//Params", "Param", "name", "FoodColor")
	_XMLCreateChildNode("//Params/Param[1]", "Color", $FoodColor, "")
	;Create param 2
	_XMLCreateChildWAttr("//Params", "Param", "name", "EnemyTarget")
	_XMLCreateChildNode("//Params/Param[2]", "Color", $EnemyTargetColor, "")
	;Create param 3
	_XMLCreateChildWAttr("//Params", "Param", "name", "TeleportToHome")
	_XMLCreateChildNode("//Params/Param[3]", "Color", $TeleportTabletColor, "")
	_XMLCreateChildNode("//Params/Param[3]", "Enabled", $UseHomeTeleport, "")
	;Create param 4
	_XMLCreateChildWAttr("//Params", "Param", "name", "TakeABreakAfterSomeTime")
	_XMLCreateChildNode("//Params/Param[4]", "FightingDuration", $FightingDuration, "")
	_XMLCreateChildNode("//Params/Param[4]", "RestingDuration", $RestingDuration, "")
	_XMLCreateChildNode("//Params/Param[4]", "ExitToLobbyButtonPosX", $ExitToLobbyButtonPosX, "")
	_XMLCreateChildNode("//Params/Param[4]", "ExitToLobbyButtonPosY", $ExitToLobbyButtonPosY, "")
	_XMLCreateChildNode("//Params/Param[4]", "Enabled", $UseResting, "")

	FileClose($sXmlFile)
EndFunc   ;==>ExportBotCurrentParams

Func ExitRSBot()
	ConsoleWrite("Bot exited." & @LF)
	Exit
EndFunc   ;==>ExitRSBot