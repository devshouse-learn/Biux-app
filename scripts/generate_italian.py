#!/usr/bin/env python3
"""
Genera la sección de traducciones al italiano para app_translations.dart.
Extrae las claves del español, traduce usando diccionario y reglas.
"""
import re
import sys

def extract_section(content, lang_var):
    """Extract key-value pairs from a language section."""
    lines = content.split('\n')
    start = None
    end = None
    brace_count = 0
    
    for i, line in enumerate(lines):
        if f'Map<String, String> {lang_var}' in line:
            start = i
            brace_count = 1
            continue
        if start is not None and i > start:
            brace_count += line.count('{') - line.count('}')
            if brace_count <= 0:
                end = i
                break
    
    if start is None or end is None:
        return [], start, end
    
    entries = []
    for i in range(start + 1, end):
        line = lines[i]
        stripped = line.strip()
        
        if stripped.startswith('//'):
            entries.append(('COMMENT', stripped))
            continue
        if not stripped or stripped == '{':
            entries.append(('EMPTY', ''))
            continue
        
        # Match key-value pairs, handling escaped single quotes
        m = re.match(r"\s+'([^']+)'\s*:\s*'((?:[^'\\]|\\.)*)'[,]?\s*$", line)
        if m:
            entries.append((m.group(1), m.group(2)))
        else:
            # Try without escapes for simple strings
            m2 = re.match(r"\s+'([^']+)'\s*:\s*'([^']*)'[,]?\s*$", line)
            if m2:
                entries.append((m2.group(1), m2.group(2)))
    
    return entries, start, end

