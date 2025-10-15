Template for baseline resources, such as KeyVaults, Recovery Services Vaults, etc. 
In this application template, these resources are created (and owned) in the same Resource Group as the application infrastructure. 
Real applications should consider having these resources in a separate Resource Group, where the service principal has limited access rights. 

Note that the baselines are so different between the ```dev``` and ```test``` environments that the ARM templates are split in different folders. 
Another option would have been to use ```condition``` to load resources based on the environment (from the same template file), but in this case I think that would have been more complex. 

### Who should load the environments 



### Update parameters file(s)

Note that part of the deployment is giving the service principal access to set and get secrets. 
This means that the *.parameters.json files needs to be updated with the Object ID of the service principal. 
This can be found in the Azure Portal under ```Enterprise Applications```
