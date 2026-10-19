# Tarea previa — Aula invertida (Guía 4)

**Universidad Manuela Beltrán · Teoría de Bases de Datos · Guía de Laboratorio N.º 4**
**Sistema:** `Guia_3` (sistema académico de las Prácticas 1-3) · **SGBD:** MySQL 8

**Integrantes:** Juan Manuel Gámez Nieto · Esteban Salvador Guzmán · Joan Sebastián Romaña Tavera

**Fecha de entrega:** ____ / ____ / 2026 *(anterior a la sesión de laboratorio)*

---

## Punto 1 — Diferencia entre GRANT y REVOKE

| | `GRANT` | `REVOKE` |
|---|---|---|
| Qué hace | **Otorga** un privilegio a un usuario o rol | **Retira** un privilegio que ya se había otorgado |
| Efecto | Suma capacidades | Resta capacidades |
| Requisito | Quien lo ejecuta debe tener `GRANT OPTION` sobre ese privilegio | Igual |

**Ejemplo de GRANT** — el analista puede consultar estudiantes:

```sql
GRANT SELECT ON Guia_3.Estudiante TO 'analista'@'localhost';
```

**Ejemplo de REVOKE** — el analista deja de poder consultarlos:

```sql
REVOKE SELECT ON Guia_3.Estudiante FROM 'analista'@'localhost';
```

Los 5 ejemplos completos están en [`Scripts/07_GRANT_vs_REVOKE.sql`](Scripts/07_GRANT_vs_REVOKE.sql) y sus resultados en `Capturas/`.

---

## Punto 2 — ¿Cuáles son los 3 tipos de control de acceso a BD más comunes?

1. **Discrecional (DAC):** el dueño de un objeto decide quién lo usa y con qué privilegios. En SQL se aplica con `GRANT` y `REVOKE`.
2. **Mandatorio (MAC):** el sistema asigna niveles de clasificación a los datos (secreto, confidencial, público) y de autorización a los usuarios. Nadie puede cambiarlos a voluntad.
3. **Basado en roles (RBAC):** los privilegios se agrupan en roles según el cargo y cada usuario recibe un rol. Facilita administrar muchos usuarios.

*(Elmasri & Navathe, 2016, cap. 24) — 71 palabras.*

---

## Punto 3 — Diseño de roles del sistema `Guia_3`

### Perfiles

| Perfil | Rol MySQL | Usuario | Función | Puede | No puede |
|---|---|---|---|---|---|
| **Administrador** | `rol_admin` | `admin_bd` | DBA: administra el esquema y los permisos | Todo sobre `Guia_3`, incluido otorgar permisos | — |
| **Consultor** | `rol_consultor` | `analista` | Consulta datos y genera reportes | `SELECT` en las 6 tablas | Insertar, modificar, borrar; ver el log |
| **Operador** | `rol_operador` | `operador` | Registra y corrige datos del día a día | `SELECT`, `INSERT`, `UPDATE` en las 6 tablas | Borrar (`DELETE`); ver el log |
| **Auditor** | *(sin rol, privilegio directo)* | `auditor` | Revisa quién cambió qué y cuándo | `SELECT` en `auditoria_log` | Ver o tocar datos de negocio |

### Matriz de permisos por tabla

S = SELECT · I = INSERT · U = UPDATE · D = DELETE · G = puede delegar (GRANT OPTION) · — = sin acceso

| Tabla | Administrador | Consultor | Operador | Auditor |
|---|:-:|:-:|:-:|:-:|
| `Programa` | S I U D G | S | S I U | — |
| `Estudiante` | S I U D G | S | S I U | — |
| `Profesor` | S I U D G | S | S I U | — |
| `Materia` | S I U D G | S | S I U | — |
| `Grupo` | S I U D G | S | S I U | — |
| `Matricula` | S I U D G | S | S I U | — |
| `auditoria_log` | S I U D G | — | — | S |

### Criterios del diseño

- **Mínimo privilegio:** cada perfil tiene solo lo que su función necesita.
- **El operador no borra:** un error se corrige con `UPDATE`; un `DELETE` es irreversible.
- **El auditor no ve datos de negocio** y nadie más que él (y el DBA) lee el log.
- **Permisos tabla por tabla** para el consultor y el operador: un `Guia_3.*` incluiría `auditoria_log` sin querer.

---

## Firmas

| Integrante | Firma |
|---|---|
| Juan Manuel Gámez Nieto | ______________________________ |
| Esteban Salvador Guzmán | ______________________________ |
| Joan Sebastián Romaña Tavera | ______________________________ |

---

**Referencia:** Elmasri, R., & Navathe, S. B. (2016). *Fundamentals of database systems* (7th ed.). Pearson.
