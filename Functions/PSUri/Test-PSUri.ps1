<#
.SYNOPSIS
    Tests any HTTP/HTTPS URIs from a remote or local machine.

.DESCRIPTION
    The cmdlet takes a URI as an input object or as a direct
    parameter then it tries to connect to it with Invoke-WebRequest with
    -UseBasicParsing switch and returns the result as a test object.

    You can specify a regular-expression for accepting various HTTP status
    codes with -AllowedStatusCodeRegexp parameter.

    Use -DisableSSLValidation switch to allow any HTTPs certificactes accepted
    for the tests.

    If a Session Property is passed via InputObject or directly with -Session
    parameter, the URI test will be executed against that.

    If -ReplaceRules hashtable is specified it will replace hash-keys with it's
    values in the URI to be tested. This could be useful, when you need to
    override the test Uri with dynamic values.

.PARAMETER InputObject
    Mandatory - Pipeline input of PSUri

.PARAMETER Uri
    Mandatory - Parameter to pass a URI as a string

.PARAMETER AllowedStatusCodeRegexp
    Optional - Regxep string to set which HTTP Response Code should be accepted.

.PARAMETER TimeOutSeconds
    Optional - TimeOut Seconds to be used for Invoke-WebRequest

.PARAMETER DisableSSLValidation
    Optional - Switch to accept any SSL certificate for HTTPS URI tests.

.PARAMETER ReplaceRules
    Optional - Hashtable that replaces hash-keys with it's values in the
    URI to be tested.

.PARAMETER Session
    Optional - PSSession to execute the test-against it.

.EXAMPLE
    Test-PSUri -Uri 'http://murati.hu'
.EXAMPLE
    Get-WebSite mysite | Get-PSWebConfig | Get-PSUri | Test-PSUri
#>
function Test-PSUri {
    [CmdletBinding(DefaultParameterSetName='ByInputObject')]
    param(
        [Parameter(ParameterSetName="ByInputObject",ValueFromPipeLine=$true)]
        [psobject[]]$InputObject,

        [Parameter(ParameterSetName="ByUri",ValueFromPipeLine=$true)]
        [Parameter(Position=0)]
        [Alias('Address','Url')]
        [string[]]$Uri,

        [string]$AllowedStatusCodeRegexp = '^20[0-9]|^401|^403|^50[0-9]',

        [ValidateRange(0,3600)]
        [Int32]$TimeOutSeconds=5,

        [switch]$DisableSSLValidation,

        [hashtable]$ReplaceRules,

        [System.Management.Automation.Runspaces.PSSession[]]$Session
    )

    process {
        Write-Verbose "Executing Test-PSUri"

        if ($Uri) {
            $InputObject = $Uri | Foreach-Object {
                New-Object -TypeName PsObject -Property @{
                    Uri = $_
                    Session = $Session
                }
            }
        }

        foreach ($entry in $InputObject) {
            if ($entry | Get-Member -Name Uri) {

                $EntrySession = $entry.Session
                if ($Session) { $EntrySession = $Session }

                $argumentList = $entry.Uri,$DisableSSLValidation,$AllowedStatusCodeRegexp,$TimeOutSeconds,$ReplaceRules

                if ($EntrySession) {
                    Invoke-Command `
                        -Session $EntrySession `
                        -ArgumentList $argumentList `
                        -ScriptBlock $Function:Test_Uri |
                    Add-Member -NotePropertyName Session -NotePropertyValue $EntrySession -Force -PassThru |
                    Set_Type -TypeName 'PSWebConfig.TestResult'
                } else {
                    Invoke-Command `
                        -ArgumentList $argumentList `
                        -ScriptBlock $Function:Test_Uri |
                    Set_Type -TypeName 'PSWebConfig.TestResult'
                }
            } else {
                Write-Verbose "InputObject doesn't contain Uri property"
            }
        }
    }
}
