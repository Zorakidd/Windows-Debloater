# ============================================
# PowerShell Deinstallations-Skript
# Autor: Zora
# ============================================

# Optionaler Schalter zum Testen: nur Log schreiben und beenden
param(
    [switch]$TestLog
)

# ========================================
# Funktion: Log schreiben
# ========================================
function Write-Log {
    param([string]$Nachricht)
    $Zeit = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $entry = "$Zeit - $Nachricht"
    try {
        # Stelle sicher, dass das Verzeichnis existiert
        $parent = Split-Path -Parent $LogDatei
        if (-not (Test-Path -Path $parent)) {
            New-Item -Path $parent -ItemType Directory -Force | Out-Null
        }
        # Schreibe den Log-Eintrag (erstellt die Datei falls nötig)
        $entry | Out-File -FilePath $LogDatei -Append -Encoding UTF8
    }
    catch {
        # Wenn Schreiben fehlschlägt, schreibe in das TEMP-Verzeichnis als Fallback
        $fallback = Join-Path $env:TEMP 'Deinstallation_Log.txt'
        $entry | Out-File -FilePath $fallback -Append -Encoding UTF8
    }
}

# Log-Datei Pfad (robust)
# Bevorzuge das aktuelle Arbeitsverzeichnis (der Ort, von dem das Skript ausgeführt wird).
# Falls das aktuelle Verzeichnis nicht vom Dateisystem ist oder nicht beschreibbar ist,
# fällt auf den Downloads-Ordner zurück. Danach folgen $PSScriptRoot, Documents, TEMP.
$logDirCandidates = @()

try {
    $cwd = (Get-Location).ProviderPath
    if ($cwd -and (Test-Path -Path $cwd -PathType Container)) { $logDirCandidates += $cwd }
}
catch {
}

$downloads = Join-Path -Path $env:USERPROFILE -ChildPath 'Downloads'
if (Test-Path -Path $downloads -PathType Container) { $logDirCandidates += $downloads }

if ($PSScriptRoot -and $PSScriptRoot.Trim().Length -gt 0) { $logDirCandidates += $PSScriptRoot }

$documentsFallback = Join-Path -Path $env:USERPROFILE -ChildPath 'Documents\WinOpLogs'
$logDirCandidates += $documentsFallback

# Always add TEMP as last fallback
$logDirCandidates += $env:TEMP

$logDir = $null
foreach ($candidate in $logDirCandidates) {
    try {
        if (-not (Test-Path -Path $candidate)) {
            New-Item -Path $candidate -ItemType Directory -Force | Out-Null
        }
        # Test write permission by creating a temporary file
        $testFile = Join-Path -Path $candidate -ChildPath ('._logpermtest_{0}.tmp' -f ([System.Guid]::NewGuid().ToString()))
        '' | Out-File -FilePath $testFile -Encoding UTF8
        Remove-Item -Path $testFile -ErrorAction SilentlyContinue
        $logDir = $candidate
        break
    }
    catch {
        # try next candidate
        continue
    }
}

if (-not $logDir) { $logDir = $env:TEMP }

$LogDatei = Join-Path -Path $logDir -ChildPath 'Deinstallation_Log.txt'

# ========================================
# Sektion: Testmodus prüfen
# ========================================

if ($TestLog) {
    Write-Host "TEST-MODUS: Skript wird beendet, ohne Apps zu entfernen."
    Write-Log "TEST-MODUS: Keine Apps entfernt"
    exit
}

# ========================================
# Sektion: Deinstallation der Apps
# ========================================

