Connect-AzureRmAccount

New-AzureRmResourceGroup -Name rgsentia -Location "westeurope"
New-AzureRmResourceGroupDeployment -ResourceGroupName rgsentia -TemplateFile azuredeploy.json

New-AzureRmTag -Name Environment -Value 'Test'
New-AzureRmTag -Name Company -Value 'Sentia'
Get-AzureRmResourceGroup rgsentia | Set-AzureRmResourceGroup -Tag @{Environment="Test";Company="Sentia"}

$definition = New-AzureRmPolicyDefinition -Name "pd_allowed-resourcetypes" -DisplayName "Allowed resource types" -description "This policy enables you to specify the resource types that your organization can deploy." -Policy 'https://raw.githubusercontent.com/Azure/azure-policy/master/samples/built-in-policy/allowed-resourcetypes/azurepolicy.rules.json' -Parameter 'https://raw.githubusercontent.com/Azure/azure-policy/master/samples/built-in-policy/allowed-resourcetypes/azurepolicy.parameters.json' -Mode All
# $definition


$RG = Get-AzureRmResourceGroup -Name “rgsentia”
$strScope = “/subscriptions/08533c31-8f8a-488e-9d95-e5f978a8f22b/resourceGroups/$($RG.ResourceGroupName)”

$arrResourceTypesAllowed = "Microsoft.Storage","Microsoft.Compute"

$assignment = New-AzureRMPolicyAssignment -Name "pa_limit_resourcetypes" -Scope $strScope -listOfResourceTypesAllowed $arrResourceTypesAllowed -PolicyDefinition $definition
$assignment

