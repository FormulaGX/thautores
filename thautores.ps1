#This program changes the vpatch.config file resolutions
#I'm sick of editing vpatch.ini files

#Requires -Version 7.2
#Requires -Module PSIni

Add-Type -AssemblyName System.Windows.Forms

function global:Start-Touhou([string]$Thcrap, [string]$Game, [string]$Modpack, [boolean]$EditOnly) {

    #File and folder paths
    $configPath = "$PSScriptRoot\thautores.json"
    $thcrapFiles = @{
        'thcrap_loader'='\bin\thcrap_loader.exe';
        'games'='\config\games.js'
    }
    $vpatchPath = '../vpatch.ini'

    #Ensure that strings are not enclosed in quotation marks
    function Get-UnenclosedString($string) {
        if ($string.StartsWith('&')) {
            $string = $string.Substring($string.IndexOf("'"))
        }
        if (($string.StartsWith('"') -and $string.EndsWith('"')) -or ($string.StartsWith("'") -and $string.EndsWith("'"))) {   
            $string = $string.Substring(1,$string.Length-2)
        }
        return $string
    }

    #Get and process user input to a plain string
    function Get-UserInput($prompt) {
        $string = Read-Host -Prompt $prompt
        $string = Get-UnenclosedString($string)
        return $string
    }

    #Load config file in the script root directory
    function Get-THAR_Config([ref]$config) {
        
        #Load THCRAP content
        function Get-THAR_THCRAP{
            $filePath = ''
            $modified = $false
            
            #Load file paths if they are valid; ask the user otherwise
            if (-not(
                        $config.Value.ContainsKey('thcrap') -and
                        $config.Value.thcrap.ContainsKey('folder') -and
                        (Test-Path -Path $config.Value['thcrap']folder -PathType Container) -and
                        ($Thcrap -eq $config.Value['thcrap']['folder'] -or $null -eq $Thcrap)
                    )
                ) {

                #Initialize config if it 
                $config.Value = $config.Value + @{
                    'thcrap'=@{
                        'folder'=$filePath
                        'thcrap_loader'=''
                        'games'=''
                    }
                    'vpatch'=@{}
                }

                while (-not(Test-Path -Path $config.Value.thcrap.folder -PathType Container)) {
                    if ($null -ne $Thcrap -and (Test-Path -Path $config.Value.thcrap.folder -PathType Container)) {
                        $filePath = $Thcrap
                    } else {
                        $filePath = Get-UserDefinedPath('Enter your thcrap folder')
                    }
                    $config.Value.thcrap.folder = $filePath
                    if (-not (Test-Path -Path $filePath -PathType Container)) {
                        Write-Output 'Folder not found, please try again.'
                    }
                }
                $modified = $true
            }

            #Get required THCRAP files
            foreach ($key in $thcrapFiles.Keys) {
                $value = $thcrapFiles[$key]
                $filePath = Join-Path $config.Value.thcrap.folder -ChildPath $value

                if (-not(
                        $config.Value.thcrap.ContainsKey($key) -and
                        ($null -ne $config.Value.thcrap[$key]) -and
                        (Test-Path -Path $config.Value.thcrap[$key] -PathType Leaf)
                        )
                    ) {
                    
                    Write-Output "`"$key`" not found, writing default values."
                    $config.Value.thcrap[$key] = $filePath
                    $modified = $true
                }
            }
            
            if($modified) {
                $config.Value | ConvertTo-Json | Out-File $configPath
            }
        }

        #Find vpatch.ini files in game directories
        function Get-THAR_Vpatch {
            $gamesTemp = Get-Content $config.Value.thcrap.games | ConvertFrom-Json -AsHashtable
            $modified = $false

            if (-not ($config.Value.ContainsKey('vpatch') -and $config.Value.vpatch -eq $gamesTemp)) {
                foreach ($key in $gamesTemp.Keys) {
                    $value = $gamesTemp[$key]
                    $filePath = Join-Path $value -ChildPath $vpatchPath

                    if ($gamesTemp.ContainsKey($key) -and ($null -ne $value) -and (Test-Path -Path $filePath -PathType Leaf)) {
                        Write-Output "vpatch.ini found for `"$key`"'s!"

                        $config.Value.vpatch[$key] = $filePath
                    } else {
                        Write-Output "vpatch.ini not found for `"$key`"'s, skipping."
                    }
                }
                $modified = $true
            }

            if ($modified) {
                    $config.Value | ConvertTo-Json | Out-File $configPath
            }
        }

        #Create a config file if it doesn't already exist
        if ((Test-Path -Path $configPath -PathType Leaf) -and ($null -ne (Get-Content $configPath | ConvertFrom-Json -AsHashtable))) {
            Write-Output 'Loading configuration file.'

            $config.Value = Get-Content $configPath | ConvertFrom-Json -AsHashtable
            Get-THAR_THCRAP
            Get-THAR_Vpatch

            Write-Output "Configuration loaded. "
        } else { #Load otherwise
            Write-Output 'No configuration file found, creating file.'

            $config.Value | ConvertTo-Json | Out-File $configPath
            Get-THAR_THCRAP
            Get-THAR_Vpatch

            Write-Output "Configuration file created as $configPath"
        }
    }

    # #TODO List mod packs to the user
    # function Get-ModPacks() {
        
    # }

    #Forward game commands to THCRAP and edit the corresponding vpatch.ini
    function Update-VPatch($config) {
        $screenSpace = [System.Windows.Forms.Screen]::PrimaryScreen

        #Typical vpatch.ini values
        $VPWindow = @{
            'Window'=@{
                'AskWindowMode' = 0
                'enabled' = 1
                'X' = 0
                'Y' = 0
                'Width' = 960
                'Height' = 720
                'TitleBar' = 0
                'AlwaysOnTop' = 0
            }
        }

        #Prepare and edit vpatch.ini
        function Edit-Vpatch_ini {

            #Calculate window size by working area in 4:3 aspect ratio
            if ($screenSpace.WorkingArea.Height -le $screenSpace.WorkingArea.Width*(3/4)) {
                $VPWindow.Window.Width = $screenSpace.WorkingArea.Height*(4/3)
                $VPWindow.Window.Height = $screenSpace.WorkingArea.Height
            } else {
                $VPWindow.Window.Width = $screenSpace.WorkingArea.Width
                $VPWindow.Window.Height = $screenSpace.WorkingArea.Width*(3/4)
            }

            $VPWindow.Window.X = (($screenSpace.WorkingArea.Width-$VPWindow.Window.width)/2)+$screenSpace.WorkingArea.X
            $VPWindow.Window.Y = (($screenSpace.WorkingArea.Height-$VPWindow.Window.height)/2)+$screenSpace.WorkingArea.Y
        }

        function Set-Vpatch_Game {

                #Handles game execution
                if ($EditOnly -eq $false) {
                    if (Test-Path -Path $Game -PathType Leaf) {
    
                        Edit-Vpatch_ini
                        Out-IniFile -InputObject $iniTarget -FilePath $iniTargetPath -Force -Pretty
                        
                        & $Game
                    } else {
                        Write-Output "The game $Game was not found. Check your spelling."
                    }
                } else {
                    if (Test-Path -Path $Game -PathType Leaf) {
                        Edit-Vpatch_ini
                        Out-IniFile -InputObject $iniTarget -FilePath $iniTargetPath -Force -Pretty
                    } else {
                        Write-Output "The game $Game was not found. Check your spelling."
                    }
                }
            }

        function Set-Vpatch_THCRAP {
            Write-Output "$Game Vpatch.ini content:" $iniTarget
            $iniTarget.Window = $VPWindow.Window

            #Handles game execution
            if ($EditOnly -eq $false) {
                if ($config.vpatch.ContainsKey($Game)) {

                    Edit-Vpatch_ini
                    Out-IniFile -InputObject $iniTarget -FilePath $config['vpatch'][$Game] -Force -Pretty

                    & $config['thcrap']['thcrap_loader'] $ModPack $Game
                } else {
                    Write-Output "The game $Game was not found. Check your spelling."
                }
            } else {
                if ($config.vpatch.ContainsKey($Game)) {
                    Edit-Vpatch_ini
                    Out-IniFile -InputObject $iniTarget -FilePath $config['vpatch'][$Game] -Force -Pretty
                } else {
                    Write-Output "The game $Game was not found. Check your spelling."
                }
            }
        }
        
        if ($useTHCRAP -eq $false) {
            $iniTargetPath = Join-Path -Path $Game -ChildPath $vpatchPath
            [hashtable] $iniTarget = Get-IniContent -FilePath $iniTargetPath
            Set-Vpatch_Game
        } else {
            $iniTargetPath = $config['vpatch'][$Game]
            [hashtable] $iniTarget = Get-IniContent -FilePath $iniTargetPath
            Set-Vpatch_THCRAP
        }
    }
    
    function main {
        
        [hashtable]$config = @{}
        
        if ($useTHCRAP -eq $false) {
            Update-VPatch
        } else {
            Get-THAR_Config([ref]$config)
            Write-Output "Configuration Content:" $config "`n----------------"
            Write-Output "Configuration Content:" $config['thcrap'] "`n----------------"
            Write-Output "Configuration Content:" $config['vpatch'] "`n----------------"
            Update-VPatch($config)
        }
    }

    $useTHCRAP = $false

    #Parameter processing
    $Game = Get-UnenclosedString($Game)
    $ModPack = Get-UnenclosedString($ModPack)

    while ($null -eq $Game) {
        $Game = Get-UserInput("Enter your game's .exe file or your thcrap folder")
    }

    if ($null -eq $Thcrap -or ($Game.EndsWith(".exe") -or $Game.EndsWith(".EXE"))) {
        $useTHCRAP = $false
    } else {
        $useTHCRAP = $true
    }

    if ($null -eq $ModPack) {
        $ModPack = ''
    }
    if (-not $ModPack.EndsWith('.js')) {
        $ModPack = "$ModPack.js"
    }

    if ($null -eq $EditOnly) {
        $EditOnly = $false
    }
    
    main
}