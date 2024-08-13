`us-east-2`
## Tasks
new vpc
turn into modules

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


