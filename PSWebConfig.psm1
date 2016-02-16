Write-Verbose "PSWebConfig module"

$functionFilter = Join-Path $PSScriptRoot "Functions\*.ps1"
Get-ChildItem -Path $functionFilter -Recurse | Foreach-Object {
    Write-Verbose "Loading file $($_.Name).."
    . $_.FullName
}

Update-FormatData -PrependPath (Join-path $PSScriptRoot 'PSWebConfig.format.ps1xml')
