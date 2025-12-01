#!/usr/bin/env bash

# Bloque inicio del script
INITIAL_SCRIPT_TIMESTAMP=$(date '+%Y-%m-%d_%H:%M:%S')
echo "$INITIAL_SCRIPT_TIMESTAMP - Inicio del script" | tee -a $INITIAL_SCRIPT_TIMESTAMP.log
echo | tee -a $INITIAL_SCRIPT_TIMESTAMP.log
# Fin bloque inicio del script

# Bloque informativo
echo "Este script está desarrollado en base a la siguiente documentación: https://docs.siderolabs.com/talos/v1.11/platform-specific-installations/virtualized-platforms/vmware" | tee -a $INITIAL_SCRIPT_TIMESTAMP.log
echo | tee -a $INITIAL_SCRIPT_TIMESTAMP.log
# Fin bloque informativo

# Bloque govc
if ! command -v govc &> /dev/null; then
    echo "❌ No tienes instalada la herramienta 'govc'." | tee -a $INITIAL_SCRIPT_TIMESTAMP.log
    echo | tee -a $INITIAL_SCRIPT_TIMESTAMP.log
    echo "Instálala siguiendo la documentación de esta URL:" | tee -a $INITIAL_SCRIPT_TIMESTAMP.log
    echo "https://github.com/vmware/govmomi/tree/main/govc#installation" | tee -a $INITIAL_SCRIPT_TIMESTAMP.log
    echo | tee -a $INITIAL_SCRIPT_TIMESTAMP.log
    echo "O mejor aún, instalala con este comando como usuario 'root':" | tee -a $INITIAL_SCRIPT_TIMESTAMP.log
    echo 'curl -L -o - "https://github.com/vmware/govmomi/releases/latest/download/govc_$(uname -s)_$(uname -m).tar.gz" | tar -C /usr/local/bin -xvzf - govc' | tee -a $INITIAL_SCRIPT_TIMESTAMP.log
    echo | tee -a $INITIAL_SCRIPT_TIMESTAMP.log
else
    echo "✅ 'govc' está instalada en tu sistema." | tee -a $INITIAL_SCRIPT_TIMESTAMP.log
    govc version 2>/dev/null | tee -a $INITIAL_SCRIPT_TIMESTAMP.log
    echo | tee -a $INITIAL_SCRIPT_TIMESTAMP.log
fi
echo
# Fin bloque govc

# Bloque talosctl
if ! command -v talosctl &> /dev/null; then
    echo "❌ No tienes instalada la herramienta 'talosctl'." | tee -a $INITIAL_SCRIPT_TIMESTAMP.log
    echo "Para instalarla clica en el apartado 'taloctl' de la siguiente página web:" | tee -a $INITIAL_SCRIPT_TIMESTAMP.log
    echo "https://docs.siderolabs.com/talos" | tee -a $INITIAL_SCRIPT_TIMESTAMP.log
    echo | tee -a $INITIAL_SCRIPT_TIMESTAMP.log
    echo "O mejor aún, instalala con este comando:" | tee -a $INITIAL_SCRIPT_TIMESTAMP.log
    echo 'curl -sL https://talos.dev/install | sh' | tee -a $INITIAL_SCRIPT_TIMESTAMP.log
    echo | tee -a $INITIAL_SCRIPT_TIMESTAMP.log
else
    echo "✅ 'talosctl' está instalada en tu sistema." | tee -a $INITIAL_SCRIPT_TIMESTAMP.log
    talosctl version 2>/dev/null | tee -a $INITIAL_SCRIPT_TIMESTAMP.log
    echo | tee -a $INITIAL_SCRIPT_TIMESTAMP.log
fi
echo
# Fin bloque talosctl

# Bloque cp.patch.yaml
echo -n "Introduce la VIP (Virtual IP) fija que quieres usar y que se le asignará a un nodo con rol \"Control Plane\" como por ejemplo 10.12.4.31: " | tee -a $INITIAL_SCRIPT_TIMESTAMP.log
read VIP
echo "VIP: $VIP" | tee -a $INITIAL_SCRIPT_TIMESTAMP.log
cat > cp.patch.yaml <<EOF
- op: add
  path: /machine/network
  value:
    interfaces:
      - interface: eth0
        dhcp: true
        vip:
          ip: $VIP
EOF
echo | tee -a $INITIAL_SCRIPT_TIMESTAMP.log
echo "Archivo cp.patch.yaml generado correctamente." | tee -a $INITIAL_SCRIPT_TIMESTAMP.log
echo | tee -a $INITIAL_SCRIPT_TIMESTAMP.log
# Fin bloque cp.patch.yaml

# Bloque de nombre
echo -n "Introduce como quieres llamar al cluster, ejemplo \"mi-cluster\": " | tee -a $INITIAL_SCRIPT_TIMESTAMP.log
read CLUSTER_NAME
echo "CLUSTER_NAME: $CLUSTER_NAME" | tee -a $INITIAL_SCRIPT_TIMESTAMP.log
echo | tee -a $INITIAL_SCRIPT_TIMESTAMP.log
# Fin de bloque de nombre

# Bloque de generación de config
echo "Generación de configuración de Talos." | tee -a $INITIAL_SCRIPT_TIMESTAMP.log
talosctl gen config $CLUSTER_NAME https://$VIP:6443 --config-patch-control-plane @cp.patch.yaml | tee -a $INITIAL_SCRIPT_TIMESTAMP.log
echo "Fin de generación de configuración de Talos." | tee -a $INITIAL_SCRIPT_TIMESTAMP.log
# Fin de Bloque de generación de config

