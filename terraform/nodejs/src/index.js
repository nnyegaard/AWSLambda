exports.handler = (event, context, callback) => {
  console.log("Hello CloudWatch!");

  callback(null, {
    statusCode: 200,
    body: JSON.stringify("Hello world!")
  });
};
