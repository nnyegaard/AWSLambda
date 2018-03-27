const path = require("path");
const ForkTsCheckerWebpackPlugin = require("fork-ts-checker-webpack-plugin");

module.exports = {
  target: "node",
  context: __dirname, // to automatically find tsconfig.json
  devtool: "source-map",
  entry: "./src/index.ts",
  resolve: {
    extensions: [".js", ".json", ".ts", ".tsx"]
  },
  output: {
    libraryTarget: "commonjs",
    path: path.join(__dirname, "./dist"),
    filename: "index.js"
  },
  externals: ["aws-sdk"],
  module: {
    rules: [
      {
        test: /\.ts(x?)$/,
        use: [
          { loader: "cache-loader" },
          {
            loader: "ts-loader",
            options: {
              transpileOnly: true
            }
          }
        ],
        exclude: "/node_modules/"
      }
    ]
  },
  plugins: [new ForkTsCheckerWebpackPlugin({ checkSyntacticErrors: true })]
};
