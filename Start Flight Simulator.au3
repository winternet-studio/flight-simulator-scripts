#include <TrayConstants.au3>
#include <AutoItConstants.au3>

; Script for automatically starting the flight simulator and related utility programs
; AutoIt documentation of functions: https://www.autoitscript.com/autoit3/docs/functions.htm

; Call the main function that we define below
Main()


Func Main()
	Local $alreadyRunning = ''

	TrayTip('', 'Starting Flight Simulator...', 1, $TIP_ICONASTERISK)

	; Start the different programs

	If Not ProcessExists('LINDA.exe') Then
		FileChangeDir('C:\ProgramsPortable\FSUIPC7')  ; change the current working directory
		Run('C:\ProgramsPortable\FSUIPC7\LINDA.exe', 'C:\ProgramsPortable\FSUIPC7')  ; second parameter is the path to start the program in (working directory). LINDA had issues if I didn't manually call FileChangeDir() above though...
		ProcessWait('LINDA.exe', 30)  ; wait for the process to start
		Sleep(5000)  ; wait another x number of milliseconds
	Else
		$alreadyRunning &= 'LINDA, '
	EndIf
	EnsureWindowPosition('LINDA', 50, 50)
	WinSetState('LINDA', '', @SW_MINIMIZE)

	; If Not ProcessExists('SimToolkitPro.exe') Then
	; 	Run('C:\Users\Allan\AppData\Local\simtoolkitpro\SimToolkitPro.exe', 'C:\Users\Allan\AppData\Local\simtoolkitpro')
	; 	ProcessWait('SimToolkitPro.exe', 30)
	; 	Sleep(5000)
	; Else
	; 	$alreadyRunning &= 'Flight planner, '
	; EndIf
	; EnsureWindowPosition('SimToolkitPro', 0, 0)
	; WinSetState('SimToolkitPro', '', @SW_MINIMIZE)

	Local $simulatorWasStarted = false
	If Not ProcessExists('FlightSimulator.exe') Then
		; How to launch games via Steam via command line: https://steamcommunity.com/app/221410/discussions/0/1621724915820500210/
		; Running it through Steam will avoid the startup message "Your last session of Microsoft Flight Simulator ended unexpectedly... Continue in Safe Mode - Continue ni Normal Mode" - as also mentioned in this thread: https://forums.flightsimulator.com/t/your-last-session-of-microsoft-flight-simulator-ended-unexpectedly-message/450568/90
		; Find App ID by opening Steam > Library > your game > Settings (cog icon) > Properties > Updates
		; Run('c:\Program Files (x86)\Steam\steam.exe steam://rungameid/1250410', 'c:\Program Files (x86)\Steam')  ; docs: https://developer.valvesoftware.com/wiki/Steam_browser_protocol
		Run('c:\Program Files (x86)\Steam\steam.exe -applaunch 1250410 -FastLaunch', 'c:\Program Files (x86)\Steam')  ; `steam -applaunch <appID> [launch parameters]` - docs: https://developer.valvesoftware.com/wiki/Command_Line_Options#Steam

		; Run('C:\Program Files (x86)\Steam\steamapps\common\MicrosoftFlightSimulator\FlightSimulator.exe', 'C:\Program Files (x86)\Steam\steamapps\common\MicrosoftFlightSimulator')
		$simulatorWasStarted = true
		Sleep(5000)
	Else
		$alreadyRunning &= 'Simulator, '
	EndIf

	; Show message if some programs were already running
	If $alreadyRunning <> '' Then
		TrayTip('Already running:', StringLeft($alreadyRunning, StringLen($alreadyRunning)-2), 3, $TIP_ICONASTERISK)
	EndIf

	; Wait for simulator to start up and ensure the window is the active one
	If $simulatorWasStarted = true Then
		If 1 = 0 Then
			; THIS DOESN'T WORK FOR SOME REASON - it never sees the "Microsoft Flight Simulator" window - so we just wait x number of seconds instead
			; We could do a work-around though since WinExists("Microsoft Flight Simulator") does work - we just have to manually poll it...
			WinWait('Microsoft Flight Simulator', 300)
			WinActivate('Microsoft Flight Simulator')
		Else
			; Sleep(63000)  ; you will need to tweak this depending on how fast your computer starts the simulator
	;		Sleep(36000)  ; This is when -FastLaunch is added to Steam launch options
		EndIf
	EndIf

	; NO LONGER NEEDED WHEN MSFS IS STARTED THROUGH STEAM!
	; If $simulatorWasStarted = true Then
	; 	WinActivate('Microsoft Flight Simulator')  ; added this line as an attempt to see if the clicking now works again after it was broken by SU11...
	; 	MouseClick($MOUSE_CLICK_LEFT, 3800, 1100)  ; click the "Continue normally"
	; 	Sleep(500)
	; 	MouseClick($MOUSE_CLICK_LEFT, 3800, 1100)  ; the first click might just have activated the window I suspect - because it didn't always work with just one click - so therefore do a second click
	; 	Sleep(3000)
	; 	MouseClick($MOUSE_CLICK_LEFT, 3800, 1100)  ; sometimes it still didn't click so I added another one...
	; 	Sleep(1000)
	; 	; there are for one I start it up on the small screen
	; 	MouseClick($MOUSE_CLICK_LEFT, 800, 750)
	; 	Sleep(500)
	; 	MouseClick($MOUSE_CLICK_LEFT, 800, 750)
	; 	Sleep(3000)
	; 	MouseClick($MOUSE_CLICK_LEFT, 800, 750)
	; 	; Play audio file in order to know when the click is made
	; 	Local $audioFile = 'c:\Data\Programs\AutoIt\Grin.mp3'
	; 	If FileExists($audioFile) Then
	; 		SoundPlay($audioFile, 1)
	; 	EndIf
	; EndIf

	; Most of the time I don't use this
	; ; NOTE: don't start this until flight simulator is up and running
	; If Not ProcessExists('SLC.exe') Then
	; 	If $simulatorWasStarted = true Then
	; 		Sleep(20000)
	; 	EndIf
	; 	Run('e:\ProgramsPRIMARY\SelfLoadingCargo\SLC.exe', 'e:\ProgramsPRIMARY\SelfLoadingCargo')
	; 	ProcessWait('SLC.exe', 30)

	; 	; Check if autosave dialog comes up
	; 	Sleep(3000)
	; 	If WinExists('SLC Autosave Available') Then
	; 		Local $noButtonControlID = 7
	; 		ControlClick('SLC Autosave Available', '', $noButtonControlID, 'left')
	; 		Sleep(500)
	; 	EndIf
	; EndIf
	; If WinExists('Self-Loading Cargo') Then
	; 	EnsureWindowPosition('Self-Loading Cargo', 600, 1100)
	; EndIf

	; SOMETHING ELSE STARTS THIS AS WELL...!
	; If Not ProcessExists('FSUIPC7.exe') Then  ; seems to not always start if we try to start it earlier in the process
	; 	Run('C:\ProgramsPortable\FSUIPC7\FSUIPC7.exe', 'C:\ProgramsPortable\FSUIPC7')
	; Else
	; 	$alreadyRunning &= 'FSUIPC, '
	; EndIf

	; Ensure the simulator is the active window when all is said and done
	WinActivate('Microsoft Flight Simulator')

	If Not ProcessExists('FSUIPCWebSocketServer.exe') Then
		Sleep(250000)  ;wait for MSFS to automatically start FSUIPC
		Run('C:\ProgramsPortable\FSUIPC7\Utils\FSUIPCWebSocketServer.exe', 'C:\ProgramsPortable\FSUIPC7\Utils')
		ProcessWait('FSUIPCWebSocketServer.exe', 30)
		Sleep(3000)
	Else
		$alreadyRunning &= 'Web Socker Server, '
	EndIf
	EnsureWindowPosition('FSUIPC WebSockets Server', 0, 500)
	WinSetState('FSUIPC WebSockets Server', '', @SW_MINIMIZE)


	; If Not ProcessExists('server.exe') Then
	; 	FileChangeDir('f:\FS20 Mods\Aircraft\flybywire-aircraft-a320-neo\MCDU SERVER')
	; 	Run('f:\FS20 Mods\Aircraft\flybywire-aircraft-a320-neo\MCDU SERVER\server.exe', 'f:\FS20 Mods\Aircraft\flybywire-aircraft-a320-neo\MCDU SERVER')
	; 	ProcessWait('server.exe', 30)  ; wait for the process to start
	; Else
	; 	$alreadyRunning &= 'MCDU server, '
	; EndIf
	; ; DOESN'T FIND THE WINDOW?!
	; ; EnsureWindowPosition('f:\FS20 Mods\Aircraft\flybywire-aircraft-a320-neo\MCDU SERVER\server.exe', 50, 50)
	; ; WinSetState('f:\FS20 Mods\Aircraft\flybywire-aircraft-a320-neo\MCDU SERVER\server.exe', '', @SW_MINIMIZE)


	; Put STP in front of LINDA, FSUIPCWebsockerServer etc.
	; WinActivate('SimToolkitPro')


	If Not ProcessExists('vPilot.exe') Then
		FileChangeDir('C:\Users\Allan\AppData\Local\vPilot')
		Run('C:\Users\Allan\AppData\Local\vPilot\vPilot.exe', 'C:\Users\Allan\AppData\Local\vPilot')
	Else
		$alreadyRunning &= 'vPilot, '
	EndIf


	If Not ProcessExists('fsltl-trafficinjector.exe') Then
		FileChangeDir('f:\FS20 Packages\Community\fsltl-traffic-injector\')
		Run('f:\FS20 Packages\Community\fsltl-traffic-injector\\fsltl-trafficinjector.exe', 'f:\FS20 Packages\Community\fsltl-traffic-injector\')
		ProcessWait('fsltl-trafficinjector.exe', 30)
	Else
		$alreadyRunning &= 'FSLTL, '
	EndIf
	WinSetState('f:\FS20 Packages\Community\fsltl-traffic-injector\fsltl-trafficinjector.exe', '', @SW_MINIMIZE)


	If Not ProcessExists('Couatl64_MSFS.exe') Then
		FileChangeDir('f:\FS20 FSDreamTeam\Addon Manager\couatl64\')
		Run('f:\FS20 FSDreamTeam\Addon Manager\couatl64\Couatl64_MSFS.exe', 'f:\FS20 FSDreamTeam\Addon Manager\couatl64\')
		ProcessWait('Couatl64_MSFS.exe', 30)
	Else
		$alreadyRunning &= 'GSX, '
	EndIf

EndFunc


; Function we use to ensure that a window appears at a specific location and not on top of the simulator itself
Func EnsureWindowPosition($title, $x, $y)
	Local $pos = WinGetPos($title)

	; MsgBox(4096, '', 'X-Pos: ' & $pos[0] & @CRLF & 'Y-Pos: ' & $pos[1] & @CRLF & 'Width: ' & $pos[2] & @CRLF & 'Height: ' & $pos[3])

	If @error Then
		MsgBox(16, 'Failure', 'Window does not exist: ' & $title)
	Else
		Local $xIndex = 0
		Local $yIndex = 1
		If $pos[$yIndex] <> $x Or $pos[$yIndex] <> $y Then
			Local $iState = WinGetState($title)

			Local $isMaximized = false
			If BitAND($iState, $WIN_STATE_MAXIMIZED) Then
				$isMaximized = true
			EndIf
			If $isMaximized = true Then
				WinSetState($title, '', @SW_RESTORE)
			EndIf

			WinMove($title, '', $x, $y)

			If $isMaximized = true Then
				WinSetState($title, '', @SW_MAXIMIZE)
			EndIf
		EndIf
	EndIf
EndFunc
