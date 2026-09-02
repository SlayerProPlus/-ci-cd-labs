# Proyecto Final — Implementación de CI/CD

Este repositorio contiene la implementación de un proceso completo de **Continuous Integration / Continuous Delivery (CI/CD)** para una aplicación web desarrollada en Python (Flask), utilizando **GitHub Actions** para la automatización y una infraestructura local con máquinas virtuales **Ubuntu** para el despliegue.

---

## 🛠️ Tecnologías y Equivalencias

El proyecto fue implementado en **Python**, manteniendo estricta equivalencia con los conceptos trabajados en el módulo:

| Componente | Implementación en este Proyecto | Equivalente en Java |
|---|---|---|
| **Lenguaje / Framework** | Python 3 + Flask API | Java + Spring Boot |
| **Gestión de dependencias** | `pip` + `requirements.txt` | Maven (`pom.xml`) |
| **Pruebas unitarias** | `pytest` | JUnit |
| **Cobertura de código** | `pytest-cov` (Reporte HTML/Term) | JaCoCo |
| **Artefacto ejecutable** | Archivo comprimido `.zip` | Archivo `.jar` |
| **Balanceador de carga** | Nginx (`least_conn`) | Nginx |
| **Infraestructura** | Ubuntu Server en VirtualBox | Ubuntu / WSL |

---

## 🏛️ Arquitectura del Proceso CI/CD

```
[ Desarrollador ]
       |
       v (Push / PR)
  feature/* --> GitHub Actions (CI)
                     |-- Build / Dependencies
                     |-- Unit Tests (pytest)
                     |-- Code Coverage (pytest-cov)
                     `-- Upload Artifacts (Reportes HTML)
                            |
                       (Merge a main)
                            |
                       (git tag v1.0.0)
                            v
               GitHub Actions (Release Workflow)
                     `-- Package & Publish .zip Artifact
                            |
                            v (scp / Despliegue)
                  [ Servidor Ubuntu ]
                            |
                 deploy-blue-green.sh
                            |
               +------------+------------+
               v                         v
          BLUE (:8080)              GREEN (:8081)
               |                         |
               +------------+------------+
                            |
                       health-check.sh
                            |
                    [ NGINX Proxy :80 ]
```

---

## 🌿 1. Estrategia de Branching

Se utiliza un flujo basado en ramas de características:

- `main`: Rama principal protegida. Contiene únicamente código validado y listo para producción.
- `feature/*`: Ramas temporales creadas para desarrollar nuevas funcionalidades o corregir errores.
- **Integración:** Todo cambio hacia `main` se realiza obligatoriamente mediante **Pull Requests**, requiriendo la ejecución exitosa del pipeline de CI.

```
main
  |
  +-- feature/feature-1
  +-- feature/feature-2
  `-- feature/feature-3
