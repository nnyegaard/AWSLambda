using Amazon.Lambda.APIGatewayEvents;
using Amazon.Lambda.Core;
using System;
using System.Collections.Generic;
using System.Net;
using Amazon.Lambda.Serialization.Json;
using Newtonsoft.Json;

[assembly: LambdaSerializer(typeof(Amazon.Lambda.Serialization.Json.JsonSerializer))]

namespace AwsDotnetCsharp
{
    public class Handler
    {
        public APIGatewayProxyResponse Hello(APIGatewayProxyRequest request, ILambdaContext context)
        {
            context.Logger.Log("context logger used - hello");
            Console.WriteLine("console.WriteLine used - hello");
            LambdaLogger.Log("LambdaLogger used - hello");
            Product p = new Product(1, "hej", DateTime.Now, new List<string> { "hej", "ddf" });
            var json = JsonConvert.SerializeObject(p);

            var response = new APIGatewayProxyResponse
            {
                StatusCode = (int)HttpStatusCode.OK,
                Body = json,
                Headers = new Dictionary<string, string> { { "Content-Type", "application/json" } }
            };

            return response;
        }
    }

    public class Handler2
    {
        public APIGatewayProxyResponse Hello2(APIGatewayProxyRequest request, ILambdaContext context)
        {
            context.Logger.Log("context logger used - hello2");
            Console.WriteLine("console.WriteLine used - hello2");
            LambdaLogger.Log("LambdaLogger used - hello2");

            var response = new APIGatewayProxyResponse
            {
                StatusCode = 200,
                Body = JsonConvert.SerializeObject(request),
                Headers = new Dictionary<string, string> { { "Content-Type", "application/json" } }
            };

            return response;
        }
    }


    public class Product
    {
        public Product(int price, string name, DateTime expireDate, List<string> sizes)
        {
            Price = price;
            Name = name;
            ExpireDate = expireDate;
            Sizes = sizes;
        }

        public int Price { get; set; }
        public string Name { get; set; }

        public DateTime ExpireDate { get; set; }

        public List<string> Sizes { get; set; }
    }
}
