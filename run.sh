#!/usr/bin/env bash

# Bloque inicio del script
INITIAL_SCRIPT_TIMESTAMP=$(date '+%Y%m%d_%H%M%S')
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
echo | tee -a $INITIAL_SCRIPT_TIMESTAMP.log
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
echo | tee -a $INITIAL_SCRIPT_TIMESTAMP.log
# Fin bloque talosctl

# Bloque comprobación de archivos
echo "Comprobación de archivos." | tee -a $INITIAL_SCRIPT_TIMESTAMP.log
if [ -e controlplane.yaml ] || [ -e cp.patch.yaml ] || [ -e talosconfig ] || [ -e worker.yaml ]; then 
    echo "Alguno de los archivos de configuración de despliegue existe." | tee -a $INITIAL_SCRIPT_TIMESTAMP.log
    echo "Por su seguridad se va a hacer una copia de seguridad empaquetada en este mismo directorio." | tee -a $INITIAL_SCRIPT_TIMESTAMP.log
    echo "¿Quiere continuar? [S/n]" | tee -a $INITIAL_SCRIPT_TIMESTAMP.log
    read -r FILE_VERIFICATION_CONTINUATION_CHECK
    echo "FILE_VERIFICATION_CONTINUATION_CHECK: $FILE_VERIFICATION_CONTINUATION_CHECK" | tee -a $INITIAL_SCRIPT_TIMESTAMP.log
    FILE_VERIFICATION_CONTINUATION_CHECK="${FILE_VERIFICATION_CONTINUATION_CHECK,,}"
    if [[ -z "$FILE_VERIFICATION_CONTINUATION_CHECK" || "$FILE_VERIFICATION_CONTINUATION_CHECK" == "s" || "$FILE_VERIFICATION_CONTINUATION_CHECK" == "si" ]]; then
        echo "Continuando con el empaquetado mediante tar..." | tee -a $INITIAL_SCRIPT_TIMESTAMP.log
        tar -czvf $INITIAL_SCRIPT_TIMESTAMP.tar.gz --ignore-failed-read controlplane.yaml cp.patch.yaml talosconfig worker.yaml | tee -a $INITIAL_SCRIPT_TIMESTAMP.log
        if [[ $? -eq 0 && -f "${INITIAL_SCRIPT_TIMESTAMP}.tar.gz" ]]; then
            echo "Paquete creado correctamente. Continuando..." | tee -a $INITIAL_SCRIPT_TIMESTAMP.log
            rm -f controlplane.yaml cp.patch.yaml talosconfig worker.yaml
        else
            echo "❌ Error: el comando falló o no se generó el archivo ${INITIAL_SCRIPT_TIMESTAMP}.tar.gz" | tee -a $INITIAL_SCRIPT_TIMESTAMP.log
            exit 1
        fi
    else
        echo "Ha seleccionado que no quiere continuar. Por lo tanto tendrá que borrar sus ficheros controlplane.yaml, cp.patch.yaml, talosconfig y worker.yaml de forma manual y volver a lanzar el script para poder realizar el despliegue de forma correcta." | tee -a $INITIAL_SCRIPT_TIMESTAMP.log
        exit 1
    fi
else
    echo "Comprobación realizada con éxito." | tee -a $INITIAL_SCRIPT_TIMESTAMP.log
fi
echo "Fin de comprobación de archivos." | tee -a $INITIAL_SCRIPT_TIMESTAMP.log
echo | tee -a $INITIAL_SCRIPT_TIMESTAMP.log
# Fin Bloque comprobación de archivos


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
echo | tee -a $INITIAL_SCRIPT_TIMESTAMP.log
# Fin de Bloque de generación de config

# Validar configuraciones
echo "Validación de configuración de Control Plane." | tee -a $INITIAL_SCRIPT_TIMESTAMP.log
talosctl validate --config controlplane.yaml --mode cloud | tee -a $INITIAL_SCRIPT_TIMESTAMP.log
echo "Fin de validación de configuraciones." | tee -a $INITIAL_SCRIPT_TIMESTAMP.log
echo "Validación de configuración de Worker." | tee -a $INITIAL_SCRIPT_TIMESTAMP.log
talosctl validate --config worker.yaml --mode cloud | tee -a $INITIAL_SCRIPT_TIMESTAMP.log
echo "Fin de validación de configuraciones." | tee -a $INITIAL_SCRIPT_TIMESTAMP.log
# Fin validar configuraciones