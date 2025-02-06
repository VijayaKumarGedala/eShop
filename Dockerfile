# Build
FROM mcr.microsoft.com/dotnet/sdk:9.0-alpine AS build
WORKDIR /src
COPY . /src
RUN dotnet build "eShop.csproj" -c Release -o /app/build

# Pulish
WORKDIR /src
RUN dotnet Pulish "eShop.csproj" -c Release -o /app//published
WORKDIR /app/published

# Runtime
FROM mcr.microsoft.com/dotnet/aspnet:9.0-alpine AS runtime 
LABEL project=".net" \
       author="vijay"
ARG USERNAME=dotnet
WORKDIR /apps
COPY --from=publish --chown=${USERNAME}:${USERNAME} /app/publish .
USER ${USERNAME}
ENTRYPOINT ["dotnet", "eShop.dll"]
