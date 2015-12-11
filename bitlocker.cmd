mode con: cols=36 lines=20
COLOR 0A
@ECHO OFF
TITLE Manage BitLocker


:SetDrive
::Set the drive to be managed
SET DRIVE=
CLS
ECHO.
ECHO  Manage Bitlocker
ECHO ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
ECHO.
ECHO    Please enter
ECHO    drive letter:
ECHO.
ECHO.
SET /P DRIVE=
IF "%DRIVE%"=="" GOTO SetDrive
::Ensure correct notation
SET COLON=:
SET DRIVE=%DRIVE:~0,1%%COLON%
::Check drive validity
CD %DRIVE% >nul
IF "%ERRORLEVEL%"=="1" GOTO InvalidDrive
::Check for encryption
manage-bde -status %DRIVE%|FIND "Protection On" >nul2
IF "%ERRORLEVEL%"=="0" SET ENCRYPTION=Y
manage-bde -status %DRIVE%|FIND "Protection Off" >nul2
IF "%ERRORLEVEL%"=="0" SET ENCRYPTION=N
GOTO MENU


:Menu
SET ERROR=
SET SIZE=
CLS
ECHO.
ECHO  Manage Bitlocker
ECHO ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
ECHO A.    Check
ECHO B.    Unlock
ECHO C.    Lock
ECHO D.    Change Drive
ECHO Z.    Exit
ECHO.
SET /P MENU="Option: "
IF %MENU%==A GOTO Check
IF %MENU%==a GOTO Check
IF %MENU%==B GOTO Unlock
IF %MENU%==b GOTO Unlock
IF %MENU%==U GOTO Unlock
IF %MENU%==u GOTO Unlock
IF %MENU%==C GOTO Lock
IF %MENU%==c GOTO Lock
IF %MENU%==L GOTO Lock
IF %MENU%==l GOTO Lock
IF %MENU%==D GOTO SetDrive
IF %MENU%==d GOTO SetDrive
IF %MENU%==z EXIT
GOTO Menu


:Check
::Prewarn if no encryption is detected
IF "%ENCRYPTION%"=="N" GOTO NoEncryption
:CheckWarned
CLS
ECHO.
ECHO  Manage Bitlocker
ECHO ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
ECHO Drive:
ECHO %DRIVE%
ECHO.
ECHO Lock Status:
manage-bde -status %DRIVE%|FIND "Locked" >nul2
IF "%ERRORLEVEL%"=="0" ECHO Locked && GOTO CheckEnd
manage-bde -status %DRIVE%|FIND "Unlocked" >nul2
IF "%ERRORLEVEL%"=="0" GOTO DriveInfo
IF "%ENCRYPTION%"=="N" GOTO DriveInfo
:DriveInfo
::Change size of window to allow display of more data
mode con: cols=36 lines=20
ECHO.
ECHO  Manage Bitlocker
ECHO ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
ECHO Drive:
ECHO %DRIVE%
ECHO.
ECHO Lock Status:
IF "%ENCRYPTION%"=="N" (ECHO N/A) ELSE ECHO Unlocked
ECHO.
::Calculate drive free space for display
ECHO Space:
FOR /F "tokens=8" %%A IN ('FSUTIL volume diskfree %DRIVE%^|FIND "free bytes"') DO SET SPACE=%%A
SET SPACE=%SPACE:~0,9%
SET /A SPACE=((SPACE/1048576)*1000)/1024
ECHO %SPACE% GB
ECHO.
::Calculate disk size for display
ECHO Size:
FOR /F "tokens=2*" %%B IN ('manage-bde -status %DRIVE%^|FIND "Size"') DO SET SIZE=%%B
ECHO %SIZE:~0,3% GB
ECHO.
::Calculate percent free for display w/graph
ECHO Percent Free:
SET /A PERCENT=(SPACE*100)/SIZE
SET /A GRAPH=PERCENT/10
IF %GRAPH% LEQ 0 (echo [          ]
    ) ELSE (
    IF %GRAPH% LEQ 1 (echo %PERCENT%%%   [I         ]
        ) ELSE (
        IF %GRAPH% LEQ 2 (echo %PERCENT%%%   [II        ]
            ) ELSE (
            IF %GRAPH% LEQ 3 (echo %PERCENT%%%   [III       ]
                ) ELSE (
                IF %GRAPH% LEQ 4 (echo %PERCENT%%%   [IIII      ]
                    ) ELSE (
                    IF %GRAPH% LEQ 5 (echo %PERCENT%%%   [IIIII     ]
                        ) ELSE (
                        IF %GRAPH% LEQ 6 (echo %PERCENT%%%   [IIIIII    ]
                            ) ELSE (
                            IF %GRAPH% LEQ 7 (echo %PERCENT%%%   [IIIIIII   ]
                                ) ELSE (
                                IF %GRAPH% LEQ 8 (echo %PERCENT%%%   [IIIIIIII  ]
                                    ) ELSE (
                                    IF %GRAPH% LEQ 9 (echo %PERCENT%%%   [IIIIIIIII ]
                                        ) ELSE (
                                            echo %PERCENT%%%   [IIIIIIIIII]
                                        )
                                    )
                                )
                            )
                        )
                    )
                )
            )
        )
    )
)
GOTO CheckEnd
:CheckEnd
PAUSE >nul
::Reset to small size
mode con: cols=36 lines=20
GOTO Menu