# Comprehensive Spanish -> Italian dictionary
TRANSLATIONS = {
    # General UI
    'Configuración': 'Configurazione',
    'Atrás': 'Indietro',
    'Enviar': 'Invia',
    'Entendido': 'Capito',
    'Actualmente': 'Attualmente',
    'Actual': 'Attuale',
    'Guardar': 'Salva',
    'Cancelar': 'Annulla',
    'Aceptar': 'Accetta',
    'Eliminar': 'Elimina',
    'Editar': 'Modifica',
    'Buscar': 'Cerca',
    'Cerrar': 'Chiudi',
    'Siguiente': 'Avanti',
    'Anterior': 'Precedente',
    'Seleccionar': 'Seleziona',
    'Confirmar': 'Conferma',
    'Crear': 'Crea',
    'Actualizar': 'Aggiorna',
    'Compartir': 'Condividi',
    'Publicar': 'Pubblica',
    'Copiar': 'Copia',
    'Descargar': 'Scarica',
    'Subir': 'Carica',
    'Listo': 'Fatto',
    'Aplicar': 'Applica',
    'Filtrar': 'Filtra',
    'Ordenar': 'Ordina',
    'Opciones': 'Opzioni',
    'Volver': 'Torna',
    'Reintentar': 'Riprova',
    'Continuar': 'Continua',
    'Iniciar': 'Inizia',
    'Finalizar': 'Termina',
    'Pausar': 'Pausa',
    'Detener': 'Ferma',
    'Habilitar': 'Abilita',
    'Deshabilitar': 'Disabilita',
    'Sí': 'Sì',
    'No': 'No',
    'Ok': 'Ok',
    'OK': 'OK',
    'Hecho': 'Fatto',
    
    # Settings
    'Preferencias': 'Preferenze',
    'Notificaciones': 'Notifiche',
    'Activar/desactivar, Sonido, Vibración': 'Attiva/disattiva, Suono, Vibrazione',
    'Apariencia': 'Aspetto',
    'Modo claro/oscuro, Idioma': 'Modalità chiaro/scuro, Lingua',
    'Privacidad': 'Privacy',
    'Quién puede ver tu perfil, Permisos': 'Chi può vedere il tuo profilo, Permessi',
    'Información': 'Informazioni',
    'Versión, Términos, Soporte Técnico': 'Versione, Termini, Supporto Tecnico',
    'Idioma': 'Lingua',
    'Seleccionar Idioma': 'Seleziona Lingua',
    
    # Notifications
    'Notificaciones Push': 'Notifiche Push',
    'Activadas': 'Attivate',
    'Desactivadas': 'Disattivate',
    'Sonido': 'Suono',
    'Sonido en las notificaciones': 'Suono nelle notifiche',
    'Vibración': 'Vibrazione',
    'Vibración en notificaciones': 'Vibrazione nelle notifiche',
    'Interacciones Sociales': 'Interazioni Sociali',
    'Likes': 'Mi piace',
    'Cuando alguien le da like a tus publicaciones': 'Quando qualcuno mette mi piace ai tuoi post',
    'Comentarios': 'Commenti',
    'Cuando alguien comenta en tus publicaciones': 'Quando qualcuno commenta i tuoi post',
    'Nuevos Seguidores': 'Nuovi Seguaci',
    'Cuando alguien comienza a seguirte': 'Quando qualcuno inizia a seguirti',
    'Historias': 'Storie',
    'Cuando tus amigos publican nuevas historias': 'Quando i tuoi amici pubblicano nuove storie',
    'Rodadas y Grupos': 'Pedalate e Gruppi',
    'Invitaciones a Rodadas': 'Inviti alle Pedalate',
    'Cuando te invitan a participar en una rodada': 'Quando ti invitano a una pedalata',
    
    # Social
    'Seguir': 'Segui',
    'Siguiendo': 'Seguendo',
    'Seguidores': 'Seguaci',
    'Dejar de seguir': 'Smetti di seguire',
    'Publicaciones': 'Pubblicazioni',
    'Me gusta': 'Mi piace',
    'Comentar': 'Commenta',
    'Responder': 'Rispondi',
    'Reportar': 'Segnala',
    'Bloquear': 'Blocca',
    'Desbloquear': 'Sblocca',
    'Silenciar': 'Silenzia',
    
    # Profile
    'Perfil': 'Profilo',
    'Nombre': 'Nome',
    'Nombre completo': 'Nome completo',
    'Nombre de usuario': 'Nome utente',
    'Descripción': 'Descrizione',
    'Biografía': 'Biografia',
    'Foto de perfil': 'Foto profilo',
    'Foto de portada': 'Foto di copertina',
    'Editar perfil': 'Modifica profilo',
    
    # Groups
    'Grupo': 'Gruppo',
    'Grupos': 'Gruppi',
    'Miembros': 'Membri',
    'Administrador': 'Amministratore',
    'Moderador': 'Moderatore',
    'Crear grupo': 'Crea gruppo',
    'Nombre del grupo': 'Nome del gruppo',
    'Descripción del grupo': 'Descrizione del gruppo',
    'Unirse al grupo': 'Unisciti al gruppo',
    'Salir del grupo': 'Esci dal gruppo',
    
    # Chat
    'Chat': 'Chat',
    'Mensaje': 'Messaggio',
    'Mensajes': 'Messaggi',
    'En línea': 'Online',
    'Desconectado': 'Disconnesso',
    'Escribir mensaje': 'Scrivi messaggio',
    'Escribir un mensaje...': 'Scrivi un messaggio...',
    'Nuevo mensaje': 'Nuovo messaggio',
    
    # Maps/Rides
    'Mapa': 'Mappa',
    'Ruta': 'Percorso',
    'Distancia': 'Distanza',
    'Velocidad': 'Velocità',
    'Tiempo': 'Tempo',
    'Altitud': 'Altitudine',
    'Rodada': 'Pedalata',
    'Rodadas': 'Pedalate',
    'Kilómetros': 'Chilometri',
    'Metros': 'Metri',
    'Horas': 'Ore',
    'Minutos': 'Minuti',
    'Segundos': 'Secondi',
    'Ubicación': 'Posizione',
    'Mi ubicación': 'La mia posizione',
    'Punto de encuentro': 'Punto d\\\'incontro',
    'Destino': 'Destinazione',
    'Elevación': 'Elevazione',
    'Duración': 'Durata',
    
    # Account
    'Cuenta': 'Account',
    'Ajustes de cuenta': 'Impostazioni account',
    'Cerrar sesión': 'Esci',
    'Eliminar cuenta': 'Elimina account',
    'Iniciar sesión': 'Accedi',
    'Registrarse': 'Registrati',
    'Correo electrónico': 'E-mail',
    'Contraseña': 'Password',
    'Teléfono': 'Telefono',
    'Número de teléfono': 'Numero di telefono',
    
    # Media
    'Foto': 'Foto',
    'Fotos': 'Foto',
    'Video': 'Video',
    'Videos': 'Video',
    'Cámara': 'Fotocamera',
    'Galería': 'Galleria',
    'Audio': 'Audio',
    'Documento': 'Documento',
    'Archivo': 'File',
    
    # Time
    'Hoy': 'Oggi',
    'Ayer': 'Ieri',
    'Mañana': 'Domani',
    'Semana': 'Settimana',
    'Día': 'Giorno',
    'Mes': 'Mese',
    'Año': 'Anno',
    'Fecha': 'Data',
    'Hora': 'Ora',
    
    # Status
    'Cargando': 'Caricamento',
    'Cargando...': 'Caricamento...',
    'Error': 'Errore',
    'Éxito': 'Successo',
    'Advertencia': 'Avviso',
    'Sin conexión': 'Senza connessione',
    'Sin resultados': 'Nessun risultato',
    'Vacío': 'Vuoto',
    'Pendiente': 'In attesa',
    'Completado': 'Completato',
    'En progreso': 'In corso',
    
    # Location
    'Ciudad': 'Città',
    'País': 'Paese',
    'Dirección': 'Indirizzo',
    
    # Info/Legal
    'Términos y condiciones': 'Termini e condizioni',
    'Política de privacidad': 'Informativa sulla privacy',
    'Acerca de': 'Informazioni',
    'Ayuda': 'Aiuto',
    'Soporte': 'Supporto',
    'Soporte Técnico': 'Supporto Tecnico',
    'Versión de la app': 'Versione app',
    'Licencias': 'Licenze',
    
    # Misc
    'Todo': 'Tutto',
    'Ninguno': 'Nessuno',
    'Más': 'Altro',
    'Menos': 'Meno',
    'Nuevo': 'Nuovo',
    'Nueva': 'Nuova',
    'Reciente': 'Recente',
    'Popular': 'Popolare',
    'Favoritos': 'Preferiti',
    'Guardado': 'Salvato',
    'Configurar': 'Configura',
}

