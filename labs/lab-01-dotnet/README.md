# Lab 01 — Modernización .NET Framework → .NET 8

> **Modo Copilot en este lab: Agente**
>
> Pasos en VS Code cada vez que el lab diga "En Copilot Chat (Modo Agente)":
> 1. Abre Copilot Chat con `Ctrl+Alt+I` (Windows) / `Cmd+Alt+I` (Mac)
> 2. Cambia el modo a **Agent** en el selector superior del panel de chat
> 3. Haz clic en **"Select tools"** (ícono 🔧) y activa el agente del paso actual
> 4. Escribe el prompt y presiona Enter

---

## Objetivo

Recorrer las **Fases 1, 2 y 3** del playbook de modernización para una app ASP.NET MVC 4.x, usando los agentes `@dotnet-assessment`, `@dotnet-planning` y `@dotnet-migration`.

Al terminar tendrás un reporte de deuda técnica, un conjunto de ADRs con las decisiones de arquitectura, y la app modernizada en .NET 8 con un Dockerfile listo para Azure Container Apps.

---

## Código fuente

[`dotnet-architecture/eShopModernizing`](https://github.com/dotnet-architecture/eShopModernizing) — App ASP.NET MVC 4.x sobre .NET Framework. Tiene `Global.asax`, `Web.config`, `packages.config`, dependencias de `System.Web.*`, y Entity Framework 6. Representa el stack que el agente va a analizar y transformar.

---

## Flujo del lab

```
flowchart LR
  A([Clonar legacy]) --> B

  subgraph AGENTES["Copilot — Modo Agente"]
    B["@dotnet-assessment\nAnálisis del sistema en legacy/dotnet/"] --> C
    C["@dotnet-planning\nDecisiones de arquitectura + ADRs"] --> D
    D["@dotnet-migration\nMigración a .NET 8 + Dockerfile"]
  end

  D --> E([dotnet run — validar /health])
  E --> F([docker build + run — validar contenedor])
```

---

## Paso 1 — Clonar el código legacy

**macOS / Linux / Codespaces:**
```bash
git clone https://github.com/dotnet-architecture/eShopModernizing.git legacy/dotnet
```

**Windows (PowerShell):**
```powershell
git clone https://github.com/dotnet-architecture/eShopModernizing.git legacy\dotnet
```

Abre VS Code en la raíz del repo del workshop (no dentro de `legacy/dotnet`):
```bash
code .
```

Explora la estructura antes de usar Copilot:
```
legacy/dotnet/eShopWebMVC/
├── Controllers/         ← CatalogController.cs — módulo que vamos a migrar
├── Models/              ← Entidades de dominio
├── App_Start/           ← RouteConfig, FilterConfig — pattern legacy sin equivalente en .NET 8
├── Web.config           ← Configuración XML — se reemplaza con appsettings.json
├── Global.asax          ← Entry point legacy — reemplazado por Program.cs
└── packages.config      ← NuGet legacy — migra a PackageReference
```

---

## Paso 2 — Fase 1: Assessment

> Agente: `@dotnet-assessment` — Fase 1 del playbook

En Copilot Chat (Modo Agente):

```
@dotnet-assessment Analiza el sistema en legacy/dotnet/
```

El agente detecta: versión de .NET Framework, tipo de app, APIs deprecadas o removidas en .NET 8 (`System.Web.HttpContext`, WCF, Remoting), paquetes NuGet legacy y su equivalente moderno, secciones de `Web.config` que no migran 1:1, y tests existentes.

Espera a que produzca los entregables en `docs/`:

```
docs/
├── README.md                    Índice maestro del assessment
├── SUMMARY.md                   Resumen ejecutivo
├── dependency-graph.md          Grafo Mermaid + orden de migración
├── features/
│   ├── 01-catalogo-productos.md
│   ├── 02-gestion-pedidos.md
│   └── ...                      (un .md por feature funcional)
└── inventory/
    ├── projects.md              Inventario de .csproj
    ├── nuget-packages.md        Paquetes con análisis de compatibilidad .NET 8
    ├── deprecated-apis.md       APIs que bloquean la migración
    └── config-sections.md       Secciones de Web.config problemáticas
```

Revisa `docs/SUMMARY.md` con el facilitador antes de continuar. Presta atención a `deprecated-apis.md` — ahí están los bloqueos reales.

---

## Paso 3 — Fase 2: Planning

> Agente: `@dotnet-planning` — Fase 2 del playbook

El agente lee los outputs de la Fase 1 y te hace preguntas sobre decisiones críticas. Cuando te las haga, responde:

- **Target framework:** .NET 8 LTS
- **Tipo de proyecto target:** ASP.NET Core Minimal API
- **WCF (si existe):** REST con ASP.NET Core
- **Estrategia:** greenfield (nueva solución en `src/`)
- **Hosting target:** Azure Container Apps (contenedor Linux)

En Copilot Chat (Modo Agente):

```
@dotnet-planning Revisa el assessment en docs/ y planifica la migración
```

Produce:

```
docs/
├── ARQUITECTURA-TARGET.md       Stack target + mapping legacy → moderno
├── migration-plan.md            Orden de migración con dependencias
└── adr/
    ├── ADR-001-target-framework.md        .NET 8 LTS
    ├── ADR-002-tipo-proyecto-target.md    ASP.NET Core Minimal API
    ├── ADR-003-wcf-replacement.md         REST con ASP.NET Core (si aplica)
    ├── ADR-004-config-strategy.md         appsettings.json + Options pattern
    ├── ADR-005-orm-strategy.md            EF Core 8 (InMemory para el taller)
    ├── ADR-006-auth-strategy.md           Sin auth para el taller (scope reducido)
    ├── ADR-007-logging-strategy.md        ILogger nativo
    └── ADR-008-upgrade-vs-greenfield.md   Greenfield justificado
```

Lee `docs/ARQUITECTURA-TARGET.md` completo antes de continuar — es el contrato que la Fase 3 va a respetar.

---

## Paso 4 — Fase 3: Migration

> Agente: `@dotnet-migration` — Fase 3 del playbook

En Copilot Chat (Modo Agente):

```
@dotnet-migration Ejecuta la migración del sistema legacy
```

El agente lee `docs/ARQUITECTURA-TARGET.md` + los ADRs + `docs/features/`, y genera el código moderno feature por feature en `src/`. El agente decide el nombre de la solución — típicamente `eShopModern` o similar. Cuando empiece a generar archivos, anota el nombre real que usó porque lo necesitarás en los pasos siguientes.

La estructura generada será similar a:

```
src/
├── eShopModern.sln
├── eShopModern.Api/              ASP.NET Core Minimal API endpoints
├── eShopModern.Application/      Use cases + DTOs
├── eShopModern.Domain/           Entities + Value Objects
├── eShopModern.Infrastructure/   EF Core 8 InMemory + repositorios
└── eShopModern.Tests/
    ├── UnitTests/
    └── IntegrationTests/
```

Trabaja feature por feature: **no acumula cambios sin compilar**. Sustituye `eShopModern` por el nombre real que el agente generó:

**macOS / Linux / Codespaces:**
```bash
dotnet build src/eShopModern.sln
```

**Windows (PowerShell):**
```powershell
dotnet build src\eShopModern.sln
```

Cuando termine, corre la app:

**macOS / Linux / Codespaces:**
```bash
dotnet run --project src/eShopModern.Api
```

**Windows (PowerShell):**
```powershell
dotnet run --project src\eShopModern.Api
```

Verifica en el navegador: `http://localhost:8080/health` → debe responder `{ "status": "Healthy" }`.

---

## Paso 5 — Generar el Dockerfile

Con la app funcionando, pide al agente. Sustituye `eShopModern.Api` por el nombre real de tu carpeta API:

```
@dotnet-migration Genera el Dockerfile multi-stage para la app .NET 8 en src/.
Usa base mcr.microsoft.com/dotnet/aspnet:8.0-alpine, puerto 8080, usuario non-root.
Guarda el Dockerfile en la carpeta del proyecto API.
```

Verifica que la imagen construye (sustituye `eShopModern.Api` por tu nombre real):

**macOS / Linux / Codespaces:**
```bash
docker build -t catalogservice:local src/eShopModern.Api/
docker run -p 8080:8080 catalogservice:local
```

**Windows (PowerShell):**
```powershell
docker build -t catalogservice:local src\eShopModern.Api\
docker run -p 8080:8080 catalogservice:local
```

`http://localhost:8080/health` desde el contenedor.

Detén con `Ctrl+C`.

---

## Entregables del lab

- `docs/SUMMARY.md` — reporte de deuda técnica
- `docs/adr/` — mínimo 6 ADRs documentados
- `docs/ARQUITECTURA-TARGET.md` — decisiones de arquitectura
- `src/` — solución .NET 8 que compila y pasa tests
- `src/eShopModern.Api/Dockerfile` (nombre exacto según lo que generó el agente) — imagen que sirve `/health` en el puerto 8080

---

## Errores comunes

**El agente genera imports de `System.Web`**
Agrega al prompt: `"El namespace System.Web no existe en .NET 8. No lo uses en ningún archivo generado."`

**Puerto 80 en lugar de 8080**
Pide al agente: `"Corrige el Dockerfile para usar EXPOSE 8080 y agrega la variable ASPNETCORE_URLS=http://+:8080"`

**EF6 en lugar de EF Core 8**
Pide: `"Usa Entity Framework Core 8 (paquete Microsoft.EntityFrameworkCore.InMemory), no Entity Framework 6."`

---

Continúa con el [Lab 02 →](../lab-02-java/README.md)
