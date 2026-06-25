#!/usr/bin/env python3
"""Add batch 3 translation keys to app_translations.dart."""

import re

TRANSLATIONS_FILE = 'lib/core/config/app_translations.dart'

NEW_KEYS = {
    'es': {
        # report_flow_screen
        'what_do_you_want_to_report': '¿Qué quieres reportar?',
        'your_report_is_anonymous': 'Tu reporte es anónimo',
        'report_anonymous_detail': 'La persona a la que reportes no sabrá quién realizó el reporte. Nuestro equipo revisará tu caso.',
        'emergency_danger_warning': 'Si alguien se encuentra en peligro inmediato, llama a los servicios de emergencia locales.',
        'select_the_post': 'Selecciona la publicación',
        'tap_post_to_report': 'Toca la publicación que quieres reportar',
        'user_has_no_posts': 'Este usuario no tiene publicaciones',
        'why_report_post': '¿Por qué reportas esta publicación?',
        'why_report_account': '¿Por qué reportas esta cuenta?',
        'select_best_reason': 'Selecciona el motivo que mejor se ajuste',
        'selected_post': 'Publicación seleccionada',
        'report_sent_title': 'Reporte enviado',
        'report_sent_message': 'Gracias por ayudar a mantener BIUX seguro.\nNuestro equipo revisará tu reporte.',
        # report_flow_screen reasons
        'report_reason_sexual': 'Contenido sexual',
        'report_reason_violence': 'Violencia o amenazas',
        'report_reason_harassment': 'Acoso o intimidación',
        'report_reason_false_info': 'Información falsa',
        'report_reason_spam': 'Spam',
        'report_reason_hate': 'Discurso de odio',
        'report_reason_illegal_sales': 'Venta de artículos ilegales',
        'report_reason_intellectual_property': 'Propiedad intelectual',
        'report_reason_disturbing': 'Contenido perturbador',
        'report_reason_other': 'Otro',
        'report_reason_impersonation': 'Suplantación de identidad',
        'report_reason_hacked': 'Cuenta hackeada',
        'report_reason_fake_account': 'Cuenta falsa',
        'report_reason_inappropriate_username': 'Nombre de usuario inapropiado',
        'report_reason_automated': 'Cuenta automatizada (bot)',
        'report_reason_underage': 'Menor de edad',
        'report_reason_self_harm': 'Autolesión o suicidio',
        'report_reason_illegal_products': 'Productos ilegales',
        # report_user_screen
        'report_sent_thanks': 'Reporte enviado. Gracias por hacer Biux más seguro',
        'error_sending_report': 'Error al enviar el reporte',
        'reporting_user': 'Reportando a',
        'why_report_this_user': '¿Por qué reportas este usuario?',
        # profile_highlights
        'highlight_default': 'Destacado',
        'select_stories': 'Selecciona historias:',
        # public_user_profile / experience_author
        'not_following_anyone': 'No sigue a nadie aún',
        'in_post_of': 'En post de',
        'daily_average': 'Promedio Diario',
        'last_7_days': 'Últimos 7 días',
        'time_ago': 'Hace',
        'time_now': 'Ahora',
        'check_profile_of': 'Mira el perfil de',
        'on_biux': 'en Biux',
        # post_detail_screen — reposted_from already exists
        # report_content_dialog
        'reason_inappropriate': 'Contenido inapropiado',
        'reason_spam': 'Spam o publicidad',
        'reason_harassment': 'Acoso o bullying',
        'reason_false_info': 'Información falsa',
        'reason_violent': 'Contenido violento',
        'reason_impersonation': 'Suplantación de identidad',
        'reason_other': 'Otro',
        'why_report_content': '¿Por qué deseas reportar este contenido?',
        'report_sent_review': 'Reporte enviado. Revisaremos el contenido.',
        # two_factor_screen
        'error_sending_code': 'Error al enviar el código',
        'enter_6_digits': 'Introduce los 6 dígitos',
        '2fa_activated': '2FA activado correctamente',
        'incorrect_code': 'Código incorrecto',
        'error_verifying': 'Error al verificar',
        'two_factor_extra_security': 'La verificación en dos pasos añade una capa extra de seguridad a tu cuenta.',
        # active_sessions_screen
        'sessions_registered': 'inicio(s) de sesión registrado(s)',
        'devices_signed_in': 'Dispositivos donde iniciaste sesión con tu número en Biux',
        'this_device': 'Este dispositivo',
        'unknown_device': 'Dispositivo desconocido',
        'confirm_close_all_sessions': '¿Seguro que quieres cerrar sesión en todos los dispositivos?',
        'firebase_account_data': 'Datos de tu cuenta Firebase',
        'current_session': 'Sesión actual',
        'last_access_label': 'Último acceso',
        # blocked_users_screen
        'no_blocked_users': 'No has bloqueado a ningún usuario',
        'confirm_unblock_user': '¿Deseas desbloquear a este usuario? Podrá volver a enviarte mensajes.',
        'user_label': 'Usuario',
        'unblock_action': 'Desbloquear',
        # user_provider fields
        'field_name': 'Nombre',
        'field_username': 'Nombre de usuario',
        'field_profile_photo': 'Foto de perfil',
        'field_bio': 'Biografía',
        'follow_me_on_biux': '¡Sígueme en Biux! 🚴',
    },
    'en': {
        'what_do_you_want_to_report': 'What do you want to report?',
        'your_report_is_anonymous': 'Your report is anonymous',
        'report_anonymous_detail': 'The person you report will not know who made the report. Our team will review your case.',
        'emergency_danger_warning': 'If someone is in immediate danger, call local emergency services.',
        'select_the_post': 'Select the post',
        'tap_post_to_report': 'Tap the post you want to report',
        'user_has_no_posts': 'This user has no posts',
        'why_report_post': 'Why are you reporting this post?',
        'why_report_account': 'Why are you reporting this account?',
        'select_best_reason': 'Select the reason that best fits',
        'selected_post': 'Selected post',
        'report_sent_title': 'Report sent',
        'report_sent_message': 'Thank you for helping keep BIUX safe.\nOur team will review your report.',
        'report_reason_sexual': 'Sexual content',
        'report_reason_violence': 'Violence or threats',
        'report_reason_harassment': 'Harassment or intimidation',
        'report_reason_false_info': 'False information',
        'report_reason_spam': 'Spam',
        'report_reason_hate': 'Hate speech',
        'report_reason_illegal_sales': 'Sale of illegal items',
        'report_reason_intellectual_property': 'Intellectual property',
        'report_reason_disturbing': 'Disturbing content',
        'report_reason_other': 'Other',
        'report_reason_impersonation': 'Impersonation',
        'report_reason_hacked': 'Hacked account',
        'report_reason_fake_account': 'Fake account',
        'report_reason_inappropriate_username': 'Inappropriate username',
        'report_reason_automated': 'Automated account (bot)',
        'report_reason_underage': 'Underage',
        'report_reason_self_harm': 'Self-harm or suicide',
        'report_reason_illegal_products': 'Illegal products',
        'report_sent_thanks': 'Report sent. Thank you for making Biux safer',
        'error_sending_report': 'Error sending report',
        'reporting_user': 'Reporting',
        'why_report_this_user': 'Why are you reporting this user?',
        'highlight_default': 'Highlight',
        'select_stories': 'Select stories:',
        'not_following_anyone': 'Not following anyone yet',
        'in_post_of': 'In post by',
        'daily_average': 'Daily Average',
        'last_7_days': 'Last 7 days',
        'time_ago': 'Ago',
        'time_now': 'Now',
        'check_profile_of': 'Check out the profile of',
        'on_biux': 'on Biux',
        'reason_inappropriate': 'Inappropriate content',
        'reason_spam': 'Spam or advertising',
        'reason_harassment': 'Harassment or bullying',
        'reason_false_info': 'False information',
        'reason_violent': 'Violent content',
        'reason_impersonation': 'Impersonation',
        'reason_other': 'Other',
        'why_report_content': 'Why do you want to report this content?',
        'report_sent_review': 'Report sent. We will review the content.',
        'error_sending_code': 'Error sending code',
        'enter_6_digits': 'Enter the 6 digits',
        '2fa_activated': '2FA activated successfully',
        'incorrect_code': 'Incorrect code',
        'error_verifying': 'Error verifying',
        'two_factor_extra_security': 'Two-step verification adds an extra layer of security to your account.',
        'sessions_registered': 'session(s) registered',
        'devices_signed_in': 'Devices where you signed in with your number on Biux',
        'this_device': 'This device',
        'unknown_device': 'Unknown device',
        'confirm_close_all_sessions': 'Are you sure you want to close sessions on all devices?',
        'firebase_account_data': 'Your Firebase account data',
        'current_session': 'Current session',
        'last_access_label': 'Last access',
        'no_blocked_users': 'You haven\'t blocked any users',
        'confirm_unblock_user': 'Do you want to unblock this user? They will be able to send you messages again.',
        'user_label': 'User',
        'unblock_action': 'Unblock',
        'field_name': 'Name',
        'field_username': 'Username',
        'field_profile_photo': 'Profile photo',
        'field_bio': 'Bio',
        'follow_me_on_biux': 'Follow me on Biux! 🚴',
    },
    'pt': {
        'what_do_you_want_to_report': 'O que você quer denunciar?',
        'your_report_is_anonymous': 'Sua denúncia é anônima',
        'report_anonymous_detail': 'A pessoa que você denunciar não saberá quem fez a denúncia. Nossa equipe revisará seu caso.',
        'emergency_danger_warning': 'Se alguém está em perigo imediato, ligue para os serviços de emergência locais.',
        'select_the_post': 'Selecione a publicação',
        'tap_post_to_report': 'Toque na publicação que deseja denunciar',
        'user_has_no_posts': 'Este usuário não tem publicações',
        'why_report_post': 'Por que você está denunciando esta publicação?',
        'why_report_account': 'Por que você está denunciando esta conta?',
        'select_best_reason': 'Selecione o motivo que melhor se aplica',
        'selected_post': 'Publicação selecionada',
        'report_sent_title': 'Denúncia enviada',
        'report_sent_message': 'Obrigado por ajudar a manter o BIUX seguro.\nNossa equipe revisará sua denúncia.',
        'report_reason_sexual': 'Conteúdo sexual',
        'report_reason_violence': 'Violência ou ameaças',
        'report_reason_harassment': 'Assédio ou intimidação',
        'report_reason_false_info': 'Informação falsa',
        'report_reason_spam': 'Spam',
        'report_reason_hate': 'Discurso de ódio',
        'report_reason_illegal_sales': 'Venda de itens ilegais',
        'report_reason_intellectual_property': 'Propriedade intelectual',
        'report_reason_disturbing': 'Conteúdo perturbador',
        'report_reason_other': 'Outro',
        'report_reason_impersonation': 'Falsidade ideológica',
        'report_reason_hacked': 'Conta hackeada',
        'report_reason_fake_account': 'Conta falsa',
        'report_reason_inappropriate_username': 'Nome de usuário inapropriado',
        'report_reason_automated': 'Conta automatizada (bot)',
        'report_reason_underage': 'Menor de idade',
        'report_reason_self_harm': 'Autolesão ou suicídio',
        'report_reason_illegal_products': 'Produtos ilegais',
        'report_sent_thanks': 'Denúncia enviada. Obrigado por tornar o Biux mais seguro',
        'error_sending_report': 'Erro ao enviar denúncia',
        'reporting_user': 'Denunciando',
        'why_report_this_user': 'Por que você está denunciando este usuário?',
        'highlight_default': 'Destaque',
        'select_stories': 'Selecione histórias:',
        'not_following_anyone': 'Não segue ninguém ainda',
        'in_post_of': 'No post de',
        'daily_average': 'Média Diária',
        'last_7_days': 'Últimos 7 dias',
        'time_ago': 'Há',
        'time_now': 'Agora',
        'check_profile_of': 'Confira o perfil de',
        'on_biux': 'no Biux',
        'reason_inappropriate': 'Conteúdo inapropriado',
        'reason_spam': 'Spam ou publicidade',
        'reason_harassment': 'Assédio ou bullying',
        'reason_false_info': 'Informação falsa',
        'reason_violent': 'Conteúdo violento',
        'reason_impersonation': 'Falsidade ideológica',
        'reason_other': 'Outro',
        'why_report_content': 'Por que você deseja denunciar este conteúdo?',
        'report_sent_review': 'Denúncia enviada. Revisaremos o conteúdo.',
        'error_sending_code': 'Erro ao enviar o código',
        'enter_6_digits': 'Insira os 6 dígitos',
        '2fa_activated': '2FA ativado com sucesso',
        'incorrect_code': 'Código incorreto',
        'error_verifying': 'Erro ao verificar',
        'two_factor_extra_security': 'A verificação em duas etapas adiciona uma camada extra de segurança à sua conta.',
        'sessions_registered': 'sessão(ões) registrada(s)',
        'devices_signed_in': 'Dispositivos onde você fez login com seu número no Biux',
        'this_device': 'Este dispositivo',
        'unknown_device': 'Dispositivo desconhecido',
        'confirm_close_all_sessions': 'Tem certeza de que deseja encerrar sessões em todos os dispositivos?',
        'firebase_account_data': 'Dados da sua conta Firebase',
        'current_session': 'Sessão atual',
        'last_access_label': 'Último acesso',
        'no_blocked_users': 'Você não bloqueou nenhum usuário',
        'confirm_unblock_user': 'Deseja desbloquear este usuário? Ele poderá enviar mensagens novamente.',
        'user_label': 'Usuário',
        'unblock_action': 'Desbloquear',
        'field_name': 'Nome',
        'field_username': 'Nome de usuário',
        'field_profile_photo': 'Foto de perfil',
        'field_bio': 'Biografia',
        'follow_me_on_biux': 'Siga-me no Biux! 🚴',
    },
    'fr': {
        'what_do_you_want_to_report': 'Que voulez-vous signaler ?',
        'your_report_is_anonymous': 'Votre signalement est anonyme',
        'report_anonymous_detail': 'La personne que vous signalez ne saura pas qui a fait le signalement. Notre équipe examinera votre cas.',
        'emergency_danger_warning': 'Si quelqu\'un est en danger immédiat, appelez les services d\'urgence locaux.',
        'select_the_post': 'Sélectionnez la publication',
        'tap_post_to_report': 'Touchez la publication que vous souhaitez signaler',
        'user_has_no_posts': 'Cet utilisateur n\'a pas de publications',
        'why_report_post': 'Pourquoi signalez-vous cette publication ?',
        'why_report_account': 'Pourquoi signalez-vous ce compte ?',
        'select_best_reason': 'Sélectionnez le motif le plus approprié',
        'selected_post': 'Publication sélectionnée',
        'report_sent_title': 'Signalement envoyé',
        'report_sent_message': 'Merci d\'aider à garder BIUX sûr.\nNotre équipe examinera votre signalement.',
        'report_reason_sexual': 'Contenu sexuel',
        'report_reason_violence': 'Violence ou menaces',
        'report_reason_harassment': 'Harcèlement ou intimidation',
        'report_reason_false_info': 'Fausse information',
        'report_reason_spam': 'Spam',
        'report_reason_hate': 'Discours de haine',
        'report_reason_illegal_sales': 'Vente d\'articles illégaux',
        'report_reason_intellectual_property': 'Propriété intellectuelle',
        'report_reason_disturbing': 'Contenu perturbant',
        'report_reason_other': 'Autre',
        'report_reason_impersonation': 'Usurpation d\'identité',
        'report_reason_hacked': 'Compte piraté',
        'report_reason_fake_account': 'Faux compte',
        'report_reason_inappropriate_username': 'Nom d\'utilisateur inapproprié',
        'report_reason_automated': 'Compte automatisé (bot)',
        'report_reason_underage': 'Mineur',
        'report_reason_self_harm': 'Automutilation ou suicide',
        'report_reason_illegal_products': 'Produits illégaux',
        'report_sent_thanks': 'Signalement envoyé. Merci de rendre Biux plus sûr',
        'error_sending_report': 'Erreur lors de l\'envoi du signalement',
        'reporting_user': 'Signalement de',
        'why_report_this_user': 'Pourquoi signalez-vous cet utilisateur ?',
        'highlight_default': 'À la une',
        'select_stories': 'Sélectionnez des stories :',
        'not_following_anyone': 'Ne suit personne encore',
        'in_post_of': 'Dans le post de',
        'daily_average': 'Moyenne Quotidienne',
        'last_7_days': '7 derniers jours',
        'time_ago': 'Il y a',
        'time_now': 'Maintenant',
        'check_profile_of': 'Découvrez le profil de',
        'on_biux': 'sur Biux',
        'reason_inappropriate': 'Contenu inapproprié',
        'reason_spam': 'Spam ou publicité',
        'reason_harassment': 'Harcèlement ou bullying',
        'reason_false_info': 'Fausse information',
        'reason_violent': 'Contenu violent',
        'reason_impersonation': 'Usurpation d\'identité',
        'reason_other': 'Autre',
        'why_report_content': 'Pourquoi souhaitez-vous signaler ce contenu ?',
        'report_sent_review': 'Signalement envoyé. Nous examinerons le contenu.',
        'error_sending_code': 'Erreur lors de l\'envoi du code',
        'enter_6_digits': 'Entrez les 6 chiffres',
        '2fa_activated': '2FA activé avec succès',
        'incorrect_code': 'Code incorrect',
        'error_verifying': 'Erreur de vérification',
        'two_factor_extra_security': 'La vérification en deux étapes ajoute une couche de sécurité supplémentaire à votre compte.',
        'sessions_registered': 'session(s) enregistrée(s)',
        'devices_signed_in': 'Appareils où vous vous êtes connecté avec votre numéro sur Biux',
        'this_device': 'Cet appareil',
        'unknown_device': 'Appareil inconnu',
        'confirm_close_all_sessions': 'Êtes-vous sûr de vouloir fermer les sessions sur tous les appareils ?',
        'firebase_account_data': 'Données de votre compte Firebase',
        'current_session': 'Session actuelle',
        'last_access_label': 'Dernier accès',
        'no_blocked_users': 'Vous n\'avez bloqué aucun utilisateur',
        'confirm_unblock_user': 'Voulez-vous débloquer cet utilisateur ? Il pourra à nouveau vous envoyer des messages.',
        'user_label': 'Utilisateur',
        'unblock_action': 'Débloquer',
        'field_name': 'Nom',
        'field_username': 'Nom d\'utilisateur',
        'field_profile_photo': 'Photo de profil',
        'field_bio': 'Biographie',
        'follow_me_on_biux': 'Suivez-moi sur Biux ! 🚴',
    },
    'it': {
        'what_do_you_want_to_report': 'Cosa vuoi segnalare?',
        'your_report_is_anonymous': 'La tua segnalazione è anonima',
        'report_anonymous_detail': 'La persona che segnali non saprà chi ha fatto la segnalazione. Il nostro team esaminerà il tuo caso.',
        'emergency_danger_warning': 'Se qualcuno è in pericolo immediato, chiama i servizi di emergenza locali.',
        'select_the_post': 'Seleziona la pubblicazione',
        'tap_post_to_report': 'Tocca la pubblicazione che vuoi segnalare',
        'user_has_no_posts': 'Questo utente non ha pubblicazioni',
        'why_report_post': 'Perché segnali questa pubblicazione?',
        'why_report_account': 'Perché segnali questo account?',
        'select_best_reason': 'Seleziona il motivo più appropriato',
        'selected_post': 'Pubblicazione selezionata',
        'report_sent_title': 'Segnalazione inviata',
        'report_sent_message': 'Grazie per aiutare a mantenere BIUX sicuro.\nIl nostro team esaminerà la tua segnalazione.',
        'report_reason_sexual': 'Contenuto sessuale',
        'report_reason_violence': 'Violenza o minacce',
        'report_reason_harassment': 'Molestie o intimidazione',
        'report_reason_false_info': 'Informazioni false',
        'report_reason_spam': 'Spam',
        'report_reason_hate': 'Discorso d\'odio',
        'report_reason_illegal_sales': 'Vendita di articoli illegali',
        'report_reason_intellectual_property': 'Proprietà intellettuale',
        'report_reason_disturbing': 'Contenuto disturbante',
        'report_reason_other': 'Altro',
        'report_reason_impersonation': 'Furto d\'identità',
        'report_reason_hacked': 'Account violato',
        'report_reason_fake_account': 'Account falso',
        'report_reason_inappropriate_username': 'Nome utente inappropriato',
        'report_reason_automated': 'Account automatizzato (bot)',
        'report_reason_underage': 'Minorenne',
        'report_reason_self_harm': 'Autolesionismo o suicidio',
        'report_reason_illegal_products': 'Prodotti illegali',
        'report_sent_thanks': 'Segnalazione inviata. Grazie per rendere Biux più sicuro',
        'error_sending_report': 'Errore nell\'invio della segnalazione',
        'reporting_user': 'Segnalazione di',
        'why_report_this_user': 'Perché segnali questo utente?',
        'highlight_default': 'In evidenza',
        'select_stories': 'Seleziona storie:',
        'not_following_anyone': 'Non segue ancora nessuno',
        'in_post_of': 'Nel post di',
        'daily_average': 'Media Giornaliera',
        'last_7_days': 'Ultimi 7 giorni',
        'time_ago': 'Fa',
        'time_now': 'Adesso',
        'check_profile_of': 'Guarda il profilo di',
        'on_biux': 'su Biux',
        'reason_inappropriate': 'Contenuto inappropriato',
        'reason_spam': 'Spam o pubblicità',
        'reason_harassment': 'Molestie o bullismo',
        'reason_false_info': 'Informazioni false',
        'reason_violent': 'Contenuto violento',
        'reason_impersonation': 'Furto d\'identità',
        'reason_other': 'Altro',
        'why_report_content': 'Perché vuoi segnalare questo contenuto?',
        'report_sent_review': 'Segnalazione inviata. Esamineremo il contenuto.',
        'error_sending_code': 'Errore nell\'invio del codice',
        'enter_6_digits': 'Inserisci le 6 cifre',
        '2fa_activated': '2FA attivato con successo',
        'incorrect_code': 'Codice errato',
        'error_verifying': 'Errore nella verifica',
        'two_factor_extra_security': 'La verifica in due passaggi aggiunge un livello extra di sicurezza al tuo account.',
        'sessions_registered': 'sessione/i registrata/e',
        'devices_signed_in': 'Dispositivi dove hai effettuato l\'accesso con il tuo numero su Biux',
        'this_device': 'Questo dispositivo',
        'unknown_device': 'Dispositivo sconosciuto',
        'confirm_close_all_sessions': 'Sei sicuro di voler chiudere le sessioni su tutti i dispositivi?',
        'firebase_account_data': 'Dati del tuo account Firebase',
        'current_session': 'Sessione attuale',
        'last_access_label': 'Ultimo accesso',
        'no_blocked_users': 'Non hai bloccato nessun utente',
        'confirm_unblock_user': 'Vuoi sbloccare questo utente? Potrà inviarti nuovamente messaggi.',
        'user_label': 'Utente',
        'unblock_action': 'Sblocca',
        'field_name': 'Nome',
        'field_username': 'Nome utente',
        'field_profile_photo': 'Foto profilo',
        'field_bio': 'Biografia',
        'follow_me_on_biux': 'Seguimi su Biux! 🚴',
    },
}

