#include <TrayConstants.au3>
#include <AutoItConstants.au3>

; Script for automatically starting the flight simulator and related utility programs
; AutoIt documentation of functions: https://www.autoitscript.com/autoit3/docs/functions.htm

; Call the main function that we define below
Main()


Func Main()
	Local $alreadyRunning = ""

	TrayTip("", "Starting Flight Simulator...", 1, $TIP_ICONASTERISK)

	; Start the different programs

	If ProcessExists("LINDA.exe") = 0 Then
		FileChangeDir("C:\ProgramsPortable\FSUIPC7")  ; change the current working directory
		Run("C:\ProgramsPortable\FSUIPC7\LINDA.exe", "C:\ProgramsPortable\FSUIPC7")  ; second parameter is the path to start the program in (working directory). LINDA had issues if I didn't manually call FileChangeDir() above though...
		ProcessWait("LINDA.exe", 30)  ; wait for the process to start
		Sleep(5000)  ; wait another x number of milliseconds
	Else
		$alreadyRunning &= "LINDA, "
	EndIf
	EnsureWindowIsOnSecondScreen("LINDA")

	If ProcessExists("SimToolkitPro.exe") = 0 Then
		Run("C:\Users\Allan\AppData\Local\simtoolkitpro\SimToolkitPro.exe", "C:\Users\Allan\AppData\Local\simtoolkitpro")
		ProcessWait("SimToolkitPro.exe", 30)
		Sleep(5000)
	Else
		$alreadyRunning &= "Flight planner, "
	EndIf
	EnsureWindowIsOnSecondScreen("SimToolkitPro")

	If ProcessExists("SLC.exe") = 0 Then
		Run("e:\ProgramsPRIMARY\SelfLoadingCargo\SLC.exe", "e:\ProgramsPRIMARY\SelfLoadingCargo")
		ProcessWait("SLC.exe", 30)
		Sleep(5000)
	Else
		$alreadyRunning &= "Self-Loading Cargo, "
	EndIf
	EnsureWindowIsOnSecondScreen("Self-Loading Cargo", 600, 1100)

	Local $simulatorWasStarted = false
	If ProcessExists("FlightSimulator.exe") = 0 Then
		Run("C:\Program Files (x86)\Steam\steamapps\common\MicrosoftFlightSimulator\FlightSimulator.exe", "C:\Program Files (x86)\Steam\steamapps\common\MicrosoftFlightSimulator")
		$simulatorWasStarted = true
		Sleep(5000)
	Else
		$alreadyRunning &= "Simulator, "
	EndIf

	If ProcessExists("FSUIPC7.exe") = 0 Then
		Run("C:\ProgramsPortable\FSUIPC7\FSUIPC7.exe", "C:\ProgramsPortable\FSUIPC7")
	Else
		$alreadyRunning &= "FSUIPC, "
	EndIf
	; AUTOMATICALLY GOES TO TRAY, SO NO NEED. EnsureWindowIsOnSecondScreen("FSUIPC")

	; Show message if some programs were already running
	If $alreadyRunning <> "" Then
		TrayTip("Already running:", StringLeft($alreadyRunning, StringLen($alreadyRunning)-2), 3, $TIP_ICONASTERISK)
	EndIf

	; Wait for simulator to start up and ensure the window is the active one
	If $simulatorWasStarted = true Then
		If 1 = 0 Then
			; THIS DOESN'T WORK FOR SOME REASON - it never sees the "Microsoft Flight Simulator" window - so we just wait x number of seconds instead
			; We could do a work-around though since WinExists("Microsoft Flight Simulator") does work - we just have to manually poll it...
			WinWait("Microsoft Flight Simulator", 300)
			WinActivate("Microsoft Flight Simulator")
			Sleep(45000)
		Else
			Sleep(105000)  ; you will need to tweak this depending on how fast your computer starts the simulator
		EndIf
		MouseClick($MOUSE_CLICK_LEFT, 400, 400)  ; click the "Press Any Key to Start" screen!!
		; Play audio file in order to know when the click is made
		Local $audioFile = "c:\Data\Programs\AutoIt\Grin.mp3"
		If FileExists($audioFile) Then
			SoundPlay($audioFile, 1)
		EndIf
	EndIf
EndFunc


; Function we use to ensure that a window appears on the second screen (and optionally at specific location) and not the primary screen with the simulator
Func EnsureWindowIsOnSecondScreen($title, $x = 0, $y = 1080)
	Local $pos = WinGetPos($title)

	; MsgBox(4096, "", "X-Pos: " & $pos[0] & @CRLF & "Y-Pos: " & $pos[1] & @CRLF & "Width: " & $pos[2] & @CRLF & "Height: " & $pos[3])

	If @error Then
		MsgBox(16, "Failure", "Window does not exist: " & $title)
	Else
		Local $xIndex = 0
		Local $yIndex = 1
		If $pos[$yIndex] < 1070 Or $x <> 0 Or $y <> 1080 Then  ; window can technically reach outside the screen without being visible there (eg. SimToolkitPro), so therefore 1070 instead of 1080
			Local $iState = WinGetState($title)

			Local $isMaximized = false
			If BitAND($iState, $WIN_STATE_MAXIMIZED) Then
				$isMaximized = true
			EndIf
			If $isMaximized = true Then
				WinSetState($title, "", @SW_RESTORE)
			EndIf

			WinMove($title, "", $x, $y)

			If $isMaximized = true Then
				WinSetState($title, "", @SW_MAXIMIZE)
			EndIf
		EndIf
	EndIf
EndFunc
