---
description: This template sets up Azure AI Studio with public access disabled. It also demonstrates how-to create compute resources in a private network.
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: aistudio-basics
languages:
- bicep
- json
---
# Azure AI Studio Private Endpoints Setup

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fctava-msft%2Faistudio-private%2Fmain%2Fazuredeploy.json)

This template sets up Azure AI Studio with public access disabled. It also demonstrates how-to create compute resources in a private network.

Azure AI Studio is built on Azure Machine Learning as the primary resource provider and takes a dependency on the Cognitive Services (Azure AI Services) resource provider to surface model-as-a-service endpoints for Azure Speech, Azure Content Safety, and Azure OpenAI service.

An 'Azure AI hub' is a special kind of 'Azure Machine Learning workspace', that is kind = "hub".

## Resources

The following table describes the resources created in the deployment:

| Provider and type | Description |
| - | - |
| `Microsoft.Compute` | `An Azure VM Compute` |
| `Microsoft.CognitiveServices` | `An Azure AI Services as the model-as-a-service endpoint provider` |
| `Microsoft.MachineLearningServices` | `An Azure AI Hub` |


## Learn more

If you are new to Azure AI studio, see:

- [Azure AI studio](https://aka.ms/aistudio/docs)