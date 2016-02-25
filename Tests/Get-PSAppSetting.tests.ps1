. (Join-Path $PSScriptRoot Import-LocalModule.ps1)

$TestVerbose=$false

$webConfigFolder = Join-Path $PSScriptRoot 'ConfigTests'
$webConfigFile = Join-Path $webConfigFolder 'web.config'

Describe 'Get-PSAppSetting' {
    Context 'Local web.config' {
        $config = Get-PSWebConfig -Path $webConfigFile -Verbose:$TestVerbose
        $appSettings = $config | Get-PSAppSetting -Verbose:$TestVerbose

        It 'should return all AppSettings' {
            $appSettings | Should Not BeNullOrEmpty
            $appSettings.Count | Should Be 5
            $appSettings | Foreach-Object {
                $_.psobject.TypeNames -contains 'PSWebConfig.AppSetting' | Should Be $true
                $_.SectionPath | Should Be 'appSettings'
                $_.key | Should Not BeNullOrEmpty
                $_.value | Should Not BeNullOrEmpty
            }
        }
    }
}
