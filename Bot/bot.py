cd /opt/PhenixBot && rm -f bot.py && cat > bot.py << 'EOF'
#!/usr/bin/env python3
from telegram import Update, InlineKeyboardButton, InlineKeyboardMarkup
from telegram.ext import ApplicationBuilder, CommandHandler, CallbackQueryHandler, ContextTypes
import random, string, time, os

TOKEN = "8803475189:AAEwP9xET8S_JPoNdoJ8-ZXlvUHA7IiCZYA"
TU_ID = 5538844330
ARCHIVO_DATOS = "/opt/PhenixBot/datos.txt"
ARCHIVO_USUARIOS = "/opt/PhenixBot/usuarios.txt"
DEFAULT_DIAS = 30

if not os.path.exists(ARCHIVO_DATOS):
    with open(ARCHIVO_DATOS, "w") as f:
        f.write("CLAVE|ESTADO|IP|USUARIO|VENCIMIENTO\n")
if not os.path.exists(ARCHIVO_USUARIOS):
    with open(ARCHIVO_USUARIOS, "w") as f:
        f.write(f"{TU_ID}|ADMIN|FENIX|9999999999\n")

def es_admin(uid: int) -> bool:
    return uid == TU_ID

def tiene_acceso(uid: int) -> bool:
    if not os.path.exists(ARCHIVO_USUARIOS): return False
    with open(ARCHIVO_USUARIOS) as f:
        for l in f:
            p = l.strip().split("|")
            if len(p)>=4 and p[0]==str(uid):
                return time.time() < int(p[3])
    return False

def generar_clave() -> str:
    return ''.join(random.choices(string.ascii_uppercase+string.digits, k=40))

# ✅ 3 BOTONES EN LÍNEA
teclado_admin = [
    [
        InlineKeyboardButton("🔑 GENERAR", callback_data="GENERAR"),
        InlineKeyboardButton("➕ AGREGAR", callback_data="AGREGAR"),
        InlineKeyboardButton("🗑️ BORRAR", callback_data="BORRAR")
    ]
]
teclado_usuario = [
    [InlineKeyboardButton("🔑 GENERAR", callback_data="GENERAR")]
]

async def btn_generar(update: Update, ctx: ContextTypes.DEFAULT_TYPE):
    q = update.callback_query
    await q.answer()
    uid = update.effective_user.id
    nom = update.effective_user.first_name or "USUARIO"

    if not tiene_acceso(uid):
        await q.message.reply_text("❌ SIN ACCESO\n\nTu ID es: `"+str(uid)+"`\nMandalo al administrador", parse_mode="Markdown")
        return

    clave = generar_clave()
    venc = int(time.time() + 4*3600)
    with open(ARCHIVO_DATOS, "a") as f:
        f.write(f"{clave}|LIBRE|SIN_IP|{nom}|{venc}\n")

    msg = f"""━━━━━━━━━━━━━━━
🔰 KEY PHENIX 🔰
━━━━━━━━━━━━━━━
🆔 ID: {uid}
👤 USUARIO: {nom}
━━━━━━━━━━━━━━━
🔑 CLAVE:
━━━━━━━━━━━━━━━
`{clave}`
━━━━━━━━━━━━━━━
INSTALADOR:
━━━━━━━━━━━━━━━
`rm -rf /root/install.sh; wget --no-cache -O /root/install.sh https://raw.githubusercontent.com/MARCELOSALVATIERRA926/PHENIX-M-M-2.0/main/install.sh; chmod +x /root/install.sh; /root/install.sh`
━━━━━━━━━━━━━━━
SISTEMAS APTOS:
📀- Ubuntu 22 / 24.04
💽- Debian 12
━━━━━━━━━━━━━━━
⏳ KEY VÁLIDA: SOLO POR 4 HORAS
━━━━━━━━━━━━━━━"""
    tk = InlineKeyboardMarkup(teclado_admin) if es_admin(uid) else InlineKeyboardMarkup(teclado_usuario)
    await q.message.reply_text(msg, parse_mode="Markdown", reply_markup=tk)

