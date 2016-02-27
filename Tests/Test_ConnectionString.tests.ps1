$isVerbose=($VerbosePreference -eq 'Continue')

Describe "Test_ConnectionString helper function" {
    # Function to test
    . (Join-Path $PSScriptRoot '..\Functions\Test_ConnectionString.ps1')

    @{
        Invalid='IvServer=localhost;IvDatabase=##DB##'
        NonExisting='Server=localhost;Database=##DB##ThatShouldNotExist;User Id=uname;Password=xxx;'
    }.GetEnumerator() |
    ForEach-Object {
        context "$($_.Key) SqlConnectionString" {
            $failingConnectionString=$_.Value

            It "Should have failed test result properties" {
                $result = Test_ConnectionString -ConnectionString $failingConnectionString -Verbose:$isVerbose -EA 0
                $result | Should Not BeNullOrEmpty
                $result.TestType | Should Be 'SqlTest'
                $result.ComputerName | Should Be ([System.Net.Dns]::GetHostByName($env:COMPUTERNAME).HostName)
                $result.RawConnectionString | Should Be $failingConnectionString
                $result.ConnectionString | Should Be $result.RawConnectionString
                $result.Passed | Should Be $false
                $result.Result | Should Not BeNullOrEmpty
                $result.Status | Should Match 'Failed'
            }

            It "Should replace ConnectionString with ReplaceRules" {
                $replacedFailingConnectionString=$failingConnectionString -replace '##DB##','DB_SUBST'
                $replaceRule = @{'##DB##'='DB_SUBST'}
                $result = Test_ConnectionString -ConnectionString $failingConnectionString -ReplaceRules $replaceRule -Verbose:$isVerbose -EA 0

                $result.RawConnectionString | Should Be $failingConnectionString
                $result.ConnectionString | Should Be $replacedFailingConnectionString
            }
        }
    }
}