# Word-level substitution for building translations of longer strings
WORD_SUBS = [
    # Articles and prepositions
    ('el ', 'il '), ('la ', 'la '), ('los ', 'i '), ('las ', 'le '),
    ('del ', 'del '), ('de la ', 'della '), ('de los ', 'dei '), ('de las ', 'delle '),
    ('un ', 'un '), ('una ', 'una '), ('en ', 'in '), ('con ', 'con '),
    ('por ', 'per '), ('para ', 'per '), ('sin ', 'senza '), ('sobre ', 'su '),
    ('entre ', 'tra '), ('hasta ', 'fino a '), ('desde ', 'da '), ('hacia ', 'verso '),
    
    # Common verbs (infinitive)
    ('buscar', 'cercare'), ('crear', 'creare'), ('editar', 'modificare'),
    ('eliminar', 'eliminare'), ('guardar', 'salvare'), ('enviar', 'inviare'),
    ('cancelar', 'annullare'), ('aceptar', 'accettare'), ('confirmar', 'confermare'),
    ('seleccionar', 'selezionare'), ('compartir', 'condividere'),
    ('publicar', 'pubblicare'), ('comentar', 'commentare'),
    ('iniciar', 'iniziare'), ('finalizar', 'terminare'),
    ('actualizar', 'aggiornare'), ('descargar', 'scaricare'),
    ('cargar', 'caricare'), ('cambiar', 'cambiare'),
    ('activar', 'attivare'), ('desactivar', 'disattivare'),
    ('verificar', 'verificare'), ('continuar', 'continuare'),
    ('cerrar', 'chiudere'), ('abrir', 'aprire'),
    ('agregar', 'aggiungere'), ('quitar', 'rimuovere'),
    ('mostrar', 'mostrare'), ('ocultar', 'nascondere'),
    ('copiar', 'copiare'), ('pegar', 'incollare'),
    ('reportar', 'segnalare'), ('bloquear', 'bloccare'),
    
    # Common nouns
    ('usuario', 'utente'), ('usuarios', 'utenti'),
    ('contraseña', 'password'), ('correo', 'email'),
    ('teléfono', 'telefono'), ('mensaje', 'messaggio'), ('mensajes', 'messaggi'),
    ('notificación', 'notifica'), ('notificaciones', 'notifiche'),
    ('configuración', 'configurazione'), ('ajustes', 'impostazioni'),
    ('grupo', 'gruppo'), ('grupos', 'gruppi'),
    ('miembro', 'membro'), ('miembros', 'membri'),
    ('seguidor', 'seguace'), ('seguidores', 'seguaci'),
    ('publicación', 'pubblicazione'), ('publicaciones', 'pubblicazioni'),
    ('comentario', 'commento'), ('comentarios', 'commenti'),
    ('historia', 'storia'), ('historias', 'storie'),
    ('foto', 'foto'), ('fotos', 'foto'),
    ('imagen', 'immagine'), ('imágenes', 'immagini'),
    ('video', 'video'), ('videos', 'video'),
    ('archivo', 'file'), ('archivos', 'file'),
    ('documento', 'documento'), ('documentos', 'documenti'),
    ('ubicación', 'posizione'), ('mapa', 'mappa'),
    ('ruta', 'percorso'), ('rodada', 'pedalata'), ('rodadas', 'pedalate'),
    ('distancia', 'distanza'), ('velocidad', 'velocità'),
    ('tiempo', 'tempo'), ('duración', 'durata'),
    ('fecha', 'data'), ('hora', 'ora'),
    ('nombre', 'nome'), ('apellido', 'cognome'),
    ('descripción', 'descrizione'), ('título', 'titolo'),
    ('precio', 'prezzo'), ('producto', 'prodotto'), ('productos', 'prodotti'),
    ('tienda', 'negozio'), ('comprar', 'acquistare'),
    ('vender', 'vendere'), ('carrito', 'carrello'),
    ('pedido', 'ordine'), ('pedidos', 'ordini'),
    ('dirección', 'indirizzo'), ('ciudad', 'città'), ('país', 'paese'),
    ('cuenta', 'account'), ('perfil', 'profilo'),
    ('sesión', 'sessione'), ('permiso', 'permesso'), ('permisos', 'permessi'),
    ('privacidad', 'privacy'), ('seguridad', 'sicurezza'),
    ('versión', 'versione'), ('información', 'informazioni'),
    ('error', 'errore'), ('éxito', 'successo'),
    ('resultado', 'risultato'), ('resultados', 'risultati'),
    ('opción', 'opzione'), ('opciones', 'opzioni'),
    ('categoría', 'categoria'), ('categorías', 'categorie'),
    ('color', 'colore'), ('colores', 'colori'),
    ('tamaño', 'taglia'), ('peso', 'peso'),
    ('cantidad', 'quantità'), ('total', 'totale'),
    ('disponible', 'disponibile'), ('disponibles', 'disponibili'),
    ('bicicleta', 'bicicletta'), ('ciclista', 'ciclista'),
    ('ruta', 'percorso'), ('punto', 'punto'),
    ('emergencia', 'emergenza'), ('auxilio', 'soccorso'),
    ('accidente', 'incidente'), ('ayuda', 'aiuto'),
    ('amigo', 'amico'), ('amigos', 'amici'),
    
    # Adjectives
    ('nuevo', 'nuovo'), ('nueva', 'nuova'), ('nuevos', 'nuovi'), ('nuevas', 'nuove'),
    ('último', 'ultimo'), ('última', 'ultima'),
    ('primero', 'primo'), ('primera', 'prima'),
    ('público', 'pubblico'), ('pública', 'pubblica'),
    ('privado', 'privato'), ('privada', 'privata'),
    ('activo', 'attivo'), ('activa', 'attiva'),
    ('inactivo', 'inattivo'), ('completo', 'completo'),
    ('vacío', 'vuoto'), ('lleno', 'pieno'),
    ('grande', 'grande'), ('pequeño', 'piccolo'),
    ('máximo', 'massimo'), ('mínimo', 'minimo'),
    ('obligatorio', 'obbligatorio'), ('opcional', 'opzionale'),
    
    # Pronouns / possessives
    ('tu ', 'il tuo '), ('tus ', 'i tuoi '),
    ('mi ', 'il mio '), ('mis ', 'i miei '),
    ('su ', 'il suo '), ('sus ', 'i suoi '),
    ('este ', 'questo '), ('esta ', 'questa '),
    ('estos ', 'questi '), ('estas ', 'queste '),
    
    # Question words
    ('¿', ''), ('?', '?'),
    
    # Common phrases
    ('no se puede', 'non si può'),
    ('no se encontró', 'non trovato'),
    ('no disponible', 'non disponibile'),
    ('en desarrollo', 'in sviluppo'),
    ('por favor', 'per favore'),
    ('intenta de nuevo', 'riprova'),
    ('algo salió mal', 'qualcosa è andato storto'),
    ('estás seguro', 'sei sicuro'),
]


