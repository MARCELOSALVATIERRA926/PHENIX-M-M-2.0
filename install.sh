#!/bin/bash
# ==============================================
#            PHENIX-M&M 2.0 - INSTALADOR
# ==============================================

REPO="https://raw.githubusercontent.com/MARCELOSALVATIERRA926/PHENIX-M-M-2.0/main"
PHENIX="/etc/PHENIX-M&M"
SCPinstal="$HOME/install"

# ==============================================
# PRESENTACION SIMPLE Y SEGURA
# ==============================================
clear
echo "====================================================="
echo "             PHENIX - M & M   2.0"
echo "====================================================="
echo "        SISTEMA DE INSTALACION VPS"
echo "====================================================="
echo "  Ingrese la clave de activacion para continuar"
echo "====================================================="
sleep 2

# ==============================================
# VALIDACION DE LICENCIA
# ==============================================
validar_licencia(){
  IP_VPS=$(hostname -I | awk '{print $1}')
  HORA_ACTUAL=$(date +%s)

  echo "  IP DETECTADA: $IP_VPS"
  echo "====================================================="
  read -p "  CLAVE: " CLAVE
  echo ""

  if [[ ! "$CLAVE" =~ ^PHENIX-[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+-[0-9]+$ ]]; then
    echo "  ERROR: FORMATO DE CLAVE INCORRECTO"
    sleep 2
    exit 1
  fi

  CLAVE_IP=$(echo "$CLAVE" | cut -d'-' -f2)
  CLAVE_VENC=$(echo "$CLAVE" | cut -d'-' -f3)

  if [[ "$CLAVE_IP" != "$IP_VPS" ]]; then
    echo "  ERROR: CLAVE NO CORRESPONDE A ESTA VPS"
    sleep 3
    exit 1
  fi

  if [[ "$HORA_ACTUAL" -gt "$CLAVE_VENC" ]]; then
    echo "  ERROR: CLAVE VENCIDA"
    sleep 2
    exit 1
  fi

  echo "$CLAVE" > ${PHENIX}/tmp/licencia.valida
  echo "  OK: LICENCIA VALIDA - INSTALANDO..."
  sleep 2
}

# ==============================================
# AVISO A TU WHATSAPP
# ==============================================
avisar_whatsapp(){
  IP=$(hostname -I | awk '{print $1}')
  LIC=$(cat ${PHENIX}/tmp/licencia.valida)
  MENSAJE="INSTALADO PHENIX-M&M 2.0%0AIP: $IP%0ACLAVE: $LIC"
  wget -q -O /dev/null "https://api.whatsapp.com/send?phone=5493815246197&text=$MENSAJE" &>/dev/null
}

# ==============================================
# CARGA Y PERMISOS
# ==============================================
mkdir -p ${PHENIX}/{install,bin,sbin,tmp}
chmod -R 755 ${PHENIX}

validar_licencia

# ==============================================
# INSTALACION DE SISTEMA
# ==============================================
apt update -y &>/dev/null
apt install -y sudo bsdmainutils zip unzip ufw curl python3 python3-pip openssl screen cron iptables lsof nano gawk grep bc jq socat net-tools dropbear &>/dev/null

mkdir -p ${SCPinstal}
archivos="menu userSSH dropBear cmd mine_port"
for arq in $archivos; do
  wget -q -O ${SCPinstal}/${arq} ${REPO}/${arq}
  mv -f ${SCPinstal}/${arq} ${PHENIX}/
  chmod +x ${PHENIX}/${arq}
done

ln -sf ${PHENIX}/menu /usr/bin/menu
ln -sf ${PHENIX}/dropBear /usr/bin/dropBear
echo "source ${PHENIX}/module" >> /root/.bashrc
echo "PHENIX-M&M 2.0" > ${PHENIX}/tmp/marca.txt

# ==============================================
# FIN
# ==============================================
avisar_whatsapp
rm -rf ${SCPinstal}
clear
echo "====================================================="
echo "            INSTALACION TERMINADA"
echo "====================================================="
echo "  ESCRIBA: menu"
echo "====================================================="
