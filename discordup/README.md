
# Actualizador automático de Discord para Linux (.deb)

Automatiza la tarea de instalación de Discord actualizada en sistemas Linux que usan paquetes `.deb`.

---

1. Consulta el servidor oficial de Discord para saber cuál es la última versión disponible del paquete `.deb`.
2. Comprueba la versión actualmente instalada localmente (buscando el archivo `build_info.json` en la ruta típica `/usr/share/discord/resources/`).
3. Si la versión instalada es más antigua, descarga el instalador `.deb` más reciente como archivo temporal.
4. Instala la nueva versión usando `dpkg`.

---

* Se puede automatizar con `cron` o `systemd` o otras cosas.

---

## Cómo usarlo

3. Ejecútalo:

```bash
./discordup
```

## Advertencias

* El script asume que Discord está instalado en `/usr/share/discord/`. Si está en otro lugar, modifica la variable `BUILD_INFO` en el script.
