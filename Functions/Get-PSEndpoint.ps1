<#
.SYNOPSIS
    Returns endpoint addresses from application or web configuration
.DESCRIPTION
    It accepts configuration XMLs and returns \client endpoint addresses from
    system.serviceModel section.

.PARAMETER ConfigXml
    Mandatory - Pipeline input for Configuration XML

.EXAMPLE
    Get-PSWebConfig -Path 'C:\inetpub\wwwroot\myapp' | Get-PSEndpoint
.EXAMPLE
    Get-WebSite mysite | Get-PSWebConfig | Get-PSEndpoint
#>
function Get-PSEndpoint {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true,ValueFromPipeLine=$true)]
        [psobject[]]$ConfigXml
    )

    process {
        foreach ($config in $ConfigXml) {
            if ($config | Get-Member -Name configuration) {
                foreach ($endpoint in $config.configuration.'system.serviceModel'.client.endpoint) {
                    $endpoint |
                    Add-Member -NotePropertyName Session -NotePropertyValue $config.Session -Force -PassThru |
                    Add-Member -NotePropertyName ComputerName -NotePropertyValue $config.ComputerName -Force -PassThru |
                    Add-Member -NotePropertyName File -NotePropertyValue $config.File -Force -PassThru |
                    Add-Member -NotePropertyName SectionPath -NotePropertyValue 'system.serviceModel/client/endpoint' -Force -PassThru |
                    Set_Type -TypeName 'PSWebConfig.Address'
                }
            }
        }
    }
}
