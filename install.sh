#!/bin/bash
# ==============================================
#            PHENIX-M&M 2.0 - INSTALADOR
# ==============================================

REPO="https://raw.githubusercontent.com/MARCELOSALVATIERRA926/PHENIX-M-M-2.0/main"
PHENIX="/etc/PHENIX-M&M"
SCPinstal="$HOME/install"

# ==============================================
# 🎨 BIENVENIDA CON TU ESTILO - LO PRIMERO QUE SE VE
# ==============================================
mkdir -p "/etc/PHENIX-M&M/tmp"
[[ ! -e "/etc/PHENIX-M&M/tmp/message.txt" ]] && echo "@FENIX-M&M" > "/etc/PHENIX-M&M/tmp/message.txt"
mess1="@FENIX-M&M"
[[ -e "/etc/PHENIX-M&M/tmp/message.txt" ]] && mess1="$(cat "/etc/PHENIX-M&M/tmp/message.txt")"

clear
echo -e "\n$(figlet -f big.flf "PHENIX-M&M")\n        RESELLER : $mess1\n\n" | lolcat
echo "====================================================="
echo "          🎉  BIENVENIDO A PHENIX-M&M  🎉"
echo "====================================================="
echo "     Vamos a instalar nuestro sistema de forma segura"
echo "     y personalizada para tu VPS."
echo "====================================================="
echo "🔑  INGRESE SU CLAVE DE ACTIVACION PARA CONTINUAR"
echo "====================================================="
sleep 2

# ==============================================
# VALIDACION DE LICENCIA
# ==============================================
validar_licencia(){
  IP_VPS=$(hostname -I | awk '{print $1}')
  HORA_ACTUAL=$(date +%s)

  echo ""
  echo "🌐  IP DETECTADA AUTOMATICAMENTE: $IP_VPS"
  echo "====================================================="
  read -p "🔑  CLAVE: " CLAVE
  echo ""

  if [[ ! "$CLAVE" =~ ^PHENIX-[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+-[0-9]+$ ]]; then
    echo "❌  ERROR: FORMATO DE CLAVE INCORRECTO"
    sleep 2
    exit 1
  fi

  CLAVE_IP=$(echo "$CLAVE" | cut -d'-' -f2)
  CLAVE_VENC=$(echo "$CLAVE" | cut -d'-' -f3)

  if [[ "$CLAVE_IP" != "$IP_VPS" ]]; then
    echo "❌  ERROR: ESTA CLAVE NO ES PARA ESTA VPS"
    sleep 3
    exit 1
  fi

  if [[ "$HORA_ACTUAL" -gt "$CLAVE_VENC" ]]; then
    echo "❌  ERROR: CLAVE VENCIDA"
    sleep 2
    exit 1
  fi

  echo "$CLAVE" > ${PHENIX}/tmp/licencia.valida
  echo "✅  CLAVE VALIDA - INICIANDO INSTALACION..."
  echo "====================================================="
  sleep 2
}

# ==============================================
# 📲 AVISO AUTOMATICO AL BOT
# ==============================================
avisar_bot(){
  IP=$(hostname -I | awk '{print $1}')
  CLAVE=$(cat ${PHENIX}/tmp/licencia.valida)
  MENSAJE="✅ INSTALACION INICIADA ✅%0A🔰 PHENIX-M&M 2.0%0A🔑 CLAVE: $CLAVE%0A🌐 IP: $IP"
  TOKEN_BOT="8803475189:AAEwP9xET8S_JPoNdoJ8-ZXlvUHA7IiCZYA"
  TU_ID="5538844330"
  wget -q -O /dev/null "https://api.telegram.org/bot${TOKEN_BOT}/sendMessage?chat_id=${TU_ID}&text=${MENSAJE}" &>/dev/null
}

# ==============================================
# PREPARACION E INSTALACION
# ==============================================
mkdir -p ${PHENIX}/{install,bin,sbin,tmp}
chmod -R 755 ${PHENIX}

validar_licencia

apt update -y &>/dev/null
apt install -y sudo bsdmainutils zip unzip ufw curl python3 python3-pip openssl screen cron iptables lsof nano gawk grep bc jq socat net-tools dropbear figlet lolcat &>/dev/null

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
# 🎨 CIERRE CON TU BANNER AL TERMINAR
# ==============================================
avisar_bot
rm -rf ${SCPinstal}

v=$(cat "/etc/PHENIX-M&M/vercion")
[[ -e "/etc/PHENIX-M&M/new_vercion" ]] && up=$(cat "/etc/PHENIX-M&M/new_vercion") || up="$v"
[[ $(date '+%s' -d "$up") -gt $(date '+%s' -d "$v") ]] && v2="🆕 Nueva Version: $v >>> $up" || v2="✅ Version Actual: $v"

clear
echo -e "\n$(figlet -f big.flf "LISTO!")\n" | lolcat
echo "====================================================="
echo "            🎉 INSTALACION FINALIZADA 🎉"
echo "====================================================="
echo "   Gracias por elegir PHENIX-M&M"
echo "   Todo quedó configurado correctamente."
echo ""
echo "   ⚡ Para entrar al panel escriba:  menu"
echo "   📋 Para ver comandos escriba:     ls-cmd"
echo ""
echo "   $v2"
echo "====================================================="
