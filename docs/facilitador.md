# Guía del facilitador

## Antes del taller

### Checklist de preparación (día anterior)
- [ ] Licencias de GitHub Copilot Business/Enterprise activas para todos los participantes
- [ ] Service Principal creado con rol `Contributor` + `User Access Administrator` sobre la suscripción
- [ ] Probar el devcontainer de Codespaces en un fork — verificar que Temurin 8 y 21 quedan en `JAVA_HOME_8` y `JAVA_HOME_21`
- [ ] Verificar que `az login --service-principal` funciona con las credenciales que vas a distribuir
- [ ] Probar el deploy del Bicep con un prefijo propio — validar que los 8 recursos se crean sin errores
- [ ] Ejecutar `cleanup.sh` después de la prueba

### Qué distribuir a los participantes al inicio
- URL del repo del workshop
- `AZURE_TENANT_ID`, `AZURE_CLIENT_ID`, `AZURE_CLIENT_SECRET`, `AZURE_SUBSCRIPTION_ID`
- Instrucción de usar Codespaces o los prerequisitos de instalación local

---

## Durante el taller

### Lab 01 — .NET
**Señal de que el grupo va bien:** la mayoría tiene `http://localhost:8080/health` respondiendo desde el contenedor Docker antes de pasar al Lab 02.

**Punto de corte si hay retraso:** el Dockerfile del Lab 01 puede postergarse al inicio del Lab 03. En ese caso, avanza al Lab 02 con solo la app corriendo en `dotnet run`.

**Error más frecuente:** Copilot genera imports de `System.Web`. Solución: pedir al participante que agregue al prompt `"No uses System.Web en ningún archivo generado"`.

### Lab 02 — Java
**Señal de que el grupo va bien:** la mayoría tiene `./mvnw spring-boot:run` iniciando la app con Spring Boot 3.x sin errores.

**Punto de corte si hay retraso:** si el upgrade de Copilot tarda más de 20 minutos, verifica si el agente está en un loop de errores de compilación. En ese caso, reinicia el chat con:
```
El upgrade quedó incompleto. Revisa el estado actual del pom.xml y 
la lista de archivos que todavía tienen javax.* y continúa desde ahí.
```

**Advertencia de tiempo:** el agente tarda entre 10 y 25 minutos por la cantidad de archivos que modifica. Avisa al grupo antes de iniciar el Lab 02 para que no cierren el chat.

### Lab 03 — IaC y deploy
**Punto crítico:** el role assignment de AcrPull requiere que el Service Principal tenga `User Access Administrator`. Si ves el error `The client does not have authorization to perform action 'Microsoft.Authorization/roleAssignments/write'`, el SP no tiene ese permiso.

**Solución de emergencia:** si el deploy de Bicep falla en el role assignment, puedes asignar el rol manualmente:
```bash
az role assignment create \
  --assignee <object-id-managed-identity> \
  --role AcrPull \
  --scope /subscriptions/<sub-id>/resourceGroups/<rg>/providers/Microsoft.ContainerRegistry/registries/<acr>
```

**Cold start Java:** la primera vez que la Container App de Java arranca con minReplicas=0 puede tardar hasta 90 segundos. Avisa al grupo antes de que abran la URL.

---

## Post-taller

Ejecutar el script de cleanup para eliminar todos los Resource Groups:

```bash
# Eliminar todos los RGs del taller de una vez
./cleanup.sh

# O eliminar el de un participante específico
./cleanup.sh arb
```
