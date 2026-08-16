# ci-cd-labs

Repositorio de laboratorios prácticos de **Integración Continua y Entrega Continua (CI/CD)**.

## Descripción

Este repositorio contiene los laboratorios del módulo de CI/CD. Cada laboratorio amplía el trabajo del anterior, construyendo progresivamente un pipeline más completo.

## Estructura del proyecto

```
ci-cd-labs/
│
├── README.md
├── .github/
│   └── workflows/
│       └── pipeline.yml     ← Pipeline de GitHub Actions
└── app/
    └── hello.txt            ← Archivo de ejemplo
```

## Laboratorios

| # | Tema |
|---|------|
| Lab 1 | Primer Pipeline de Integración Continua |
| Lab 2 | Branching, Pull Requests y Ejecución de CI |
| Lab 3 | Integración de Pruebas Automatizadas al Pipeline |

## Plataforma utilizada

GitHub Actions

## Estado del pipeline

![CI](https://github.com/TU_USUARIO/ci-cd-labs/actions/workflows/pipeline.yml/badge.svg)
 
## Laboratorio 2

### Branching y Pull Requests

En este laboratorio se implementó una estrategia de branching basada en ramas de funcionalidad.

#### Reglas del flujo de trabajo

- La rama `main` representa la versión estable del proyecto.
- Todo cambio se desarrolla en una rama `feature/` independiente.
- Los cambios se integran únicamente mediante Pull Request.
- El pipeline de CI valida cada cambio antes del merge.

#### Flujo implementado

```text
Developer → Feature Branch → Commit → Push → CI Pipeline → Pull Request → Review → Merge → main