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
- Introduce `Get-PSEndpoint` and `Get-PSUri` to get URIs from config files
- Change `FileName` output to `FileInfo`
- Add `PSScriptAnalyzer` module for Pester tests
- Fix code suggestions from `PSScriptAnalyzer`
- Test if expected commands are exported too

## 1.5.0 (Feb 27, 2016)
- Add `Test-PSUri` to test HTTP/HTTPS URIs
- Add `Test-PSWebConfig` to fully test all URIs and Connectionstrings from complete configurations
- Rename `PSAddress` to `PSUri`
- Add `ReplaceRules` to Connectionstring test results
- Add `PSWebConfig.TestResult` view for all tests

## 1.5.1 (Feb 28, 2016)
- Regenerate module manifest for PSGallery

## 1.5.2 (Feb 28, 2016)
- Refactor Pester tests and Fixtures
- Reorganize functions into subfolders
