 function Move-Status {
   Start-Sleep 5
   $moveRequests = Get-365MoveRequest | Get-365MoveRequestStatistics | Select Identity, Status, SuspendWhenReadyToComplete, WorkloadType, DisplayName, TargetDatabase, PercentComplete, BadItemsEncountered, TotalMailboxSize, TotalMailboxItemCount, TotalInProgressDuration,TotalSuspendedDuration,TotalQueuedDuration | where ({([String]$_.WorkloadType -eq "Onboarding") -and ([String]$_.SuspendWhenReadyToComplete -eq "False")})
   While (($moveRequests | ? {$_.Status -match"InProgress"}) -or ($moveRequests | ? {$_.Status -eq"CompletionInProgress"}) -or ($moveRequests | ? {$_.Status -eq"Queued"}))
   {
      foreach($moveRequest in $moveRequests)
      {
         #$mailboxIdentity = $moveRequest.Identity;
         $displayName = $moveRequest.DisplayName;
         [String]$status = $moveRequest.Status;
         $percentComplete = $moveRequest.PercentComplete;
         $targetDatabase = $moveRequest.TargetDatabase;
         $badItemsEncountered = $moveRequest.BadItemsEncountered;
         $totalMailboxSize = $moveRequest.TotalMailboxSize;
         $duration = $moveRequest.TotalInProgressDuration;
         $itemCount = $moveRequest.TotalMailboxItemCount;
         $timeSuspended = $moveRequest.TotalSuspendedDuration;
         $timeQueued = $moveRequest.TotalQueuedDuration       
         if (($status -eq "InProgress") -or ($status -eq "CompletionInProgress") -or ($status -eq "Completed")) {
            #Write-Host "$mailboxAlias   $percentComplete%    duration: $duration       Target: $targetDatabase    BadItems: $badItemsEncountered";
            Write-Host "$displayName     $percentComplete%    duration: $duration       Target: $targetDatabase    BadItems: $badItemsEncountered";                
         } elseif ($status -eq "Queued") {
            Write-Host "$displayName - Queued for $timeQueued";                   
         }
      }
      Write-Host "------Waiting for move to complete, will recheck in 5 seconds------"
      Start-Sleep 5;
      $moveRequests = Get-365MoveRequest | Get-365MoveRequestStatistics | Select Identity, Status, SuspendWhenReadyToComplete, WorkloadType, DisplayName, TargetDatabase, PercentComplete, BadItemsEncountered, TotalMailboxSize, TotalMailboxItemCount, TotalInProgressDuration,TotalSuspendedDuration,TotalQueuedDuration | where ({([String]$_.WorkloadType -eq "Onboarding") -and ([String]$_.SuspendWhenReadyToComplete -eq "False")})
   }
}