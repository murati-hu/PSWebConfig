. (Join-Path $PSScriptRoot Import-LocalModule.ps1)

$TestVerbose=$false

$webConfigFolder = Join-Path $PSScriptRoot 'ConfigTests'
$webConfigFile = Join-Path $webConfigFolder 'web.config'

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

Describe "Get-PSWebConfig" {
    Context "Invalid Paths" {
        It "Should not return anything" {
            Get-PSWebConfig -Path 'clearly:\invalid\path\to_fail' -Verbose:$TestVerbose |
            Should BeNullOrEmpty
        }
    }

    Context "Default XML output" {
        It "should return the XML object by default" {
            $defaultConfig = Get-PSWebConfig -Path $webConfigFile -Verbose:$TestVerbose
            $defaultConfig | Should Not BeNullOrEmpty
            $defaultConfig.GetType().Name | Should Be "XmlDocument"
            #$defaultConfig.OuterXml | Set-Content ./default.txt -Enc UTF8

            $xmlConfig = Get-PSWebConfig -Path $webConfigFile -AsXml -Verbose:$TestVerbose
            $xmlConfig | Should Not BeNullOrEmpty
            $xmlConfig.GetType().Name | Should Be "XmlDocument"
            #$xmlConfig.OuterXml | Set-Content ./xml.txt -Enc UTF8

            $defaultConfig.OuterXml | Should Be $xmlConfig.OuterXml
        }

        It "should have PSWebConfig.WebConfig additional type" {
            $config = Get-PSWebConfig -Path $webConfigFile -Verbose:$TestVerbose
            $config | Should Not BeNullOrEmpty
            $config.psobject.TypeNames -contains 'PsWebConfig.WebConfig' | Should Be $true
        }

        It "Should be a valid XML Configuration" {
            $config = Get-PSWebConfig -Path $webConfigFile -Verbose:$TestVerbose
            $config.GetType().Name | Should Be "XmlDocument"
            $config.configuration | Should Not BeNullOrEmpty
            $config.configuration.GetType().Name | Should Be "XmlElement"
        }
    }

    Context "FileName output" {
        It "should match the source filename as a string" {
            $config = Get-PSWebConfig -Path $webConfigFile -AsFileName -Verbose:$TestVerbose
            $config | Should Not BeNullOrEmpty
            $config | Should Be $webConfigFile
            $config.GetType().Name | Should Be 'String'
        }

        It "should find web.config in folders" {
            $config = Get-PSWebConfig -Path $webConfigFolder -AsFileName -Verbose:$TestVerbose
            $config | Should Not BeNullOrEmpty
            $config | Should Be $webConfigFile
        }
    }

    Context "Unencrypted text output" {
        It "should be the same XML string as the source file" {
            $config = Get-PSWebConfig -Path $webConfigFile -AsText -Verbose:$TestVerbose
            $config | Should Not BeNullOrEmpty
            $config.GetType().Name | Should Be 'String'

            $rawConfig = Get-Content -Path $webConfigFile

            #Convert both String to XML to strip unnessary whitespaces
            ([xml]$config).OuterXml  | Should Be ([xml]$rawConfig).OuterXml
        }
    }
}
