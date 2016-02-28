. (Join-Path $PSScriptRoot '../Import-LocalModule.ps1')

$isVerbose=($VerbosePreference -eq 'Continue')

Describe "Get_ConfigFile helper" {
    # Function to test
    . (Join-Path $script:functionFolder 'Get_ConfigFile.ps1')
    $webConfigFile = Join-Path $script:configFolder 'web.config'

    It "Should be able to find web.config files recursively" {
        $files = Get_ConfigFile -Path $script:configFolder -AsFileInfo:$true -Recurse:$true -Verbose:$isVerbose
        $files | Should Not BeNullOrEmpty
        $files.GetType().Name | Should Be 'FileInfo'
    }

    It "Should be able to return XML content" {
        $xml = Get_ConfigFile -Path $webConfigFile -Verbose:$isVerbose
        $xml | Should Not BeNullOrEmpty
        $xml.configuration.GetType().Name | Should Be 'XmlElement'
        $xml.File | Should Be $webConfigFile
        $xml.ComputerName | Should Be ([System.Net.Dns]::GetHostByName($env:COMPUTERNAME).HostName)
    }

    It "Should be able to read the file content" {
        $content = Get_ConfigFile -Path $webConfigFile -AsText:$true -Verbose:$isVerbose
        $content | Should Not BeNullOrEmpty
        $content.GetType().Name | Should Be 'String'
    }
}
