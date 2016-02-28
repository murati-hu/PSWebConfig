. (Join-Path $PSScriptRoot '../Import-LocalModule.ps1')

$isVerbose=($VerbosePreference -eq 'Continue')

$webConfigFile = Join-Path $script:configFolder 'web.config'

Describe "Get-PSEndpoint" {
    Context "Local web.config" {
        $config = Get-PSWebConfig -Path $webConfigFile -Verbose:$isVerbose
        $endpoints = $config | Get-PSEndpoint -Verbose:$isVerbose

        It "should return all client endpoints as an address" {
            $endpoints | Should Not BeNullOrEmpty
            $endpoints.Count | Should Be 2
            $endpoints | Foreach-Object {
                $_.psobject.TypeNames -contains 'PSWebConfig.Uri' | Should Be $true
                $_.SectionPath | Should Be 'system.serviceModel/client/endpoint'
                $_.name | Should Not BeNullOrEmpty
                $_.address | Should Not BeNullOrEmpty
                $_.Uri | Should Not BeNullOrEmpty
            }
        }
    }
}
