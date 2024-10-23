# Azure Application Gateway with App Service PE backend Lab

This Terraform lab environment will deploy an Application Gateway with App Service PE backend Lab. This lab uses GitHub Codespaces which allows you to deploy a containerized dev environment with all dependencies included. Follow the steps below to deploy and manage the lab environment.

## Prerequisites
- GitHub account

## Steps to Deploy the Lab

1. **Create a Codespace from the GitHub Repository**

   - Navigate to the GitHub repository for this lab.
   - Click on the `Code` button.
   - Select the `Codespaces` tab.
   - Click on `Create codespace on main` (or the appropriate branch).

2. **Login to Azure**

   Open a terminal in the Codespace and run the following command to login to your Azure account:

   ```sh
   az login
   ```

   If you have issues signing in, try using:
   ```sh
   az login --use-device-code
   ```

4. **Update the answers.json File**

    Update the answers.json file with your environment values. Make sure to use a unique name for the app service. The file should look like this:

    ```json
    {
      "subscriptionId": "your-subscription-id",
      "location": "your-location",
      "resourceGroupName": "your-resource-group-name"
      "app_service_name": "your unique app service name"
    }
5. **Run the Deploy Script**

    Run the deploy.ps1 script to deploy the lab environment:

    ```
    ./deploy.ps1
## Clean Up the Lab
   
   When you're ready to clean up the lab environment, run the destroy.ps1 script:
   
   ```
   ./destroy.ps1
   ```

**Notes**

Ensure you have the necessary permissions to create and manage resources in your Azure subscription.
Review the Terraform configurations and scripts to understand the resources being deployed and managed. I suggest using useast2 for resource availability.

Happy deploying!
