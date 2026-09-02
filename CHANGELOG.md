# Changelog

Todas las modificaciones notables de este proyecto se documentan en este archivo.

## [1.0.0] - 2026-09-01
### Added
- Integración de API web con Flask (`app/api.py`).
- Endpoints de salud (`/health`) y telemetría de instancia (`/api/instance`).
- Scripts de automatización en `scripts/`:
  - `deploy-blue-green.sh` para despliegue Blue-Green con rollback automático.
  - `health-check.sh` para verificación de disponibilidad.
  - `traffic-test.sh` para pruebas de balanceo de carga.
- Pipeline de publicación automática de releases (`.github/workflows/release.yml`).
- Configuración documentada de balanceo con Nginx en `nginx/python-lb.conf`.
- Documentación completa del proceso CI/CD en `README.md`.

## [0.4.0] - 2026-08-26
### Added
- Separación de pasos de Pruebas Unitarias y Cobertura de Código en el pipeline CI.
- Generación de reportes independientes como artefactos HTML descargables.

## [0.3.0] - 2026-08-20
### Added
- Módulo de calculadora (`app/calculator.py`) con funciones sumar, restar, multiplicar, dividir.
- Pruebas unitarias con `pytest` (`tests/test_calculator.py`).
- Medición de cobertura con `pytest-cov`.
- Archivo `requirements.txt` con dependencias del proyecto.

## [0.2.0] - 2026-08-16
### Added
- Soporte para ramas `feature/**` y validación de Pull Requests en el pipeline.
- Reglas de protección de rama `main`.

## [0.1.0] - 2026-08-15
### Added
- Pipeline inicial de CI en GitHub Actions (`.github/workflows/pipeline.yml`).
- Estructura base del repositorio.
- Archivo `app/hello.txt` inicial.