async def btn_agregar(update: Update, ctx: ContextTypes.DEFAULT_TYPE):
    q = update.callback_query
    await q.answer()
    uid = update.effective_user.id
    if not es_admin(uid):
        await q.message.reply_text("❌ SOLO EL ADMINISTRADOR PUEDE AGREGAR USUARIOS")
        return
    msg = """📝 PARA AGREGAR UN USUARIO:

📌 COMANDO:
/agregar ID NOMBRE DÍAS

📌 EJEMPLO:
/agregar 123456789 Juan 30"""
    await q.message.reply_text(msg, reply_markup=InlineKeyboardMarkup(teclado_admin))

async def btn_borrar(update: Update, ctx: ContextTypes.DEFAULT_TYPE):
    q = update.callback_query
    await q.answer()
    uid = update.effective_user.id
    if not es_admin(uid):
        await q.message.reply_text("❌ SOLO EL ADMINISTRADOR PUEDE BORRAR USUARIOS")
        return
    msg = """🗑️ PARA BORRAR UN USUARIO:

📌 COMANDO:
/borrar ID

📌 EJEMPLO:
/borrar 123456789

✅ BORRA TODO: USUARIO + CLAVES"""
    await q.message.reply_text(msg, reply_markup=InlineKeyboardMarkup(teclado_admin))

async def cmd_agregar(update: Update, ctx: ContextTypes.DEFAULT_TYPE):
    uid = update.effective_user.id
    if not es_admin(uid):
        await update.message.reply_text("❌ NO TENÉS PERMISO")
        return
    if len(ctx.args)<2:
        await update.message.reply_text("⚠️ USO: /agregar ID NOMBRE [DÍAS]")
        return
    nuevo_id = int(ctx.args[0])
    nombre = ctx.args[1]
    dias = int(ctx.args[2]) if len(ctx.args)>=3 else DEFAULT_DIAS
    venc = int(time.time() + dias*86400)
    existe = False
    with open(ARCHIVO_USUARIOS) as f:
        existe = any(l.startswith(f"{nuevo_id}|") for l in f)
    if existe:
        await update.message.reply_text("⚠️ ESE USUARIO YA EXISTE")
        return
    with open(ARCHIVO_USUARIOS, "a") as f:
        f.write(f"{nuevo_id}|USUARIO|{nombre}|{venc}\n")
    fecha = time.strftime("%d/%m/%Y", time.localtime(venc))
    await update.message.reply_text(f"✅ USUARIO AGREGADO\n\n🆔 ID: {nuevo_id}\n👤 NOMBRE: {nombre}\n⏰ DÍAS: {dias}\n📅 VENCE: {fecha}", reply_markup=InlineKeyboardMarkup(teclado_admin))
    await ctx.bot.send_message(nuevo_id, f"✅ TE DIERON PERMISO\n📅 VENCE: {fecha}", reply_markup=InlineKeyboardMarkup(teclado_usuario))