```

**Reglas:**
- Las ramas `feature/*` se crean desde `main`.
- El merge se realiza únicamente mediante Pull Request aprobado.
- La rama `main` está protegida contra push directo.
- El pipeline de CI se ejecuta automáticamente en cada PR.

---

## 🏷️ 2. Estrategia de Tagging y Versionamiento

Se aplica **Semantic Versioning** con el formato `vMAJOR.MINOR.PATCH`:

| Versión | Significado |
|---|---|
| `v1.0.0` | Primera versión estable con deployment automatizado |
| `v1.1.0` | Nueva funcionalidad menor |
| `v1.1.1` | Corrección de bugs |

**Cuándo se crea un tag:**
```bash
git tag v1.0.0
git push origin v1.0.0
```

El tag dispara automáticamente el workflow `release.yml`, que empaqueta el código y publica el Release en GitHub.

**Relación:** 1 Tag = 1 Artifact (`.zip`) = 1 Release publicado en GitHub.

---

## ⚙️ 3. Pipeline de Integración Continua (CI)

Ubicado en `.github/workflows/pipeline.yml`. Se ejecuta en cada push a `main` o `feature/*` y en cada Pull Request.

**Etapas del pipeline:**

```
Checkout
   |
   v
Setup Python
   |
   v
Install Dependencies (pip install -r requirements.txt)
   |
   v
Unit Tests (pytest --html=reporte-pruebas.html)
   |
   v
Code Coverage (pytest-cov --cov-report=html)
   |
   v
Upload Artifacts (reportes HTML)
```

Si cualquier etapa falla, el pipeline se detiene y el Pull Request queda bloqueado.

---

## 📦 4. Generación del Artifact y Publicación de Releases

Ubicado en `.github/workflows/release.yml`. Se activa únicamente cuando se hace push de un tag `v*`.

**Flujo:**
1. Se hace `git tag v1.0.0` y `git push origin v1.0.0`.
2. GitHub Actions ejecuta `release.yml`.
3. Se empaqueta `app/` + `requirements.txt` en `release-python.zip`.
4. Se publica el Release oficial en GitHub con el artifact adjunto.

El artifact es inmutable: el mismo `.zip` que se prueba es el que se despliega.

---

## 🚀 5. Estrategia de Despliegue: Blue-Green Deployment

Se implementa **Blue-Green Deployment** para garantizar cero tiempo de inactividad durante los despliegues.

**Infraestructura:**
- **VM 1** (`192.168.1.170`): Servidor con Nginx como balanceador de carga.
- **VM 2** (`192.168.1.171`): Servidor de aplicación con dos instancias Flask.

**Flujo de despliegue:**

```
BLUE activo (:8080)
       |
       v
Deploy nueva version en GREEN (:8081)
       |
       v
Health Check de GREEN
       |
    [OK] --> GREEN activo | [FAIL] --> Rollback, BLUE sigue activo
```

**Scripts disponibles en `scripts/`:**

| Script | Función |
|---|---|
| `deploy-blue-green.sh` | Despliegue completo con cambio automático de entorno |
| `health-check.sh` | Verifica que la instancia responda HTTP 200 en `/health` |
| `traffic-test.sh` | Envía múltiples peticiones a Nginx para verificar el balanceo |

**Uso:**
```bash
# Desplegar nueva versión
bash scripts/deploy-blue-green.sh /ruta/al/release-python.zip

# Verificar una instancia específica
bash scripts/health-check.sh 8080

# Probar el balanceo de tráfico
bash scripts/traffic-test.sh http://192.168.1.170/api/instance 20
```

---

## 🌐 6. Endpoints de la Aplicación

| Endpoint | Método | Respuesta | Uso |
|---|---|---|---|
| `/` | GET | Texto de bienvenida con instancia y puerto | Verificación rápida |
| `/health` | GET | `{"status": "ok", "instance": "BLUE", "port": "8080"}` | Health Check automático |
| `/api/instance` | GET | `{"instance": "BLUE", "port": "8080"}` | Verificar balanceo de tráfico |

---

## 🔄 7. Procedimiento de Rollback

**Con Blue-Green Deployment el rollback es inmediato:**

1. Si el Health Check de la nueva versión falla durante el deployment, el script `deploy-blue-green.sh` detiene automáticamente el proceso y conserva el entorno anterior activo.
2. Si el fallo se detecta después de cambiar el tráfico, se reactiva manualmente el entorno anterior.

**El entorno anterior siempre se conserva intacto** hasta que la nueva versión sea completamente verificada.

---

## ✅ 8. Verificación del Deployment

Para verificar que el despliegue fue exitoso:

```bash
# 1. Health check directo
bash scripts/health-check.sh 8080
bash scripts/health-check.sh 8081

# 2. Probar el balanceo desde el navegador
# Abrir: http://192.168.1.170/api/instance
# Recargar la página varias veces y verificar que alterna entre BLUE y GREEN

# 3. Script de tráfico automatizado
bash scripts/traffic-test.sh http://192.168.1.170/api/instance 20
```