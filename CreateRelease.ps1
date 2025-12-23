param(
    # Technische Parameter
    [string]$InputFile = (Join-Path $PSScriptRoot "AppUninstallDailyVersion.ps1"),
    [string]$OutputFile = (Join-Path $PSScriptRoot "AppUninstallDailyVersion.exe"),
    [string]$IconFile = (Join-Path $PSScriptRoot "icon.ico"),

    # Metadaten
    [string]$Title = "App Uninstall",
    [string]$Description = "Hilfsprogramm zur Deinstallation von Programmen",
    [string]$Company = "Zora Industries",
    [string]$Product = "App Uninstall Tool",
    [string]$Copyright = "© 2025 Zora Industries",
    [string]$Trademark = "Zora Uninstaller",
    [string]$Version = "1.0.0.0"
)

<#
.SYNOPSIS
    Erstellt eine EXE aus einem PowerShell-Skript mit optionalem Icon.
#>

if (-not (Get-Command Invoke-PS2EXE -ErrorAction SilentlyContinue)) {
    Write-Error "Invoke-PS2EXE ist nicht verfuegbar. Bitte installiere das PS2EXE-Modul."
    Write-Host "Installiere es mit:"
    Write-Host "Install-Module -Name PS2EXE -Scope CurrentUser"
    exit 1
}

if (-not (Test-Path $InputFile)) {
    Write-Error "Die Eingabedatei '$InputFile' existiert nicht."
    exit 1
}

if (-not (Test-Path $IconFile)) {
    Write-Warning "Icon-Datei '$IconFile' nicht gefunden. Es wird kein Icon verwendet."
    $IconFile = $null
}

try {
    Invoke-PS2EXE `
        -InputFile   $InputFile `
        -OutputFile  $OutputFile `
        -IconFile    $IconFile `
        -Title       $Title `
        -Description $Description `
        -Company     $Company `
        -Product     $Product `
        -Copyright   $Copyright `
        -Trademark   $Trademark `
        -Version     $Version `
        -RequireAdmin `
        -NoConsole
}
catch {
    Write-Error "Fehler beim Erstellen der EXE: $_"
    exit 1
}