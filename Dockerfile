# Build Stage
FROM mcr.microsoft.com/dotnet/sdk:9.0-alpine AS build
WORKDIR /src
COPY . .  # Copy everything in the context into /src
RUN ls -al /src  # Add this line to verify the files are being copied properly
RUN dotnet build "eShop.csproj" -c Release -o /app/build


# Publish Stage
WORKDIR /src
RUN dotnet publish "eShop.csproj" -c Release -o /app/published
WORKDIR /app/published

# Runtime Stage
FROM mcr.microsoft.com/dotnet/aspnet:9.0-alpine AS runtime
LABEL project=".net" \
      author="vijay"

# Set the working directory and user
ARG USERNAME=dotnet
WORKDIR /apps
COPY --from=build --chown=${USERNAME}:${USERNAME} /app/published .
USER ${USERNAME}

# Set entry point to run the application
ENTRYPOINT ["dotnet", "eShop.dll"]
