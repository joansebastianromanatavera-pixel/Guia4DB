# Práctica 4 — Seguridad en Bases de Datos

**UMB · Teoría de Bases de Datos · Guía N.º 4** — Usuarios · Privilegios · Roles · Auditoría
**Sistema:** `Guia_4` (sistema académico de las Prácticas 1-3) · **SGBD:** MySQL 8

---

## Cómo ejecutar

### Orden de ejecución (igual en Windows y Linux)

| # | Script | Ejecutar como | Qué hace |
|:-:|---|---|---|
| 01 | `00_Preparacion/Scripts/01_Tablas.sql` | root | Crea `Guia_4` y sus 6 tablas |
| 02 | `00_Preparacion/Scripts/02_Datos.sql` | root | Carga los datos de prueba |
| 03 | `02_Actividad1_Usuarios_Privilegios/Scripts/03_Usuarios_Privilegios.sql` | root | 4 usuarios con privilegios directos + tabla `auditoria_log` |
| 04 | `02_Actividad1_Usuarios_Privilegios/Scripts/04_Pruebas_Acceso.sql` | cada usuario, por bloques | Qué puede y qué no puede hacer cada uno |
| 05 | `03_Actividad2_Roles/Scripts/05_Roles_Corporativos.sql` | root | 3 roles, asignados a los usuarios |
| 06 | `03_Actividad2_Roles/Scripts/06_Pruebas_Acceso.sql` | cada usuario, por bloques | Pruebas con permisos heredados por rol |
| 07 | `01_Tarea_Previa/Scripts/07_GRANT_vs_REVOKE.sql` | root | 5 ejemplos de GRANT/REVOKE (usa los usuarios y roles anteriores) |
| 08 | `05_Actividad4_Auditoria/Scripts/08_Triggers_Auditoria.sql` | root | Triggers AFTER UPDATE y AFTER DELETE en `Estudiante` |
| 09 | `05_Actividad4_Auditoria/Scripts/09_Pruebas_Log.sql` | Parte A root · Parte B por bloques | Cambios simulados y lectura del log |
| — | `04_Actividad3_Inyeccion_SQL/Scripts/1_Vulnerable_ANTES.py` y `2_Segura_DESPUES.py` | Python 3 | Inyección SQL antes y después |
| 10 | `06_Actividad5_Informe/Scripts/10_Mapa_Seguridad.sql` | root | Mapa de seguridad (solo consultas) |

> **Por bloques:** abrir una sesión con el usuario que indica cada bloque ("Conectado como analista", etc.) y ejecutar solo esas líneas. Las marcadas `ERROR 1142` deben fallar; eso demuestra el permiso negado.
>
> **Contraseñas de laboratorio:** `AdminBD_2026!` · `Analista_2026!` · `Operador_2026!` · `Auditor_2026!`

### Windows

**Opción A — MySQL Workbench (recomendada para las capturas)**

1. Abrir la conexión de root y cargar cada script con *File → Open SQL Script*.
2. Script completo: ⚡ o `Ctrl+Shift+Enter`.
3. Bloques de prueba: crear una conexión por usuario (Hostname `127.0.0.1`, Port `3306`, Username `analista`, etc.) y ejecutar línea por línea con `Ctrl+Enter`.

**Opción B — PowerShell**

```powershell
cd <ruta>\Guia_4
& "C:\Program Files\MySQL\MySQL Server 8.4\bin\mysql.exe" -u root -p --default-character-set=utf8mb4
```

Dentro de `mysql>`:

```sql
source 00_Preparacion/Scripts/01_Tablas.sql
source 00_Preparacion/Scripts/02_Datos.sql
source 02_Actividad1_Usuarios_Privilegios/Scripts/03_Usuarios_Privilegios.sql
-- ... y así con los demás, en el orden de la tabla
```

Para las pruebas de un usuario, abrir otra terminal con `-u analista -p Guia_4` en lugar de `-u root -p`. Se usa `source` porque PowerShell no acepta `< archivo.sql`.

**Python (Actividad 3)**

```powershell
py -m pip install mysql-connector-python
py 04_Actividad3_Inyeccion_SQL\Scripts\1_Vulnerable_ANTES.py
py 04_Actividad3_Inyeccion_SQL\Scripts\2_Segura_DESPUES.py
```

