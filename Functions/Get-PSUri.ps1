<#
.SYNOPSIS
    Returns any URIs from application or web configuration.
.DESCRIPTION
    It accepts configuration XMLs and returns any URIs found in appSettings and
    from client endpoint addresses.

    The cmdlet filters PSAppSettings for URIs and also returns PSEndpoint results.

.PARAMETER ConfigXml
    Mandatory - Pipeline input for Configuration XML

.EXAMPLE
    Get-PSWebConfig -Path 'C:\inetpub\wwwroot\myapp' | Get-PSUri
.EXAMPLE
    Get-WebSite mysite | Get-PSWebConfig | Get-PSUri
#>
function Get-PSUri {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true,ValueFromPipeLine=$true)]
        [psobject[]]$ConfigXml
    )

    process {
        # Return all service endpoint addresses
        Get-PSEndpoint -ConfigXml $configXml

        # Return any URL from appSettings as an Address
        Get-PSAppSetting -ConfigXml $configXml |
            Where-Object value -imatch '^http[s]*:' |
            Add-Member -MemberType AliasProperty -Name name -Value key -Force -PassThru |
            Add-Member -MemberType AliasProperty -Name address -Value value -Force -PassThru |
            Add-Member -MemberType AliasProperty -Name Uri -Value value -Force -PassThru |
            Set_Type -TypeName 'PSWebConfig.Uri'
    }
}
