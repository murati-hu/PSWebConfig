. (Join-Path $PSScriptRoot Import-LocalModule.ps1)

$TestVerbose=$false

$webConfigFolder = Join-Path $PSScriptRoot 'ConfigTests'
$webConfigFile = Join-Path $webConfigFolder 'web.config'

Describe 'Get-PSAddress' {
    Context 'Local web.config' {
        $config = Get-PSWebConfig -Path $webConfigFile -Verbose:$TestVerbose
        $addresses = $config | Get-PSAddress -Verbose:$TestVerbose

        It 'should return all addresses' {
            $addresses | Should Not BeNullOrEmpty
            $addresses.Count | Should Be (2+2) # appSetting + endpoints
            $addresses | Foreach-Object {
                $_.psobject.TypeNames -contains 'PSWebConfig.Address' | Should Be $true
                $_.SectionPath | Should Match '^system.serviceModel/client/endpoint$|^appSettings$'
                $_.name | Should Not BeNullOrEmpty
                $_.address | Should Match '^http[s]*:'
            }
        }
    }
}
