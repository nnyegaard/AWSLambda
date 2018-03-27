# Collection of code samples for AWS Lambda

This repo is divided into code that uses the ServerlessFramework and code that uses Terraform to handle ressources on AWS.

# Serverless

Contains an example of getting a .NET Core 2 function deployed.

### dotnet2_simple_function

Contains a simple function that will create

* A GET endpoint
* a POST endpoint

Will serialize and object and return it in both cases

# Terraform

Contains examples for Nodejs, .NET Core 2 and Nodejs + Typescript

### dotnetcore2

Contains a simple function that will create

* A GET endpoint
* a POST endpoint

Will serialize and object and return it in both cases

#### Howto:

run

* dotnet restore

go into the infra folder

* terraform init
* terraform apply

### nodejs

Contains a simple function that will create

* A GET endpoint

Will run a serialized object

#### Howto:

go into the infra folder

* terraform init
* terraform apply

### typescript

Contains a simple function that will create

* A GET endpoint

Will run a serialized object.

NOTE: If you are using any modules the node_modules need to be deployed together with the index.js file

#### Howto:

run

* npm install

go into the infra folder

* terraform init
* terraform apply

### typescript-webpack

Contains a simple function that will create

* A GET endpoint

Will run a serialized object

NOTE: Webpack will bundle all the code we use into one file and only this needs to be deployed.

#### Howto:

run

* npm install
* npm run build

go into the infra folder

* terraform init
* terraform apply

# Links of interest

Serverless Applications with AWS Lambda and API Gateway(https://www.terraform.io/docs/providers/aws/guides/serverless-with-aws-lambda-and-api-gateway.html)
