# Explain your Git branching strategy and how you managed changes across multiple scripts.


What Linux kernel parameters did you tune and why?

How do your scripts handle unexpected errors or edge cases?

## * Explain the security measures you implemented on your servers:

 1. SSH Hardening: I configured SSH to allow only key-based authentication, eliminating the risk of password-based brute-force attacks.

 2. Root Privileges for Critical Scripts: To prevent unauthorized execution, scripts that require system-level changes are designed to run exclusively as root.

 3. Automated Security Updates: I set up automated patching for system packages to ensure known vulnerabilities are promptly fixed.

 4. Secure Environment Configuration: Sensitive information, such as IP addresses and SSH keys, is never hardcoded in scripts. Instead, I store them in a .env file to keep credentials secure and maintain a clean codebase.

 5. Password Policy Enforcement: I implemented strict password policies, including complexity requirements and expiration periods, to enhance authentication security.

 6. Firewall Protection: I configured UFW with a default deny policy, allowing only specific, necessary services to minimize exposure to unauthorized access.


## How would you scale your solution to manage dozens of servers? 

1.  I would update the Scripts in a way that it can accomodate other linux distros like RedHat, Debiamn E.t.c

## Demonstrate how your backup and recovery process works.

1. My Backup is scheduled everyday,.Files can be restrievd from the backup. However, over 30 day are deleted , The Backup also verfies backup to be sure of its realibality


# Explain how you tested your scripts to ensure they work correctly.

1. I tested each Script indvidually  on a dedicated created on vagrant or wsl depending its suitablilty

# What was the most challenging Linux administration task you encountered? 
    
    * The most challenging part was the [Part 2: Linux Server Administration](./Scripts/Part%202%20Scripts/Sec1.sh) , after so much effort, I was unable to access the target server with the Admin Server . But Honestly, Most of the tasks were challenging especially the bash scripting , I have always been used to hard coding the bash command directly into the terminal. This was a step compared to what I do normally. but afterward , it is a great oppurtunity to  learn


## How did you ensure that your networking configuration is secure?

1. I only allow required Ports , in the traffic rules

2. I made sure all incomming traffic access is restricted except required 



## Which Bash scripting techniques did you find most useful for this project?

1. The variable environment method was very useful for security

2. The if statements for checks were essential to enable the code handle error well

3. The while loop was also really resourceful 