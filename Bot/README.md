# 🎯 COMANDOS PARA USARLO — CLARITOS Y SEPARADOS:
 
# ✅ 🔌 ENCENDER el bot (queda andando aunque cierres la VPS):

cd /opt/PhenixBot
pkill -f PhenixBot 2>/dev/null
screen -dmS PhenixBot bash bot.sh


# ✅ 👀 VERLO / ENTRAR A VER QUÉ HACE:

screen -r PhenixBot


# ✅ ❌ APAGAR el bot:

pkill -f PhenixBot

# ✅ ✅ COMPROBAR SI ESTÁ ANDANDO:

screen -ls
