#!/bin/bash

MAC="ED:8F:01:20:44:69"
MAX_TRIES=10

conectar() {
    echo "[*] Intentando conectar…"
    for i in $(seq 1 "$MAX_TRIES"); do
        echo "   → intento $i"
        bluetoothctl connect "$MAC" >/dev/null 2>&1

        STATE=$(bluetoothctl info "$MAC" | grep Connected | awk '{print $2}')

        if [ "$STATE" = "yes" ]; then
            echo "[+] Conectado"
            return 0
        fi

        sleep 2
    done

    return 1
}

if ! conectar; then
    echo "[!] No se pudo conectar — ejecutando acciones"
    sudo nvme-close
    exit 1
fi

echo "[*] Monitoreando…"
STATE="yes"

while true; do
    NEW_STATE=$(bluetoothctl info "$MAC" | grep Connected | awk '{print $2}')

    if [ "$NEW_STATE" != "$STATE" ]; then
        if [ "$NEW_STATE" = "yes" ]; then
            echo "[+] Conectado de nuevo"
        else
            sudo nvme-close & echo "[!] Se desconectó — ejecutando acciones" &
            sudo nvme-close & sudo nvme-close
            sudo nvme-close
            exit 0
        fi

        STATE="$NEW_STATE"
    fi

    sleep 1
done