:Unlock
IF "%ENCRYPTION%"=="N" GOTO NoEncryption
CLS
ECHO.
ECHO  Manage Bitlocker
ECHO ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
ECHO.
ECHO     Unlock?
ECHO.
ECHO.
ECHO Enter Password:
::Unlock the drive
manage-bde -unlock %DRIVE% -pw >nul2
IF "%ERRORLEVEL%"=="-2144272345" GOTO WrongPass
IF "%ERRORLEVEL%"=="-1" GOTO UnlockedAlready
IF "%ERRORLEVEL%"=="0" GOTO Disarmed

:Disarmed
CLS
ECHO.
ECHO  Manage Bitlocker
ECHO ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
ECHO.
ECHO       LOCK
ECHO     DISARMED!
ECHO.
ECHO.
PING -n 4 127.0.0.1 >nul

:OpenOffer
SET MENU=
::Offer to open in explorer
CLS
ECHO.
ECHO  Manage Bitlocker
ECHO ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
ECHO.
ECHO   Do you want to
ECHO   open the drive?
ECHO.
ECHO.
SET /P MENU="Y/N: "
IF %MENU%==Y GOTO Open&Exit
IF %MENU%==y GOTO Open&Exit
IF %MENU%==N EXIT
IF %MENU%==n EXIT
GOTO OpenOffer

:Open&Exit
CLS
ECHO.
ECHO  Manage Bitlocker
ECHO ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
ECHO.
ECHO     Opening!
ECHO.
ECHO.
Explorer "%DRIVE%"
EXIT


:Lock
IF "%ENCRYPTION%"=="N" GOTO NoEncryption
CLS
ECHO.
ECHO  Manage Bitlocker
ECHO ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
ECHO.
ECHO       Lock?
ECHO.
ECHO.
ECHO   Press any key
PAUSE >nul
CLS
ECHO.
ECHO  Manage Bitlocker
ECHO ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
ECHO.
ECHO    Locking...
ECHO.
ECHO.
ECHO.
::Unlock the drive
manage-bde -lock %DRIVE% -forcedismount >nul2
IF "%ERRORLEVEL%"=="-2144272384" GOTO LockedAlready
IF "%ERRORLEVEL%"=="0" GOTO Armed


:InvalidDrive
CLS
ECHO.
ECHO  Manage Bitlocker
ECHO ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
ECHO.
ECHO   Drive %DRIVE% not
ECHO     detected.
ECHO.
ECHO.
PING -n 4 127.0.0.1 >nul
GOTO SetDrive


:NoEncryption
CLS
ECHO  Manage Bitlocker
ECHO ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
ECHO.
ECHO   No encryption
ECHO  detected on disk
ECHO        %DRIVE%
ECHO.
ECHO.
PAUSE >nul
GOTO CheckWarned

:Armed
CLS
ECHO.
ECHO  Manage Bitlocker
ECHO ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
ECHO.
ECHO       LOCK
ECHO      ARMED!
ECHO.
ECHO.
PING -n 4 127.0.0.1 >nul
EXIT


:LockedAlready
CLS
ECHO.
ECHO  Manage Bitlocker
ECHO ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
ECHO.
ECHO     !FAILED!
ECHO   Already Locked
ECHO.
ECHO.
PING -n 4 127.0.0.1 >nul
GOTO MENU


:WrongPass
CLS
ECHO.
ECHO  Manage Bitlocker
ECHO ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
ECHO.
ECHO     !FAILED!
ECHO     Incorrect
ECHO     Password
ECHO.
PING -n 4 127.0.0.1 >nul
GOTO MENU


:UnlockedAlready
CLS
ECHO.
ECHO  Manage Bitlocker
ECHO ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
ECHO.
ECHO     !FAILED!
ECHO  Already Unlocked
ECHO.
ECHO.
PING -n 4 127.0.0.1 >nul
GOTO MENU
