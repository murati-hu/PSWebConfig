. (Join-Path $PSScriptRoot Import-LocalModule.ps1)

$moduleName = 'PSWebConfig'
$exportedCommands = (Get-Command -Module $moduleName)
$expectedCommands = @(
    'Get-PSWebConfig'
    'Test-PSWebConfig'
    
    'Get-PSAppSetting'

    'Get-PSConnectionString'
    'Test-PSConnectionString'

    'Get-PSEndpoint'
    'Get-PSUri'
    'Test-PSUri'
)

Describe "$moduleName Module" {
    It "Should be loaded" {
        Get-Module $moduleName | Should Not BeNullOrEmpty
    }
}

Describe 'Exported commands' {
    # Test if the exported command is expected
    Foreach ($command in $exportedCommands)
    {
        Context $command {
            It 'Should be an expected command' {
                $expectedCommands -contains $command.Name | Should Be $true
            }

            It 'Should have proper help' {
                $help = Get-Help $command.Name
                $help.description | Should Not BeNullOrEmpty
                $help.Synopsis | Should Not BeNullOrEmpty
                $help.examples | Should Not BeNullOrEmpty
            }
        }
    }
}

Describe 'Expected commands' {
    # Test if the expected command is exported
    Foreach ($command in $expectedCommands)
    {
        Context $command {
            It 'Should be an exported command' {
                $exportedCommands.Name -contains $command | Should Be $true
            }
        }
    }
}
