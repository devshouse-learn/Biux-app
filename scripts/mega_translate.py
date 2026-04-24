#!/usr/bin/env python3
"""
Mega translation script for Biux app.
Phase 1: Add all missing translation keys to all 5 language sections.
Phase 2: Replace hardcoded Spanish strings with l.t() calls in presentation files.
Phase 3: Ensure 'l' variable is available in all modified files.
Phase 4: Remove 'const' from widgets containing l.t().
"""
import re
import os
import glob

TRANS_FILE = 'lib/core/config/app_translations.dart'

# =============================================================================
# PHASE 1: Define all new translation keys
# =============================================================================
# Format: 'key': {'es': 'Spanish', 'en': 'English', 'pt': 'Portuguese', 'fr': 'French', 'it': 'Italian'}
NEW_KEYS = {
    # ── Common UI buttons/actions ──
    'cancel': {'es': 'Cancelar', 'en': 'Cancel', 'pt': 'Cancelar', 'fr': 'Annuler', 'it': 'Annulla'},
    'save': {'es': 'Guardar', 'en': 'Save', 'pt': 'Salvar', 'fr': 'Enregistrer', 'it': 'Salva'},
    'delete': {'es': 'Eliminar', 'en': 'Delete', 'pt': 'Excluir', 'fr': 'Supprimer', 'it': 'Elimina'},
    'edit': {'es': 'Editar', 'en': 'Edit', 'pt': 'Editar', 'fr': 'Modifier', 'it': 'Modifica'},
    'confirm': {'es': 'Confirmar', 'en': 'Confirm', 'pt': 'Confirmar', 'fr': 'Confirmer', 'it': 'Conferma'},
    'accept': {'es': 'Aceptar', 'en': 'Accept', 'pt': 'Aceitar', 'fr': 'Accepter', 'it': 'Accetta'},
    'close': {'es': 'Cerrar', 'en': 'Close', 'pt': 'Fechar', 'fr': 'Fermer', 'it': 'Chiudi'},
    'continue_action': {'es': 'Continuar', 'en': 'Continue', 'pt': 'Continuar', 'fr': 'Continuer', 'it': 'Continua'},
    'discard': {'es': 'Descartar', 'en': 'Discard', 'pt': 'Descartar', 'fr': 'Abandonner', 'it': 'Scarta'},
    'exit': {'es': 'Salir', 'en': 'Exit', 'pt': 'Sair', 'fr': 'Quitter', 'it': 'Esci'},
    'loading': {'es': 'Cargando...', 'en': 'Loading...', 'pt': 'Carregando...', 'fr': 'Chargement...', 'it': 'Caricamento...'},
    'share': {'es': 'Compartir', 'en': 'Share', 'pt': 'Compartilhar', 'fr': 'Partager', 'it': 'Condividi'},
    'use_video': {'es': 'Usar video', 'en': 'Use video', 'pt': 'Usar vídeo', 'fr': 'Utiliser la vidéo', 'it': 'Usa video'},
    'publish': {'es': 'Publicar', 'en': 'Publish', 'pt': 'Publicar', 'fr': 'Publier', 'it': 'Pubblica'},
    'select': {'es': 'Seleccionar', 'en': 'Select', 'pt': 'Selecionar', 'fr': 'Sélectionner', 'it': 'Seleziona'},
    'block': {'es': 'Bloquear', 'en': 'Block', 'pt': 'Bloquear', 'fr': 'Bloquer', 'it': 'Blocca'},
    'unblock': {'es': 'Desbloquear', 'en': 'Unblock', 'pt': 'Desbloquear', 'fr': 'Débloquer', 'it': 'Sblocca'},

    # ── Profile ──
    'profile': {'es': 'Perfil', 'en': 'Profile', 'pt': 'Perfil', 'fr': 'Profil', 'it': 'Profilo'},
    'edit_profile': {'es': 'Editar perfil', 'en': 'Edit profile', 'pt': 'Editar perfil', 'fr': 'Modifier le profil', 'it': 'Modifica profilo'},
    'profile_photo': {'es': 'Foto de Perfil', 'en': 'Profile Photo', 'pt': 'Foto de Perfil', 'fr': 'Photo de profil', 'it': 'Foto del profilo'},
    'cover_photo': {'es': 'Foto de Portada', 'en': 'Cover Photo', 'pt': 'Foto de Capa', 'fr': 'Photo de couverture', 'it': 'Foto di copertina'},
    'add_cover': {'es': 'Agregar portada', 'en': 'Add cover', 'pt': 'Adicionar capa', 'fr': 'Ajouter une couverture', 'it': 'Aggiungi copertina'},
    'name_label': {'es': 'Nombre', 'en': 'Name', 'pt': 'Nome', 'fr': 'Nom', 'it': 'Nome'},
    'username_label': {'es': 'Nombre de Usuario', 'en': 'Username', 'pt': 'Nome de Usuário', 'fr': "Nom d'utilisateur", 'it': 'Nome utente'},
    'description_bio': {'es': 'Descripción / Bio', 'en': 'Description / Bio', 'pt': 'Descrição / Bio', 'fr': 'Description / Bio', 'it': 'Descrizione / Bio'},
    'profile_updated': {'es': 'Perfil actualizado correctamente', 'en': 'Profile updated successfully', 'pt': 'Perfil atualizado com sucesso', 'fr': 'Profil mis à jour avec succès', 'it': 'Profilo aggiornato con successo'},
    'try_again_later': {'es': 'Intenta nuevamente', 'en': 'Try again', 'pt': 'Tente novamente', 'fr': 'Réessayer', 'it': 'Riprova'},
    'error_loading_profile': {'es': 'Error cargando datos del perfil', 'en': 'Error loading profile data', 'pt': 'Erro ao carregar dados do perfil', 'fr': 'Erreur lors du chargement du profil', 'it': 'Errore nel caricamento del profilo'},
    'add_story': {'es': 'Agregar Historia', 'en': 'Add Story', 'pt': 'Adicionar História', 'fr': 'Ajouter une histoire', 'it': 'Aggiungi storia'},
    'no_name': {'es': 'Sin nombre', 'en': 'No name', 'pt': 'Sem nome', 'fr': 'Sans nom', 'it': 'Senza nome'},
    'followers': {'es': 'Seguidores', 'en': 'Followers', 'pt': 'Seguidores', 'fr': 'Abonnés', 'it': 'Follower'},
    'following': {'es': 'Siguiendo', 'en': 'Following', 'pt': 'Seguindo', 'fr': 'Abonnements', 'it': 'Seguiti'},
    'follow': {'es': 'Seguir', 'en': 'Follow', 'pt': 'Seguir', 'fr': 'Suivre', 'it': 'Segui'},
    'publications': {'es': 'Publicaciones', 'en': 'Posts', 'pt': 'Publicações', 'fr': 'Publications', 'it': 'Pubblicazioni'},
    'no_posts_yet': {'es': 'Sin publicaciones aún', 'en': 'No posts yet', 'pt': 'Sem publicações ainda', 'fr': 'Pas encore de publications', 'it': 'Nessuna pubblicazione ancora'},
    'no_valid_posts': {'es': 'Sin publicaciones válidas', 'en': 'No valid posts', 'pt': 'Sem publicações válidas', 'fr': 'Aucune publication valide', 'it': 'Nessuna pubblicazione valida'},
    'no_reposts_yet': {'es': 'Sin reposteos aún', 'en': 'No reposts yet', 'pt': 'Sem repostagens ainda', 'fr': 'Pas encore de repartages', 'it': 'Nessun repost ancora'},
    'create_first_post': {'es': 'Crea tu primera publicación', 'en': 'Create your first post', 'pt': 'Crie sua primeira publicação', 'fr': 'Créez votre première publication', 'it': 'Crea la tua prima pubblicazione'},
    'repost_other_users': {'es': 'Repostea publicaciones de otros usuarios', 'en': 'Repost from other users', 'pt': 'Reposte publicações de outros usuários', 'fr': "Repartagez les publications d'autres utilisateurs", 'it': 'Riposta pubblicazioni di altri utenti'},
    'delete_publication_question': {'es': '¿Eliminar publicación?', 'en': 'Delete post?', 'pt': 'Excluir publicação?', 'fr': 'Supprimer la publication ?', 'it': 'Eliminare la pubblicazione?'},
    'action_cannot_undo': {'es': 'Esta acción no se puede deshacer', 'en': 'This action cannot be undone', 'pt': 'Esta ação não pode ser desfeita', 'fr': 'Cette action est irréversible', 'it': 'Questa azione non può essere annullata'},
    'delete_repost_question': {'es': '¿Deseas eliminar este reposteo de tu perfil?', 'en': 'Do you want to remove this repost from your profile?', 'pt': 'Deseja remover esta repostagem do seu perfil?', 'fr': 'Voulez-vous supprimer ce repartage de votre profil ?', 'it': 'Vuoi eliminare questo repost dal tuo profilo?'},
    'error_loading_posts': {'es': 'Error cargando publicaciones', 'en': 'Error loading posts', 'pt': 'Erro ao carregar publicações', 'fr': 'Erreur lors du chargement des publications', 'it': 'Errore nel caricamento delle pubblicazioni'},
    'user_not_found': {'es': 'Usuario no encontrado', 'en': 'User not found', 'pt': 'Usuário não encontrado', 'fr': 'Utilisateur non trouvé', 'it': 'Utente non trovato'},
    'error_loading_profile_msg': {'es': 'Error al cargar el perfil', 'en': 'Error loading profile', 'pt': 'Erro ao carregar o perfil', 'fr': 'Erreur lors du chargement du profil', 'it': 'Errore nel caricamento del profilo'},
    'verify_connection_retry': {'es': 'Verifica tu conexión e intenta nuevamente', 'en': 'Check your connection and try again', 'pt': 'Verifique sua conexão e tente novamente', 'fr': 'Vérifiez votre connexion et réessayez', 'it': 'Verifica la connessione e riprova'},
    'copy_profile_url': {'es': 'Copiar URL del perfil', 'en': 'Copy profile URL', 'pt': 'Copiar URL do perfil', 'fr': "Copier l'URL du profil", 'it': "Copia l'URL del profilo"},
    'share_this_profile': {'es': 'Compartir este perfil', 'en': 'Share this profile', 'pt': 'Compartilhar este perfil', 'fr': 'Partager ce profil', 'it': 'Condividi questo profilo'},
    'block_user': {'es': 'Bloquear usuario', 'en': 'Block user', 'pt': 'Bloquear usuário', 'fr': "Bloquer l'utilisateur", 'it': "Blocca l'utente"},
    'block_user_question': {'es': '¿Deseas bloquear a este usuario?', 'en': 'Do you want to block this user?', 'pt': 'Deseja bloquear este usuário?', 'fr': 'Voulez-vous bloquer cet utilisateur ?', 'it': 'Vuoi bloccare questo utente?'},
    'block_user_msg': {'es': 'No podrá enviarte mensajes ni ver tu perfil.', 'en': 'They will not be able to send you messages or see your profile.', 'pt': 'Não poderá enviar mensagens nem ver seu perfil.', 'fr': 'Il ne pourra plus vous envoyer de messages ni voir votre profil.', 'it': 'Non potrà inviarti messaggi né vedere il tuo profilo.'},
    'user_blocked': {'es': 'Usuario bloqueado', 'en': 'User blocked', 'pt': 'Usuário bloqueado', 'fr': 'Utilisateur bloqué', 'it': 'Utente bloccato'},
    'no_followers_yet': {'es': 'Sin seguidores aún', 'en': 'No followers yet', 'pt': 'Sem seguidores ainda', 'fr': "Pas encore d'abonnés", 'it': 'Nessun follower ancora'},
    'user_default': {'es': 'Usuario', 'en': 'User', 'pt': 'Usuário', 'fr': 'Utilisateur', 'it': 'Utente'},
    'profile_completed_pct': {'es': 'Perfil completado al', 'en': 'Profile completed at', 'pt': 'Perfil completado em', 'fr': 'Profil complété à', 'it': 'Profilo completato al'},
    'complete': {'es': 'Completar', 'en': 'Complete', 'pt': 'Completar', 'fr': 'Compléter', 'it': 'Completa'},
    'report_user_label': {'es': 'Reportar', 'en': 'Report', 'pt': 'Denunciar', 'fr': 'Signaler', 'it': 'Segnala'},
    'not_defined': {'es': 'Sin definir', 'en': 'Not defined', 'pt': 'Não definido', 'fr': 'Non défini', 'it': 'Non definito'},

    # ── Activity Hub ──
    'posts_you_liked': {'es': 'Publicaciones que te gustaron', 'en': 'Posts you liked', 'pt': 'Publicações que você curtiu', 'fr': 'Publications que vous avez aimées', 'it': 'Pubblicazioni che ti sono piaciute'},
    'your_comments': {'es': 'Tus comentarios en publicaciones', 'en': 'Your comments on posts', 'pt': 'Seus comentários em publicações', 'fr': 'Vos commentaires sur des publications', 'it': 'I tuoi commenti sulle pubblicazioni'},
    'your_recent_stories': {'es': 'Tus historias recientes', 'en': 'Your recent stories', 'pt': 'Suas histórias recentes', 'fr': 'Vos histoires récentes', 'it': 'Le tue storie recenti'},
    'publication': {'es': 'Publicación', 'en': 'Post', 'pt': 'Publicação', 'fr': 'Publication', 'it': 'Pubblicazione'},
    'story_label': {'es': 'Historia', 'en': 'Story', 'pt': 'História', 'fr': 'Histoire', 'it': 'Storia'},
    'comments_label': {'es': 'Comentarios', 'en': 'Comments', 'pt': 'Comentários', 'fr': 'Commentaires', 'it': 'Commenti'},
    'no_comments_yet': {'es': 'No has hecho comentarios aún', 'en': 'You have not made any comments yet', 'pt': 'Você ainda não fez comentários', 'fr': "Vous n'avez pas encore fait de commentaires", 'it': 'Non hai ancora fatto commenti'},
    'likes_label': {'es': 'Me gusta', 'en': 'Likes', 'pt': 'Curtidas', 'fr': "J'aime", 'it': 'Mi piace'},
    'remove_like': {'es': 'Quitar Me gusta', 'en': 'Remove Like', 'pt': 'Remover Curtida', 'fr': "Retirer J'aime", 'it': 'Rimuovi Mi piace'},
    'remove_like_question': {'es': '¿Quieres quitar tu like? Desaparecerá de esta lista.', 'en': 'Do you want to remove your like? It will disappear from this list.', 'pt': 'Quer remover sua curtida? Ela desaparecerá desta lista.', 'fr': "Voulez-vous retirer votre j'aime ? Il disparaîtra de cette liste.", 'it': 'Vuoi rimuovere il tuo mi piace? Scomparirà da questa lista.'},
    'no_shared_posts': {'es': 'No has compartido publicaciones aún', 'en': 'You have not shared posts yet', 'pt': 'Você ainda não compartilhou publicações', 'fr': "Vous n'avez pas encore partagé de publications", 'it': 'Non hai ancora condiviso pubblicazioni'},
    'no_shared_stories': {'es': 'No has compartido historias aún', 'en': 'You have not shared stories yet', 'pt': 'Você ainda não compartilhou histórias', 'fr': "Vous n'avez pas encore partagé d'histoires", 'it': 'Non hai ancora condiviso storie'},
    'statistics': {'es': 'Estadísticas', 'en': 'Statistics', 'pt': 'Estatísticas', 'fr': 'Statistiques', 'it': 'Statistiche'},

    # ── Accessibility ──
    'bold_text': {'es': 'Texto en negrita', 'en': 'Bold text', 'pt': 'Texto em negrito', 'fr': 'Texte en gras', 'it': 'Testo in grassetto'},
    'high_contrast': {'es': 'Alto contraste', 'en': 'High contrast', 'pt': 'Alto contraste', 'fr': 'Contraste élevé', 'it': 'Alto contrasto'},
    'increase_contrast': {'es': 'Aumenta el contraste de colores', 'en': 'Increase color contrast', 'pt': 'Aumenta o contraste de cores', 'fr': 'Augmenter le contraste des couleurs', 'it': 'Aumenta il contrasto dei colori'},
    'reduce_animations': {'es': 'Reducir animaciones', 'en': 'Reduce animations', 'pt': 'Reduzir animações', 'fr': 'Réduire les animations', 'it': 'Riduci le animazioni'},
    'follow_system': {'es': 'Seguir al sistema', 'en': 'Follow system', 'pt': 'Seguir o sistema', 'fr': 'Suivre le système', 'it': 'Segui il sistema'},

    # ── Account & settings ──
    'account_label': {'es': 'Cuenta', 'en': 'Account', 'pt': 'Conta', 'fr': 'Compte', 'it': 'Account'},
    'active_sessions': {'es': 'Sesiones activas', 'en': 'Active sessions', 'pt': 'Sessões ativas', 'fr': 'Sessions actives', 'it': 'Sessioni attive'},
    'see_close_sessions': {'es': 'Ver y cerrar sesiones en otros dispositivos', 'en': 'View and close sessions on other devices', 'pt': 'Ver e fechar sessões em outros dispositivos', 'fr': 'Voir et fermer les sessions sur d\'autres appareils', 'it': 'Visualizza e chiudi sessioni su altri dispositivi'},
    'request_account_deletion': {'es': 'Solicitar eliminación de cuenta', 'en': 'Request account deletion', 'pt': 'Solicitar exclusão de conta', 'fr': 'Demander la suppression du compte', 'it': "Richiedi l'eliminazione dell'account"},
    'account_data_deleted': {'es': 'Tu cuenta y datos serán eliminados permanentemente', 'en': 'Your account and data will be permanently deleted', 'pt': 'Sua conta e dados serão excluídos permanentemente', 'fr': 'Votre compte et vos données seront supprimés définitivement', 'it': 'Il tuo account e i dati saranno eliminati in modo permanente'},
    'request_sent_email': {'es': 'Solicitud enviada. Recibirás un email con tus datos en 48h.', 'en': 'Request sent. You will receive an email with your data within 48h.', 'pt': 'Solicitação enviada. Você receberá um email com seus dados em 48h.', 'fr': 'Demande envoyée. Vous recevrez un email avec vos données sous 48h.', 'it': 'Richiesta inviata. Riceverai un\'email con i tuoi dati entro 48h.'},
    'delete_account_question': {'es': '¿Eliminar cuenta?', 'en': 'Delete account?', 'pt': 'Excluir conta?', 'fr': 'Supprimer le compte ?', 'it': "Eliminare l'account?"},
    'delete_account_irreversible': {'es': 'Esta acción es irreversible. Todos tus datos, grupos y rodadas serán eliminados permanentemente.', 'en': 'This action is irreversible. All your data, groups and rides will be permanently deleted.', 'pt': 'Esta ação é irreversível. Todos os seus dados, grupos e pedaladas serão excluídos permanentemente.', 'fr': 'Cette action est irréversible. Toutes vos données, groupes et sorties seront supprimés définitivement.', 'it': 'Questa azione è irreversibile. Tutti i tuoi dati, gruppi e pedalate saranno eliminati in modo permanente.'},
    'activity_history': {'es': 'Historial de actividad', 'en': 'Activity history', 'pt': 'Histórico de atividade', 'fr': "Historique d'activité", 'it': 'Cronologia attività'},
    'manage_activities': {'es': 'Gestiona qué actividades quedan registradas', 'en': 'Manage which activities are recorded', 'pt': 'Gerencie quais atividades ficam registradas', 'fr': 'Gérez quelles activités sont enregistrées', 'it': 'Gestisci quali attività vengono registrate'},

    # ── Permissions screen ──
    'permissions': {'es': 'Permisos', 'en': 'Permissions', 'pt': 'Permissões', 'fr': 'Autorisations', 'it': 'Autorizzazioni'},
    'camera_chat_reports': {'es': 'Fotos, cámara en chat y reportes', 'en': 'Photos, camera in chat and reports', 'pt': 'Fotos, câmera no chat e relatórios', 'fr': 'Photos, caméra dans le chat et signalements', 'it': 'Foto, fotocamera nella chat e segnalazioni'},
    'gallery_label': {'es': 'Galería', 'en': 'Gallery', 'pt': 'Galeria', 'fr': 'Galerie', 'it': 'Galleria'},
    'send_photos_videos': {'es': 'Enviar fotos y videos desde galería', 'en': 'Send photos and videos from gallery', 'pt': 'Enviar fotos e vídeos da galeria', 'fr': 'Envoyer des photos et vidéos depuis la galerie', 'it': 'Invia foto e video dalla galleria'},
    'gps_map_rides': {'es': 'GPS, mapa, rodadas y ubicación en chat', 'en': 'GPS, map, rides and location in chat', 'pt': 'GPS, mapa, pedaladas e localização no chat', 'fr': 'GPS, carte, sorties et localisation dans le chat', 'it': 'GPS, mappa, pedalate e posizione nella chat'},
    'messages_rides_alerts': {'es': 'Mensajes, rodadas y alertas', 'en': 'Messages, rides and alerts', 'pt': 'Mensagens, pedaladas e alertas', 'fr': 'Messages, sorties et alertes', 'it': 'Messaggi, pedalate e avvisi'},
    'find_friends_invite': {'es': 'Encontrar amigos e invitar ciclistas', 'en': 'Find friends and invite cyclists', 'pt': 'Encontrar amigos e convidar ciclistas', 'fr': 'Trouver des amis et inviter des cyclistes', 'it': 'Trova amici e invita ciclisti'},
    'permission_camera': {'es': 'cámara', 'en': 'camera', 'pt': 'câmera', 'fr': 'caméra', 'it': 'fotocamera'},
    'permission_location': {'es': 'ubicación', 'en': 'location', 'pt': 'localização', 'fr': 'localisation', 'it': 'posizione'},
    'permission_microphone': {'es': 'micrófono', 'en': 'microphone', 'pt': 'microfone', 'fr': 'microphone', 'it': 'microfono'},
    'permission_gallery': {'es': 'galería', 'en': 'gallery', 'pt': 'galeria', 'fr': 'galerie', 'it': 'galleria'},
    'permission_required': {'es': 'Permiso requerido', 'en': 'Permission required', 'pt': 'Permissão necessária', 'fr': 'Autorisation requise', 'it': 'Autorizzazione richiesta'},

    # ── Groups ──
    'delete_group_question': {'es': '¿Eliminar grupo?', 'en': 'Delete group?', 'pt': 'Excluir grupo?', 'fr': 'Supprimer le groupe ?', 'it': 'Eliminare il gruppo?'},
    'delete_group_permanent': {'es': 'Esta acción es permanente', 'en': 'This action is permanent', 'pt': 'Esta ação é permanente', 'fr': 'Cette action est permanente', 'it': 'Questa azione è permanente'},
    'delete_group': {'es': 'Borrar grupo', 'en': 'Delete group', 'pt': 'Excluir grupo', 'fr': 'Supprimer le groupe', 'it': 'Elimina il gruppo'},

    # ── Ride Tracker ──
    'ready_to_ride': {'es': '¿Listo para pedalear?', 'en': 'Ready to ride?', 'pt': 'Pronto para pedalar?', 'fr': 'Prêt à pédaler ?', 'it': 'Pronto a pedalare?'},
    'waiting_location': {'es': 'Espera mientras encontramos tu ubicación', 'en': 'Wait while we find your location', 'pt': 'Aguarde enquanto encontramos sua localização', 'fr': 'Attendez pendant que nous trouvons votre position', 'it': 'Attendi mentre troviamo la tua posizione'},
    'press_start_record': {'es': 'Presiona iniciar para grabar tu rodada', 'en': 'Press start to record your ride', 'pt': 'Pressione iniciar para gravar sua pedalada', 'fr': 'Appuyez sur démarrer pour enregistrer votre sortie', 'it': 'Premi avvia per registrare la tua pedalata'},
    'location_shared': {'es': 'Ubicación compartida', 'en': 'Location shared', 'pt': 'Localização compartilhada', 'fr': 'Position partagée', 'it': 'Posizione condivisa'},
    'update': {'es': 'Actualizar', 'en': 'Update', 'pt': 'Atualizar', 'fr': 'Mettre à jour', 'it': 'Aggiorna'},
    'history_updated': {'es': 'Historial actualizado', 'en': 'History updated', 'pt': 'Histórico atualizado', 'fr': 'Historique mis à jour', 'it': 'Cronologia aggiornata'},
    'no_rides_yet': {'es': 'Sin rodadas aún', 'en': 'No rides yet', 'pt': 'Sem pedaladas ainda', 'fr': 'Pas encore de sorties', 'it': 'Nessuna pedalata ancora'},
    'rides_will_appear': {'es': 'Tus rodadas grabadas aparecerán aquí', 'en': 'Your recorded rides will appear here', 'pt': 'Suas pedaladas gravadas aparecerão aqui', 'fr': 'Vos sorties enregistrées apparaîtront ici', 'it': 'Le tue pedalate registrate appariranno qui'},
    'rides_registered': {'es': 'rodadas registradas', 'en': 'registered rides', 'pt': 'pedaladas registradas', 'fr': 'sorties enregistrées', 'it': 'pedalate registrate'},
    'duration': {'es': 'Duración', 'en': 'Duration', 'pt': 'Duração', 'fr': 'Durée', 'it': 'Durata'},
    'ride_too_short_title': {'es': 'Rodada muy corta', 'en': 'Very short ride', 'pt': 'Pedalada muito curta', 'fr': 'Sortie très courte', 'it': 'Pedalata molto corta'},
    'finish_ride_question': {'es': '¿Finalizar rodada?', 'en': 'Finish ride?', 'pt': 'Finalizar pedalada?', 'fr': 'Terminer la sortie ?', 'it': 'Terminare la pedalata?'},
    'ride_name_question': {'es': '¿Cómo se llama esta rodada?', 'en': 'What is this ride called?', 'pt': 'Como se chama esta pedalada?', 'fr': 'Comment s\'appelle cette sortie ?', 'it': 'Come si chiama questa pedalata?'},
    'my_ride': {'es': 'Mi rodada', 'en': 'My ride', 'pt': 'Minha pedalada', 'fr': 'Ma sortie', 'it': 'La mia pedalata'},
    'exit_question': {'es': '¿Salir?', 'en': 'Exit?', 'pt': 'Sair?', 'fr': 'Quitter ?', 'it': 'Uscire?'},
    'ride_in_progress_warning': {'es': 'Tienes una rodada en curso. Si sales perderás los datos.', 'en': 'You have a ride in progress. If you exit you will lose the data.', 'pt': 'Você tem uma pedalada em andamento. Se sair, perderá os dados.', 'fr': 'Vous avez une sortie en cours. Si vous quittez, vous perdrez les données.', 'it': 'Hai una pedalata in corso. Se esci perderai i dati.'},
    'exit_ride_question': {'es': '¿Salir de la rodada?', 'en': 'Exit ride?', 'pt': 'Sair da pedalada?', 'fr': 'Quitter la sortie ?', 'it': 'Uscire dalla pedalata?'},
    'active_ride_warning': {'es': 'Tienes una rodada activa. Si sales, se perderá el progreso.', 'en': 'You have an active ride. If you exit, progress will be lost.', 'pt': 'Você tem uma pedalada ativa. Se sair, o progresso será perdido.', 'fr': 'Vous avez une sortie active. Si vous quittez, la progression sera perdue.', 'it': 'Hai una pedalata attiva. Se esci, il progresso andrà perso.'},
    'ride_deleted': {'es': 'Rodada eliminada', 'en': 'Ride deleted', 'pt': 'Pedalada excluída', 'fr': 'Sortie supprimée', 'it': 'Pedalata eliminata'},
    'ride_cancelled': {'es': 'Rodada cancelada', 'en': 'Ride cancelled', 'pt': 'Pedalada cancelada', 'fr': 'Sortie annulée', 'it': 'Pedalata annullata'},
    'ride_cancelled_by_organizer': {'es': 'Esta rodada ha sido cancelada por el organizador.', 'en': 'This ride has been cancelled by the organizer.', 'pt': 'Esta pedalada foi cancelada pelo organizador.', 'fr': 'Cette sortie a été annulée par l\'organisateur.', 'it': "Questa pedalata è stata annullata dall'organizzatore."},

    # ── Rides ──
    'ride_finished_no_add': {'es': 'Rodada finalizada - No se pueden agregar participantes', 'en': 'Ride finished - Cannot add participants', 'pt': 'Pedalada finalizada - Não é possível adicionar participantes', 'fr': 'Sortie terminée - Impossible d\'ajouter des participants', 'it': 'Pedalata terminata - Non è possibile aggiungere partecipanti'},
    'going_to_ride': {'es': '¿Vas a esta rodada?', 'en': 'Are you going to this ride?', 'pt': 'Vai a esta pedalada?', 'fr': 'Allez-vous à cette sortie ?', 'it': 'Vai a questa pedalata?'},
    'going_to_ride2': {'es': '¿Vas a ir a esta rodada?', 'en': 'Are you going to this ride?', 'pt': 'Vai participar desta pedalada?', 'fr': 'Allez-vous participer à cette sortie ?', 'it': 'Parteciperai a questa pedalata?'},
    'cancel_attendance_question': {'es': '¿Estás seguro de que ya no vas a asistir a esta rodada?', 'en': 'Are you sure you will not attend this ride anymore?', 'pt': 'Tem certeza de que não vai mais participar desta pedalada?', 'fr': 'Êtes-vous sûr de ne plus assister à cette sortie ?', 'it': 'Sei sicuro di non partecipare più a questa pedalata?'},
    'loading_weather': {'es': 'Cargando clima...', 'en': 'Loading weather...', 'pt': 'Carregando clima...', 'fr': 'Chargement de la météo...', 'it': 'Caricamento meteo...'},

    # ── Road Reports ──
    'unknown_location': {'es': 'Ubicación desconocida', 'en': 'Unknown location', 'pt': 'Localização desconhecida', 'fr': 'Lieu inconnu', 'it': 'Posizione sconosciuta'},
    'report_confirmed': {'es': '¡Reporte confirmado!', 'en': 'Report confirmed!', 'pt': 'Relatório confirmado!', 'fr': 'Signalement confirmé !', 'it': 'Segnalazione confermata!'},
    'delete_report_question': {'es': '¿Estás seguro de que quieres eliminar este reporte?', 'en': 'Are you sure you want to delete this report?', 'pt': 'Tem certeza de que quer excluir este relatório?', 'fr': 'Êtes-vous sûr de vouloir supprimer ce signalement ?', 'it': 'Sei sicuro di voler eliminare questa segnalazione?'},
    'report_deleted': {'es': 'Reporte eliminado', 'en': 'Report deleted', 'pt': 'Relatório excluído', 'fr': 'Signalement supprimé', 'it': 'Segnalazione eliminata'},
    'report_action': {'es': 'Reportar', 'en': 'Report', 'pt': 'Reportar', 'fr': 'Signaler', 'it': 'Segnala'},
    'no_active_reports': {'es': 'No hay reportes activos', 'en': 'No active reports', 'pt': 'Sem relatórios ativos', 'fr': 'Aucun signalement actif', 'it': 'Nessuna segnalazione attiva'},
    'danger': {'es': 'Peligro', 'en': 'Danger', 'pt': 'Perigo', 'fr': 'Danger', 'it': 'Pericolo'},
    'new_report': {'es': 'Nuevo Reporte', 'en': 'New Report', 'pt': 'Novo Relatório', 'fr': 'Nouveau signalement', 'it': 'Nuova segnalazione'},
    'description': {'es': 'Descripción', 'en': 'Description', 'pt': 'Descrição', 'fr': 'Description', 'it': 'Descrizione'},
    'current_location_used': {'es': 'Se usará tu ubicación actual', 'en': 'Your current location will be used', 'pt': 'Sua localização atual será usada', 'fr': 'Votre position actuelle sera utilisée', 'it': 'Verrà utilizzata la tua posizione attuale'},
    'send_report': {'es': 'Enviar Reporte', 'en': 'Send Report', 'pt': 'Enviar Relatório', 'fr': 'Envoyer le signalement', 'it': 'Invia segnalazione'},
    'report_sent_success': {'es': '¡Reporte enviado!', 'en': 'Report sent!', 'pt': 'Relatório enviado!', 'fr': 'Signalement envoyé !', 'it': 'Segnalazione inviata!'},
    'cyclist_label': {'es': 'Ciclista', 'en': 'Cyclist', 'pt': 'Ciclista', 'fr': 'Cycliste', 'it': 'Ciclista'},

    # ── Danger Zones ──
    'danger_zones': {'es': 'Zonas Peligrosas', 'en': 'Danger Zones', 'pt': 'Zonas Perigosas', 'fr': 'Zones dangereuses', 'it': 'Zone pericolose'},
    'tap_map_report': {'es': 'Toca el mapa para reportar una zona peligrosa', 'en': 'Tap the map to report a danger zone', 'pt': 'Toque no mapa para reportar uma zona perigosa', 'fr': 'Touchez la carte pour signaler une zone dangereuse', 'it': 'Tocca la mappa per segnalare una zona pericolosa'},
    'report_danger_zone': {'es': 'Reportar zona peligrosa', 'en': 'Report danger zone', 'pt': 'Reportar zona perigosa', 'fr': 'Signaler une zone dangereuse', 'it': 'Segnala zona pericolosa'},
    'danger_type': {'es': 'Tipo de peligro', 'en': 'Danger type', 'pt': 'Tipo de perigo', 'fr': 'Type de danger', 'it': 'Tipo di pericolo'},
    'description_optional': {'es': 'Descripción (opcional)', 'en': 'Description (optional)', 'pt': 'Descrição (opcional)', 'fr': 'Description (optionnel)', 'it': 'Descrizione (opzionale)'},
    'send_report_btn': {'es': 'Enviar reporte', 'en': 'Send report', 'pt': 'Enviar relatório', 'fr': 'Envoyer le signalement', 'it': 'Invia segnalazione'},
    'reports_count': {'es': 'reportes', 'en': 'reports', 'pt': 'relatórios', 'fr': 'signalements', 'it': 'segnalazioni'},

    # ── Safety / Two Factor ──
    'verification_method': {'es': 'Método de verificación', 'en': 'Verification method', 'pt': 'Método de verificação', 'fr': 'Méthode de vérification', 'it': 'Metodo di verifica'},
    'email_label': {'es': 'Correo electrónico', 'en': 'Email', 'pt': 'E-mail', 'fr': 'E-mail', 'it': 'E-mail'},
    'send_code_btn': {'es': 'Enviar código', 'en': 'Send code', 'pt': 'Enviar código', 'fr': 'Envoyer le code', 'it': 'Invia codice'},
    'enter_verification_code': {'es': 'Ingresa el código de verificación', 'en': 'Enter verification code', 'pt': 'Insira o código de verificação', 'fr': 'Entrez le code de vérification', 'it': 'Inserisci il codice di verifica'},
    'verify_and_activate': {'es': 'Verificar y activar', 'en': 'Verify and activate', 'pt': 'Verificar e ativar', 'fr': 'Vérifier et activer', 'it': 'Verifica e attiva'},
    'protect_account': {'es': 'Protege tu cuenta', 'en': 'Protect your account', 'pt': 'Proteja sua conta', 'fr': 'Protégez votre compte', 'it': 'Proteggi il tuo account'},
    'two_factor_description': {'es': 'La verificación en dos pasos añade una capa extra de seguridad a tu cuenta.', 'en': 'Two-step verification adds an extra layer of security to your account.', 'pt': 'A verificação em duas etapas adiciona uma camada extra de segurança à sua conta.', 'fr': 'La vérification en deux étapes ajoute une couche supplémentaire de sécurité à votre compte.', 'it': 'La verifica in due passaggi aggiunge un ulteriore livello di sicurezza al tuo account.'},
    'report_user_title': {'es': 'Reportar usuario', 'en': 'Report user', 'pt': 'Denunciar usuário', 'fr': "Signaler l'utilisateur", 'it': "Segnala l'utente"},
    'why_report_user': {'es': '¿Por qué reportas este usuario?', 'en': 'Why are you reporting this user?', 'pt': 'Por que você está denunciando este usuário?', 'fr': 'Pourquoi signalez-vous cet utilisateur ?', 'it': 'Perché segnali questo utente?'},
    'also_block_user': {'es': 'También bloquear a este usuario', 'en': 'Also block this user', 'pt': 'Também bloquear este usuário', 'fr': 'Bloquer également cet utilisateur', 'it': 'Blocca anche questo utente'},
    'send_report_user': {'es': 'Enviar reporte', 'en': 'Send report', 'pt': 'Enviar denúncia', 'fr': 'Envoyer le signalement', 'it': 'Invia segnalazione'},
    'report_sent_thankyou': {'es': 'Reporte enviado. Gracias por hacer Biux más seguro', 'en': 'Report sent. Thank you for making Biux safer', 'pt': 'Denúncia enviada. Obrigado por tornar o Biux mais seguro', 'fr': 'Signalement envoyé. Merci de rendre Biux plus sûr', 'it': 'Segnalazione inviata. Grazie per rendere Biux più sicuro'},
    'error_sending_report': {'es': 'Error al enviar el reporte', 'en': 'Error sending the report', 'pt': 'Erro ao enviar a denúncia', 'fr': "Erreur lors de l'envoi du signalement", 'it': "Errore nell'invio della segnalazione"},

    # ── Biometric ──
    'biometric_security': {'es': 'Seguridad biométrica', 'en': 'Biometric security', 'pt': 'Segurança biométrica', 'fr': 'Sécurité biométrique', 'it': 'Sicurezza biometrica'},
    'account_protected_biometric': {'es': 'Cuenta protegida con biometría', 'en': 'Account protected with biometrics', 'pt': 'Conta protegida com biometria', 'fr': 'Compte protégé par biométrie', 'it': 'Account protetto con biometria'},
    'no_access_without_biometric': {'es': 'Nadie más puede acceder sin tu biometría', 'en': 'No one else can access without your biometrics', 'pt': 'Ninguém mais pode acessar sem sua biometria', 'fr': 'Personne d\'autre ne peut accéder sans votre biométrie', 'it': 'Nessun altro può accedere senza la tua biometria'},
    'quick_access_no_password': {'es': 'Acceso rápido sin contraseña', 'en': 'Quick access without password', 'pt': 'Acesso rápido sem senha', 'fr': 'Accès rapide sans mot de passe', 'it': 'Accesso rapido senza password'},

    # ── Blocked Users ──
    'blocked_users': {'es': 'Usuarios bloqueados', 'en': 'Blocked users', 'pt': 'Usuários bloqueados', 'fr': 'Utilisateurs bloqués', 'it': 'Utenti bloccati'},
    'no_blocked_users': {'es': 'No has bloqueado a ningún usuario', 'en': 'You have not blocked any user', 'pt': 'Você não bloqueou nenhum usuário', 'fr': "Vous n'avez bloqué aucun utilisateur", 'it': 'Non hai bloccato nessun utente'},
    'unblock_user_title': {'es': 'Desbloquear usuario', 'en': 'Unblock user', 'pt': 'Desbloquear usuário', 'fr': "Débloquer l'utilisateur", 'it': "Sblocca l'utente"},
    'unblock_user_msg': {'es': '¿Deseas desbloquear a este usuario? Podrá volver a enviarte mensajes.', 'en': 'Do you want to unblock this user? They will be able to message you again.', 'pt': 'Deseja desbloquear este usuário? Poderá enviar mensagens novamente.', 'fr': 'Voulez-vous débloquer cet utilisateur ? Il pourra à nouveau vous envoyer des messages.', 'it': 'Vuoi sbloccare questo utente? Potrà inviarti di nuovo messaggi.'},

    # ── Active Sessions ──
    'access_history': {'es': 'Historial de accesos', 'en': 'Access history', 'pt': 'Histórico de acessos', 'fr': 'Historique des accès', 'it': 'Cronologia degli accessi'},
    'devices_logged_in': {'es': 'Dispositivos donde iniciaste sesión con tu número en Biux', 'en': 'Devices where you logged in with your number on Biux', 'pt': 'Dispositivos onde você fez login com seu número no Biux', 'fr': 'Appareils où vous vous êtes connecté avec votre numéro sur Biux', 'it': 'Dispositivi dove hai effettuato l\'accesso con il tuo numero su Biux'},
    'close_all_sessions': {'es': 'Cerrar todas las sesiones', 'en': 'Close all sessions', 'pt': 'Fechar todas as sessões', 'fr': 'Fermer toutes les sessions', 'it': 'Chiudi tutte le sessioni'},
    'close_all_sessions_question': {'es': '¿Seguro que quieres cerrar sesión en todos los dispositivos?', 'en': 'Are you sure you want to log out of all devices?', 'pt': 'Tem certeza de que deseja encerrar as sessões em todos os dispositivos?', 'fr': 'Êtes-vous sûr de vouloir vous déconnecter de tous les appareils ?', 'it': 'Sei sicuro di voler chiudere tutte le sessioni su tutti i dispositivi?'},
    'close_sessions_btn': {'es': 'Cerrar sesiones', 'en': 'Close sessions', 'pt': 'Fechar sessões', 'fr': 'Fermer les sessions', 'it': 'Chiudi sessioni'},
    'current_session': {'es': 'Sesión actual', 'en': 'Current session', 'pt': 'Sessão atual', 'fr': 'Session actuelle', 'it': 'Sessione corrente'},

    # ── Post Detail ──
    'post_not_found': {'es': 'Publicación no encontrada', 'en': 'Post not found', 'pt': 'Publicação não encontrada', 'fr': 'Publication non trouvée', 'it': 'Pubblicazione non trovata'},
    'download_image': {'es': 'Descargar imagen', 'en': 'Download image', 'pt': 'Baixar imagem', 'fr': "Télécharger l'image", 'it': "Scarica l'immagine"},
    'delete_post_confirm': {'es': '¿Estás seguro de que deseas eliminar esta publicación? Esta acción no se puede deshacer.', 'en': 'Are you sure you want to delete this post? This action cannot be undone.', 'pt': 'Tem certeza de que deseja excluir esta publicação? Esta ação não pode ser desfeita.', 'fr': 'Êtes-vous sûr de vouloir supprimer cette publication ? Cette action est irréversible.', 'it': 'Sei sicuro di voler eliminare questa pubblicazione? Questa azione non può essere annullata.'},

    # ── Notifications ──
    'request_accepted': {'es': 'Solicitud aceptada', 'en': 'Request accepted', 'pt': 'Solicitação aceita', 'fr': 'Demande acceptée', 'it': 'Richiesta accettata'},
    'request_denied': {'es': 'Solicitud denegada', 'en': 'Request denied', 'pt': 'Solicitação negada', 'fr': 'Demande refusée', 'it': 'Richiesta rifiutata'},
    'error_accepting_request': {'es': 'Error al aceptar la solicitud', 'en': 'Error accepting request', 'pt': 'Erro ao aceitar a solicitação', 'fr': "Erreur lors de l'acceptation de la demande", 'it': "Errore nell'accettazione della richiesta"},
    'error_denying_request': {'es': 'Error al denegar la solicitud', 'en': 'Error denying request', 'pt': 'Erro ao negar a solicitação', 'fr': 'Erreur lors du refus de la demande', 'it': 'Errore nel rifiuto della richiesta'},

    # ── Report Content ──
    'spam_advertising': {'es': 'Spam o publicidad', 'en': 'Spam or advertising', 'pt': 'Spam ou publicidade', 'fr': 'Spam ou publicité', 'it': 'Spam o pubblicità'},
    'false_info': {'es': 'Información falsa', 'en': 'False information', 'pt': 'Informação falsa', 'fr': 'Fausse information', 'it': 'Informazione falsa'},
    'report_content': {'es': 'Reportar contenido', 'en': 'Report content', 'pt': 'Denunciar conteúdo', 'fr': 'Signaler le contenu', 'it': 'Segnala contenuto'},
    'why_report_content': {'es': '¿Por qué deseas reportar este contenido?', 'en': 'Why do you want to report this content?', 'pt': 'Por que deseja denunciar este conteúdo?', 'fr': 'Pourquoi voulez-vous signaler ce contenu ?', 'it': 'Perché vuoi segnalare questo contenuto?'},
    'report_sent_review': {'es': 'Reporte enviado. Revisaremos el contenido.', 'en': 'Report sent. We will review the content.', 'pt': 'Denúncia enviada. Revisaremos o conteúdo.', 'fr': 'Signalement envoyé. Nous examinerons le contenu.', 'it': 'Segnalazione inviata. Esamineremo il contenuto.'},
    'error_sending_report2': {'es': 'Error enviando reporte', 'en': 'Error sending report', 'pt': 'Erro ao enviar denúncia', 'fr': "Erreur lors de l'envoi du signalement", 'it': "Errore nell'invio della segnalazione"},
    'send_report_label': {'es': 'Enviar Reporte', 'en': 'Send Report', 'pt': 'Enviar Denúncia', 'fr': 'Envoyer le signalement', 'it': 'Invia segnalazione'},

    # ── Recommendations ──
    'recommendations_title': {'es': 'Recomendaciones', 'en': 'Recommendations', 'pt': 'Recomendações', 'fr': 'Recommandations', 'it': 'Raccomandazioni'},
    'no_recommendations_received': {'es': 'Sin recomendaciones recibidas', 'en': 'No recommendations received', 'pt': 'Sem recomendações recebidas', 'fr': 'Aucune recommandation reçue', 'it': 'Nessuna raccomandazione ricevuta'},
    'no_recommendations_sent': {'es': 'No has enviado recomendaciones', 'en': 'You have not sent recommendations', 'pt': 'Você não enviou recomendações', 'fr': "Vous n'avez pas envoyé de recommandations", 'it': 'Non hai inviato raccomandazioni'},
    'distance': {'es': 'Distancia', 'en': 'Distance', 'pt': 'Distância', 'fr': 'Distance', 'it': 'Distanza'},
    'duration_label': {'es': 'Duración', 'en': 'Duration', 'pt': 'Duração', 'fr': 'Durée', 'it': 'Durata'},
    'recommend_route': {'es': 'Recomendar ruta', 'en': 'Recommend route', 'pt': 'Recomendar rota', 'fr': 'Recommander un itinéraire', 'it': 'Raccomanda percorso'},
    'route_name': {'es': 'Nombre de la ruta', 'en': 'Route name', 'pt': 'Nome da rota', 'fr': "Nom de l'itinéraire", 'it': 'Nome del percorso'},
    'route_type': {'es': 'Tipo de ruta', 'en': 'Route type', 'pt': 'Tipo de rota', 'fr': "Type d'itinéraire", 'it': 'Tipo di percorso'},
    'tell_friend_route': {'es': 'Cuéntale a tu amigo qué encontrará en esta ruta...', 'en': 'Tell your friend what they will find on this route...', 'pt': 'Conte ao seu amigo o que encontrará nesta rota...', 'fr': 'Dites à votre ami ce qu\'il trouvera sur cet itinéraire...', 'it': 'Racconta al tuo amico cosa troverà su questo percorso...'},
    'add_label': {'es': 'Agregar', 'en': 'Add', 'pt': 'Adicionar', 'fr': 'Ajouter', 'it': 'Aggiungi'},
    'cover_photo_label': {'es': 'Foto de portada', 'en': 'Cover photo', 'pt': 'Foto de capa', 'fr': 'Photo de couverture', 'it': 'Foto di copertina'},
    'tap_to_add_photo': {'es': 'Toca para agregar una foto', 'en': 'Tap to add a photo', 'pt': 'Toque para adicionar uma foto', 'fr': 'Appuyez pour ajouter une photo', 'it': 'Tocca per aggiungere una foto'},
    'send_to': {'es': 'Enviar a', 'en': 'Send to', 'pt': 'Enviar para', 'fr': 'Envoyer à', 'it': 'Invia a'},
    'send_recommendation': {'es': 'Enviar recomendación', 'en': 'Send recommendation', 'pt': 'Enviar recomendação', 'fr': 'Envoyer une recommandation', 'it': 'Invia raccomandazione'},
    'select_friend': {'es': 'Selecciona un amigo', 'en': 'Select a friend', 'pt': 'Selecione um amigo', 'fr': 'Sélectionnez un ami', 'it': 'Seleziona un amico'},
    'add_route_name': {'es': 'Agrega un nombre a la ruta', 'en': 'Add a name to the route', 'pt': 'Adicione um nome à rota', 'fr': "Ajoutez un nom à l'itinéraire", 'it': 'Aggiungi un nome al percorso'},
    'error_sending': {'es': 'Error al enviar', 'en': 'Error sending', 'pt': 'Erro ao enviar', 'fr': "Erreur lors de l'envoi", 'it': "Errore nell'invio"},

    # ── Weather ──
    'weather_for_cyclists': {'es': 'Clima para ciclistas', 'en': 'Weather for cyclists', 'pt': 'Clima para ciclistas', 'fr': 'Météo pour cyclistes', 'it': 'Meteo per ciclisti'},
    'getting_location_weather': {'es': 'Obteniendo tu ubicación y clima...', 'en': 'Getting your location and weather...', 'pt': 'Obtendo sua localização e clima...', 'fr': 'Obtention de votre position et météo...', 'it': 'Ottenimento della posizione e del meteo...'},
    'loading_weather_msg': {'es': 'Cargando clima...', 'en': 'Loading weather...', 'pt': 'Carregando clima...', 'fr': 'Chargement de la météo...', 'it': 'Caricamento meteo...'},
    'good_weather_ride': {'es': '¡Buen clima para rodar!', 'en': 'Great weather to ride!', 'pt': 'Bom clima para pedalar!', 'fr': 'Beau temps pour rouler !', 'it': 'Bel tempo per pedalare!'},
    'safety_recommendations': {'es': 'Recomendaciones de seguridad', 'en': 'Safety recommendations', 'pt': 'Recomendações de segurança', 'fr': 'Recommandations de sécurité', 'it': 'Raccomandazioni di sicurezza'},
    'carry_water_hot': {'es': 'Lleva suficiente agua, hace calor', 'en': 'Carry enough water, it is hot', 'pt': 'Leve água suficiente, está quente', 'fr': "Prenez suffisamment d'eau, il fait chaud", 'it': "Porta abbastanza acqua, fa caldo"},
    'humidity_causes_fatigue': {'es': 'La humedad alta causa fatiga, hidrátate', 'en': 'High humidity causes fatigue, stay hydrated', 'pt': 'A umidade alta causa fadiga, hidrate-se', 'fr': "L'humidité élevée provoque de la fatigue, hydratez-vous", 'it': "L'umidità alta causa affaticamento, idratati"},
    'humidity': {'es': 'Humedad', 'en': 'Humidity', 'pt': 'Umidade', 'fr': 'Humidité', 'it': 'Umidità'},
    'wind': {'es': 'Viento', 'en': 'Wind', 'pt': 'Vento', 'fr': 'Vent', 'it': 'Vento'},

    # ── Report Flow ──
    'what_to_report': {'es': '¿Qué quieres reportar?', 'en': 'What do you want to report?', 'pt': 'O que você quer denunciar?', 'fr': 'Que voulez-vous signaler ?', 'it': 'Cosa vuoi segnalare?'},
    'report_anonymous': {'es': 'Tu reporte es anónimo', 'en': 'Your report is anonymous', 'pt': 'Sua denúncia é anônima', 'fr': 'Votre signalement est anonyme', 'it': 'La tua segnalazione è anonima'},
    'report_anonymous_desc': {'es': 'La persona a la que reportes no sabrá quién realizó el reporte. Nuestro equipo revisará tu caso.', 'en': 'The person you report will not know who made the report. Our team will review your case.', 'pt': 'A pessoa que você denunciar não saberá quem fez a denúncia. Nossa equipe revisará seu caso.', 'fr': 'La personne que vous signalez ne saura pas qui a fait le signalement. Notre équipe examinera votre cas.', 'it': 'La persona che segnali non saprà chi ha fatto la segnalazione. Il nostro team esaminerà il tuo caso.'},
    'immediate_danger_call': {'es': 'Si alguien se encuentra en peligro inmediato, llama a los servicios de emergencia locales.', 'en': 'If someone is in immediate danger, call local emergency services.', 'pt': 'Se alguém estiver em perigo imediato, ligue para os serviços de emergência locais.', 'fr': "Si quelqu'un est en danger immédiat, appelez les services d'urgence locaux.", 'it': 'Se qualcuno è in pericolo immediato, chiama i servizi di emergenza locali.'},
    'specific_post': {'es': 'Una publicación concreta', 'en': 'A specific post', 'pt': 'Uma publicação específica', 'fr': 'Une publication spécifique', 'it': 'Una pubblicazione specifica'},
    'select_post_report': {'es': 'Selecciona una publicación de este usuario para reportar', 'en': 'Select a post from this user to report', 'pt': 'Selecione uma publicação deste usuário para denunciar', 'fr': 'Sélectionnez une publication de cet utilisateur à signaler', 'it': "Seleziona una pubblicazione di questo utente da segnalare"},
    'something_about_account': {'es': 'Algo sobre esta cuenta', 'en': 'Something about this account', 'pt': 'Algo sobre esta conta', 'fr': 'Quelque chose sur ce compte', 'it': 'Qualcosa su questo account'},
    'report_account_reasons': {'es': 'Reporta la cuenta por suplantación, hackeo u otros motivos', 'en': 'Report the account for impersonation, hacking or other reasons', 'pt': 'Denuncie a conta por falsificação, invasão ou outros motivos', 'fr': "Signaler le compte pour usurpation d'identité, piratage ou autre", 'it': "Segnala l'account per furto d'identità, hacking o altri motivi"},
    'select_post_label': {'es': 'Selecciona la publicación', 'en': 'Select the post', 'pt': 'Selecione a publicação', 'fr': 'Sélectionnez la publication', 'it': 'Seleziona la pubblicazione'},
    'tap_post_to_report': {'es': 'Toca la publicación que quieres reportar', 'en': 'Tap the post you want to report', 'pt': 'Toque na publicação que deseja denunciar', 'fr': 'Touchez la publication que vous voulez signaler', 'it': 'Tocca la pubblicazione che vuoi segnalare'},
    'user_has_no_posts': {'es': 'Este usuario no tiene publicaciones', 'en': 'This user has no posts', 'pt': 'Este usuário não tem publicações', 'fr': "Cet utilisateur n'a pas de publications", 'it': 'Questo utente non ha pubblicazioni'},
    'why_report_post': {'es': '¿Por qué reportas esta publicación?', 'en': 'Why are you reporting this post?', 'pt': 'Por que você está denunciando esta publicação?', 'fr': 'Pourquoi signalez-vous cette publication ?', 'it': 'Perché segnali questa pubblicazione?'},
    'why_report_account': {'es': '¿Por qué reportas esta cuenta?', 'en': 'Why are you reporting this account?', 'pt': 'Por que você está denunciando esta conta?', 'fr': 'Pourquoi signalez-vous ce compte ?', 'it': 'Perché segnali questo account?'},
    'selected_post': {'es': 'Publicación seleccionada', 'en': 'Selected post', 'pt': 'Publicação selecionada', 'fr': 'Publication sélectionnée', 'it': 'Pubblicazione selezionata'},
    'report_sent_label': {'es': 'Reporte enviado', 'en': 'Report sent', 'pt': 'Denúncia enviada', 'fr': 'Signalement envoyé', 'it': 'Segnalazione inviata'},
    'team_will_review': {'es': 'Nuestro equipo revisará tu reporte.', 'en': 'Our team will review your report.', 'pt': 'Nossa equipe revisará sua denúncia.', 'fr': 'Notre équipe examinera votre signalement.', 'it': 'Il nostro team esaminerà la tua segnalazione.'},
    'false_misleading_info': {'es': 'Información falsa o engañosa', 'en': 'False or misleading information', 'pt': 'Informação falsa ou enganosa', 'fr': 'Information fausse ou trompeuse', 'it': 'Informazione falsa o fuorviante'},
    'hacked_account': {'es': 'Cuenta que no le pertenece (hackeada)', 'en': 'Account that does not belong to them (hacked)', 'pt': 'Conta que não pertence a ele (hackeada)', 'fr': "Compte qui ne lui appartient pas (piraté)", 'it': 'Account che non gli appartiene (violato)'},
    'fake_account': {'es': 'Cuenta falsa o engañosa', 'en': 'Fake or misleading account', 'pt': 'Conta falsa ou enganosa', 'fr': 'Compte faux ou trompeur', 'it': 'Account falso o fuorviante'},
    'inappropriate_username': {'es': 'Nombre de usuario inapropiado', 'en': 'Inappropriate username', 'pt': 'Nome de usuário inapropriado', 'fr': "Nom d'utilisateur inapproprié", 'it': 'Nome utente inappropriato'},
    'spam_automated': {'es': 'Spam o cuenta automatizada', 'en': 'Spam or automated account', 'pt': 'Spam ou conta automatizada', 'fr': 'Spam ou compte automatisé', 'it': 'Spam o account automatizzato'},
    'illegal_sales': {'es': 'Venta de productos ilegales', 'en': 'Sale of illegal products', 'pt': 'Venda de produtos ilegais', 'fr': 'Vente de produits illégaux', 'it': 'Vendita di prodotti illegali'},

    # ── Onboarding ──
    'onboarding_desc': {'es': 'Biux es tu comunidad ciclista. Únete a grupos, planifica rodadas y conecta con otros ciclistas.', 'en': 'Biux is your cycling community. Join groups, plan rides and connect with other cyclists.', 'pt': 'Biux é sua comunidade ciclista. Junte-se a grupos, planeje pedaladas e conecte-se com outros ciclistas.', 'fr': 'Biux est votre communauté cycliste. Rejoignez des groupes, planifiez des sorties et connectez-vous avec d\'autres cyclistes.', 'it': 'Biux è la tua comunità ciclistica. Unisciti a gruppi, pianifica pedalate e connettiti con altri ciclisti.'},
    'join_cycling_groups': {'es': 'Únete a grupos de ciclismo', 'en': 'Join cycling groups', 'pt': 'Junte-se a grupos de ciclismo', 'fr': 'Rejoignez des groupes de cyclisme', 'it': 'Unisciti a gruppi di ciclismo'},
    'organize_rides': {'es': 'Organiza rodadas', 'en': 'Organize rides', 'pt': 'Organize pedaladas', 'fr': 'Organisez des sorties', 'it': 'Organizza pedalate'},
    'discover_nearby_routes': {'es': 'Descubre rutas cercanas', 'en': 'Discover nearby routes', 'pt': 'Descubra rotas próximas', 'fr': 'Découvrez des itinéraires à proximité', 'it': 'Scopri percorsi vicini'},

    # ── Connectivity ──
    'no_connection_offline': {'es': 'Sin conexión — modo offline', 'en': 'No connection — offline mode', 'pt': 'Sem conexão — modo offline', 'fr': 'Pas de connexion — mode hors ligne', 'it': 'Nessuna connessione — modalità offline'},

    # ── Your Story ──
    'your_story': {'es': 'Tu historia', 'en': 'Your story', 'pt': 'Sua história', 'fr': 'Votre histoire', 'it': 'La tua storia'},
    'video_url_empty': {'es': 'URL del video está vacía', 'en': 'Video URL is empty', 'pt': 'URL do vídeo está vazia', 'fr': 'L\'URL de la vidéo est vide', 'it': 'L\'URL del video è vuoto'},

    # ── Location Provider ──
    'location_disabled': {'es': 'El servicio de ubicación está deshabilitado. Actívalo en configuración.', 'en': 'Location service is disabled. Enable it in settings.', 'pt': 'O serviço de localização está desativado. Ative-o nas configurações.', 'fr': 'Le service de localisation est désactivé. Activez-le dans les paramètres.', 'it': 'Il servizio di localizzazione è disabilitato. Attivalo nelle impostazioni.'},
    'location_permission_denied': {'es': 'Permisos de ubicación denegados', 'en': 'Location permissions denied', 'pt': 'Permissões de localização negadas', 'fr': 'Autorisations de localisation refusées', 'it': 'Permessi di localizzazione negati'},
    'location_permission_permanent': {'es': 'Permisos de ubicación denegados permanentemente. Ve a configuración para habilitarlos.', 'en': 'Location permissions permanently denied. Go to settings to enable them.', 'pt': 'Permissões de localização negadas permanentemente. Vá para configurações para ativá-las.', 'fr': 'Autorisations de localisation refusées de façon permanente. Allez dans les paramètres pour les activer.', 'it': 'Permessi di posizione negati permanentemente. Vai alle impostazioni per attivarli.'},
}