# Map closing patterns per language
LANG_MARKERS = {
    'es': ('_es', r"^  \};"),
    'en': ('_en', r"^  \};"),
    'pt': ('_pt', r"^  \};"),
    'fr': ('_fr', r"^  \};"),
    'it': ('_it', r"^  \};"),
}


def find_map_closing(lines, map_name):
    """Find the closing `};` of a specific map declaration."""
    in_map = False
    brace_count = 0
    for i, line in enumerate(lines):
        if f'Map<String, String> {map_name}' in line or f'final {map_name}' in line:
            in_map = True
        if in_map:
            brace_count += line.count('{') - line.count('}')
            if brace_count <= 0 and in_map:
                return i
    return -1


def main():
    with open(TRANSLATIONS_FILE, 'r', encoding='utf-8') as f:
        content = f.read()
    lines = content.split('\n')

    # Find existing keys to avoid duplicates
    existing_keys = set()
    for line in lines:
        m = re.match(r"\s+'(\w+)'\s*:", line)
        if m:
            existing_keys.add(m.group(1))

    maps_order = ['_es', '_en', '_pt', '_fr', '_it']
    lang_order = ['es', 'en', 'pt', 'fr', 'it']

    # Find all map closings
    closings = {}
    for map_name in maps_order:
        idx = find_map_closing(lines, map_name)
        if idx == -1:
            print(f"ERROR: Could not find closing for {map_name}")
            return
        closings[map_name] = idx
        print(f"Found {map_name} closing at line {idx + 1}")

    # Insert keys from bottom to top to preserve line numbers
    for map_name, lang in reversed(list(zip(maps_order, lang_order))):
        keys = NEW_KEYS.get(lang, {})
        if not keys:
            continue
        
        insert_lines = []
        for key, value in keys.items():
            if key in existing_keys:
                print(f"  SKIP (exists): '{key}' in {lang}")
                continue
            # Escape single quotes in value
            escaped_value = value.replace("'", "\\'")
            insert_lines.append(f"    '{key}': '{escaped_value}',")
        
        if insert_lines:
            closing_idx = closings[map_name]
            # Insert before the closing };
            for j, insert_line in enumerate(insert_lines):
                lines.insert(closing_idx + j, insert_line)
            print(f"  Inserted {len(insert_lines)} keys into {map_name}")
            
            # Adjust subsequent closing indices
            offset = len(insert_lines)
            for mn in maps_order:
                if closings[mn] > closings[map_name]:
                    closings[mn] += offset

    with open(TRANSLATIONS_FILE, 'w', encoding='utf-8') as f:
        f.write('\n'.join(lines))
    
    print("\nDone! Keys added successfully.")


if __name__ == '__main__':
    main()
