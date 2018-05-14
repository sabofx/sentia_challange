$strResourceGroup = "rgsentia"

Connect-AzureRmAccount

# Unassign policy from resource group
$RG = Get-AzureRmResourceGroup -Name $strResourceGroup
Remove-AzureRmPolicyAssignment -name "pa_limit_resourcetypes" -scope $RG.resourceid

# Remove policy
$PolicyDefinition = Get-AzureRmPolicyDefinition -Name "pd_allowed-resourcetypes" 
Remove-AzureRmPolicyDefinition -Id $PolicyDefinition.ResourceId -Force

# Remove resource group
Remove-AzureRmResourceGroup $strResourceGroup -force