def get_existing_keys(content):
    """Extract existing keys from _es section"""
    es_match = re.search(r"static const Map<String, String> _es = \{", content)
    depth = 0
    for i in range(es_match.start(), len(content)):
        if content[i] == '{': depth += 1
        elif content[i] == '}':
            depth -= 1
            if depth == 0:
                es_end = i + 1
                break
    es_section = content[es_match.start():es_end]
    return set(re.findall(r"'([a-z_0-9]+)'\s*:", es_section))

def add_keys_to_section(content, lang_marker, lang_code, new_keys, existing_keys):
    """Add new keys to a language section, before the closing };"""
    marker = f"static const Map<String, String> {lang_marker} = {{"
    idx = content.find(marker)
    if idx == -1:
        print(f"  WARNING: Could not find section {lang_marker}")
        return content
    
    # Find closing }; for this section
    depth = 0
    for i in range(idx, len(content)):
        if content[i] == '{': depth += 1
        elif content[i] == '}':
            depth -= 1
            if depth == 0:
                close_idx = i
                break
    
    # Build new entries
    entries = []
    for key, translations in sorted(new_keys.items()):
        if key not in existing_keys:
            val = translations.get(lang_code, translations.get('es', key))
            # Escape single quotes in value
            val = val.replace("'", "\\'")
            entries.append(f"    '{key}': '{val}',")
    
    if entries:
        insert_text = "\n\n    // ── Additional translations (auto-generated) ──\n" + "\n".join(entries) + "\n"
        content = content[:close_idx] + insert_text + content[close_idx:]
    
    return content

