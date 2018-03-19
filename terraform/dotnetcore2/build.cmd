cd src/
dotnet restore
dotnet lambda package --configuration release --framework netcoreapp2.0 --output-package ./../deploy-package.zip

cd ..