# Build Stage
FROM mcr.microsoft.com/dotnet/sdk:9.0-alpine AS build
WORKDIR /src
COPY . /src
RUN dotnet build "eShop.csproj" -c Release -o /app/build

# Publish Stage
WORKDIR /src
RUN dotnet publish "eShop.csproj" -c Release -o /app/published
WORKDIR /app/published

# Runtime Stage
FROM mcr.microsoft.com/dotnet/aspnet:9.0-alpine AS runtime
LABEL project=".net" \
      author="vijay"

# Install glibc and locales for globalization support
RUN apk add --no-cache \
    ca-certificates \
    libc6-compat \
    && apk add --no-cache --virtual .build-deps gcc g++ make \
    && apk add --no-cache locales \
    && locale-gen en_US.UTF-8 \
    && update-locale LANG=en_US.UTF-8 \
    && apk del .build-deps

# Set the working directory and user
ARG USERNAME=dotnet
WORKDIR /apps
COPY --from=build --chown=${USERNAME}:${USERNAME} /app/published .
USER ${USERNAME}

# Set entry point to run the application
ENTRYPOINT ["dotnet", "eShop.dll"]