# ✅ BORRADO COMPLETO: BORRA USUARIO + TODAS SUS CLAVES DE UN GOLPE
async def cmd_borrar(update: Update, ctx: ContextTypes.DEFAULT_TYPE):
    uid = update.effective_user.id
    if not es_admin(uid):
        await update.message.reply_text("❌ NO TENÉS PERMISO")
        return
    if len(ctx.args)<1:
        await update.message.reply_text("⚠️ USO: /borrar ID")
        return

    id_borrar = str(ctx.args[0])
    nombre_borrar = ""
    dias_restantes = 0
    fecha_venc = ""
    cantidad_claves = 0

    # 🗑️ PASO 1: BUSCAR Y BORRAR EL USUARIO
    lineas_nuevas = []
    with open(ARCHIVO_USUARIOS) as f:
        for l in f:
            partes = l.strip().split("|")
            if len(partes)>=4 and partes[0]==id_borrar:
                nombre_borrar = partes[2]
                venc = int(partes[3])
                ahora = int(time.time())
                dias_restantes = max(0, int((venc - ahora)/86400))
                fecha_venc = time.strftime("%d/%m/%Y", time.localtime(venc))
            else:
                lineas_nuevas.append(l)

    if not nombre_borrar:
        await update.message.reply_text("⚠️ NO SE ENCONTRÓ ESE USUARIO")
        return

    # 🗑️ PASO 2: BORRAR TODAS LAS CLAVES DE ESE USUARIO
    claves_nuevas = []
    with open(ARCHIVO_DATOS) as f:
        for l in f:
            partes = l.strip().split("|")
            if len(partes)>=4 and partes[3]==nombre_borrar:
                cantidad_claves += 1
            else:
                claves_nuevas.append(l)

    # ✅ GUARDAR ARCHIVOS LIMPIOS
    with open(ARCHIVO_USUARIOS, "w") as f:
        f.writelines(lineas_nuevas)
    with open(ARCHIVO_DATOS, "w") as f:
        f.writelines(claves_nuevas)

    # ✅ CONFIRMACIÓN COMPLETA
    await update.message.reply_text(f"""🗑️ USUARIO BORRADO COMPLETO ✅

━━━━━━━━━━━━━━━
🆔 ID: {id_borrar}
👤 NOMBRE: {nombre_borrar}
⏰ DÍAS QUE TENÍA: {dias_restantes}
📅 VENCIMIENTO: {fecha_venc}
🔑 CLAVES BORRADAS: {cantidad_claves}
━━━━━━━━━━━━━━━

✅ TODO ELIMINADO COMPLETAMENTE""", reply_markup=InlineKeyboardMarkup(teclado_admin))

async def cmd_start(update: Update, ctx: ContextTypes.DEFAULT_TYPE):
    uid = update.effective_user.id
    nombre = update.effective_user.first_name or "USUARIO"

    if es_admin(uid):
        await update.message.reply_text(
            f"👋 ¡HOLA, {nombre}!\n\n✅ BIENVENIDO A PHENIX-M&M\nSOS EL ADMINISTRADOR\n\nTocá los botones abajo:",
            reply_markup=InlineKeyboardMarkup(teclado_admin)
        )
    elif tiene_acceso(uid):
        await update.message.reply_text(
            f"👋 ¡HOLA, {nombre}!\n\n✅ BIENVENIDO A PHENIX-M&M\n\nTocá 🔑 GENERAR para tu clave:",
            reply_markup=InlineKeyboardMarkup(teclado_usuario)
        )
    else:
        await update.message.reply_text(
            f"👋 ¡HOLA!\n\n❌ NO TENÉS ACCESO\n\nTu ID es: `{uid}`\nMandalo al administrador.",
            parse_mode="Markdown"
        )

if __name__ == "__main__":
    print("🔰 BOT PHENIX INICIADO")
    app = ApplicationBuilder().token(TOKEN).build()
    app.add_handler(CommandHandler("start", cmd_start))
    app.add_handler(CommandHandler("agregar", cmd_agregar))
    app.add_handler(CommandHandler("borrar", cmd_borrar))
    app.add_handler(CallbackQueryHandler(btn_generar, pattern="^GENERAR$"))
    app.add_handler(CallbackQueryHandler(btn_agregar, pattern="^AGREGAR$"))
    app.add_handler(CallbackQueryHandler(btn_borrar, pattern="^BORRAR$"))
    print("✅ LISTO — BORRADO COMPLETO")
    app.run_polling()
EOF

pkill -f "python3 /opt/PhenixBot/bot.py" 2>/dev/null
screen -dmS PhenixBot python3 /opt/PhenixBot/bot.py
