#!/bin/bash
# ==============================================
#            PHENIX-M&M 2.0 - INSTALADOR
# ==============================================

REPO="https://raw.githubusercontent.com/MARCELOSALVATIERRA926/PHENIX-M-M-2.0/main"
PHENIX="/etc/PHENIX-M&M"
SCPinstal="$HOME/install"

# ==============================================
# 🎨 BIENVENIDA CON TU ESTILO
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
echo "     Instalación segura y controlada."
echo "🔑  INGRESE SU CLAVE DE ACTIVACION"
echo "====================================================="
sleep 2

# ==============================================
# 🔒 NUEVA VALIDACION CON TU SERVIDOR PRINCIPAL
# ==============================================
validar_licencia(){
  IP_VPS=$(hostname -I | awk '{print $1}')
  IP_SERVIDOR="149.50.147.26"
  PUERTO_SERVIDOR=7777

  echo ""
  echo "🌐  IP DETECTADA: $IP_VPS"
  echo "====================================================="
  read -p "🔑  CLAVE: " CLAVE
  echo ""

  # Validación básica de longitud
  [[ ${#CLAVE} -ne 40 ]] && { echo "❌ FORMATO DE CLAVE INCORRECTO"; sleep 2; exit 1; }

  # Bajamos el validador desde TU repositorio
  wget -q -O ${PHENIX}/bin/licencia_valida ${REPO}/bin/licencia_valida
  chmod +x ${PHENIX}/bin/licencia_valida

  # Consultamos a TU VPS PRINCIPAL
  echo "🔍 VALIDANDO LICENCIA..."
  RESULTADO=$(${PHENIX}/bin/licencia_valida "$CLAVE" "$IP_VPS")

  if [[ "$RESULTADO" == "AUTORIZADO" ]]; then
    echo "✅  LICENCIA VALIDA - INICIANDO..."
    echo "$CLAVE" > ${PHENIX}/tmp/licencia.valida
    sleep 2
  else
    echo "❌  $RESULTADO"
    sleep 3
    exit 1
  fi
}

# ==============================================
# 📲 AVISO AL BOT CUANDO SE AUTORIZA
# ==============================================
avisar_bot(){
  IP=$(hostname -I | awk '{print $1}')
  CLAVE=$(cat ${PHENIX}/tmp/licencia.valida)
  MENSAJE="✅ INSTALACION AUTORIZADA%0A🔰 PHENIX-M&M 2.0%0A🔑 CLAVE: $CLAVE%0A🌐 IP: $IP"
  TOKEN="8803475189:AAEwP9xET8S_JPoNdoJ8-ZXlvUHA7IiCZYA"
  ID="5538844330"
  wget -q -O /dev/null "https://api.telegram.org/bot${TOKEN}/sendMessage?chat_id=${ID}&text=${MENSAJE}" &>/dev/null
}

# ==============================================
# PREPARACION E INSTALACION
# ==============================================
mkdir -p ${PHENIX}/{install,bin,sbin,tmp}
chmod -R 755 ${PHENIX}

# EJECUTAMOS LA VALIDACION ANTES DE SEGUIR
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
# FINAL
# ==============================================
avisar_bot
rm -rf ${SCPinstal}

clear
echo -e "\n$(figlet -f big.flf "LISTO!")\n" | lolcat
echo "====================================================="
echo "            🎉 INSTALACION FINALIZADA 🎉"
echo "====================================================="
echo "   ⚡ Para entrar al panel escriba:  menu"
echo "====================================================="
