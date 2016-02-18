$isVerbose=($VerbosePreference -eq 'Continue')

Describe "Test_ConnectionString helper" {
    # Function to test
    . (Join-Path $PSScriptRoot '..\Functions\Test_ConnectionString.ps1')
    $webConfigFolder = Join-Path $PSScriptRoot 'ConfigTests'
    $webConfigFile = Join-Path $webConfigFolder 'web.config'
    context "Failing SqlConnectionString" {
        $failingConnectionString='Server=localhost;Database=$DbThatShouldNotEVerExist;User Id=uname;Password=xxx;'

        It "Should have failed test result properties" {
            $result = Test_ConnectionString -ConnectionString $failingConnectionString -Verbose:$isVerbose -EA 0
            $result | Should Not BeNullOrEmpty
            $result.TestType | Should Be 'SqlTest'
            $result.ComputerName | Should Be ([System.Net.Dns]::GetHostByName($env:COMPUTERNAME).HostName)
            $result.RawConnectionString | Should Be $failingConnectionString
            $result.ConnectionString | Should Be $result.RawConnectionString
            $result.Passed | Should Be $false
            $result.SqlQuery | Should Not BeNullOrEmpty
            $result.Result | Should Not BeNullOrEmpty
        }

        It "Should replace ConnectionString with ReplaceRules" {
            $replacedFailingConnectionString=$failingConnectionString -replace 'xxx','r4nd0mP4$$word'
            $replaceRule = @{'xxx'='r4nd0mP4$$word'}
            $result = Test_ConnectionString -ConnectionString $failingConnectionString -ReplaceRules $replaceRule -Verbose:$isVerbose -EA 0

            $result.RawConnectionString | Should Be $failingConnectionString
            $result.ConnectionString | Should Be $replacedFailingConnectionString
        }
    }
}
