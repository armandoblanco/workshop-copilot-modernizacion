# Referencia — Legacy Modernization Playbook

Este workshop implementa las Fases 1 a 4 del [legacy-modernization-playbook](https://github.com/armandoblanco/legacy-modernization-playbook).

## Mapeo del workshop al playbook

| Lab | Fase | Agente del playbook | Entregables |
|-----|------|--------------------|-|
| Lab 01 — Assessment .NET | Fase 1 | `@dotnet-assessment` | `docs/features/` + `docs/inventory/` + `docs/SUMMARY.md` |
| Lab 01 — Planning .NET | Fase 2 | `@dotnet-planning` | `docs/ARQUITECTURA-TARGET.md` + `docs/adr/` (8 ADRs) |
| Lab 01 — Migration .NET | Fase 3 | `@dotnet-migration` | `src/` con .NET 8 + tests + Dockerfile |
| Lab 02 — Assessment Java | Fase 1 | `@spring-legacy-assessment` | `docs/inventory/javax-usages.md` + features + CVEs |
| Lab 02 — Planning Java | Fase 2 | `@spring-legacy-planning` | `docs/ARQUITECTURA-TARGET.md` + `docs/adr/` (8 ADRs) |
| Lab 02 — Migration Java | Fase 3 | `@spring-legacy-migration` | OpenRewrite + Spring Boot 3.x + Dockerfile |
| Lab 03 — Cloud Deploy | Fase 4 | `@azure-architect` | `infra/main.bicep` + URLs públicas Azure |

## Qué cubre el playbook que el workshop no incluye (por tiempo)

El playbook tiene también: Fase 0 Business Case (`@business-case-analyst`), Fase 0 Security (`@security-assessor`), y soporte completo para J2EE, Oracle Forms, VB6 y COBOL. Para proyectos reales de cliente, esas fases son críticas.

## Qué es la carpeta `legacy/` en este repo

Siguiendo la convención del playbook, el código fuente legacy va en `legacy/` y es **read-only**. Los agentes solo lo leen — nunca lo modifican. El código moderno generado por los agentes va en `src/` (.NET) o se aplica in-place en `legacy/java/` (Java upgrade in-place según ADR-004).

## ADRs que este workshop debe producir

### .NET (Lab 01)
- ADR-001: Target framework .NET 8 LTS
- ADR-002: Tipo de proyecto — ASP.NET Core Minimal API
- ADR-003: WCF replacement (si existe) — REST con ASP.NET Core
- ADR-004: Config strategy — appsettings.json + Options pattern
- ADR-005: ORM strategy — EF Core 8 InMemory (taller) / SQL Server (producción)
- ADR-006: Auth strategy — fuera de scope del taller
- ADR-007: Logging strategy — ILogger nativo
- ADR-008: Upgrade vs greenfield — greenfield justificado

### Java (Lab 02)
- ADR-001: Java target — Java 21 Eclipse Temurin
- ADR-002: Spring Boot version — 3.5.x
- ADR-003: Namespace strategy — OpenRewrite `javax-to-jakarta`
- ADR-004: Upgrade vs greenfield — upgrade in-place
- ADR-005: Hibernate strategy — annotations + Spring Data JPA
- ADR-006: Packaging — JAR ejecutable (no WAR)
- ADR-007: CVE remediation — versiones seguras de dependencias
- ADR-008: Test strategy — JUnit 5 + Testcontainers
