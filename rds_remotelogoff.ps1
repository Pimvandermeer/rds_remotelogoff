$rdshost = "your remote desktop"

$RDCB = "broker"

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


#script 


Invoke-Command -ScriptBlock $disablelogin


Wait-Event -Timeout 45  #time when you wanna starts users to log-off

Invoke-Command -Scriptblock $message 


Wait-Event -Timeout 25   #time to log-off 
Invoke-Command -Scriptblock $logoff



Wait-Event -Timeout 20  #reboot

Invoke-Command -Scriptblock $reboot
