FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /source

# copy csproj and restore as distinct layers
COPY *.sln .
COPY SS14.Watchdog/*.csproj ./SS14.Watchdog/
COPY SS14.Watchdog.Tests/*.csproj ./SS14.Watchdog.Tests/
RUN dotnet restore -r linux-x64

# copy everything else and build app
COPY SS14.Watchdog/. ./SS14.Watchdog/
COPY SS14.Watchdog.Tests/. ./SS14.Watchdog.Tests/
WORKDIR /source/SS14.Watchdog/
RUN dotnet publish -c release -r linux-x64 -o /app --no-self-contained --no-restore

# final stage/image
FROM mcr.microsoft.com/dotnet/sdk:8.0

# dependencies
RUN apt-get update \
  && apt-get install -y git python3 python-is-python3

WORKDIR /app
COPY --from=build /app ./

ENV DOTNET_ENVIRONMENT Production

ENTRYPOINT ["/app/SS14.Watchdog"]
