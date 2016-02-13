. (Join-Path $PSScriptRoot Import-LocalModule.ps1)

$TestVerbose=$false

#region Test-WebConfig
$webConfigFile = Join-Path $PSScriptRoot 'ConfigTests/web.config'
$webConfigSections = @(
    "appSettings"
    "connectionStrings"
)
#endregion

Describe "Web.config file test" {
    It "Test-file Should exists" {
        $webConfigFile | Should Exist
    }

    $xml = [xml](gc $webConfigFile)
    It "Should be a valid XMLDocument" {
        $xml.GetType().Name | Should Be "XmlDocument"
    }

    foreach($section in $webConfigSections) {
        It "Should have '$section' configuration section" {
            $xml.configuration.$section | Should Not BeNullOrEmpty
        }
    }
}

Describe "PSWebConfig Model" {
    # Load test file
    $config = Get-PSWebConfig -Path $webConfigFile -Verbose:$TestVerbose

    It "Should be able to read the file" {
        $config | Should Not BeNullOrEmpty
    }

    It "Should be a valid XMLDocument" {
        $config.GetType().Name | Should Be "XmlDocument"
    }

    It "Should have a configuration section" {
        $config.configuration | Should Not BeNullOrEmpty
    }

    It "Should have a configuration section" {
        $config.configuration.GetType().Name | Should Be "XmlElement"
    }
}
