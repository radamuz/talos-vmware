#!/usr/bin/env bash

# Bloque govc
if ! command -v govc &> /dev/null; then
    echo "❌ No tienes instalada la herramienta 'govc'."
    echo
    echo "Instálala siguiendo la documentación de esta URL:"
    echo "https://github.com/vmware/govmomi/tree/main/govc#installation"
    echo
    echo "O mejor aún, instalala con este comando como usuario 'root':"
    echo 'curl -L -o - "https://github.com/vmware/govmomi/releases/latest/download/govc_$(uname -s)_$(uname -m).tar.gz" | tar -C /usr/local/bin -xvzf - govc'
    echo
else
    echo "✅ 'govc' está instalada en tu sistema."
    govc version 2>/dev/null
    echo
fi
echo
# Fin bloque govc

# Bloque talosctl
if ! command -v talosctl &> /dev/null; then
    echo "❌ No tienes instalada la herramienta 'talosctl'."
    echo "Para instalarla clica en el apartado 'taloctl' de la siguiente página web:"
    echo "https://docs.siderolabs.com/talos"
    echo
    echo "O mejor aún, instalala con este comando:"
    echo 'curl -sL https://talos.dev/install | sh'
    echo
else
    echo "✅ 'talosctl' está instalada en tu sistema."
    talosctl version 2>/dev/null
    echo
fi
echo
# Fin bloque talosctl