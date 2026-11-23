________________________________________________________________________________
MAKE SURE YOU HAVE POWERSHELL 7 BEFORE RUNNING THIS SCRIPT

MAKE SURE TO SHOW FILE EXTENSIONS IN YOUR FILE EXPLORER

VPATCH IS REQUIRED

PSINI IS REQUIRED
---------------------------------------------------------------------------------

This script will resize your Touhou vpatch games every time you start the script.
---------------------------------------------------------------------------------

[Table of Contents]
1. SETUP
2. HOW TO RUN WITH YOUR GAME
3. How TO RUN WITH THCRAP
4. Options (Don't forget to read)
---------------------------------
_________________________________________________________________________________

__________
1. SETUP
__________

1 - If you do not have Windows 11, download Powershell 7 from here:
    https://github.com/PowerShell/PowerShell/releases
    |
    -   Look for a file ending in win-x64.msi or win-x86.msi, then install it

2 - Open a Powershell 7 window

3 - Copy and paste: Install-Module -Name PsIni

4 - If it asks you if you trust PowerShell Gallery, type y

5 - Close Powershell
__________


______________________________
2. HOW TO RUN WITH YOUR GAME
______________________________

1 - To start the script and run your game, move the script to your Touhou folder
    -   THIS IS VERY IMPORTANT: Do not make a new folder. It works best next to your game this way.

2 - Make a new txt file where your and paste the following line:

pwsh.exe -command "&{.\thautores.ps1; Start-Touhou -Game '.\Touhou06.exe'}"

3 - replace '.\Touhou06.exe' with your game name (example: '.\Touhou15.exe')

4 - save and rename your .txt file's extension as .bat

5 - You're done! Just double click your .bat file
__________

___________________________
3. HOW TO RUN WITH THCRAP
___________________________

1 - Download THCRAP from https://github.com/thpatch/thcrap/releases and find thcrap.zip

2 - Unzip the files to any folder and run thcrap.exe and follow the installer

3 - Make a new .txt file where your thcrap is and paste the following line:

pwsh.exe -command "&{.thautores.ps1; Start-Touhou -Thcrap 'C:\thcrap' -Game 'th06' -Modpack 'thpatch-en.js' }"

4 - Replace -Thcrap 'C:\thcrap' with your thcrap folder location
    -   Use -Thcrap '.\' if the script is in the folder
    -   Use -Thcrap '..\' if the script is in a folder inside thcrap
    -   Use -Thcrap '..\thcrap' if the script is in a folder next to the thcrap folder

5 - Replace -Game 'th06' with your game's initials (example: -Game 'th15')

6 - Replace -Modpack 'thpatch-en.js' with the mod pack you made in step 1 (example: -Modpack "lang_en-alt.js")

8 - Save and rename your .txt file's extension as .bat

5 - You're done! Just double click your .bat file
__________

____________
4. Options
____________

-Thcrap     -   Your thcrap folder

-Game       -   Your game .exe file or your game's initials in thcrap's settings
                -   Pointing to an exe file ignores thcrap and launches your game directly instead

-Modpack    -   the name of your desired mod pack
                -   Find the names of your mod packs in your "thcrap/config/" folder (example "lang_en-alt.js")

-EditOnly   -   Whether or not to start the game after changing vpatch.ini
                -   This is set to 0 by default. If you are using a launcher like Playnite, consider setting it to 1.
__________