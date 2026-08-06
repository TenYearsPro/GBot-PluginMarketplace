#Requires -Version 5.1
<#
.SYNOPSIS
  第三方作者：把已编译的插件 DLL 打成市场 zip，并可选更新 marketplace.json。
#>
param(
    [Parameter(Mandatory = $true)][string]$DllDir,
    [Parameter(Mandatory = $true)][string]$Id,
    [Parameter(Mandatory = $true)][string]$Name,
    [Parameter(Mandatory = $true)][string]$Version,
    [Parameter(Mandatory = $true)][string]$Author,
    [Parameter(Mandatory = $true)][string]$Description,
    [Parameter(Mandatory = $true)][string]$EntryDll,
    [string]$Homepage = "",
    [string]$MinAppVersion = "0.1.15",
    [int]$AbstractionsMajor = 1,
    [switch]$SkipCatalogUpdate
)

$ErrorActionPreference = "Stop"
$marketRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
$dllDirFull = Resolve-Path $DllDir
$entryPath = Join-Path $dllDirFull $EntryDll
if (-not (Test-Path $entryPath)) { throw "Entry DLL not found: $entryPath" }

function Write-Utf8NoBom([string]$Path, [string]$Content) {
    $utf8 = New-Object System.Text.UTF8Encoding $false
    [System.IO.File]::WriteAllText($Path, $Content, $utf8)
}

$pkgDir = Join-Path $marketRoot "packages"
$staging = Join-Path $env:TEMP ("gbot-mkt-" + [guid]::NewGuid().ToString("N"))
New-Item -ItemType Directory -Force -Path $pkgDir, $staging | Out-Null

$banned = @("GBot.PluginAbstractions.dll", "GBot.Core.dll", "gbot.dll", "gbot.exe")
Get-ChildItem $dllDirFull -Filter *.dll | ForEach-Object {
    if ($banned -contains $_.Name) { Write-Host "Skip banned: $($_.Name)"; return }
    if ($_.Name -like "Avalonia*") { Write-Host "Skip Avalonia: $($_.Name)"; return }
    Copy-Item $_.FullName (Join-Path $staging $_.Name) -Force
}

$pluginObj = [ordered]@{
    id = $Id; name = $Name; version = $Version; author = $Author
    description = $Description; homepage = $Homepage
    minAppVersion = $MinAppVersion; abstractionsMajor = $AbstractionsMajor
    entryDll = $EntryDll
}
Write-Utf8NoBom (Join-Path $staging "plugin.json") ($pluginObj | ConvertTo-Json -Depth 5)

$zipName = "$Id-$Version.zip"
$zipPath = Join-Path $pkgDir $zipName
if (Test-Path $zipPath) { Remove-Item $zipPath -Force }
Add-Type -AssemblyName System.IO.Compression.FileSystem
[System.IO.Compression.ZipFile]::CreateFromDirectory($staging, $zipPath)
Remove-Item $staging -Recurse -Force

$hash = (Get-FileHash -Algorithm SHA256 -Path $zipPath).Hash.ToLowerInvariant()
Write-Host "Packed: $zipPath"
Write-Host "SHA256: $hash"

if ($SkipCatalogUpdate) { return }

$catalogPath = Join-Path $marketRoot "marketplace.json"
$plugins = @()
if (Test-Path $catalogPath) {
    $catalog = [System.IO.File]::ReadAllText($catalogPath, [System.Text.UTF8Encoding]::new($false)) | ConvertFrom-Json
    if ($catalog.plugins) { $plugins = @($catalog.plugins) }
}

$entry = [pscustomobject]@{
    id = $Id; name = $Name; version = $Version; author = $Author
    description = $Description; homepage = $Homepage
    minAppVersion = $MinAppVersion; abstractionsMajor = $AbstractionsMajor
    downloadUrl = "packages/$zipName"; sha256 = $hash; entryDll = $EntryDll
}
$plugins = @($plugins | Where-Object { $_.id -ne $Id }) + $entry
$catalogObj = [pscustomobject]@{
    schemaVersion = 1
    updatedAt = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
    plugins = $plugins
}
Write-Utf8NoBom $catalogPath ($catalogObj | ConvertTo-Json -Depth 8)
Write-Host "Updated: $catalogPath"