def translate_value(es_value):
    """Translate a Spanish string to Italian."""
    if not es_value:
        return es_value
    
    # Direct dictionary match
    if es_value in TRANSLATIONS:
        return TRANSLATIONS[es_value]
    
    # Try case-insensitive match
    for k, v in TRANSLATIONS.items():
        if k.lower() == es_value.lower():
            # Preserve original casing pattern
            if es_value[0].isupper():
                return v[0].upper() + v[1:]
            return v
    
    # Word-level substitution for longer strings
    result = es_value
    for es_word, it_word in WORD_SUBS:
        result = result.replace(es_word, it_word)
        # Also try capitalized version
        if es_word[0].isalpha():
            result = result.replace(es_word.capitalize(), it_word.capitalize())
    
    return result


def main():
    filepath = 'lib/core/config/app_translations.dart'
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Extract Spanish entries
    es_entries, _, _ = extract_section(content, '_es')
    key_count = len([e for e in es_entries if e[0] not in ('COMMENT', 'EMPTY')])
    print(f"Extracted {key_count} Spanish keys")
    
    # Generate Italian section
    lines = []
    lines.append('')
    lines.append('  // ─── ITALIANO ──────────────────────────────────────────────────')
    lines.append("  static const Map<String, String> _it = {")
    
    translated = 0
    kept_original = 0
    
    for key, value in es_entries:
        if key == 'COMMENT':
            lines.append(f'    {value}')
            continue
        if key == 'EMPTY':
            lines.append('')
            continue
        
        it_value = translate_value(value)
        # Escape single quotes in value
        it_value_escaped = it_value.replace("'", "\\'") if "'" in it_value and "\\'" not in it_value else it_value
        
        if it_value != value:
            translated += 1
        else:
            kept_original += 1
        
        lines.append(f"    '{key}': '{it_value_escaped}',")
    
    lines.append('  };')
    
    print(f"Translated: {translated}, Kept original: {kept_original}")
    
    # Write output
    output_file = 'lib/core/config/app_translations_it.dart.tmp'
    with open(output_file, 'w', encoding='utf-8') as f:
        f.write('\n'.join(lines))
    
    print(f"Written to {output_file}")
    print(f"Total lines: {len(lines)}")


if __name__ == '__main__':
    main()
