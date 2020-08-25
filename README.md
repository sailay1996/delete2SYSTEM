# Delete2SYSTEM
Weaponizing for Arbitrary Files/Directories Delete bugs to Get NT AUTHORITY\SYSTEM

#### Short Description:
I just combined @jonasLyk's technique https://secret.club/2020/04/23/directory-deletion-shell.html and one of technique from this article 
https://0x00sec.org/t/windows-defender-av-zero-day-vulnerability/22258 which using windows media player (service and folder).


##### Read Me:
In order to work this technique, you must to delete the 2 folders which are `C:\ProgramData\Microsoft\Windows\WER\*` and `C:\Program Files (x86)\Windows Media Player` with Arbitrary Files/Directories Delete bugs such as **CVE-2020-1170, CVE-2020-1571, etc ...**

##### Note:
`NtApiDotNet.dll` from James Forshaw.

![test1](https://github.com/sailay1996/delete2SYSTEM/blob/master/wmp_del2sys.jpg)

*Thanks to: [@jonasLyk](https://twitter.com/jonasLyk) and other who research awesome things*

###### Code Browsed from:
https://github.com/sailay1996/RpcSsImpersonator
