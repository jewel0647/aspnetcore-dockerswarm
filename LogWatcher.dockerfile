FROM microsoft/dotnet:latest

# Set environment variables
ENV ASPNETCORE_URLS="http://*:5005"
ENV ASPNETCORE_ENVIRONMENT="Staging"

# Copy files to app directory
COPY /src/RethinkDbLogProvider /app/src/RethinkDbLogProvider
COPY /src/LogWatcher /app/src/LogWatcher
COPY NuGet.Config /app/src/LogWatcher/NuGet.Config

# RethinkDbLogProvider
WORKDIR /app/src/RethinkDbLogProvider
RUN ["dotnet", "restore"]

# Set working directory
WORKDIR /app/src/LogWatcher

# Restore NuGet packages
RUN ["dotnet", "restore"]

# Build the app
RUN mkdir release && dotnet publish -c Release -o /app/src/LogWatcher/release

# Open port
EXPOSE 5005/tcp

HEALTHCHECK CMD curl --fail http://localhost:5005/home/healthcheck || exit 1

# Set working directory to release
WORKDIR /app/src/LogWatcher/release

# Run the app
ENTRYPOINT ["dotnet", "LogWatcher.dll"]