# lab-01 - provision supporting resources

## Estimated completion time - 15 min

We start by provisioning supporting resources such as Log Analytics, Application Insights, API Management, Container Registry and Public IP Prefix. Because supporting resources and AKS resources use different life cycle, they will be deployed to separate Resource Groups. Since we use API Management and it requires Private Virtual Network, we will provision and configure Vnet as well.

Note, to simplify our setup, I will skip Network Security Groups configuration in this workshop and we will cover it in more details as part of dedicated security workshop. 

![model](images/base-rg-with-apim.png)

## Goals

* Provision `Base` resource group
* Provision Private Virtual Network for APIM Management
* Provision Log Analytics workspace
* Provision Application Insight
* Provision Public IP Prefix

## Task #1 - provision supporting resources

We will use the following [naming conventions](../../naming-conventions.md)

Note, because Azure Log Analytics, Azure Container Registry, Azure KeyVault and APIM instance name are global resource and are part of global DNS, they have to be uniquely named. I suggest we prefix them by using your short name.

If you want to learn and provision resources yourself, follow the set of commands described in this task. If you don't want to copy-paste all commands, feel free to use the script, located at `02-aks-advanced-configuration\scripts\01-provision-base-resources.sh` (which contains all below commands). 

```bash
WS_PREFIX='iac-ws2'
YOUR_NAME='<USE YOUR NAME>'                 # I am using "evg"
BASE_RG="$WS_PREFIX-rg"                     # iac-ws2-rg
VNET_NAME=$WS_PREFIX-vnet                   # iac-ws2-vnet
LA_NAME="$WS_PREFIX-$YOUR_NAME-la"          # iac-ws2-evg-la
APPINSIGHTS_NAME="$WS_PREFIX-appinsights"   # iac-ws2-appinsights
PREFIX_NAME="$WS_PREFIX-pip-prefix"         # iac-ws2-pip-prefix
ACR_NAME="iacws2${YOUR_NAME}acr"            # iacws2evgacr

# Create base resource group
az group create -g $BASE_RG -l westeurope

# Create APIM VNet with AGW subnet
az network vnet create -g $BASE_RG -n $VNET_NAME --address-prefix 10.10.0.0/16 --subnet-name apim-net --subnet-prefix 10.10.0.0/27

# Create Public IP Prefix
az network public-ip prefix create --length 28 --location westeurope -n $PREFIX_NAME -g $BASE_RG

# Create AppInsight app
az monitor app-insights component create --app $APPINSIGHTS_NAME -l westeurope --kind web -g $BASE_RG --application-type web --retention-time 120

# Create Log Analytics
az monitor log-analytics workspace create -g $BASE_RG -n $LA_NAME

# Create Azure Container Registry
az acr create -g $BASE_RG -n $ACR_NAME --sku Basic
```

If you decided to use `01-provision-base-resources.sh` script, you need to provide an input parameter - your user name that will be used to make unique resource names (Log Analytic Workspace, Azure Container Registry etc...). Please inspect the script to understand what it actually does.

```bash
# Go to the scripts folder
cd 02-aks-advanced-configuration\scripts\

# Use your user name as an input parameter
./01-provision-base-resources.sh <YOUR-USER-NAME>
```

## Task #2 - provision API Management

We will use API Management (further APIM) to expose services running in AKS cluster. Since AKS cluster is deployed into private virtual network and will not be publicly accessible, we need to deploy APIM into private virtual network as well. APIM supports 2 ways to deploy to private Vnet:

* internal - the API Management gateway is accessible only from within the virtual network via an internal load balancer. The gateway can access resources within the virtual network
* external - the API Management gateway is accessible from the public internet via an external load balancer. The gateway can access resources within the virtual network

We will use `external` mode.

![model](images/base-rg-with-apim.png)

It takes more than 50 mins to provision APIM with VNet integration, therefore we do it as early as possible, so it will be ready when we start working with labs related to APIM. 

We will use `Developer` tier APIM, which provides all functionality included into `Premium`, but there is no SLA and estimated maximum throughput is `500 requests/sec`. It's a perfect choice for testing, workshops and POCs.

The cost of using `Developer` tier is `kr0.59/hour`.

We will use [ARM templates](https://docs.microsoft.com/en-us/azure/azure-resource-manager/templates/overview?WT.mc_id=AZ-MVP-5003837) to provision APIM. 

```bash
# Got to ARM folder
cd 02-aks-advanced-configuration\labs\lab-01\ARM\APIM\

# Validate APIM ARM template. Run this command from lab-02 folder
az deployment group validate -g iac-ws2-rg --template-file template.json --parameters publisherEmail=<YOUR-EMAIL> userName=<YOUR-USERNAME>

# If no errors, deploy APIM ARM template. APIM deployment takes between 30 and 50 mins
az deployment group create -g iac-ws2-rg --template-file template.json --parameters publisherEmail=<YOUR-EMAIL> userName=<YOUR-USERNAME>
```

APIM instance name has to be unique, therefore I suggest to use your short username to prefix it. Use `userName` property to set your name. Based on our [naming conventions](../../naming-conventions.md), APIM instance will be called `iac-ws2-{YOUR-NAME}-apim`.

Use your email for `publisherEmail` property and your short username for `userName` property. It takes almost an hour to provision APIM and we are not going to wait until it finished. Instead, when instance is provisioned and ready to be used, APIM will notify you with by email sent to your email specified at `publisherEmail` parameter. 

Check that deployment has started. You can do it by navigating to the `Deployments` tab of the `iac-ws2-rg` resource group.

![Deployments](images/rg-deployments.png)

If you go to `Overview` tab of the `iac-ws2-rg` resource group, you should see APIM instance was already created, but not yet ready to be used.

![Deployments](images/apim.png)

## Useful links

* [Azure Container Registry documentation](https://docs.microsoft.com/en-us/azure/container-registry/?WT.mc_id=AZ-MVP-5003837)
* [Overview of Log Analytics in Azure Monitor](https://docs.microsoft.com/en-us/azure/azure-monitor/logs/log-analytics-overview?WT.mc_id=AZ-MVP-5003837)
* [What is Application Insights?](https://docs.microsoft.com/en-us/azure/azure-monitor/app/app-insights-overview?WT.mc_id=AZ-MVP-5003837)
* [Public IP address prefix](https://docs.microsoft.com/en-us/azure/virtual-network/public-ip-address-prefix?WT.mc_id=AZ-MVP-5003837)
* [How to use Azure API Management with virtual networks](https://docs.microsoft.com/en-us/azure/api-management/api-management-using-with-vnet?WT.mc_id=AZ-MVP-5003837)
* [API Management pricing](https://azure.microsoft.com/en-us/pricing/details/api-management/?WT.mc_id=AZ-MVP-5003837)
* [What are ARM templates?](https://docs.microsoft.com/en-us/azure/azure-resource-manager/templates/overview?WT.mc_id=AZ-MVP-5003837)

As I said, it takes almost an hour to provision APIM, so we will come back to it hen it's provisioned.

## Next: provision AKS cluster

[Go to lab-02](../lab-02/readme.md)

## Feedback

* Visit the [Github Issue](https://github.com/evgenyb/aks-workshops/issues/15) to comment on this lab. 