Cada script pide usuario (Enter = root) y la contraseña de root.

### Linux (CachyOS / Arch)

Los repositorios de Arch traen **MariaDB**, no MySQL, y en MariaDB fallan los scripts 05, 06, 07 y 10 (otra sintaxis de roles, sin `SHOW GRANTS ... USING` ni `mysql.role_edges`). Por eso se usa **MySQL 8.4 en Docker**, el mismo motor de Windows.

**1. Instalar Docker y levantar MySQL**

```bash
sudo pacman -S --needed docker python
sudo systemctl enable --now docker

cd ~/ruta/a/Guia_4
sudo docker run -d --name mysql-guia4 -e MYSQL_ROOT_PASSWORD='Root_2026!' -p 3306:3306 -v "$PWD":/guia4:ro mysql:8.4

sudo docker logs -f mysql-guia4    # esperar "ready for connections" y salir con Ctrl+C
```

**2. Ejecutar los scripts**

```bash
sudo docker exec -it mysql-guia4 mysql -uroot -p --default-character-set=utf8mb4
```

```sql
source /guia4/00_Preparacion/Scripts/01_Tablas.sql
source /guia4/00_Preparacion/Scripts/02_Datos.sql
source /guia4/02_Actividad1_Usuarios_Privilegios/Scripts/03_Usuarios_Privilegios.sql
-- ... y así con los demás, en el orden de la tabla
```

Pruebas de un usuario, en otra terminal:

```bash
sudo docker exec -it mysql-guia4 mysql -u analista -p Guia_4
```

> Entrar **siempre con `docker exec`**: los usuarios son `@'localhost'` y, desde fuera del contenedor (DBeaver, etc.), MySQL los ve llegar desde la red de Docker y no los deja entrar. Root sí funciona desde fuera.

**3. Python (Actividad 3)** — Arch no permite `pip` en el Python del sistema; se usa un entorno virtual:

```bash
python -m venv .venv
source .venv/bin/activate.fish      # fish (shell por defecto de CachyOS); en bash/zsh: source .venv/bin/activate
pip install mysql-connector-python
python 04_Actividad3_Inyeccion_SQL/Scripts/1_Vulnerable_ANTES.py
python 04_Actividad3_Inyeccion_SQL/Scripts/2_Segura_DESPUES.py
```

Usuario `root`, contraseña `Root_2026!`.

**Apagar o borrar el contenedor**

```bash
sudo docker stop mysql-guia4      # volver a usarlo: sudo docker start mysql-guia4
sudo docker rm -f mysql-guia4     # borrarlo por completo
```

### Empezar de cero (cualquier sistema, como root)

```sql
DROP DATABASE IF EXISTS Guia_4;
DROP USER IF EXISTS admin_bd@localhost, analista@localhost, operador@localhost, auditor@localhost;
DROP ROLE IF EXISTS rol_admin, rol_consultor, rol_operador;
```

---

## Estructura

Cada carpeta es una parte de la guía y tiene sus `Scripts/` y sus `Capturas/`.
Los scripts están numerados **en el orden en que se ejecutan** (01 → 10).

```
Guia_4/
├── README.md
├── 00_Preparacion/
│   └── Scripts/   01_Tablas.sql · 02_Datos.sql
├── 01_Tarea_Previa/
│   ├── Tarea_Previa.md            <- puntos 1, 2 y 3 (para imprimir y firmar)
│   ├── Scripts/   07_GRANT_vs_REVOKE.sql
│   └── Capturas/  TareaPrevia-01 … 22
├── 02_Actividad1_Usuarios_Privilegios/
│   ├── Scripts/   03_Usuarios_Privilegios.sql · 04_Pruebas_Acceso.sql
│   └── Capturas/  Actividad1-01 … 28
├── 03_Actividad2_Roles/
│   ├── Scripts/   05_Roles_Corporativos.sql · 06_Pruebas_Acceso.sql
│   └── Capturas/  Actividad2-01 … 49
├── 04_Actividad3_Inyeccion_SQL/
│   ├── Explicacion.txt
│   ├── Scripts/   1_Vulnerable_ANTES.py · 2_Segura_DESPUES.py
│   └── Capturas/  (pendiente)
├── 05_Actividad4_Auditoria/
│   ├── Scripts/   08_Triggers_Auditoria.sql · 09_Pruebas_Log.sql
│   └── Capturas/  Actividad4-01 … 02
└── 06_Actividad5_Informe/
    ├── Informe_Seguridad.md
    ├── Practica4_Informe_Seguridad.pdf
    ├── Scripts/   10_Mapa_Seguridad.sql
    └── Capturas/  (pendiente)
```

