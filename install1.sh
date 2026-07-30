#!/bin/bash
# ==============================================
#                PHENIX-M&M 2.0
#           INSTALADOR OFICIAL VPS
# ==============================================

REPO="https://raw.githubusercontent.com/MARCELOSALVATIERRA926/PHENIX-M-M-2.0/main"
PHENIX="/etc/PHENIX-M&M"
SCPinstal="$HOME/install"

# ==============================================
# 🎨 PANTALLA DE BIENVENIDA
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
  Se instalaran todos los servicios y herramientas
  de forma segura y automatica.
  Se requiere CLAVE DE ACTIVACION valida.
=====================================================\033[0m"
sleep 3

# ==============================================
# 🔒 SISTEMA DE LICENCIA DINAMICA
# ==============================================
validar_licencia(){
  clear
  echo -e "\033[1;31m=====================================================\033[0m"
  echo -e "      \033[1;33mACTIVACION DE LICENCIA\033[0m"
  echo -e "\033[1;31m=====================================================\033[0m"

  IP_VPS=$(hostname -I | awk '{print $1}')
  HORA_ACTUAL=$(date +%s)

  echo "  IP DETECTADA: $IP_VPS"
  echo -e "\033[1;31m=====================================================\033[0m"
  read -p "  INGRESE CLAVE DE ACTIVACION: " CLAVE
  echo ""

  if [[ ! "$CLAVE" =~ ^PHENIX-[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+-[0-9]+$ ]]; then
    echo -e "\033[1;31m❌ FORMATO DE CLAVE INCORRECTO\033[0m"
    sleep 2
    exit 1
  fi

  CLAVE_IP=$(echo "$CLAVE" | cut -d'-' -f2)
  CLAVE_VENC=$(echo "$CLAVE" | cut -d'-' -f3)

  if [[ "$CLAVE_IP" != "$IP_VPS" ]]; then
    echo -e "\033[1;31m❌ ESTA CLAVE NO CORRESPONDE A ESTA VPS\033[0m"
    sleep 3
    exit 1
  fi

  if [[ "$HORA_ACTUAL" -gt "$CLAVE_VENC" ]]; then
    echo -e "\033[1;31m❌ CLAVE VENCIDA\033[0m"
    sleep 2
    exit 1
  fi

  echo "$CLAVE" > ${PHENIX}/tmp/licencia.valida
  echo -e "\033[1;32m✅ LICENCIA VALIDA - COMENZANDO INSTALACION...\033[0m"
  sleep 2
}

# ==============================================
# 📲 AVISO AUTOMATICO A TU WHATSAPP
# ==============================================
avisar_whatsapp(){
  IP=$(hostname -I | awk '{print $1}')
  LIC=$(cat ${PHENIX}/tmp/licencia.valida)
  MENSAJE="✅ INSTALACION PHENIX-M&M 2.0%0A%0A🔹 IP: $IP%0A🔹 CLAVE: $LIC%0A🔹 ESTADO: LISTO PARA CONFIGURAR"
  wget -q -O /dev/null "https://api.whatsapp.com/send?phone=5493815246197&text=$MENSAJE" &>/dev/null
}

# ==============================================
# CARGA DE FUNCIONES BASE
# ==============================================
module="$(pwd)/module"
rm -rf ${module}
wget -O ${module} "${REPO}/module" &>/dev/null
[[ ! -e ${module} ]] && exit
chmod +x ${module} &>/dev/null
source ${module}

CTRL_C(){ rm -rf ${module}; exit; }
[[ $(id -u) -ne 0 ]] && { echo "ERROR: EJECUTE COMO ROOT"; exit; }
trap "CTRL_C" INT TERM EXIT

# ✅ VALIDAMOS LICENCIA PRIMERO
validar_licencia

# ==============================================
# ESTRUCTURA E INSTALACION (SIN TOCAR PUERTOS)
# ==============================================
mkdir -p ${PHENIX}/{install,bin,sbin,tmp}
chmod -R 755 ${PHENIX}
chown -R root:root ${PHENIX}

clear
echo -e "\033[1;34m>>> ACTUALIZANDO SISTEMA...\033[0m"
apt update -y &>/dev/null

echo -e "\033[1;34m>>> INSTALANDO PAQUETES NECESARIOS...\033[0m"
apt install -y sudo bsdmainutils zip unzip ufw curl python3 python3-pip openssl screen cron iptables lsof nano gawk grep bc jq socat net-tools dropbear &>/dev/null

echo -e "\033[1;34m>>> DESCARGANDO ARCHIVOS PHENIX-M&M...\033[0m"
mkdir -p ${SCPinstal}
archivos="menu userSSH dropBear cmd mine_port"
for arq in $archivos; do
  wget -q -O ${SCPinstal}/${arq} ${REPO}/${arq}
  mv -f ${SCPinstal}/${arq} ${PHENIX}/
  chmod +x ${PHENIX}/${arq}
  echo "    ✅ $arq"
done

ln -sf ${PHENIX}/menu /usr/bin/menu
ln -sf ${PHENIX}/dropBear /usr/bin/dropBear
echo "source ${PHENIX}/module" >> /root/.bashrc
echo "PHENIX-M&M 2.0" > ${PHENIX}/tmp/marca.txt

# ==============================================
# FINALIZACION
# ==============================================
avisar_whatsapp
rm -rf ${SCPinstal} ${module}
sleep 1
clear
echo -e "\033[1;32m=====================================================\033[0m"
echo -e "           ✅ INSTALACION FINALIZADA ✅"
echo -e "=====================================================\033[0m"
echo -e "  AHORA CONFIGURE PUERTOS Y SERVICIOS DESDE EL MENU"
echo -e "  ESCRIBA: \033[1;37mmenu\033[1;32m  PARA EMPEZAR"
echo -e "\033[1;32m=====================================================\033[0m"
