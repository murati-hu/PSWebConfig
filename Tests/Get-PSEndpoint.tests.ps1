. (Join-Path $PSScriptRoot Import-LocalModule.ps1)

$TestVerbose=$false

$webConfigFolder = Join-Path $PSScriptRoot 'ConfigTests'
$webConfigFile = Join-Path $webConfigFolder 'web.config'

Describe "Get-PSEndpoint" {
    Context "Local web.config" {
        $config = Get-PSWebConfig -Path $webConfigFile -Verbose:$TestVerbose
        $endpoints = $config | Get-PSEndpoint -Verbose:$TestVerbose

        It "should return all client endpoints as an address" {
            $endpoints | Should Not BeNullOrEmpty
            $endpoints.Count | Should Be 2
            $endpoints | Foreach-Object {
                $_.psobject.TypeNames -contains 'PSWebConfig.Address' | Should Be $true
                $_.SectionPath | Should Be 'system.serviceModel/client/endpoint'
                $_.name | Should Not BeNullOrEmpty
                $_.address | Should Not BeNullOrEmpty
            }
        }
    }
}
