#!/usr/bin/env python3
# Actividad 3 · DESPUÉS: las mismas 2 consultas con PREPARED STATEMENTS.
# La consulta lleva %s y el dato viaja aparte: el motor nunca lo ejecuta como SQL.
# Requiere: pip install mysql-connector-python
import getpass
import sys
import mysql.connector

# Segunda defensa: solo se aceptan documentos de 6 a 10 dígitos
def documento_valido(valor):
    return valor.isdigit() and 6 <= len(valor) <= 10

def main():
    print("=" * 70)
    print(" ACTIVIDAD 3: CONSULTAS SEGURAS MEDIANTE PREPARED STATEMENTS (DESPUÉS)")
    print("=" * 70)

    db_user = input("Usuario MariaDB/MySQL [root]: ").strip() or "root"
    db_password = getpass.getpass("Contraseña: ")

    config = {
        "host": "localhost",
        "user": db_user,
        "password": db_password,
        "database": "Guia_4",
        "autocommit": True
    }

    try:
        conn = mysql.connector.connect(**config)
        # prepared=True: el servidor compila la plantilla primero y recibe los datos después
        cursor = conn.cursor(prepared=True, dictionary=True)
        print("\n[+] Conexión establecida con la base de datos 'Guia_4'.\n")

        # Caso 1: el mismo ataque ' OR '1'='1 ya no expone la tabla
        print("-" * 70)
        print("CASO 1: BÚSQUEDA DE ESTUDIANTE (PARAMETRIZADA)")
        print("-" * 70)

        payload_1 = "1031422990' OR '1'='1"

        query_segura_1 = "SELECT IdEstudiante, PrimerNombre, PrimerApellido FROM Estudiante WHERE IdEstudiante = %s"
        print(f"Plantilla precompilada: {query_segura_1}")
        print(f"Parámetro transmitido: ({payload_1},)\n")

        cursor.execute(query_segura_1, (payload_1,))
        res_1 = cursor.fetchall()
        print(f"Filas devueltas: {len(res_1)}")
        for r in res_1:
            print(f"  * {r}")
        if len(res_1) <= 1:
            print("-> PROTEGIDO: El OR '1'='1' no se ejecutó como SQL; no se expuso la tabla completa.")
            print("   (Si aparece 1 fila es porque MySQL convierte la cadena a INT tomando sus dígitos")
            print("   iniciales: 1031422990. Por eso se añade la validación de entrada del final.)\n")

        # Caso 2: el "--" ya no comenta nada; el AND IdMatricula se mantiene
        print("-" * 70)
        print("CASO 2: FILTRO COMPUESTO EN MATRÍCULA (PARAMETRIZADA)")
        print("-" * 70)

        payload_estudiante = "1031422990 OR 1=1 -- "
        param_matricula = 9999

        query_segura_2 = "SELECT IdMatricula, IdEstudiante, ValorMatricula FROM Matricula WHERE IdEstudiante = %s AND IdMatricula = %s"
        print(f"Plantilla precompilada: {query_segura_2}")
        print(f"Parámetros transmitidos: ({payload_estudiante}, {param_matricula})\n")

        cursor.execute(query_segura_2, (payload_estudiante, param_matricula))
        res_2 = cursor.fetchall()
        print(f"Filas devueltas: {len(res_2)}")
        if not res_2:
            print("-> PROTEGIDO: El motor mantuvo la lógica del operador AND y evaluó la entrada como dato puro.\n")

        # Validación de entrada: los payloads se rechazan antes de llegar a la BD
        print("-" * 70)
        print("VALIDACIÓN DE ENTRADA (LISTA BLANCA: SOLO DÍGITOS, 6 A 10)")
        print("-" * 70)

        for entrada in (payload_1, payload_estudiante, "1031422990"):
            if documento_valido(entrada):
                cursor.execute(query_segura_1, (int(entrada),))
                print(f"ACEPTADA  {entrada!r:<28} -> filas: {len(cursor.fetchall())}")
            else:
                print(f"RECHAZADA {entrada!r:<28} -> no llega a la base de datos")
        print()

        cursor.close()
        conn.close()

    except mysql.connector.Error as err:
        print(f"\n[!] Error de base de datos: {err}", file=sys.stderr)

if __name__ == "__main__":
    main()
