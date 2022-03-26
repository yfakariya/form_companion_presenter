<#
.SYNOPSIS
Run genhtml for lcov. This script should run on each package directory.
#>
#Requires -Version 5.1
using namespace System.Diagnostics
using namespace System.IO
using namespace System.Runtime.InteropServices

param(
    [String][ValidateNotNullOrEmpty()]$InputDirectory = './coverage/',
    [String][ValidateNotNullOrEmpty()]$OutputDirectory = './coverage/html'
)

Set-StrictMode -Version Latest

$VerbosePreference = 'SilentlyContinue'
$InformationPreference = 'Continue'
$ErrorActionPreference = 'Stop'

[Stopwatch]$sw = [Stopwatch]::StartNew()

[string]$originalCurrentDirectory = [Environment]::CurrentDirectory
try {
    [Environment]::CurrentDirectory = $pwd

    [string]$inputPath = [Path]::GetFullPath($InputDirectory)
    [string]$outputPath = [Path]::GetFullPath($OutputDirectory)

    Write-Information "Input directory path  : $inputPath"
    Write-Information "Output directory path : $outputPath"

    if (!(Test-Path $inputPath -PathType Container)) {
        throw "$inputDirectory does not exist."
    }

    [string]$lcovFilePath = [Path]::Combine($InputDirectory, 'lcov.info')
    
    if (!(Test-Path $lcovFilePath -PathType Leaf)) {
        if ((Test-Path "$inputPath/test" -PathType Container) -and
            [Directory]::GetFiles("$inputPath", '*.vm.json', [SearchOption]::AllDirectories).Count -eq 0) {
            throw "$inputPath does not have any file."
        }

        Write-Information "$lcovFilePath does not exist but some *.vm.json files are found. Converting..."
 
        fvm dart pub global run coverage:format_coverage --packages=.packages --report-on=lib --lcov -i "$inputPath" -o $lcovFilePath
        if ($LASTEXITCODE -ne 0) {
            throw 'Failed to run coverage:format_coverage to convert *.vm.json file(s) to lcov.info.'
        }
    }

    Write-Information "Generate HTML to $outputPath"

    if ([RuntimeInformation]::IsOSPlatform([OSPlatform]::Windows)) {
        where.exe perl *> $null
        if ($LASTEXITCODE -ne 0) {
            throw 'perl is required. Ensure install lcov package from chocolatey.'
        }
        if (!(Test-Path "${env:ProgramData}\chocolatey\lib\lcov\tools\bin\genhtml" -PathType Leaf)) {
            throw 'genhtml is required. Ensure install lcov package from chocolatey.'
        }

        perl """${env:ProgramData}\chocolatey\lib\lcov\tools\bin\genhtml""" -o """$outputPath""" """$lcovFilePath"""
    }
    else {
        which genhtml *> $null
        if ($LASTEXITCODE -ne 0) {
            throw 'genhtml is required. Ensure install lcov package from package manager like apt, homebrew, etc..'
        }

        genhtml -o $outputPath $lcovFilePath
    }

    Write-Information "Done. Elapsed $($sw.Elapsed)"

    & "$outputPath/index.html"
}
finally {
    [Environment]::CurrentDirectory = $originalCurrentDirectory
}