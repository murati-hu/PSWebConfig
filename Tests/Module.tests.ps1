. (Join-Path $PSScriptRoot Import-LocalModule.ps1)

$moduleName = 'PSWebConfig'
$expectedCommands = @(
    'Get-PSWebConfig'
    'Get-PSConnectionString'
)

Describe "$moduleName Module" {
    It "Should be loaded" {
        Get-Module $moduleName | Should Not BeNullOrEmpty
    }
}

Foreach ($command in (Get-Command -Module $moduleName))
{
    Describe "$moduleName\$command Command" {
        It "Should be expected" {
            $expectedCommands -contains $command.Name | Should Be $true
        }

        It "Should have proper help" {
            $help = Get-Help $command.Name
            $help.description | Should Not BeNullOrEmpty
            $help.Synopsis | Should Not BeNullOrEmpty
            $help.examples | Should Not BeNullOrEmpty
        }
    }
}
