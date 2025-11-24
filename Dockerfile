# syntax=docker/dockerfile:1

## Buildstage ##
FROM mcr.microsoft.com/dotnet/sdk:9.0 AS buildstage

RUN \
  echo "**** git clone repo ****" && \
  git clone https://github.com/JPVenson/Jellyfin.Pgsql.git /src

WORKDIR /src

# Restore and publish
RUN dotnet restore Jellyfin.Plugin.Pgsql.sln
RUN dotnet publish Jellyfin.Plugin.Pgsql.sln -c Release --no-restore -o /app/publish

## Single layer deployed image ##
FROM scratch

LABEL maintainer="Cremator"

# Copy the published plugin and config files
COPY --from=buildstage /app/publish/ /jellyfin-pgsql/plugin/
COPY --from=buildstage /src/docker/entrypoint.sh /jellyfin-pgsql/entrypoint.sh
COPY --from=buildstage /src/docker/database.xml /jellyfin-pgsql/database.xml
COPY --from=buildstage /src/docker/jellyfindb.load /jellyfin-pgsql/jellyfindb.load
COPY --from=buildstage /src/docker/jellyfin.PgsqlMigrator.dll /jellyfin-pgsql/jellyfin.PgsqlMigrator.dll
RUN chmod +x /jellyfin-pgsql/entrypoint.sh