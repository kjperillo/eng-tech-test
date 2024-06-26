#  Implementation details
I went ahead and implemented both the AWS and Azure code to create the Network Configuration, Storage and Serverless Functions

To install, first go to projects/setup and do terraform init / plan / apply to setup the backend (s3 based, change as needed).

Next do terraform init / plan / apply from projects/aws and projects/azure.

For the AWS code there are three modules, aws/lambda, aws/s3 and aws/vpc.
For the Azure code, there are two modules, azure/function and azure/vnet.

I used clockify (free online time tracker) to record my work.  See detailed report pdf in this directory.  I put about 6.5 hours into, 
but it seems like of that was in documenting, refactoring, making the code prettier, etc.

Note, AWS code is fully functional and tested.  
On the Azure side, everything gets created fine, but there is an issue with the Blob upload trigger not firing the python function.  I would need to do some further research here and rework it a bit to get it 100% functional.  However, I don't want to hold up the review process and hopefully there is enough here to inspire confidence.

### Detailed installation instructions
Clone the repo
cd into repo
Assuming you have AWS access and Azure access configured locally

```
cd projects/setup
# review S3 settings in setup.tf, change as desired
terraform init
terraform plan
# Should be 3 to add
terraform apply -auto-approve
```

Now that backend is setup, install AWS
```
cd ../aws
# review backend settings to make sure they match whatever changes you made
terraform init
terraform plan
# should be 16 to add
terraform apply -auto-approve
```
To test, review VPC set up
Upload test_file.txt to identify-tech-test
Wait a couple of minutes
Review Lambda logs

For Azure
```
cd ..\azure
# review backend settings to make sure they match whatever changes you made
terraform init
terraform plan
# should be 21 to add
terraform apply -auto-approve
```
To test, review VNet set up
Upload test_file.txt to techtesttargetsa / tech-test-container
Wait up to 5 minutes.
Review function logs

### -----
### Original Ask
Cloud Engineer Technical Test

Objective:
Design a cloud infrastructure that includes network configuration, storage, and serverless computing using either AWS or Azure. Implement this infrastructure using Terraform and script a serverless function in Python to interact with the cloud storage.

You do not need to actually launch this as part of the test, 

Requirements:
•Cloud Provider Choice:
   - Choose either AWS or Azure for implementing the solution.

•Network Configuration:
   - Create a Virtual Private Cloud (VPC) on AWS or a Virtual Network (VNet) on Azure with the following details:
     - One public subnet
     - One private subnet
     - One NAT gateway

•Storage:
   - Set up an S3 bucket on AWS or a storage container on Azure.

•Serverless Function:
   - Implement a Lambda function on AWS or a Function App on Azure using Python.
   - The function should trigger on an event indicating that a new file has been uploaded to the cloud storage.
   - Read the contents of the newly uploaded file and print them to a log.

•Infrastructure as Code (IaC):
   - Use Terraform to script all the infrastructure components.
   - Ensure your Terraform scripts include appropriate modules, variables, and outputs for reusability and maintainability.

•Documentation and Clean Code:
   - Document your Python script and Terraform configuration for clarity and maintainability.
 

Deliverables:
- Terraform files for setting up the VPC/VNet, subnets, S3/storage container, and Lambda/Function App.
- Python script for the serverless function.
- You do not need to launch this into an actual environment, simply upload the files to a public repository (GitHub, GitLab) or email a zip file.

Evaluation Criteria:
- Correctness of the implementation.
- Adherence to cloud best practices for security and architecture.
- Quality of the Terraform scripts in terms of structure, use of modules, and ease of maintenance.
- Functionality of the Python script and its error handling capabilities.
- Clarity and detail in documentation.
