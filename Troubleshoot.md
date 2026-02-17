[Error Log: Subscription Quota / VM Size Restriction]
Issue:
When running terraform apply, the process fails with a 400 Bad Request or BadRequest error stating that a specific VM size (e.g., Standard_B2s or Standard_DS2_v2) is not allowed in the subscription/location.

Error Message Example:

The VM size of Standard_B2s is not allowed in your subscription in location 'centralus'. The available VM sizes are 'standard_b2s_v2, standard_d2pds_v5...'

Root Cause:
Azure Free Trial and certain corporate subscriptions have a "Regional Quota" of zero for many older or highly utilized VM families. This is a provider-side restriction to manage capacity.

Resolution:

Analyze the Log: Read the message field in the error response. Azure explicitly lists the "Available VM sizes" for your specific subscription in that region.

Pivot SKU: Update the vm_size parameter in the default_node_pool block of the Terraform configuration to match one of the available sizes.

Note: The _v2 (like Standard_B2s_v2) or _v5 series are often more available for trial accounts than the base models.

Regional Shift: If the available list is too small, shift the location in the Resource Group to a higher-capacity region like westus2 or eastus2.

[Error Log: Kubectl Not Recognized]
Issue:
kubectl : The term 'kubectl' is not recognized...

Resolution:

Install the CLI via Azure: az aks install-cli.

Crucial Step: Close all terminal windows and reopen a new session to refresh the Environment PATH variables.

#################################################################################################################################
#
Troubleshooting & Lab Log

🚨 Error: cat: /data/db/hello.txt: No such file or directory (Persistence Test)
Scenario: File disappeared after deleting pods even though PVC was bound.

Cause: Multiple Replicas (3). The echo command hit Pod A, but after deletion, the cat command hit Pod B (which didn't have the disk mounted or was in a different zone).

Fix: Scaled deployment to replicas: 1 to ensure the disk was attached to the specific pod being tested.

🚨 Issue: echo command printing to terminal instead of file
Scenario: Running kubectl exec -- sh -c 'echo "Text" > file.txt' in PowerShell.

Cause: PowerShell quoting conflicts. It was truncating the string at the first space.

Fix: Switched to double quotes for the outer wrapper: kubectl exec ... -- sh -c "echo 'Text' > file.txt".

🚨 Issue: "Welcome to nginx" page instead of App
Scenario: Accessing the Ingress Public IP.

Cause: The Ingress rule was not explicitly linked to the Nginx Controller class.

Fix: Added ingressClassName: nginx to the Ingress spec and verified the backend.service.name matched the actual service exactly.