# Read translation file
with open(TRANS_FILE, 'r', encoding='utf-8') as f:
    content = f.read()

existing = get_existing_keys(content)
to_add = {k: v for k, v in NEW_KEYS.items() if k not in existing}
print(f"Existing keys: {len(existing)}")
print(f"New keys to add: {len(to_add)}")

if to_add:
    # Add to each language section (process in reverse order so indices don't shift)
    sections = [
        ('_it', 'it'),
        ('_fr', 'fr'),
        ('_pt', 'pt'),
        ('_en', 'en'),
        ('_es', 'es'),
    ]
    for marker, lang in sections:
        content = add_keys_to_section(content, marker, lang, to_add, existing)
        print(f"  Added {len(to_add)} keys to {lang} section")
    
    with open(TRANS_FILE, 'w', encoding='utf-8') as f:
        f.write(content)
    print(f"✅ Translation file updated with {len(to_add)} new keys")
else:
    print("No new keys to add")

# =============================================================================
# PHASE 2: Replace hardcoded strings in source files
# =============================================================================
# Map: exact Spanish string → translation key
# We use this to do find-and-replace in the files
STRING_TO_KEY = {
    # Common
    'Cancelar': 'cancel',
    'Guardar': 'save',
    'Eliminar': 'delete',
    'Editar': 'edit',
    'Confirmar': 'confirm',
    'Aceptar': 'accept',
    'Cerrar': 'close',
    'Continuar': 'continue_action',
    'Descartar': 'discard',
    'Salir': 'exit',
    'Compartir': 'share',
    'Usar video': 'use_video',
    'Publicar': 'publish',
    'Seleccionar': 'select',
    'Bloquear': 'block',
    'Reportar': 'report_action',
    'Reintentar': 'retry',
    'Actualizar': 'update',
    'Cargando...': 'loading',

    # Profile
    'Foto de Perfil': 'profile_photo',
    'Foto de Portada': 'cover_photo',
    'Agregar portada': 'add_cover',
    'Nombre': 'name_label',
    'Nombre de Usuario': 'username_label',
    'Nombre de usuario': 'username_label',
    'Descripción / Bio': 'description_bio',
    'Perfil actualizado correctamente': 'profile_updated',
    'Intenta nuevamente': 'try_again_later',
    'Error cargando datos del perfil': 'error_loading_profile',
    'Agregar Historia': 'add_story',
    'Sin nombre': 'no_name',
    'Seguidores': 'followers',
    'Siguiendo': 'following',
    'Seguir': 'follow',
    'Publicaciones': 'publications',
    'Sin publicaciones aún': 'no_posts_yet',
    'Sin publicaciones válidas': 'no_valid_posts',
    'Sin reposteos aún': 'no_reposts_yet',
    'Crea tu primera publicación': 'create_first_post',
    'Repostea publicaciones de otros usuarios': 'repost_other_users',
    '¿Eliminar publicación?': 'delete_publication_question',
    'Esta acción no se puede deshacer': 'action_cannot_undo',
    '¿Deseas eliminar este reposteo de tu perfil?': 'delete_repost_question',
    'Error cargando publicaciones': 'error_loading_posts',
    'Sin definir': 'not_defined',
    'Usuario no encontrado': 'user_not_found',
    'Error al cargar el perfil': 'error_loading_profile_msg',
    'Verifica tu conexión e intenta nuevamente': 'verify_connection_retry',
    'Copiar URL del perfil': 'copy_profile_url',
    'Compartir este perfil': 'share_this_profile',
    'Bloquear usuario': 'block_user',
    'Usuario bloqueado': 'user_blocked',
    'Sin seguidores aún': 'no_followers_yet',
    'Usuario': 'user_default',
    'No se pudo cargar el perfil': 'error_loading_profile_msg',
    'Completar': 'complete',
    'Configuración': 'settings',

    # Activity
    'Publicaciones que te gustaron': 'posts_you_liked',
    'Tus comentarios en publicaciones': 'your_comments',
    'Tus historias recientes': 'your_recent_stories',
    'Publicación': 'publication',
    'Historia': 'story_label',
    'Comentarios': 'comments_label',
    'No has hecho comentarios aún': 'no_comments_yet',
    'Me gusta': 'likes_label',
    'Quitar Me gusta': 'remove_like',
    'No has compartido publicaciones aún': 'no_shared_posts',
    'No has compartido historias aún': 'no_shared_stories',
    'Estadísticas': 'statistics',
    'Publicación no encontrada': 'post_not_found',
    'Descargar imagen': 'download_image',

    # Accessibility
    'Texto en negrita': 'bold_text',
    'Alto contraste': 'high_contrast',
    'Aumenta el contraste de colores': 'increase_contrast',
    'Reducir animaciones': 'reduce_animations',
    'Seguir al sistema': 'follow_system',

    # Settings/Privacy
    'Historial de actividad': 'activity_history',
    'Cuenta': 'account_label',
    'Sesiones activas': 'active_sessions',
    'Permisos': 'permissions',

    # Permissions
    'Galería': 'gallery_label',

    # Groups
    '¿Eliminar grupo?': 'delete_group_question',
    'Borrar grupo': 'delete_group',

    # Ride Tracker
    '¿Listo para pedalear?': 'ready_to_ride',
    'Espera mientras encontramos tu ubicación': 'waiting_location',
    'Presiona iniciar para grabar tu rodada': 'press_start_record',
    'Ubicación compartida': 'location_shared',
    'Historial actualizado': 'history_updated',
    'Sin rodadas aún': 'no_rides_yet',
    'Tus rodadas grabadas aparecerán aquí': 'rides_will_appear',
    'Duración': 'duration',
    'Rodada muy corta': 'ride_too_short_title',
    '¿Finalizar rodada?': 'finish_ride_question',
    '¿Cómo se llama esta rodada?': 'ride_name_question',
    'Mi rodada': 'my_ride',
    '¿Salir?': 'exit_question',
    'Rodada eliminada': 'ride_deleted',
    'Rodada cancelada': 'ride_cancelled',

    # Road Reports
    'Ubicación desconocida': 'unknown_location',
    '¡Reporte confirmado!': 'report_confirmed',
    'Reporte eliminado': 'report_deleted',
    'No hay reportes activos': 'no_active_reports',
    'Nuevo Reporte': 'new_report',
    'Descripción': 'description',
    'Se usará tu ubicación actual': 'current_location_used',
    'Enviar Reporte': 'send_report',
    '¡Reporte enviado!': 'report_sent_success',
    'Ciclista': 'cyclist_label',

    # Danger Zones
    'Zonas Peligrosas': 'danger_zones',
    'Toca el mapa para reportar una zona peligrosa': 'tap_map_report',
    'Reportar zona peligrosa': 'report_danger_zone',
    'Tipo de peligro': 'danger_type',
    'Descripción (opcional)': 'description_optional',
    'Enviar reporte': 'send_report_btn',

    # Two Factor
    'Método de verificación': 'verification_method',
    'Correo electrónico': 'email_label',
    'Enviar código': 'send_code_btn',
    'Ingresa el código de verificación': 'enter_verification_code',
    'Verificar y activar': 'verify_and_activate',
    'Protege tu cuenta': 'protect_account',

    # Report user
    'Reportar usuario': 'report_user_title',
    'Enviar reporte': 'send_report_user',

    # Biometric
    'Seguridad biometrica': 'biometric_security',
    'Seguridad biométrica': 'biometric_security',
    'Cuenta protegida con biometria': 'account_protected_biometric',
    'Cuenta protegida con biometría': 'account_protected_biometric',
    'Nadie mas puede acceder sin tu biometria': 'no_access_without_biometric',
    'Nadie más puede acceder sin tu biometría': 'no_access_without_biometric',
    'Acceso rapido sin contrasena': 'quick_access_no_password',
    'Acceso rápido sin contraseña': 'quick_access_no_password',

    # Blocked users
    'Usuarios bloqueados': 'blocked_users',
    'No has bloqueado a ningún usuario': 'no_blocked_users',
    'Desbloquear usuario': 'unblock_user_title',

    # Active sessions
    'Historial de accesos': 'access_history',
    'Cerrar todas las sesiones': 'close_all_sessions',
    'Cerrar sesiones': 'close_sessions_btn',

    # Report content
    'Spam o publicidad': 'spam_advertising',
    'Información falsa': 'false_info',
    'Reportar contenido': 'report_content',
    'Enviar Reporte': 'send_report_label',

    # Notifications
    'Solicitud aceptada': 'request_accepted',
    'Solicitud denegada': 'request_denied',
    'Error al aceptar la solicitud': 'error_accepting_request',
    'Error al denegar la solicitud': 'error_denying_request',

    # Recommendations
    'Recomendaciones': 'recommendations_title',
    'Sin recomendaciones recibidas': 'no_recommendations_received',
    'No has enviado recomendaciones': 'no_recommendations_sent',
    'Distancia': 'distance',
    'Recomendar ruta': 'recommend_route',
    'Nombre de la ruta': 'route_name',
    'Tipo de ruta': 'route_type',
    'Agregar': 'add_label',
    'Foto de portada': 'cover_photo_label',
    'Toca para agregar una foto': 'tap_to_add_photo',
    'Enviar a': 'send_to',
    'Enviar recomendación': 'send_recommendation',
    'Selecciona un amigo': 'select_friend',
    'Agrega un nombre a la ruta': 'add_route_name',
    'Error al enviar': 'error_sending',

    # Weather
    'Clima para ciclistas': 'weather_for_cyclists',
    'Obteniendo tu ubicación y clima...': 'getting_location_weather',
    '¡Buen clima para rodar!': 'good_weather_ride',
    'Recomendaciones de seguridad': 'safety_recommendations',
    'Lleva suficiente agua, hace calor': 'carry_water_hot',
    'La humedad alta causa fatiga, hidrátate': 'humidity_causes_fatigue',
    'Humedad': 'humidity',
    'Viento': 'wind',

    # Onboarding
    'Únete a grupos de ciclismo': 'join_cycling_groups',
    'Organiza rodadas': 'organize_rides',
    'Descubre rutas cercanas': 'discover_nearby_routes',

    # Connectivity
    'Sin conexión — modo offline': 'no_connection_offline',

    # Story
    'Tu historia': 'your_story',

    # Location
    'Permisos de ubicación denegados': 'location_permission_denied',

    # Peligro
    '🚨 Peligro': 'danger',
}

