function Read-AppConfig {
    param(
        [String]$Path,
        [bool]$ReadContent,
        [bool]$AsText,
        [bool]$IncludeHeader,
        [bool]$Recurse,
        [string]$Verbose
    )

    function Copy_WebConfig([string]$config) {
        if (-Not (Test-Path $config)) {
            Write-Warning "Could not find '$config'"
            return $null
        }

        # Construct Temp folder
        $tempFolder = [System.IO.Path]::GetTempPath()
        $appGuid = [guid]::NewGuid().Guid
        $tempAppFolder = Join-Path $tempFolder $appGuid
        $tempAppConfig = Join-Path $tempAppFolder 'web.config'

        Write-Verbose "Creating $tempAppFolder"
        mkdir $tempAppFolder -Force | Out-Null

        Write-Verbose "Copying $c to $tempAppFolder"
        Copy-Item -Path $config -Destination $tempAppFolder

        return $tempAppConfig
    }

    function Decypt_WebConfig([string]$folder) {
        $webConfigFile = Join-Path $folder 'web.config'
        if (Test-Path $webConfigFile) {
            $aspnet_regiis = "c:/windows/microsoft.net/framework/v4.0.30319/aspnet_regiis.exe"
            $sections = @('connectionStrings', 'appSettings', 'Cassandra', 'SquareSettings', 'FreshBooksSettings', 'HighriseSettings', 'nhibernate', 'system.web', 'system.web/sessionState')

            $xmlContent = [xml](Get-Content $webConfigFile)
            if (-Not $xmlContent) {
                Write-Warning "'$webConfigFile' is not a valid XML file."
            }

            foreach ($s in $sections) {
                $encryptedSection = ($xmlContent -and ($xmlContent.configuration.$s.EncryptedData -or $s -match '/'))
                if ($encryptedSection) {
                    $cryptArgs = "-pdf $s $folder"
                    Write-Verbose "Decrypting > $aspnet_regiis $cryptArgs"
                    Start-Process -FilePath $aspnet_regiis -ArgumentList $cryptArgs -WindowStyle Hidden -Wait
                } else {
                    Write-Verbose "Skipping decryption of '$s' section "
                }
            }
        }
    }

    if ([String]::IsNullOrEmpty($Path) -or -Not (Test-Path $Path)) { return }

    $VerbosePreference = $Verbose

    Write-Verbose "Looking for config files at '$Path'.."
    $configs = $()
    foreach ($f in @("web.config","*.exe.config")) {
        $found = $null
        $found = Get-ChildItem $Path -Filter $f -Recurse:$Recurse -ErrorAction SilentlyContinue
        if ($found) {
            $configs += @($found)
        }
    }

    if ($ReadContent) {
        foreach ($c in ($configs | Select -Unique)) {
            $content = $null
            Write-Verbose "File '$($c.FullName)'.."
            $isWebConfig = ($c.Name -eq 'web.config')

            if ($isWebConfig) {
                # Create a copy of web.config's and decrypt it
                $tempAppFolder = $null

                Write-Verbose "Cloning $($c.FullName) ..."
                $tempAppConfig = Copy_WebConfig -config $c.FullName
                $tempAppFolder = Split-Path $tempAppConfig -Parent

                if (Test-Path $tempAppConfig) {
                    Decypt_WebConfig -folder $tempAppFolder

                    Write-Verbose "Reading web.config content"
                    $content = Get-Content $tempAppConfig | Out-String
                }

                Write-Verbose "Deleting $tempAppFolder"
                rmdir $tempAppFolder -Force -Recurse
            } else {
                # App.config
                Write-Verbose "Reading app config content"
                $content = Get-Content $c.FullName | Out-String
            }

            if ($AsText) {
                if ($IncludeHeader) {
                    "#### $($c.FullName) ####"
                }
                $content
            }
            else {
                $content = [xml]$content
                $content | Add-Member -NotePropertyName File -NotePropertyValue $c.FullName
                $content
            }
        }
    } else {
        $configs.FullName
    }

    $VerbosePreference = 'SilentlyContinue'
}
