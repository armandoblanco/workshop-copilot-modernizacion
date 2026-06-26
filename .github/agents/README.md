# Agentes del playbook

Los archivos `.agent.md` de esta carpeta son los agentes del
[legacy-modernization-playbook](https://github.com/armandoblanco/legacy-modernization-playbook).

Se copian aquí durante el bootstrap del playbook. Para este workshop, el facilitador
los copió manualmente desde el playbook original. No los edites — son la fuente de verdad.

## Agentes requeridos para este workshop

```
01-dotnet-assessment.agent.md       @dotnet-assessment       Fase 1 — .NET
02-dotnet-planning.agent.md         @dotnet-planning         Fase 2 — .NET
03-dotnet-migration.agent.md        @dotnet-migration        Fase 3 — .NET
04-spring-legacy-assessment.agent.md  @spring-legacy-assessment  Fase 1 — Java
05-spring-legacy-planning.agent.md    @spring-legacy-planning    Fase 2 — Java
06-spring-legacy-migration.agent.md   @spring-legacy-migration   Fase 3 — Java
07-azure-architect.agent.md           @azure-architect           Fase 4 — Cloud
```

## Cómo obtenerlos

```bash
# Clonar el playbook y copiar los agentes de .NET y Spring legacy
git clone https://github.com/armandoblanco/legacy-modernization-playbook.git /tmp/playbook

cp /tmp/playbook/.github/agents/01-dotnet-assessment.agent.md .github/agents/
cp /tmp/playbook/.github/agents/02-dotnet-planning.agent.md .github/agents/
cp /tmp/playbook/.github/agents/03-dotnet-migration.agent.md .github/agents/

# Para Java: el bootstrap del playbook los copia con el prefijo del sub-stack elegido
# Ejecuta el bootstrap y elige "spring-legacy" como sub-stack Java
```