# Files to process - only presentation layer
PRESENTATION_FILES = glob.glob('lib/**/presentation/**/*.dart', recursive=True)
PRESENTATION_FILES += glob.glob('lib/shared/widgets/*.dart', recursive=True)
PRESENTATION_FILES += glob.glob('lib/shared/services/permission_service.dart')
PRESENTATION_FILES = list(set(PRESENTATION_FILES))
PRESENTATION_FILES = [f for f in PRESENTATION_FILES if 'app_translations' not in f and 'locale_notifier' not in f]

replaced_count = 0
modified_files = set()

for fpath in sorted(PRESENTATION_FILES):
    try:
        with open(fpath, 'r', encoding='utf-8') as f:
            original = f.read()
    except:
        continue
    
    modified = original
    file_changed = False
    
    for spanish, key in sorted(STRING_TO_KEY.items(), key=lambda x: -len(x[0])):
        # Replace 'Spanish text' with l.t('key') - but only when it's a standalone string value
        # Pattern: 'exact Spanish text' (not part of a key, not already in l.t())
        
        # Simple replacements for exact matches
        old1 = f"'{spanish}'"
        new1 = f"l.t('{key}')"
        
        if old1 in modified:
            # Make sure we're not inside l.t() already
            lines = modified.split('\n')
            new_lines = []
            for line in lines:
                if old1 in line and "l.t('" + key + "')" not in line:
                    # Skip if this is a translation key definition
                    if "': '" in line and old1.count("'") == 2:
                        new_lines.append(line)
                        continue
                    # Skip debug/log lines
                    stripped = line.strip()
                    if stripped.startswith('//') or 'print(' in stripped or 'debugPrint(' in stripped:
                        new_lines.append(line)
                        continue
                    # Do replacement
                    line = line.replace(old1, new1)
                    file_changed = True
                    replaced_count += 1
                new_lines.append(line)
            modified = '\n'.join(new_lines)
    
    if file_changed:
        with open(fpath, 'w', encoding='utf-8') as f:
            f.write(modified)
        modified_files.add(fpath)

