function Test_Uri  {
    [CmdletBinding()]
    param(
        [string]$Uri,
        [bool]$DisableSSLValidation=$false,
        [string]$AllowedStatusCodeRegexp,
        [Int32]$TimeOutSeconds,
        [hashtable]$ReplaceRules
    )

    $result = New-Object PsObject -Property @{
        ComputerName = [System.Net.Dns]::GetHostByName($env:COMPUTERNAME).HostName
        TestType='UriTest'
        Test=$Uri
        Passed = $false
        Result = $null
        Status = $null

        Uri=$Uri
        ReplaceRules = $ReplaceRules
        AllowedStatusRegexp = $AllowedStatusCodeRegexp
        DisableSSLValidation = $DisableSSLValidation
        TimeOutSeconds = $TimeOutSeconds
    }

    if ($DisableSSLValidation) {
        Write-Verbose "Disabling SSL Validation for Invoke-WebRequest"
        try {
            Add-Type @"
                using System.Net;
                using System.Security.Cryptography.X509Certificates;
                public class TrustAllCertsPolicy : ICertificatePolicy {
                    public bool CheckValidationResult(
                        ServicePoint srvPoint, X509Certificate certificate,
                        WebRequest request, int certificateProblem) {
                        return true;
                    }
                }
"@
            [System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy
        } catch {
            Write-Error "Disabling SSL Validation failed."
            Write-Error $_
        }
    }

    try {
        # Transform Uris
        if ($ReplaceRules) {
            $ReplaceRules.GetEnumerator() | ForEach-Object {
                $result.Uri = $result.Uri -replace $_.Key,$_.Value
            }
        }

        $result.Result = Invoke-WebRequest -UseBasicParsing -uri $result.Uri -TimeoutSec $result.TimeOutSeconds -ErrorAction Stop

        # Evaluate Response
        if ($result.Result) {
            $result.Status = $result.Result.StatusCode
            $result.Passed = ($result.Result.StatusCode -match $AllowedStatusCodeRegexp)
        }
    } catch {
        $result.Passed = $false
        $result.Status = $_
        $result.Result = $_
        Write-Error $_
    }
    $result
}