# Liste der zu entfernenen Apps (als Strings)
$appsToRemove = @(
    "*3d*",
    "*CandyCrush*",
    "*crossdevice*",
    "*feedbackhub*",
    "*MicrosoftFamily*",
    "*Skype*",
    "*Solitair*",
    "*Spades*",
    "*Weather*",
    "*windowscommunicationsapps*",
    "*windowsmaps*",
    "*xing*",
    "*YourPhone*",
    "7EE7776C.LinkedInforWindows",
    "LinkedInforWindows",
    "Microsoft.BioEnrollment",
    "Microsoft.MSPaint3D",
    "Microsoft.Paint3D",
    "Microsoft.PeopleExperienceHost",
    "Microsoft.ParentalControls",
    "Clipchamp.Clipchamp",
    "Microsoft.Clipchamp",
    "Microsoft.3DBuilder",
    "Microsoft.3DViewer",
    "Microsoft.Microsoft3DViewer",
    "Microsoft.549981C3F5F10",
    "Microsoft.Asphalt8Airborne",
    "Microsoft.BingFinance",
    "Microsoft.BingNews",
    "Microsoft.BingSports",
    "Microsoft.BingWeather",
    "Microsoft.Calculator",
    "Microsoft.Camera",
    "Microsoft.CandyCrush",
    "Microsoft.CandyCrushFriends",
    "Microsoft.CandyCrushSaga",
    "Microsoft.CandyCrushSodaSaga",
    "Microsoft.Copilot",
    "Microsoft.Cortana",
    "Microsoft.CrossDevice",
    "Microsoft.DrawboardPDF",
    "Microsoft.Feedbackhub",
    "Microsoft.WindowsFeedbackhub",
    "Microsoft.GetHelp",
    "Microsoft.Getstarted",
    "Microsoft.MicrosoftFamily",
    "Microsoft.MicrosoftNews",
    "Microsoft.MicrosoftSolitaireCollection",
    "Microsoft.MicrosoftStickyNotes",
    "Microsoft.MicrosoftWindowsFeedbackHub",
    "MicrosoftWindows.Client.WebExperience",
    "Microsoft.MicrosoftYourPhone",
    "Microsoft.MixedReality.Portal",
    "Microsoft.MSPaint",
    "Microsoft.MSPaintApp",
    "Microsoft.MicrosoftOfficeHub", # Office Dinge
    "Microsoft.Office.Desktop",
    "Microsoft.Office.Lens",
    "Microsoft.Office.OneNote",
    "Microsoft.Office.Sway",
    "Microsoft.OneNote",
    "Microsoft.OneConnect",
    "Microsoft.OneDrive",
    "Microsoft.People",
    "Microsoft.PhonicsApp",
    "Microsoft.PSAko",
    "Microsoft.Skype",
    "Microsoft.SkypeApp",
    "Microsoft.StartExperiencesApp",
    "Microsoft.Todos",
    "Microsoft.Wallet",
    "Microsoft.WebMediaExtensions",
    "Microsoft.Whiteboard",
    "Microsoft.WidgetsPlatformRuntime",
    "Microsoft.WindowsAlarms",
    "Microsoft.WindowsCamera",
    "Microsoft.WindowsCalculator",
    "Microsoft.WindowsCommunicationsApps",
    "Microsoft.WindowsFeedbackHub",
    "Microsoft.WindowsMaps",
    "Microsoft.WindowsSolitaireCollection",
    "Microsoft.WindowsSoundRecorder",
    "Microsoft.WindowsStickyNotes",
    "Microsoft.WindowsTips",
    "Microsoft.WindowsWeather",
    # "Microsoft.XboxGamingOverlay", # Damit Gaming Overlay nicht nervt
    # "Microsoft.MicrosoftXboxApp", # Wegen Minecraft etc.
    # "Microsoft.MicrosoftXboxIdentityProvider",
    # "Microsoft.MicrosoftXboxSpeechToTextOverlay",
    # "Microsoft.WindowsXboxSigningTool",
    # "Microsoft.XboxApp",
    # "Microsoft.GamingApp",
    # "Microsoft.GamingServices",
    # "Microsoft.Xbox.TCUI",
    # "Microsoft.XboxIdentityProvider",
    # "Microsoft.XboxSpeechToTextOverlay",
    # "Microsoft.XboxGameCallableUI",
    "Microsoft.Windows.DevHome",
    "Microsoft.Edge.GameAssist",
    "Microsoft.MicrosoftEdge",
    "Microsoft.MicrosoftEdge.Stable",
    "Microsoft.MicrosoftEdgeDevToolsClient",
    "Microsoft.Ink.Handwriting*",
    "Microsoft.Windows.NarratorQuickStart",
    "Microsoft.Windows.SecureAssessmentBrowser",
    "Microsoft.Windows.AssignedAccessLockApp",
    "Microsoft.Windows.ParentalControls",
    "Microsoft.Windows.PeopleExperienceHost",
    "Microsoft.YourPhone",
    "Microsoft.MicrosoftZuneVideo",
    "Microsoft.ZuneVideo",
    "Microsoft.PowerAutomateDesktop",
    "Microsoft.PeopleApp",
    "Microsoft.BingSearch",
    "Microsoft.Paint",
    "Microsoft.OutlookForWindows",
    "Microsoft.XING",
    "MicrosoftCorporationII.QuickAssist",
    "MSTeams",
    "Microsoft.WindowsCalculator"
    "Microsoft.WindowsVoiceRecorder"
    # "Microsoft.WindowsNotepad", # Die Dinger nutze ich selbst
    # "Microsoft.Windows.Photos"
    # "Microsoft.ScreenSketch",
    # "Microsoft.ZuneMusic",
    # "Microsoft.MicrosoftZuneMusic",
    # "SpotifyAB.SpotifyMusic" # Falls Spotify App installiert ist
)