## Resumen por actividad

### Tarea previa
GRANT otorga un privilegio y REVOKE lo retira (5 ejemplos). Respuesta DAC / MAC / RBAC y diseño de los 4 perfiles en [`Tarea_Previa.md`](01_Tarea_Previa/Tarea_Previa.md).

### Actividad 1 — Usuarios y privilegios directos

| Usuario | SELECT | INSERT | UPDATE | DELETE | Lee `auditoria_log` | GRANT OPTION |
|---|:-:|:-:|:-:|:-:|:-:|:-:|
| `admin_bd` | ✔ | ✔ | ✔ | ✔ | ✔ | ✔ |
| `analista` | ✔ | ✘ | ✘ | ✘ | ✘ | ✘ |
| `operador` | ✔ | ✔ | ✔ | ✘ | ✘ | ✘ |
| `auditor`  | ✘ | ✘ | ✘ | ✘ | ✔ | ✘ |

### Actividad 2 — Roles corporativos

```
admin_bd ──▶ rol_admin ─────▶ ALL PRIVILEGES ON Guia_4.* WITH GRANT OPTION
analista ──▶ rol_consultor ─▶ SELECT en las 6 tablas
operador ──▶ rol_operador ──▶ SELECT, INSERT, UPDATE en las 6 tablas
auditor  ┄┄▶ (directo, sin rol) ┄┄▶ SELECT en auditoria_log
```

- **Directo:** `SHOW GRANTS` muestra el privilegio. **Heredado:** solo muestra el rol; con `USING 'rol'` se ven los permisos reales.
- Un `REVOKE` sobre un rol afecta a todos sus usuarios a la vez.

### Actividad 3 — Inyección SQL
Dos consultas vulnerables (`' OR '1'='1` y `OR 1=1 --`) reescritas con prepared statements y validación de entrada. Ver [`Explicacion.txt`](04_Actividad3_Inyeccion_SQL/Explicacion.txt).

| | Caso 1 | Caso 2 |
|---|:-:|:-:|
| ANTES (vulnerable) | 5 filas (toda la tabla) | 13 filas (todas las matrículas) |
| DESPUÉS (seguro) | 1 fila como máximo | 0 filas |

### Actividad 4 — Trigger de auditoría
`auditoria_log(id, tabla, operacion, usuario, fecha, dato_anterior)`. Los triggers guardan **quién** (`USER()`), **cuándo** (`NOW()`) y **la fila anterior** en JSON.

### Actividad 5 — Informe de seguridad
Mapa de usuarios, roles, privilegios y auditoría, 11 hallazgos de riesgo y 19 recomendaciones para producción: [`Informe_Seguridad.md`](06_Actividad5_Informe/Informe_Seguridad.md).

---

## Verificación

Todos los scripts se ejecutaron de punta a punta sobre MySQL 8.4 sin errores, y todas las pruebas de acceso dieron el resultado esperado.

## Pendiente

| Qué | Dónde |
|---|---|
| Imprimir, firmar y fechar `Tarea_Previa.md` (fecha anterior a la sesión) | `01_Tarea_Previa/` |
| Capturas de la salida de los 2 scripts Python | `04_Actividad3_Inyeccion_SQL/Capturas/` |
| Rehacer capturas en `Guia_3` (las actuales son de `Guia_4` y solo muestran `root`), con cambios de `operador` y `admin_bd` | `05_Actividad4_Auditoria/Capturas/` |
| Figuras 5.1 a 5.9 (un bloque del script 10 por figura) | `06_Actividad5_Informe/Capturas/` |
| Informe final `Practica4_NombreEquipo.pdf` con la estructura de la guía | Moodle |

> **Contraseñas:** están en texto plano solo para el laboratorio (`AdminBD_2026!`, `Analista_2026!`, `Operador_2026!`, `Auditor_2026!`). En producción se usaría `IDENTIFIED BY RANDOM PASSWORD` (hallazgo H1 del informe).
