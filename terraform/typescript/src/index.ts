import { APIGatewayEvent, Callback, Context, Handler } from "aws-lambda";

export const controller: Handler = async (event: APIGatewayEvent, context: Context, callback: Callback) => {
  try {
    console.log("Hello world!");
    context.succeed({
      statusCode: 200,
      body: JSON.stringify({ Hello: "World" })
    });
  } catch (error) {
    context.succeed({
      statusCode: 400,
      body: JSON.stringify({ Error: "Message goes here" })
    });
  }
};
