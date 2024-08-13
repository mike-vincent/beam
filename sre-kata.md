# SRE Candidate Kata

Hello and thanks for considering Beam! We are interested in your experience with the specific technologies listed, but you may solve the problems however you see fit. Be prepared to discuss your work during your interview. Cheers!

## AWS Details

* The AWS region we want any resources deployed in is `us-east-2`
* We will send you IAM credentials in a secure email through Virtu. You can find instructions on how to activate Virtru and access the secure email (once it has arrived) [here](https://support.virtru.com/hc/en-us/sections/360006714293-Install-Activate-Virtru-for-Users)

## Tasks

The below tasks must be created by you and subsequent runs of your solution should be idempotent. Make sure **all** of your resources are tagged with `Owner: yourName`. You are free to use the existing VPC configuration to create your resources in, but you are also welcome to create your own if desired. Look for VPC resources tagged with `Owner: sre` if you intend to re-use the existing VPC setup.

Please use terraform (or other similar IaC tech) to complete **any two** of the following tasks:

1. Stand up a container service of your choosing and configure it to run:
    * A Redis Instance
    * A web application accessible from the internet with a dependency on Redis
      * Use the `beamdental/sre-kata-app` container image from docker hub
        * This app listens on port 4567/tcp
      * This app requires the `REDIS_URL` environment variable to locate Redis

2. Stand up an RDS instance running your database of choice
    * Place the instance in either our database subnets or your own if you created them
    * The RDS instance should not be publicly accessible
    * Allow access from the public facing subnet to your database instance
      * This should be done in a secure manner (i.e: don't open 3306/tcp to the world)

3. Deploy a serverless function
    * The function can be written in any language
    * Using OpenBreweryDB's API (`https://api.openbrewerydb.org/v1/breweries`), your lambda should parse all breweries in the city of Columbus, Ohio. Use the API's documentation for how to do this.
    * Your Lambda should log to Cloudwatch
      * Produce a log in JSON of the `name`, `street` and `phone` of each Brewery returned (ascended by `name`)
    * Bonus points for including unit tests for your lambda function code

### Tips

* Avoid copy/pasting example code from the internet. We want to know what you know!
* Treat passwords as sensitive. There's no need to deploy a Vault instance, but how would you go about providing a password securely?
* In your IaC, use outputs! We want to see what data you might find important to pass to other states

### Submission

* Include a README.md file. At a minimum, this should include things like:
  * Outlining which tasks you've chosen and a rundown of what you've built
  * How to access and test your chosen tasks
  * Applicable versions of software used
* Send us your work in a compressed file format of your choice, including any related state files
  * This should only include code that you have written. As an example, the `.terraform` directory isn't necessary to deliver
* You have 1 calendar week to complete this. If you need more time, do let us know

Good luck!