Write-Host "Log-Datei: $LogDatei"
Write-Host "Log-Verzeichnis vorhanden: $(Test-Path -Path (Split-Path $LogDatei -Parent))"
Write-Host ""
Write-Host "Starte Deinstallation..." -ForegroundColor Green
Write-Log "=== Starte Deinstallation ==="

# Entfernen bestimmter Apps mit Fehlerbehandlung aus der Liste
foreach ($app in $appsToRemove) {

    try {
        $package = Get-AppxPackage -AllUsers -Name $app -ErrorAction Stop
        if ($null -ne $package) {
            $package | Remove-AppxPackage -AllUsers -ErrorAction Stop
            Write-Log "App $app wurde erfolgreich entfernt."
        }
        else {
            Write-Log "App $app wurde nicht gefunden."
        }
    }
    catch {
        Write-Log "  [ERROR] Fehler beim Entfernen von $app : $($_.Exception.Message)"
    }

    # Provisioned Packages entfernen (für neue Benutzer)
    try {
        $provisionedPackages = Get-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue | 
        Where-Object { $_.PackageName -like $app }
        
        if ($provisionedPackages.Count -gt 0) {
            foreach ($provPackage in $provisionedPackages) {
                $provPackage | Remove-AppxProvisionedPackage -Online -ErrorAction Stop -Confirm:$false
                Write-Log "  [OK] Provisioned Package entfernt: $($provPackage.PackageName)"
            }
        }
    }
    catch {
        Write-Log "  [ERROR] Fehler bei Provisioned Package '$app': $($_.Exception.Message)"
    }
}

# ========================================
# Sektion: Abschluss und Neustart
# ========================================

Write-Host ""
Write-Host "Deinstallation abgeschlossen!" -ForegroundColor Green
Write-Log "=== Deinstallation abgeschlossen ==="
Start-Sleep -Seconds 2


# MessageBox für Reboot anzeigen
Add-Type -AssemblyName PresentationFramework
$logMsg = "Das Log wurde gespeichert unter:`n$LogDatei"
$msg = "Ein Neustart wird empfohlen, um alle Changes abzuschliessen.`n`n$logMsg`n`nWollen Sie den Computer jetzt neu starten?"

$Antwort = [System.Windows.MessageBox]::Show(
    $msg,
    "Systemwartung Neustart empfohlen",
    'YesNo',
    'Question'
)

if ($Antwort -eq "Yes") {
    Write-Log "Benutzer hat Neustart gewählt."
    Restart-Computer -Force
}
else {
    Write-Log "Benutzer hat Neustart abgelehnt."
}

# Ende des Skripts