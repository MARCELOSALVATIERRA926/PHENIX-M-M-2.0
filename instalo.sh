#!/bin/bash
# ==============================================
#                PHENIX-M&M 2.0
#           INSTALADOR OFICIAL VPS
# ==============================================

REPO="https://raw.githubusercontent.com/MARCELOSALVATIERRA926/PHENIX-M-M-2.0/main"
PHENIX="/etc/PHENIX-M&M"
SCPinstal="$HOME/install"

# ==============================================
# PANTALLA DE BIENVENIDA
# ==============================================
clear
echo -e "\033[1;35m
 ____  _   _ ______ __   __ __  __ _   _ 
|  _ \| | | |  ____|  \ /  |  \/  | \ | |
| |_) | | | | |__  |   V   | |  | |  \| |
|  __/| |_| |  __| | |\ /| | |  | | . ` |
|_|    \___/|_____|_|    |_|_|  |_|_| \_|
\033[1;36m
             SISTEMA VPS - VERSION 2.0
\033[1;37m
=====================================================
       BIENVENIDO AL INSTALADOR DE PHENIX-M&M
=====================================================
  Se requiere CLAVE DE ACTIVACION valida.
=====================================================\033[0m"
sleep 2

# ==============================================
# LICENCIA DINAMICA
# ==============================================
validar_licencia(){
  clear
  echo "====================================================="
  echo "      ACTIVACION DE LICENCIA"
  echo "====================================================="
  IP_VPS=$(hostname -I | awk '{print $1}')
  HORA_ACTUAL=$(date +%s)
  echo "  IP DETECTADA: $IP_VPS"
  echo "====================================================="
  read -p "  INGRESE CLAVE: " CLAVE
  echo ""

  if [[ ! "$CLAVE" =~ ^PHENIX-[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+-[0-9]+$ ]]; then
    echo "❌ FORMATO INCORRECTO"
    sleep 2
    exit 1
  fi

  CLAVE_IP=$(echo "$CLAVE" | cut -d'-' -f2)
  CLAVE_VENC=$(echo "$CLAVE" | cut -d'-' -f3)

  [[ "$CLAVE_IP" != "$IP_VPS" ]] && { echo "❌ NO ES PARA ESTA IP"; sleep 3; exit 1; }
  [[ "$HORA_ACTUAL" -gt "$CLAVE_VENC" ]] && { echo "❌ CLAVE VENCIDA"; sleep 2; exit 1; }

  echo "$CLAVE" > ${PHENIX}/tmp/licencia.valida
  echo "✅ LICENCIA VALIDA - INSTALANDO..."
  sleep 2
}

# ==============================================
# AVISO WHATSAPP
# ==============================================
avisar_whatsapp(){
  IP=$(hostname -I | awk '{print $1}')
  LIC=$(cat ${PHENIX}/tmp/licencia.valida)
  MENSAJE="✅ INSTALADO PHENIX-M&M 2.0%0A🔹 IP: $IP%0A🔹 CLAVE: $LIC"
  wget -q -O /dev/null "https://api.whatsapp.com/send?phone=5493815246197&text=$MENSAJE" &>/dev/null
}

# ==============================================
# CARGA BASE
# ==============================================
module="$(pwd)/module"
rm -rf ${module}
wget -q -O ${module} "${REPO}/module"
[[ ! -e ${module} ]] && exit
chmod +x ${module}
source ${module}

CTRL_C(){ rm -rf ${module}; exit; }
[[ $(id -u) -ne 0 ]] && { echo "ERROR: USE ROOT"; exit; }
trap "CTRL_C" INT TERM EXIT

validar_licencia

# ==============================================
# INSTALACION
# ==============================================
mkdir -p ${PHENIX}/{install,bin,sbin,tmp}
chmod -R 755 ${PHENIX}

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

avisar_whatsapp
rm -rf ${SCPinstal} ${module}
clear
echo "====================================================="
echo "           ✅ INSTALACION FINALIZADA ✅"
echo "====================================================="
echo "  ESCRIBA: menu"
echo "====================================================="
