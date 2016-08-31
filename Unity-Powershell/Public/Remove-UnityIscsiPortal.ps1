Function Remove-UnityIscsiPortal {

  <#
      .SYNOPSIS
      Delete an iSCSI network portal.
      .DESCRIPTION
      Delete an iSCSI network portal.
      You need to have an active session with the array.
      .NOTES
      Written by Erwan Quelin under MIT licence - https://github.com/equelin/Unity-Powershell/blob/master/LICENSE
      .LINK
      https://github.com/equelin/Unity-Powershell
      .PARAMETER Session
      Specify an UnitySession Object.
      .PARAMETER ID
      iSCSI network portal ID or Object.
      .PARAMETER Confirm
      If the value is $true, indicates that the cmdlet asks for confirmation before running. 
      If the value is $false, the cmdlet runs without asking for user confirmation.
      .PARAMETER WhatIf
      Indicate that the cmdlet is run only to display the changes that would be made and actually no objects are modified.
      .EXAMPLE
      Remove-UnityIscsiPortal -ID 'if_6'

      Delete the iSCSI network portal with ID 'if_6'
      .EXAMPLE
      Get-UnityIscsiPortal -ID 'if_6' | Remove-UnityIscsiPortal

      Delete the iSCSI network portal with ID 'if_6'. iSCSI network portal informations are provided by the Get-UnityIscsiPortal through the pipeline.
  #>

  [CmdletBinding(SupportsShouldProcess = $True,ConfirmImpact = 'High')]
  Param (
    [Parameter(Mandatory = $false,HelpMessage = 'EMC Unity Session')]
    $session = ($global:DefaultUnitySession | where-object {$_.IsConnected -eq $true}),
    [Parameter(Mandatory = $true,Position = 0,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'iSCSI network portal ID or Object')]
    $ID
  )

  Begin {
    Write-Verbose "Executing function: $($MyInvocation.MyCommand)"
  }

  Process {

    Foreach ($sess in $session) {

      Write-Verbose "Processing Session: $($sess.Server) with SessionId: $($sess.SessionId)"

      If ($Sess.TestConnection()) {

        Foreach ($i in $ID) {

          # Determine input and convert to UnityIscsiPortal object
          Write-Verbose "Input object type is $($ID.GetType().Name)"
          Switch ($ID.GetType().Name)
          {
            "String" {
              $IscsiPortal = get-UnityIscsiPortal -Session $Sess -ID $ID
              $IscsiPortalID = $IscsiPortal.id
            }
            "UnityIscsiPortal" {
              $IscsiPortalID = $ID.id
            }
          }

          If ($IscsiPortalID) {
            #Building the URI
            $URI = 'https://'+$sess.Server+'/api/instances/iscsiPortal/'+$IscsiPortalID
            Write-Verbose "URI: $URI"

            if ($pscmdlet.ShouldProcess($IscsiPortalID,"Delete iSCSI network portal")) {
              #Sending the request
              $request = Send-UnityRequest -uri $URI -Session $Sess -Method 'DELETE'
            }

            If ($request.StatusCode -eq '204') {

              Write-Verbose "iSCSI network portal with ID: $id has been deleted"

            }
          } else {
            Write-Information -MessageData "iSCSI network portal $IscsiPortalID does not exist on the array $($sess.Name)"
          }
        }
      } else {
        Write-Information -MessageData "You are no longer connected to EMC Unity array: $($Sess.Server)"
      }
    }
  }

  End {}
}
