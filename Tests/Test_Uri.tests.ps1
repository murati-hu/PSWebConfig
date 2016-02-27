$isVerbose=($VerbosePreference -eq 'Continue')

Describe "Test_Uri helper function" {
    # Function to test
    . (Join-Path $PSScriptRoot '..\Functions\Test_Uri.ps1')

    Context "Testing multiple URIs and StatusCodes" {
        $uriTests = Import-Csv -LiteralPath (Join-Path $PSScriptRoot 'ConfigTests/webrequest-tests.csv') -Delimiter ','

        foreach ($uriTest in $uriTests) {
            $verb = 'fail'
            if ($uriTest.shouldpass -eq 1) { $verb = 'pass'}

            It "'$($uriTest.uri)' should $verb if statuscode matches '$($uriTest.statuscodes)'" {
                $result = $null
                if ($uriTest.statuscodes) {
                    $result = Test_Uri -Uri $uriTest.uri -AllowedStatusCodeRegexp $uriTest.statuscodes -ErrorAction SilentlyContinue
                } else {
                    $result = Test_Uri -Uri $uriTest.uri -ErrorAction SilentlyContinue
                }

                $result | Should Not BeNullOrEmpty
                $result.TestType | Should Be 'UriTest'
                $result.Uri | Should Be $UriTest.uri
                $result.Passed | Should Be ($uriTest.shouldpass -eq 1)
                $result.ComputerName | Should Be ([System.Net.Dns]::GetHostByName($env:COMPUTERNAME).HostName)
                $result.Result | Should Not BeNullOrEmpty
                $result.Status | Should Not BeNullOrEmpty
            }
        }
    }
}
