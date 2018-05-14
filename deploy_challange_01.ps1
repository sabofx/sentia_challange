######################################################
# INSTRUCTIONS:                                      #
#                                                    #
# Make sure to download the latest files from:       #
# https://github.com/sabofx/sentia_challange.git     #
#                                                    #
# Put all downloaded files in the same folder        #
######################################################

write-host "Setting assignment values"
$strResourceGroup = "rgsentia"
$arrResourceTypesAllowed = "Microsoft.Storage","Microsoft.Compute"

write-host "Determine path of JSON files depending on folder from where script is launched"
$ScriptRoot = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition
$TemplateFilepath = $("$ScriptRoot" + "\template.json")
$TemplateParameterFilepath = $("$ScriptRoot" + "\parameters.json")

Connect-AzureRmAccount

write-host "Create Resource Group"
New-AzureRmResourceGroup -Name $strResourceGroup -Location "westeurope"

write-host "Deploy Resource Group based on local JSON files"
New-AzureRmResourceGroupDeployment -ResourceGroupName $strResourceGroup -TemplateFile $TemplateFilepath -TemplateParameterFile $TemplateParameterFilepath

write-host "Create TAGS"
New-AzureRmTag -Name Environment -Value 'Test'
New-AzureRmTag -Name Company -Value 'Sentia'

write-host "Apply TAGS to Resource Group"
Get-AzureRmResourceGroup $strResourceGroup | Set-AzureRmResourceGroup -Tag @{Environment="Test";Company="Sentia"}

write-host "Define policy"
$definition = New-AzureRmPolicyDefinition -Name "pd_allowed-resourcetypes" -DisplayName "Allowed resource types" -description "This policy enables you to specify the resource types that your organization can deploy." -Policy 'https://raw.githubusercontent.com/Azure/azure-policy/master/samples/built-in-policy/allowed-resourcetypes/azurepolicy.rules.json' -Parameter 'https://raw.githubusercontent.com/Azure/azure-policy/master/samples/built-in-policy/allowed-resourcetypes/azurepolicy.parameters.json' -Mode All

write-host "Apply policy"
$strScope = (Get-AzureRmResourceGroup -Name $strResourceGroup).ResourceId
$assignment = New-AzureRMPolicyAssignment -Name "pa_limit_resourcetypes" -Scope $strScope -listOfResourceTypesAllowed $arrResourceTypesAllowed -PolicyDefinition $definition
$assignment

write-host "Done!"