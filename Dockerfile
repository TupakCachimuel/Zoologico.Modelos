FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
WORKDIR /app
# Eliminar EXPOSE 10000
# Eliminar ENV ASPNETCORE_URLS=http://+:10000

# -----------------------------------------------------
# NOTA: .NET automáticamente escucha en el puerto 8080 si se usa la imagen 'aspnet:8.0', 
# lo cual Render maneja bien, o leerá la variable PORT si se le pasa.
# Para asegurar que la variable PORT de Render se use, lo mejor es dejar la configuración por defecto
# o usar el puerto 8080 si Render lo acepta (que generalmente sí lo hace para aplicaciones web).
# Dejando las líneas EXPOSE y ENV afuera, la configuración por defecto de .NET/Kestrel
# es flexible.
# -----------------------------------------------------

FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# ASUME que el Dockerfile está en la raíz, por eso se ajustan las rutas:
COPY ["Zoologico.API/Zoologico.API.csproj", "Zoologico.API/"] 
RUN dotnet restore "Zoologico.API/Zoologico.API.csproj"
COPY . .


WORKDIR "/src/Zoologico.API"

RUN dotnet build "Zoologico.API.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "Zoologico.API.csproj" -c Release -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .

# Asegura que el servicio escuche en el puerto 8080, que es el puerto estándar 
# usado por imágenes de .NET para contenedores, y que Render puede mapear.
# Render mapeará su variable PORT a este puerto 8080.
EXPOSE 8080 
ENTRYPOINT ["dotnet", "Zoologico.API.dll"]