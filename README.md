# TF Technical Execises

- Using Terraform with variables from a file we'd like to manage a DNS Zone in Route53.
- Create a Terraform project.
- Create the Zone in Route53 using Terraform.
From an array of subdomain,ip pairs create the records in the zone. ``(10.0.0.1, 'app1' ; 10.0.0.2, 'app2' ; 10.0.0.3, 'app3' ; )``
- For each subdomain add a sub-subdomain of ``www, api, mail``, (either a cname to the subdomain or an A record, your choice).
- Setup an IAM user with least privileges to run it.
Create a jenkins instance and job to run the terraform code on checkin to git.
- Update the array with a new subdomain,ip pair and commit your code to git.


# Folders & Files
- ``iam_policy.json``  IAM group policy to run rf
- ``tf_dns``  tf code to create Route53 records
- ``jenkins`` exported jenkins job def

