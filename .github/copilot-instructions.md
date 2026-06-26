# Instrucciones globales — Workshop Modernización de Apps

## Contexto del workshop

Este repositorio es un taller de modernización de aplicaciones legacy basado en el
[legacy-modernization-playbook](https://github.com/armandoblanco/legacy-modernization-playbook).

Contiene dos proyectos legacy en la carpeta `legacy/`:
- `legacy/dotnet/` — ASP.NET MVC 5 sobre .NET Framework 4.8.2 (ContosoUniversity)
- `legacy/java/`   — ContosoUniversity en .NET Framework 4.8 (Azure-Samples/java-migration-copilot-samples)

El código en `legacy/` es **read-only**. Los agentes lo leen pero nunca lo modifican.

## Reglas globales

### Idioma
- Documentación y comentarios: **español**
- Código (clases, métodos, variables, endpoints): **inglés**

### .NET target
- Framework: **.NET 8 Minimal API** (no Controllers, no MVC)
- ORM: **Entity Framework Core 8** con InMemory para el taller
- Health check obligatorio en `/health`
- Imagen Docker: `mcr.microsoft.com/dotnet/aspnet:8.0-alpine`, multi-stage
- Puerto de contenedor: **8080** — `ASPNETCORE_URLS=http://+:8080`
- Prohibido: `System.Web`, `HttpContext.Current`, `ViewBag`, `BinaryFormatter`

### Java target
- JDK: **Eclipse Temurin 21** (sin licencia Oracle)
- Framework: **Spring Boot 3.x** con namespace `jakarta.*` (no `javax.*`)
- Build: **Maven**, packaging **JAR ejecutable** (no WAR)
- Imagen Docker: `eclipse-temurin:21-jre-alpine`, multi-stage
- Puerto de contenedor: **8080**
- Namespace change: aplicar OpenRewrite recipe `javax-to-jakarta` como primer paso

### IaC
- Herramienta: **Bicep** nativo
- Compute: **Azure Container Apps** — no App Service, no AKS
- Recursos mínimos: Log Analytics, Application Insights, ACR, Managed Identity
- Parámetro obligatorio: `participantPrefix` para evitar colisiones
- ACR pull via Managed Identity — nunca credenciales en texto plano

## Restricciones de seguridad
- No hardcodees secrets, connection strings ni tokens
- No uses `localhost` en configuraciones de Azure
- El código debe compilar en el primer intento en un Codespace limpio