print(f"\n✅ Phase 2: Replaced {replaced_count} strings in {len(modified_files)} files")
for f in sorted(modified_files):
    print(f"  {f}")

# =============================================================================
# PHASE 3: Ensure 'l' variable is available
# =============================================================================
PROVIDER_IMPORT = "import 'package:provider/provider.dart';"
LOCALE_IMPORT = "import 'package:biux/core/config/locale_notifier.dart';"

injected_count = 0

for fpath in sorted(modified_files):
    with open(fpath, 'r', encoding='utf-8') as f:
        content = f.read()
    
    if 'l.t(' not in content:
        continue
    
    original = content
    
    # Add imports if missing
    if LOCALE_IMPORT not in content:
        # Add after last import
        import_lines = [i for i, line in enumerate(content.split('\n')) if line.strip().startswith('import ')]
        if import_lines:
            lines = content.split('\n')
            last_import = import_lines[-1]
            lines.insert(last_import + 1, LOCALE_IMPORT)
            if PROVIDER_IMPORT not in content:
                lines.insert(last_import + 2, PROVIDER_IMPORT)
            content = '\n'.join(lines)
    elif PROVIDER_IMPORT not in content:
        import_lines = [i for i, line in enumerate(content.split('\n')) if line.strip().startswith('import ')]
        if import_lines:
            lines = content.split('\n')
            last_import = import_lines[-1]
            lines.insert(last_import + 1, PROVIDER_IMPORT)
            content = '\n'.join(lines)
    
    # Check if l is already defined via getter or build method
    has_l_getter = 'LocaleNotifier get l' in content
    has_l_in_build = False
    
    # Check for State class
    if 'extends State<' in content and not has_l_getter:
        # Add getter to State class
        state_match = re.search(r'(class \w+ extends State<\w+>.*?\{)', content, re.DOTALL)
        if state_match:
            insert_pos = state_match.end()
            getter = '\n  LocaleNotifier get l => Provider.of<LocaleNotifier>(context);\n'
            content = content[:insert_pos] + getter + content[insert_pos:]
            injected_count += 1
    
    # For StatelessWidget, check if build method has l
    if 'extends StatelessWidget' in content:
        # Find build method and add l definition if not present
        build_match = re.search(r'Widget build\(BuildContext context\)\s*\{', content)
        if build_match and 'final l = ' not in content:
            insert_pos = build_match.end()
            l_def = '\n    final l = Provider.of<LocaleNotifier>(context);\n'
            content = content[:insert_pos] + l_def + content[insert_pos:]
            injected_count += 1
    
    if content != original:
        with open(fpath, 'w', encoding='utf-8') as f:
            f.write(content)

