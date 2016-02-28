. (Join-Path $PSScriptRoot '../Import-LocalModule.ps1')

$scriptSources = Get-ChildItem -Path $script:FunctionPath -Filter '*.ps1' -Recurse
$scriptAnalyzer = Get-Module PSScriptAnalyzer -ListAvailable

if (-Not $scriptAnalyzer) {
    Write-Verbose "PSScriptAnalyzer module is not available."
    return
}

Describe "Script Source analysis" {
    Import-Module PSScriptAnalyzer

    $scriptSources | ForEach-Object {
        Context "Source $($_.Name)" {
            $results = Invoke-ScriptAnalyzer -Path $_.FullName -ErrorVariable $errors

            it "should have no errors" {
                $errors | Should BeNullOrEmpty
            }

            it "should not have warnings" {
                $results |
                Where-Object Severity -eq "Warning" |
                Should BeNullOrEmpty
            }

        }
    }
}
