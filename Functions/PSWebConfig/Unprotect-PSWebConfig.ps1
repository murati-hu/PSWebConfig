<#
.SYNOPSIS
    Decrypts and saves inplace a web.config file
.DESCRIPTION
    Takes a Path or a WebAdministration object as an input, creates a
    backup of the original file and overrides the configuration with its
    decrypted version.

    The cmdlet prompts for clarification on the override, unless -Confirm
    is set to false.

.PARAMETER InputObject
    Mandatory - Parameter to pass the Application or WebSite from pipeline
.PARAMETER Path
    Mandatory - Parameter to pass the path for the target application
.PARAMETER Recurse
    Optional - Switch to look for multiple web.config files in sub-folders for
    web applications
.PARAMETER Confirm
    Optional - Boolean to disable override confirmation (default -Confirm:$true)
.PARAMETER Session
    Optional - PSSession to execute the action

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

        [switch]$Recurse,
        [bool]$Confirm=$true,

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

                    $BackupAndOverride = {
                        param(
                            [string]$configFile,
                            [string]$backupFile,
                            [string]$decryptedConfig,
                            [bool]$Confirm
                        )
                        Write-Verbose "Creating backup to '$backupFile'.."
                        Copy-Item -Path $configFile -Destination $backupFile -Force

                        Write-Verbose "Overriding '$configFile' with decrypted content ..."
                        Set-Content -Path $configFile -Value $decryptedConfig -Confirm:$Confirm
                    }

                    Invoke-SessionCommand -Session:$EntrySession -ArgumentList $configFile,$backupFile,$decryptedConfig,$Confirm -ScriptBlock $BackupAndOverride
                }
            }
        }
    }
}
