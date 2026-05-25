#!/bin/bash


# ============================================================
# USO:
#   ./screenshot.sh region    -> Captura una región
#   ./screenshot.sh focused   -> Captura el monitor enfocado
#   ./screenshot.sh           -> Captura todos los monitores
#
# Las capturas se guardan en ~/Pictures/Screenshots/
# DEPENDENCIAS NECESARIAS:
#   - slurp       (seleccionar región)
#   - grim        (capturar pantalla)
#   - jq          (procesar JSON de hyprctl)
# sudo pacman -S slurp grim jq
# ============================================================

PICTURES_DIR=$(xdg-user-dir PICTURES 2>/dev/null)
[ -z "$PICTURES_DIR" ] && PICTURES_DIR="$HOME/Pictures"

BASE_DIR="$PICTURES_DIR/Screenshots"
mkdir -p "$BASE_DIR"

TIMESTAMP=$(date +"%d-%m-%Y_%H-%M-%S")

MODE="$1"

# ---------------------------------
# MODO REGIÓN
# ---------------------------------
if [ "$MODE" = "region" ]; then
    DIR="$BASE_DIR/Region"
    mkdir -p "$DIR"

    GEOM=$(slurp)

    if [ -n "$GEOM" ]; then
        FILE="$DIR/$TIMESTAMP.png"

        grim -g "$GEOM" "$FILE"

       (
            ACTION=$(notify-send \
                -A "open=Abrir" \
                --hint=string:image-path:"$FILE" \
                "Captura de región" \
                "$(basename "$FILE")")

            if [ "$ACTION" = "open" ]; then
                thunar "$FILE"
            fi
        ) &
    else
        notify-send "Captura de región" "No se detectó región seleccionada"
    fi
    exit 0
fi

# ---------------------------------
# MODO MONITOR ENFOCADO
# ---------------------------------
if [ "$MODE" = "focused" ]; then
    MON=$(hyprctl monitors -j | jq -r '.[] | select(.focused==true) | .name')

    if [ -n "$MON" ]; then
        DIR="$BASE_DIR/$MON"
        mkdir -p "$DIR"

        FILE="$DIR/$TIMESTAMP.png"

        grim -o "$MON" "$FILE"

        (
            ACTION=$(notify-send \
                -A "open=Abrir" \
                --hint=string:image-path:"$FILE" \
                "Captura monitor enfocado" \
                "$MON")

            if [ "$ACTION" = "open" ]; then
                thunar "$FILE"
            fi
        ) &
    else
        notify-send "Error" "No se detectó monitor enfocado"
    fi

    exit 0
fi

# ---------------------------------
# MODO TODOS LOS MONITORES
# ---------------------------------

COUNT=0
FILES=()

MONITORS=$(hyprctl monitors -j | jq -r '.[].name')

for MON in $MONITORS; do
    DIR="$BASE_DIR/$MON"
    mkdir -p "$DIR"

    FILE="$DIR/$TIMESTAMP.png"
    grim -o "$MON" "$FILE"

    FILES+=("$FILE")
    LAST_FILE="$FILE"
    COUNT=$((COUNT+1))
done

if [ "$COUNT" -gt 0 ]; then
    (
        ACTION=$(notify-send \
            -A "open=Abrir" \
            --hint=string:image-path:"$LAST_FILE" \
            "Captura realizada" \
            "$COUNT monitor(es)")

        if [ "$ACTION" = "open" ]; then
            thunar "${FILES[@]}"
        fi
    ) &
else
    notify-send "Error" "No se detectaron monitores"
fi