print(f"\n✅ Phase 3: Injected 'l' in {injected_count} files")

# =============================================================================
# PHASE 4: Remove const from widgets containing l.t()
# =============================================================================
const_fixes = 0
for fpath in sorted(modified_files):
    with open(fpath, 'r', encoding='utf-8') as f:
        content = f.read()
    
    if 'l.t(' not in content:
        continue
    
    original = content
    lines = content.split('\n')
    
    # Find lines with l.t() and trace back to find const parents
    for i, line in enumerate(lines):
        if 'l.t(' in line:
            # Look backwards for const keyword on parent widget
            for j in range(i-1, max(i-20, -1), -1):
                stripped = lines[j].strip()
                if re.match(r'const\s+(Row|Column|Text|SnackBar|PopupMenuItem|Padding|SizedBox|Container|Card|ListTile|AlertDialog|SimpleDialog)\s*\(', stripped):
                    lines[j] = lines[j].replace('const ', '', 1)
                    const_fixes += 1
                    break
                elif re.match(r'(child|content|children|title|subtitle|body|actions):\s*const\s+\w+\(', stripped):
                    lines[j] = lines[j].replace('const ', '', 1)
                    const_fixes += 1
                    break
                # Stop if we hit a different widget/statement
                if stripped.endswith(';') or stripped.endswith('),') or (stripped.endswith(')') and not stripped.startswith('//')):
                    break
    
    new_content = '\n'.join(lines)
    if new_content != original:
        with open(fpath, 'w', encoding='utf-8') as f:
            f.write(new_content)

print(f"\n✅ Phase 4: Fixed {const_fixes} const issues")
print("\n🎉 Done! Run 'flutter analyze' to check for remaining issues.")
