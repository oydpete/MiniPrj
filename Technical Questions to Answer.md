Explain your Git branching strategy and how you managed changes across multiple scripts.


What Linux kernel parameters did you tune and why?

How do your scripts handle unexpected errors or edge cases?

## * Explain the security measures you implemented on your servers:

1. SSH Hardening: I configured SSH to allow only key-based authentication, eliminating the risk of password-based brute-force attacks.

2. Root Privileges for Critical Scripts: To prevent unauthorized execution, scripts that require system-level changes are designed to run exclusively as root.

3. Automated Security Updates: I set up automated patching for system packages to ensure known vulnerabilities are promptly fixed.

4. Secure Environment Configuration: Sensitive information, such as IP addresses and SSH keys, is never hardcoded in scripts. Instead, I store them in a .env file to keep credentials secure and maintain a clean codebase.

5. Password Policy Enforcement: I implemented strict password policies, including complexity requirements and expiration periods, to enhance authentication security.

6. Firewall Protection: I configured UFW with a default deny policy, allowing only specific, necessary services to minimize exposure to unauthorized access.


How would you scale your solution to manage dozens of servers? 

Demonstrate how your backup and recovery process works.

# Explain how you tested your scripts to ensure they work correctly.

1. I tested them on a server dedicated to that purpose

# What was the most challenging Linux administration task you encountered? 
Most of the tasks were challenging especially the bash scripting , I have always been used to hard coding the bash command directly into the terminal

Hvaing to automate these command through the bash scripts was particualy challenging

How did you ensure that your networking configuration is secure?

I ensured they were secured through only allowing access to only essential ports 

Which Bash scripting techniques did you find most useful for this project?

1. The variable environment method was very useful for security

2. The if statements for checks were essential to enable the code handle error well 