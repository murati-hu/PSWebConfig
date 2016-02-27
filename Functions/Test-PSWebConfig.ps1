<#
.SYNOPSIS
    Tests all URI and ConnectionStrings from web or application configuration.

.DESCRIPTION
    The cmdlet fetches all ConnectionString and URIs for a configuration file
    and executes a test against them on a local or remote machine.

.PARAMETER InputObject
    Mandatory - Parameter to pass a PSWebConfig object

.PARAMETER Session
    Optional - PSSession to execute configuration test

.EXAMPLE
    Get-PSWebConfig -Path 'c:\intepub\wwwroot\testapp\' | Test-PSWebConfig

.EXAMPLE
    Get-WebSite | Get-PSWebConfig -Recurse | Test-PSWebConfig
#>
function Test-PSWebConfig {
    [CmdletBinding(DefaultParameterSetName="FromPipeLine")]
    param(
        [Parameter(ParameterSetName="FromPipeLine",Position=0)]
        [Parameter(ValueFromPipeLine=$true)]
        [psobject[]]$ConfigXml,

        [System.Management.Automation.Runspaces.PSSession]$Session
    )
    process {
       Get-PSEndpoint -ConfigXml $ConfigXml |
       Test-PSUri -Session $Session

       Get-PSConnectionString -ConfigXml $ConfigXml |
       Test-PSConnectionString -Session $Session
    }
}
