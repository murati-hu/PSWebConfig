## 1.0.0 (Oct 4, 2015)
 - Initial version of `Get-PSWebConfig` and `Get-PSConnectionString`
 - Remote and local decryption of appSettings and connectionStrings WebConfig sections

## 1.1.0 (Feb 19, 2016)
 - Add `Test-PSConnectionString` cmdlet
 - Replace `-ComputerName` with `-PSSession` parameter for more flexible remote execution scenarios
 - Populating ComputerName property for all objects
 - Add PowerShell views for WebConfig, ConnectionString objects
 - Add warning for non-admin users for decrypt attemps

## 1.2.0 (Feb 20, 2016)
- Add views for all `PSWebConfig` object-types

## 1.3.0 (Feb 25, 2016)
 - Automatic decryption of all configuration sections
 - Add `FileInfo` InputObject support
 - Set Path as the firts positinal parameter

## 1.4.0 (Feb 26, 2016)
 - Introduce `Get-PSEndpoint` and `Get-PSAddress` to get URLs from config files
 - Change `FileName` output to `FileInfo`
 - Add `PSScriptAnalyzer` module for Pester tests
 - Fix code suggestions from `PSScriptAnalyzer`
 - Test if expected commands are exported too
