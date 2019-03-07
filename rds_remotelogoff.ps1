$rdshost = "NLDCVTRDS002.vergeerholland.lan"

$RDCB = "NLDCVTRDS003.vergeerholland.lan"

$id = Get-RDUserSession -ConnectionBroker $RDCB | select-object -expandproperty UnifiedSessionID

$disablelogin = {
    Set-RDSessionHost -SessionHost $rdshost -NewConnectionAllowed NotUntilReboot -ConnectionBroker $RDCB 
}

$message = {
    forEach($userID in $id) {
    Send-RDUserMessage -HostServer $rdshost -UnifiedSessionID $userID -MessageTitle "Serveronderhoud" -MessageBody "We gaan deze server herstarten over 5 minuten, graag uitloggen."
    }
 }

 $logoff = {
     forEach($userID in $id) {
    Invoke-RDUserLogoff -HostServer $rdshost -UnifiedSessionID $userID -Force
    }
 }


 $reboot = {
Restart-Computer -ComputerName $rdshost -Force
}


#!<--Script wat alles kapot maakt-->


Invoke-Command -ScriptBlock $disablelogin


Wait-Event -Timeout 45  #tijd wanneer 1e bericht getoond wordt

Invoke-Command -Scriptblock $message 


Wait-Event -Timeout 25   #tijd wanneer die daadwerkelijk iedereen moet 

Invoke-Command -Scriptblock $logoff



Wait-Event -Timeout 20

Invoke-Command -Scriptblock $reboot
