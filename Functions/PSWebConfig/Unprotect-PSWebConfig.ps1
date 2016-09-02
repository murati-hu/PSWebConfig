<#
.SYNOPSIS
    Decrypts and saves inplace a web.config file
.DESCRIPTION

.PARAMETER InputObject
    Mandatory - Parameter to pass the Application or WebSite from pipeline
.PARAMETER Path
    Mandatory - Parameter to pass the path for the target application
.PARAMETER Recurse
    Optional - Switch to look for multiple web.config files in sub-folders for
    web applications
.PARAMETER Session
    Optional - PSSession to execute configuration file lookup

.EXAMPLE
    Unprotect-PSWebConfig -Path 'c:\intepub\wwwroot\testapp\'
.EXAMPLE
    $server1 = New-PSSession 'server1.local.domain'
    Unprotect-PSWebConfig -Path 'c:\intepub\wwwroot\testapp\' -Session $server1
.EXAMPLE
    Get-WebSite | Unprotect-PSWebConfig
#>

function Unprotect-PSWebConfig {
    [CmdletBinding(DefaultParameterSetName="FromPipeLine")]
    param(
        [Parameter(ParameterSetName="FromPipeLine",Position=0)]
        [Parameter(ValueFromPipeLine=$true)]
        [psobject[]]$InputObject,

        [Parameter(ParameterSetName="FromPath",Position=0,Mandatory=$true)]
        [Alias('physicalPath')]
        [string]$Path,

        [Parameter(ParameterSetName="FromPath")]
        [Parameter(ParameterSetName="FromPipeLine")]
        [Parameter(ParameterSetName="AsXml")]
        [switch]$Recurse,

        [System.Management.Automation.Runspaces.PSSession]$Session
    )
    process {
        Write-Verbose "Executing Unprotect-PSWebConfig"

        if ($Path) {
            Write-Verbose "Processing by Path"
            $InputObject = New-Object -TypeName PsObject -Property @{
                physicalPath = $Path
                Session = $Session
            }
        }

        if ($InputObject) {
            Write-Verbose "Processing by InputObject"
            foreach ($entry in $InputObject) {
                # Setting Remote Session
                $EntrySession = $entry.Session
                if ($Session) {
                    Write-Verbose "Overriding session from -Session Parameter"
                    $EntrySession = $Session
                }
                elseif ($entry | Get-Member -Name RunspaceId) {
                    Write-Verbose "Getting Session from RunspaceId '$($entry.RunspaceId)'"
                    $EntrySession = Get-PSSession -InstanceId $entry.RunspaceId
                }

                Write-Verbose "Getting config files..."
                $configs = $entry | Get-PSWebConfig -AsFileInfo -Recurse:$Recurse -Session:$EntrySession

                foreach ($config in $configs) {
                    $configFile = $config.FullName
                    $backupFile = [string]::Join('.',@($configFile,((Get-Date -Format s) -replace ':','-'),'config'))
                    $decryptedConfig = Get-PSWebConfig -AsText -Path $configFile -Session:$EntrySession

                    Invoke-Command -Session:$EntrySession -ArgumentList $configFile,$backupFile,$decryptedConfig -ScriptBlock
                }
            }
        }
    }
}
