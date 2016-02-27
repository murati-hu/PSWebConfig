. (Join-Path $PSScriptRoot Import-LocalModule.ps1)

$TestVerbose=$false

$webConfigFolder = Join-Path $PSScriptRoot 'ConfigTests'
$webConfigFile = Join-Path $webConfigFolder 'web.config'

Describe 'Get-PSUri' {
    Context 'Local web.config' {
        $config = Get-PSWebConfig -Path $webConfigFile -Verbose:$TestVerbose
        $addresses = $config | Get-PSUri -Verbose:$TestVerbose

        It 'should return all addresses' {
            $addresses | Should Not BeNullOrEmpty
            $addresses.Count | Should Be (2+2) # appSetting + endpoints
            $addresses | Foreach-Object {
                $_.psobject.TypeNames -contains 'PSWebConfig.Uri' | Should Be $true
                $_.SectionPath | Should Match '^system.serviceModel/client/endpoint$|^appSettings$'
                $_.name | Should Not BeNullOrEmpty
                $_.address | Should Not BeNullOrEmpty
                $_.Uri | Should Match '^http[s]*:'
            }
        }
    }
}
