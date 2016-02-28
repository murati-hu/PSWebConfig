. (Join-Path $PSScriptRoot '../Import-LocalModule.ps1')

$isVerbose=($VerbosePreference -eq 'Continue')

$webConfigFile = Join-Path $script:FixturePath 'web.config'

Describe "Get-PSConnectionString" {
    Context "Local web.config connectionStrings section" {
        $config = Get-PSWebConfig -Path $webConfigFile -Verbose:$isVerbose

        It "should return only connectionStrings by default" {
            $connStrs = $config | Get-PSConnectionString -Verbose:$isVerbose
            $connStrs | Should Not BeNullOrEmpty
            $connStrs.GetType().Name | Should Be "XmlElement"
            $connStrs.psobject.TypeNames -contains 'PSWebConfig.ConnectionString' | Should Be $true

            $connStrs.name | Should Be 'login'
            $connStrs.SectionPath | Should Be 'connectionStrings'
            $connStrs.connectionstring | Should Not BeNullOrEmpty
        }

        It "should return connectionStrings with -IncludeAppSettings" {
            $connStrs = $config | Get-PSConnectionString -IncludeAppSettings -Verbose:$isVerbose
            $connStrs | Should Not BeNullOrEmpty
            $connStrs.Count | Should Be 2
            $connStrs | Foreach-Object {
                $_.psobject.TypeNames -contains 'PSWebConfig.ConnectionString' | Should Be $true
                @('login','AppConfigSqlConnectionString') -contains $_.name  | Should Be $true
                @('connectionStrings','appSettings') -contains $_.SectionPath | Should Be $true
                $_.connectionstring | Should Not BeNullOrEmpty
            }
        }
    }
}
