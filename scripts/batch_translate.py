"""
Batch add translation keys to app_translations.dart for all 5 languages.
This script reads the file, finds the insertion point in each language section,
and adds all missing keys.
"""
import re

TRANSLATIONS_FILE = 'lib/core/config/app_translations.dart'

# All new translation keys organized by category
NEW_KEYS = {
    # ── App Drawer / Navigation ──
    'sos': {'es': 'SOS', 'en': 'SOS', 'pt': 'SOS', 'fr': 'SOS', 'it': 'SOS'},
    'activating_sos': {'es': 'Activando SOS...', 'en': 'Activating SOS...', 'pt': 'Ativando SOS...', 'fr': 'Activation SOS...', 'it': 'Attivazione SOS...'},
    'emergency_sos': {'es': 'Emergencia SOS', 'en': 'Emergency SOS', 'pt': 'Emergência SOS', 'fr': 'Urgence SOS', 'it': 'Emergenza SOS'},
    'release_to_cancel': {'es': 'Suelta para cancelar', 'en': 'Release to cancel', 'pt': 'Solte para cancelar', 'fr': 'Relâchez pour annuler', 'it': 'Rilascia per annullare'},
    'my_rides': {'es': 'Mis Rodadas', 'en': 'My Rides', 'pt': 'Minhas Pedaladas', 'fr': 'Mes sorties', 'it': 'Le mie uscite'},
    'my_stats': {'es': 'Mis Estadísticas', 'en': 'My Stats', 'pt': 'Minhas Estatísticas', 'fr': 'Mes statistiques', 'it': 'Le mie statistiche'},
    'achievements_title': {'es': 'Logros', 'en': 'Achievements', 'pt': 'Conquistas', 'fr': 'Réalisations', 'it': 'Traguardi'},
    'business_events': {'es': 'Negocios y Eventos', 'en': 'Business & Events', 'pt': 'Negócios e Eventos', 'fr': 'Commerces et événements', 'it': 'Attività ed eventi'},
    'business_events_subtitle': {'es': 'Publicidad y eventos con registro', 'en': 'Advertising and events with registration', 'pt': 'Publicidade e eventos com registro', 'fr': 'Publicité et événements avec inscription', 'it': 'Pubblicità ed eventi con registrazione'},
    'road_reports': {'es': 'Reportes Viales', 'en': 'Road Reports', 'pt': 'Relatórios Viários', 'fr': 'Signalements routiers', 'it': 'Segnalazioni stradali'},
    'stolen_bikes': {'es': 'Bicicletas Robadas', 'en': 'Stolen Bikes', 'pt': 'Bicicletas Roubadas', 'fr': 'Vélos volés', 'it': 'Biciclette rubate'},
    'road_education': {'es': 'Educación Vial', 'en': 'Road Education', 'pt': 'Educação Viária', 'fr': 'Éducation routière', 'it': 'Educazione stradale'},
    'weather_title': {'es': 'Clima', 'en': 'Weather', 'pt': 'Clima', 'fr': 'Météo', 'it': 'Meteo'},
    'close_session_drawer': {'es': 'Cerrar Sesión', 'en': 'Log Out', 'pt': 'Sair', 'fr': 'Se déconnecter', 'it': 'Esci'},
    'confirm_close_session': {'es': '¿Estás seguro que deseas cerrar sesión?', 'en': 'Are you sure you want to log out?', 'pt': 'Tem certeza que deseja sair?', 'fr': 'Êtes-vous sûr de vouloir vous déconnecter?', 'it': 'Sei sicuro di voler uscire?'},
    
    # ── Common Buttons & Actions ──
    'cancel': {'es': 'Cancelar', 'en': 'Cancel', 'pt': 'Cancelar', 'fr': 'Annuler', 'it': 'Annulla'},
    'delete_btn': {'es': 'Eliminar', 'en': 'Delete', 'pt': 'Excluir', 'fr': 'Supprimer', 'it': 'Elimina'},
    'confirm_btn': {'es': 'Confirmar', 'en': 'Confirm', 'pt': 'Confirmar', 'fr': 'Confirmer', 'it': 'Conferma'},
    'save_btn': {'es': 'Guardar', 'en': 'Save', 'pt': 'Salvar', 'fr': 'Enregistrer', 'it': 'Salva'},
    'edit_btn': {'es': 'Editar', 'en': 'Edit', 'pt': 'Editar', 'fr': 'Modifier', 'it': 'Modifica'},
    'open_settings': {'es': 'Abrir configuración', 'en': 'Open settings', 'pt': 'Abrir configurações', 'fr': 'Ouvrir les paramètres', 'it': 'Apri impostazioni'},
    'save_and_exit': {'es': 'Guardar y Salir', 'en': 'Save and Exit', 'pt': 'Salvar e Sair', 'fr': 'Enregistrer et quitter', 'it': 'Salva ed esci'},
    'save_changes': {'es': 'Guardar Cambios', 'en': 'Save Changes', 'pt': 'Salvar Alterações', 'fr': 'Enregistrer les modifications', 'it': 'Salva modifiche'},
    'cancel_and_exit': {'es': 'Cancelar y salir', 'en': 'Cancel and exit', 'pt': 'Cancelar e sair', 'fr': 'Annuler et quitter', 'it': 'Annulla ed esci'},
    'resend_code': {'es': 'Reenviar código', 'en': 'Resend code', 'pt': 'Reenviar código', 'fr': 'Renvoyer le code', 'it': 'Reinvia codice'},
    'update_password_btn': {'es': 'Actualizar Contraseña', 'en': 'Update Password', 'pt': 'Atualizar Senha', 'fr': 'Mettre à jour le mot de passe', 'it': 'Aggiorna password'},
    'confirm_new_password': {'es': 'Confirmar nueva contraseña', 'en': 'Confirm new password', 'pt': 'Confirmar nova senha', 'fr': 'Confirmer le nouveau mot de passe', 'it': 'Conferma nuova password'},

    # ── Error View / Shared ──
    'no_connection': {'es': 'Sin conexión', 'en': 'No connection', 'pt': 'Sem conexão', 'fr': 'Pas de connexion', 'it': 'Nessuna connessione'},
    'check_connection': {'es': 'Verifica tu conexión a internet e intenta nuevamente.', 'en': 'Check your internet connection and try again.', 'pt': 'Verifique sua conexão de internet e tente novamente.', 'fr': 'Vérifiez votre connexion internet et réessayez.', 'it': 'Controlla la tua connessione internet e riprova.'},
    'not_found': {'es': 'No encontrado', 'en': 'Not found', 'pt': 'Não encontrado', 'fr': 'Non trouvé', 'it': 'Non trovato'},
    'content_not_available': {'es': 'El contenido que buscas no está disponible.', 'en': 'The content you are looking for is not available.', 'pt': 'O conteúdo que você procura não está disponível.', 'fr': 'Le contenu que vous cherchez n\'est pas disponible.', 'it': 'Il contenuto che stai cercando non è disponibile.'},
    'no_permissions': {'es': 'Sin permisos', 'en': 'No permissions', 'pt': 'Sem permissões', 'fr': 'Pas de permissions', 'it': 'Nessun permesso'},
    'no_permissions_msg': {'es': 'No tienes permisos para acceder a este contenido.', 'en': 'You do not have permissions to access this content.', 'pt': 'Você não tem permissão para acessar este conteúdo.', 'fr': 'Vous n\'avez pas la permission d\'accéder à ce contenu.', 'it': 'Non hai i permessi per accedere a questo contenuto.'},
    'server_error': {'es': 'Error del servidor', 'en': 'Server error', 'pt': 'Erro do servidor', 'fr': 'Erreur du serveur', 'it': 'Errore del server'},
    'server_error_msg': {'es': 'Hubo un problema con el servidor. Intenta más tarde.', 'en': 'There was a problem with the server. Try again later.', 'pt': 'Houve um problema com o servidor. Tente mais tarde.', 'fr': 'Un problème est survenu avec le serveur. Réessayez plus tard.', 'it': 'Si è verificato un problema con il server. Riprova più tardi.'},
    'no_content': {'es': 'Sin contenido', 'en': 'No content', 'pt': 'Sem conteúdo', 'fr': 'Pas de contenu', 'it': 'Nessun contenuto'},
    'nothing_to_show': {'es': 'No hay nada que mostrar aquí por ahora.', 'en': 'There is nothing to show here for now.', 'pt': 'Não há nada para mostrar aqui por enquanto.', 'fr': 'Il n\'y a rien à afficher ici pour le moment.', 'it': 'Non c\'è niente da mostrare qui per il momento.'},
    'something_went_wrong': {'es': 'Algo salió mal', 'en': 'Something went wrong', 'pt': 'Algo deu errado', 'fr': 'Quelque chose s\'est mal passé', 'it': 'Qualcosa è andato storto'},
    'unexpected_error': {'es': 'Ocurrió un error inesperado. Intenta nuevamente.', 'en': 'An unexpected error occurred. Please try again.', 'pt': 'Ocorreu um erro inesperado. Tente novamente.', 'fr': 'Une erreur inattendue est survenue. Veuillez réessayer.', 'it': 'Si è verificato un errore imprevisto. Riprova.'},

    # ── Chat ──
    'gallery': {'es': 'Galería', 'en': 'Gallery', 'pt': 'Galeria', 'fr': 'Galerie', 'it': 'Galleria'},
    'camera': {'es': 'Cámara', 'en': 'Camera', 'pt': 'Câmera', 'fr': 'Caméra', 'it': 'Fotocamera'},
    'audio': {'es': 'Audio', 'en': 'Audio', 'pt': 'Áudio', 'fr': 'Audio', 'it': 'Audio'},
    'location_label': {'es': 'Ubicación', 'en': 'Location', 'pt': 'Localização', 'fr': 'Emplacement', 'it': 'Posizione'},
    'poll': {'es': 'Encuesta', 'en': 'Poll', 'pt': 'Enquete', 'fr': 'Sondage', 'it': 'Sondaggio'},
    'precise_location': {'es': 'Ubicación precisa', 'en': 'Precise location', 'pt': 'Localização precisa', 'fr': 'Emplacement précis', 'it': 'Posizione precisa'},
    'share_exact_location': {'es': 'Se comparte tu ubicación exacta', 'en': 'Your exact location will be shared', 'pt': 'Sua localização exata será compartilhada', 'fr': 'Votre emplacement exact sera partagé', 'it': 'La tua posizione esatta verrà condivisa'},
    'approximate_location': {'es': 'Ubicación aproximada', 'en': 'Approximate location', 'pt': 'Localização aproximada', 'fr': 'Emplacement approximatif', 'it': 'Posizione approssimativa'},
    'share_general_area': {'es': 'Se comparte un área general', 'en': 'A general area will be shared', 'pt': 'Uma área geral será compartilhada', 'fr': 'Une zone générale sera partagée', 'it': 'Verrà condivisa un\'area generale'},
    'getting_location': {'es': 'Obteniendo ubicación...', 'en': 'Getting location...', 'pt': 'Obtendo localização...', 'fr': 'Obtention de l\'emplacement...', 'it': 'Ottenimento posizione...'},
    'could_not_get_location': {'es': 'No se pudo obtener la ubicación', 'en': 'Could not get the location', 'pt': 'Não foi possível obter a localização', 'fr': 'Impossible d\'obtenir l\'emplacement', 'it': 'Impossibile ottenere la posizione'},
    'user_blocked': {'es': 'Usuario bloqueado', 'en': 'User blocked', 'pt': 'Usuário bloqueado', 'fr': 'Utilisateur bloqué', 'it': 'Utente bloccato'},
    'user_unblocked': {'es': 'Usuario desbloqueado', 'en': 'User unblocked', 'pt': 'Usuário desbloqueado', 'fr': 'Utilisateur débloqué', 'it': 'Utente sbloccato'},
    'search_messages': {'es': 'Buscar mensajes...', 'en': 'Search messages...', 'pt': 'Buscar mensagens...', 'fr': 'Rechercher des messages...', 'it': 'Cerca messaggi...'},
    'search_conversation': {'es': 'Buscar conversación...', 'en': 'Search conversation...', 'pt': 'Buscar conversa...', 'fr': 'Rechercher une conversation...', 'it': 'Cerca conversazione...'},
    'filter_by_name': {'es': 'Filtrar por nombre...', 'en': 'Filter by name...', 'pt': 'Filtrar por nome...', 'fr': 'Filtrer par nom...', 'it': 'Filtra per nome...'},
    'write_message': {'es': 'Escribe un mensaje...', 'en': 'Write a message...', 'pt': 'Escreva uma mensagem...', 'fr': 'Écrivez un message...', 'it': 'Scrivi un messaggio...'},
    'write_new_message': {'es': 'Escribe el nuevo mensaje...', 'en': 'Write the new message...', 'pt': 'Escreva a nova mensagem...', 'fr': 'Écrivez le nouveau message...', 'it': 'Scrivi il nuovo messaggio...'},
    'delete_for_me': {'es': 'Eliminar para mí', 'en': 'Delete for me', 'pt': 'Excluir para mim', 'fr': 'Supprimer pour moi', 'it': 'Elimina per me'},
    'delete_for_all': {'es': 'Eliminar para todos', 'en': 'Delete for everyone', 'pt': 'Excluir para todos', 'fr': 'Supprimer pour tout le monde', 'it': 'Elimina per tutti'},
    'cannot_play_audio': {'es': 'No se puede reproducir el audio', 'en': 'Cannot play audio', 'pt': 'Não é possível reproduzir o áudio', 'fr': 'Impossible de lire l\'audio', 'it': 'Impossibile riprodurre l\'audio'},
    'delete_message': {'es': 'Eliminar mensaje', 'en': 'Delete message', 'pt': 'Excluir mensagem', 'fr': 'Supprimer le message', 'it': 'Elimina messaggio'},
    'select_location': {'es': 'Seleccionar ubicación', 'en': 'Select location', 'pt': 'Selecionar localização', 'fr': 'Sélectionner l\'emplacement', 'it': 'Seleziona posizione'},
    'create_poll': {'es': 'Crear encuesta', 'en': 'Create poll', 'pt': 'Criar enquete', 'fr': 'Créer un sondage', 'it': 'Crea sondaggio'},
    'write_question': {'es': 'Escribe una pregunta', 'en': 'Write a question', 'pt': 'Escreva uma pergunta', 'fr': 'Écrivez une question', 'it': 'Scrivi una domanda'},
    'add_at_least_2_options': {'es': 'Agrega al menos 2 opciones', 'en': 'Add at least 2 options', 'pt': 'Adicione pelo menos 2 opções', 'fr': 'Ajoutez au moins 2 options', 'it': 'Aggiungi almeno 2 opzioni'},
    'write_your_question': {'es': 'Escribe tu pregunta...', 'en': 'Write your question...', 'pt': 'Escreva sua pergunta...', 'fr': 'Écrivez votre question...', 'it': 'Scrivi la tua domanda...'},
    'option_n': {'es': 'Opción', 'en': 'Option', 'pt': 'Opção', 'fr': 'Option', 'it': 'Opzione'},
    'add_option': {'es': 'Agregar opción', 'en': 'Add option', 'pt': 'Adicionar opção', 'fr': 'Ajouter une option', 'it': 'Aggiungi opzione'},
    'customization': {'es': 'Personalización', 'en': 'Customization', 'pt': 'Personalização', 'fr': 'Personnalisation', 'it': 'Personalizzazione'},
    'backup': {'es': 'Copia de seguridad', 'en': 'Backup', 'pt': 'Backup', 'fr': 'Sauvegarde', 'it': 'Backup'},
    'privacy': {'es': 'Privacidad', 'en': 'Privacy', 'pt': 'Privacidade', 'fr': 'Confidentialité', 'it': 'Privacy'},
    'text_preview': {'es': 'Vista previa del texto', 'en': 'Text preview', 'pt': 'Pré-visualização do texto', 'fr': 'Aperçu du texte', 'it': 'Anteprima del testo'},
    'error_recording': {'es': 'Error al iniciar grabación', 'en': 'Error starting recording', 'pt': 'Erro ao iniciar gravação', 'fr': 'Erreur de démarrage de l\'enregistrement', 'it': 'Errore avvio registrazione'},
    'error_sending_audio': {'es': 'Error al enviar audio', 'en': 'Error sending audio', 'pt': 'Erro ao enviar áudio', 'fr': 'Erreur d\'envoi de l\'audio', 'it': 'Errore invio audio'},

    # ── Profile ──
    'edit_profile': {'es': 'Editar Perfil', 'en': 'Edit Profile', 'pt': 'Editar Perfil', 'fr': 'Modifier le profil', 'it': 'Modifica profilo'},
    'new_post': {'es': 'Nueva Publicación', 'en': 'New Post', 'pt': 'Nova Publicação', 'fr': 'Nouvelle publication', 'it': 'Nuovo post'},
    'edit_post': {'es': 'Editar publicación', 'en': 'Edit post', 'pt': 'Editar publicação', 'fr': 'Modifier la publication', 'it': 'Modifica post'},
    'delete_post': {'es': 'Eliminar publicación', 'en': 'Delete post', 'pt': 'Excluir publicação', 'fr': 'Supprimer la publication', 'it': 'Elimina post'},
    'post_deleted': {'es': 'Publicación eliminada', 'en': 'Post deleted', 'pt': 'Publicação excluída', 'fr': 'Publication supprimée', 'it': 'Post eliminato'},
    'no_followers_yet': {'es': 'Sin seguidores aún', 'en': 'No followers yet', 'pt': 'Sem seguidores ainda', 'fr': 'Pas encore d\'abonnés', 'it': 'Ancora nessun follower'},
    'not_following_anyone': {'es': 'No sigue a nadie aún', 'en': 'Not following anyone yet', 'pt': 'Não segue ninguém ainda', 'fr': 'Ne suit personne pour le moment', 'it': 'Non segue ancora nessuno'},
    'invalid_user_error': {'es': 'Error: Usuario inválido', 'en': 'Error: Invalid user', 'pt': 'Erro: Usuário inválido', 'fr': 'Erreur: Utilisateur invalide', 'it': 'Errore: Utente non valido'},
    'your_full_name': {'es': 'Tu nombre completo', 'en': 'Your full name', 'pt': 'Seu nome completo', 'fr': 'Votre nom complet', 'it': 'Il tuo nome completo'},
    'your_username': {'es': 'tu_nombre_usuario', 'en': 'your_username', 'pt': 'seu_nome_usuario', 'fr': 'votre_nom_utilisateur', 'it': 'tuo_nome_utente'},
    'tell_about_you': {'es': 'Cuéntales sobre ti', 'en': 'Tell them about you', 'pt': 'Conte sobre você', 'fr': 'Parlez de vous', 'it': 'Racconta di te'},
    'qr_code': {'es': 'Código QR', 'en': 'QR Code', 'pt': 'Código QR', 'fr': 'Code QR', 'it': 'Codice QR'},

    # ── Activity Hub ──
    'likes': {'es': 'Likes', 'en': 'Likes', 'pt': 'Curtidas', 'fr': 'J\'aime', 'it': 'Mi piace'},
    'comments_label': {'es': 'Comentarios', 'en': 'Comments', 'pt': 'Comentários', 'fr': 'Commentaires', 'it': 'Commenti'},
    'posts': {'es': 'Publicaciones', 'en': 'Posts', 'pt': 'Publicações', 'fr': 'Publications', 'it': 'Post'},
    'stories': {'es': 'Historias', 'en': 'Stories', 'pt': 'Histórias', 'fr': 'Stories', 'it': 'Storie'},
    'my_stories': {'es': 'Mis Historias', 'en': 'My Stories', 'pt': 'Minhas Histórias', 'fr': 'Mes stories', 'it': 'Le mie storie'},
    'my_posts': {'es': 'Mis Publicaciones', 'en': 'My Posts', 'pt': 'Minhas Publicações', 'fr': 'Mes publications', 'it': 'I miei post'},
    'today': {'es': 'Hoy', 'en': 'Today', 'pt': 'Hoje', 'fr': 'Aujourd\'hui', 'it': 'Oggi'},
    'avg_7_days': {'es': 'Prom. 7 días', 'en': 'Avg. 7 days', 'pt': 'Méd. 7 dias', 'fr': 'Moy. 7 jours', 'it': 'Med. 7 giorni'},
    'avg_30_days': {'es': 'Prom. 30 días', 'en': 'Avg. 30 days', 'pt': 'Méd. 30 dias', 'fr': 'Moy. 30 jours', 'it': 'Med. 30 giorni'},
    'total_week': {'es': 'Total semana', 'en': 'Total week', 'pt': 'Total semana', 'fr': 'Total semaine', 'it': 'Totale settimana'},

    # ── Accessibility ──
    'appearance_label': {'es': 'Apariencia', 'en': 'Appearance', 'pt': 'Aparência', 'fr': 'Apparence', 'it': 'Aspetto'},
    'light': {'es': 'Claro', 'en': 'Light', 'pt': 'Claro', 'fr': 'Clair', 'it': 'Chiaro'},
    'dark': {'es': 'Oscuro', 'en': 'Dark', 'pt': 'Escuro', 'fr': 'Sombre', 'it': 'Scuro'},
    'system': {'es': 'Sistema', 'en': 'System', 'pt': 'Sistema', 'fr': 'Système', 'it': 'Sistema'},
    'accessibility': {'es': 'Accesibilidad', 'en': 'Accessibility', 'pt': 'Acessibilidade', 'fr': 'Accessibilité', 'it': 'Accessibilità'},

    # ── Cycling Stats ──
    'stats_updated': {'es': 'Estadísticas actualizadas', 'en': 'Stats updated', 'pt': 'Estatísticas atualizadas', 'fr': 'Statistiques mises à jour', 'it': 'Statistiche aggiornate'},
    'loading_weather': {'es': 'Cargando clima...', 'en': 'Loading weather...', 'pt': 'Carregando clima...', 'fr': 'Chargement de la météo...', 'it': 'Caricamento meteo...'},
    'current_weather_cycling': {'es': 'Clima actual para rodar', 'en': 'Current cycling weather', 'pt': 'Clima atual para pedalar', 'fr': 'Météo actuelle pour rouler', 'it': 'Meteo attuale per pedalare'},
    'distance': {'es': 'Distancia', 'en': 'Distance', 'pt': 'Distância', 'fr': 'Distance', 'it': 'Distanza'},
    'rides_label': {'es': 'Rodadas', 'en': 'Rides', 'pt': 'Pedaladas', 'fr': 'Sorties', 'it': 'Uscite'},
    'avg_speed': {'es': 'Vel. Promedio', 'en': 'Avg. Speed', 'pt': 'Vel. Média', 'fr': 'Vit. moyenne', 'it': 'Vel. media'},
    'max_speed': {'es': 'Vel. Máxima', 'en': 'Max Speed', 'pt': 'Vel. Máxima', 'fr': 'Vit. maximale', 'it': 'Vel. massima'},
    'elevation': {'es': 'Elevación', 'en': 'Elevation', 'pt': 'Elevação', 'fr': 'Dénivelé', 'it': 'Dislivello'},
    'calories': {'es': 'Calorías', 'en': 'Calories', 'pt': 'Calorias', 'fr': 'Calories', 'it': 'Calorie'},
    'time_label': {'es': 'Tiempo', 'en': 'Time', 'pt': 'Tempo', 'fr': 'Temps', 'it': 'Tempo'},
    'streak': {'es': 'Racha', 'en': 'Streak', 'pt': 'Sequência', 'fr': 'Série', 'it': 'Serie'},
    'n_rides': {'es': 'rodadas', 'en': 'rides', 'pt': 'pedaladas', 'fr': 'sorties', 'it': 'uscite'},
    'no_rides_yet': {'es': 'Sin rodadas aún', 'en': 'No rides yet', 'pt': 'Sem pedaladas ainda', 'fr': 'Pas encore de sorties', 'it': 'Ancora nessuna uscita'},
    'total_rides': {'es': 'Total Rodadas', 'en': 'Total Rides', 'pt': 'Total Pedaladas', 'fr': 'Total sorties', 'it': 'Totale uscite'},
    'friends_label': {'es': 'Amigos', 'en': 'Friends', 'pt': 'Amigos', 'fr': 'Amis', 'it': 'Amici'},
    'regional': {'es': 'Regional', 'en': 'Regional', 'pt': 'Regional', 'fr': 'Régional', 'it': 'Regionale'},
    'regional_ranking_soon': {'es': 'Ranking regional próximamente', 'en': 'Regional ranking coming soon', 'pt': 'Ranking regional em breve', 'fr': 'Classement régional bientôt', 'it': 'Classifica regionale in arrivo'},
    'no_friends_ranking': {'es': 'Sin amigos en el ranking', 'en': 'No friends in the ranking', 'pt': 'Sem amigos no ranking', 'fr': 'Pas d\'amis dans le classement', 'it': 'Nessun amico in classifica'},
    'speed_label': {'es': 'Velocidad', 'en': 'Speed', 'pt': 'Velocidade', 'fr': 'Vitesse', 'it': 'Velocità'},

    # ── Achievements ──
    'my_achievements': {'es': 'Mis Logros', 'en': 'My Achievements', 'pt': 'Minhas Conquistas', 'fr': 'Mes réalisations', 'it': 'I miei traguardi'},
    'sync_achievements': {'es': 'Sincronizar logros', 'en': 'Sync achievements', 'pt': 'Sincronizar conquistas', 'fr': 'Synchroniser les réalisations', 'it': 'Sincronizza traguardi'},
    'how_achievements_work': {'es': 'Cómo funcionan los logros', 'en': 'How achievements work', 'pt': 'Como funcionam as conquistas', 'fr': 'Comment fonctionnent les réalisations', 'it': 'Come funzionano i traguardi'},
    'search_friend': {'es': 'Buscar amigo...', 'en': 'Search friend...', 'pt': 'Buscar amigo...', 'fr': 'Chercher un ami...', 'it': 'Cerca amico...'},

    # ── Ride Tracker ──
    'start_point': {'es': 'Inicio', 'en': 'Start', 'pt': 'Início', 'fr': 'Départ', 'it': 'Partenza'},
    'edit_name': {'es': 'Editar nombre', 'en': 'Edit name', 'pt': 'Editar nome', 'fr': 'Modifier le nom', 'it': 'Modifica nome'},
    'ride_name_hint': {'es': 'Ej: Ruta del domingo', 'en': 'E.g.: Sunday route', 'pt': 'Ex: Rota de domingo', 'fr': 'Ex: Parcours du dimanche', 'it': 'Es: Percorso della domenica'},
    'delete_ride': {'es': 'Eliminar rodada', 'en': 'Delete ride', 'pt': 'Excluir pedalada', 'fr': 'Supprimer la sortie', 'it': 'Elimina uscita'},
    'ride_too_short': {'es': 'Rodada muy corta, no se guardó', 'en': 'Ride too short, not saved', 'pt': 'Pedalada muito curta, não foi salva', 'fr': 'Sortie trop courte, non enregistrée', 'it': 'Uscita troppo corta, non salvata'},

    # ── Road Reports ──
    'enable_location_service': {'es': 'Activa el servicio de ubicación', 'en': 'Enable location service', 'pt': 'Ative o serviço de localização', 'fr': 'Activez le service de localisation', 'it': 'Attiva il servizio di localizzazione'},
    'location_permissions_needed': {'es': 'Se necesitan permisos de ubicación', 'en': 'Location permissions needed', 'pt': 'Permissões de localização necessárias', 'fr': 'Permissions de localisation nécessaires', 'it': 'Permessi di localizzazione necessari'},
    'permissions_denied_settings': {'es': 'Permisos denegados. Ve a Configuración.', 'en': 'Permissions denied. Go to Settings.', 'pt': 'Permissões negadas. Vá para Configurações.', 'fr': 'Permissions refusées. Allez dans les paramètres.', 'it': 'Permessi negati. Vai alle impostazioni.'},
    'delete_report': {'es': 'Eliminar reporte', 'en': 'Delete report', 'pt': 'Excluir relatório', 'fr': 'Supprimer le signalement', 'it': 'Elimina segnalazione'},
    'road_reports_title': {'es': 'Reportes de Vía', 'en': 'Road Reports', 'pt': 'Relatórios Viários', 'fr': 'Signalements routiers', 'it': 'Segnalazioni stradali'},
    'report_description_hint': {'es': 'Ej: Hueco grande en el carril...', 'en': 'E.g.: Large pothole in the lane...', 'pt': 'Ex: Buraco grande na pista...', 'fr': 'Ex: Grand nid de poule sur la voie...', 'it': 'Es: Buca grande nella corsia...'},
    'write_description': {'es': 'Escribe una descripción', 'en': 'Write a description', 'pt': 'Escreva uma descrição', 'fr': 'Écrivez une description', 'it': 'Scrivi una descrizione'},
    'must_login': {'es': 'Debes iniciar sesión', 'en': 'You must log in', 'pt': 'Você deve fazer login', 'fr': 'Vous devez vous connecter', 'it': 'Devi accedere'},

    # ── Rides / Attendance ──
    'yes_confirmed': {'es': 'Sí, voy confirmado', 'en': 'Yes, confirmed', 'pt': 'Sim, confirmado', 'fr': 'Oui, confirmé', 'it': 'Sì, confermato'},
    'definitely_attending': {'es': 'Definitivamente asistiré', 'en': 'I will definitely attend', 'pt': 'Eu definitivamente irei', 'fr': 'J\'y serai certainement', 'it': 'Parteciperò sicuramente'},
    'not_sure_yet': {'es': 'No estoy seguro/a todavía', 'en': 'I\'m not sure yet', 'pt': 'Ainda não tenho certeza', 'fr': 'Je ne suis pas encore sûr(e)', 'it': 'Non sono ancora sicuro/a'},
    'confirm_attendance': {'es': 'Confirmar asistencia', 'en': 'Confirm attendance', 'pt': 'Confirmar presença', 'fr': 'Confirmer la présence', 'it': 'Conferma partecipazione'},
    'cancel_attendance': {'es': 'Cancelar asistencia', 'en': 'Cancel attendance', 'pt': 'Cancelar presença', 'fr': 'Annuler la présence', 'it': 'Annulla partecipazione'},
    'yes_cancel': {'es': 'Sí, cancelar', 'en': 'Yes, cancel', 'pt': 'Sim, cancelar', 'fr': 'Oui, annuler', 'it': 'Sì, annulla'},

    # ── Experiences / Social ──
    'repost_publication': {'es': 'Repostear publicación', 'en': 'Repost publication', 'pt': 'Repostar publicação', 'fr': 'Repartager la publication', 'it': 'Ripubblica post'},
    'add_comment_optional': {'es': 'Añade un comentario (opcional)', 'en': 'Add a comment (optional)', 'pt': 'Adicione um comentário (opcional)', 'fr': 'Ajoutez un commentaire (optionnel)', 'it': 'Aggiungi un commento (opzionale)'},
    'post_reposted': {'es': '¡Publicación reposteada!', 'en': 'Post reposted!', 'pt': 'Publicação repostada!', 'fr': 'Publication repartagée!', 'it': 'Post ripubblicato!'},
    'edit_publication': {'es': 'Editar Publicación', 'en': 'Edit Post', 'pt': 'Editar Publicação', 'fr': 'Modifier la publication', 'it': 'Modifica post'},
    'save_publish_changes': {'es': 'Guardar y publicar cambios', 'en': 'Save and publish changes', 'pt': 'Salvar e publicar alterações', 'fr': 'Enregistrer et publier les modifications', 'it': 'Salva e pubblica modifiche'},
    'post_updated_success': {'es': '¡Publicación actualizada exitosamente!', 'en': 'Post updated successfully!', 'pt': 'Publicação atualizada com sucesso!', 'fr': 'Publication mise à jour avec succès!', 'it': 'Post aggiornato con successo!'},
    'delete_story': {'es': 'Eliminar historia', 'en': 'Delete story', 'pt': 'Excluir história', 'fr': 'Supprimer la story', 'it': 'Elimina storia'},
    'add_message_optional': {'es': 'Añade un mensaje (opcional)', 'en': 'Add a message (optional)', 'pt': 'Adicione uma mensagem (opcional)', 'fr': 'Ajoutez un message (optionnel)', 'it': 'Aggiungi un messaggio (opzionale)'},
    'highlight_name': {'es': 'Nombre del destacado', 'en': 'Highlight name', 'pt': 'Nome do destaque', 'fr': 'Nom de la une', 'it': 'Nome in evidenza'},
    'create_highlight': {'es': 'Crear Destacado', 'en': 'Create Highlight', 'pt': 'Criar Destaque', 'fr': 'Créer une une', 'it': 'Crea in evidenza'},
    'delete_highlight': {'es': 'Eliminar destacado', 'en': 'Delete highlight', 'pt': 'Excluir destaque', 'fr': 'Supprimer la une', 'it': 'Elimina in evidenza'},
    'video_preview': {'es': 'Vista previa del video', 'en': 'Video preview', 'pt': 'Pré-visualização do vídeo', 'fr': 'Aperçu de la vidéo', 'it': 'Anteprima video'},
    'additional_details_optional': {'es': 'Detalles adicionales (opcional)', 'en': 'Additional details (optional)', 'pt': 'Detalhes adicionais (opcional)', 'fr': 'Détails supplémentaires (optionnel)', 'it': 'Dettagli aggiuntivi (opzionale)'},

    # ── Emergency ──
    'cancel_alert': {'es': 'Cancelar alerta', 'en': 'Cancel alert', 'pt': 'Cancelar alerta', 'fr': 'Annuler l\'alerte', 'it': 'Annulla allerta'},
    'sos_alert_sent': {'es': 'Alerta SOS enviada', 'en': 'SOS alert sent', 'pt': 'Alerta SOS enviado', 'fr': 'Alerte SOS envoyée', 'it': 'Allerta SOS inviata'},
    'my_emergency_contacts': {'es': 'Mis Contactos de Emergencia', 'en': 'My Emergency Contacts', 'pt': 'Meus Contatos de Emergência', 'fr': 'Mes contacts d\'urgence', 'it': 'I miei contatti di emergenza'},
    'phone_example': {'es': 'Ej: 3001234567', 'en': 'E.g.: 3001234567', 'pt': 'Ex: 3001234567', 'fr': 'Ex: 3001234567', 'it': 'Es: 3001234567'},
    'name_phone_required': {'es': 'Nombre y teléfono son requeridos', 'en': 'Name and phone are required', 'pt': 'Nome e telefone são obrigatórios', 'fr': 'Le nom et le téléphone sont requis', 'it': 'Nome e telefono sono obbligatori'},

    # ── Safety ──
    'two_step_verification': {'es': 'Verificación en dos pasos', 'en': 'Two-step verification', 'pt': 'Verificação em duas etapas', 'fr': 'Vérification en deux étapes', 'it': 'Verifica in due passaggi'},
    'sms': {'es': 'SMS', 'en': 'SMS', 'pt': 'SMS', 'fr': 'SMS', 'it': 'SMS'},
    'email': {'es': 'Email', 'en': 'Email', 'pt': 'Email', 'fr': 'Email', 'it': 'Email'},
    'additional_description_optional': {'es': 'Descripción adicional (opcional)', 'en': 'Additional description (optional)', 'pt': 'Descrição adicional (opcional)', 'fr': 'Description supplémentaire (optionnel)', 'it': 'Descrizione aggiuntiva (opzionale)'},
    'account_created': {'es': 'Cuenta creada', 'en': 'Account created', 'pt': 'Conta criada', 'fr': 'Compte créé', 'it': 'Account creato'},
    'last_access': {'es': 'Último acceso registrado', 'en': 'Last registered access', 'pt': 'Último acesso registrado', 'fr': 'Dernier accès enregistré', 'it': 'Ultimo accesso registrato'},
    'verified_number': {'es': 'Número verificado', 'en': 'Verified number', 'pt': 'Número verificado', 'fr': 'Numéro vérifié', 'it': 'Numero verificato'},
    'delete_record': {'es': 'Eliminar registro', 'en': 'Delete record', 'pt': 'Excluir registro', 'fr': 'Supprimer l\'enregistrement', 'it': 'Elimina registro'},
    'auth_failed': {'es': 'Autenticación fallida', 'en': 'Authentication failed', 'pt': 'Autenticação falhou', 'fr': 'Authentification échouée', 'it': 'Autenticazione fallita'},
    'two_factor_auth': {'es': 'Autenticación de dos factores', 'en': 'Two-factor authentication', 'pt': 'Autenticação de dois fatores', 'fr': 'Authentification à deux facteurs', 'it': 'Autenticazione a due fattori'},

    # ── Accidents ──
    'report_accident': {'es': 'Reportar Accidente', 'en': 'Report Accident', 'pt': 'Reportar Acidente', 'fr': 'Signaler un accident', 'it': 'Segnala incidente'},
    'accident_reports': {'es': 'Reportes de Accidentes', 'en': 'Accident Reports', 'pt': 'Relatórios de Acidentes', 'fr': 'Signalements d\'accidents', 'it': 'Segnalazioni di incidenti'},
    'accident_detail': {'es': 'Detalle del Accidente', 'en': 'Accident Detail', 'pt': 'Detalhe do Acidente', 'fr': 'Détail de l\'accident', 'it': 'Dettaglio incidente'},

    # ── Maps ──
    'danger_zones': {'es': 'Zonas de Peligro', 'en': 'Danger Zones', 'pt': 'Zonas de Perigo', 'fr': 'Zones dangereuses', 'it': 'Zone di pericolo'},
    'accident_label': {'es': 'Accidente', 'en': 'Accident', 'pt': 'Acidente', 'fr': 'Accident', 'it': 'Incidente'},
    'robbery': {'es': 'Robo', 'en': 'Robbery', 'pt': 'Roubo', 'fr': 'Vol', 'it': 'Furto'},
    'others': {'es': 'Otros', 'en': 'Others', 'pt': 'Outros', 'fr': 'Autres', 'it': 'Altri'},
    'confirm_danger_zone': {'es': 'Confirmar zona peligrosa', 'en': 'Confirm danger zone', 'pt': 'Confirmar zona perigosa', 'fr': 'Confirmer la zone dangereuse', 'it': 'Conferma zona pericolosa'},

    # ── Shop/Store ──
    'search_products': {'es': 'Buscar productos...', 'en': 'Search products...', 'pt': 'Buscar produtos...', 'fr': 'Rechercher des produits...', 'it': 'Cerca prodotti...'},
    'create_product': {'es': 'Crear Producto', 'en': 'Create Product', 'pt': 'Criar Produto', 'fr': 'Créer un produit', 'it': 'Crea prodotto'},
    'edit_product': {'es': 'Editar Producto', 'en': 'Edit Product', 'pt': 'Editar Produto', 'fr': 'Modifier le produit', 'it': 'Modifica prodotto'},
    'delete_product': {'es': 'Eliminar Producto', 'en': 'Delete Product', 'pt': 'Excluir Produto', 'fr': 'Supprimer le produit', 'it': 'Elimina prodotto'},
    'my_products': {'es': 'Mis Productos', 'en': 'My Products', 'pt': 'Meus Produtos', 'fr': 'Mes produits', 'it': 'I miei prodotti'},
    'search_products_brands': {'es': 'Buscar productos, marcas, categorías...', 'en': 'Search products, brands, categories...', 'pt': 'Buscar produtos, marcas, categorias...', 'fr': 'Rechercher produits, marques, catégories...', 'it': 'Cerca prodotti, marchi, categorie...'},
    'admin_panel': {'es': 'Panel de administración', 'en': 'Admin panel', 'pt': 'Painel de administração', 'fr': 'Panneau d\'administration', 'it': 'Pannello di amministrazione'},
    'delete_products': {'es': 'Eliminar Productos', 'en': 'Delete Products', 'pt': 'Excluir Produtos', 'fr': 'Supprimer les produits', 'it': 'Elimina prodotti'},
    'edit_products': {'es': 'Editar Productos', 'en': 'Edit Products', 'pt': 'Editar Produtos', 'fr': 'Modifier les produits', 'it': 'Modifica prodotti'},
    'call_us': {'es': 'Llámanos', 'en': 'Call us', 'pt': 'Ligue para nós', 'fr': 'Appelez-nous', 'it': 'Chiamaci'},
    'last_week': {'es': 'Última semana', 'en': 'Last week', 'pt': 'Última semana', 'fr': 'Dernière semaine', 'it': 'Ultima settimana'},
    'last_month': {'es': 'Último mes', 'en': 'Last month', 'pt': 'Último mês', 'fr': 'Dernier mois', 'it': 'Ultimo mese'},
    'last_quarter': {'es': 'Último trimestre', 'en': 'Last quarter', 'pt': 'Último trimestre', 'fr': 'Dernier trimestre', 'it': 'Ultimo trimestre'},
    'refund': {'es': 'Devolución', 'en': 'Refund', 'pt': 'Devolução', 'fr': 'Remboursement', 'it': 'Rimborso'},
    'warranty': {'es': 'Garantía', 'en': 'Warranty', 'pt': 'Garantia', 'fr': 'Garantie', 'it': 'Garanzia'},
    'create_purchase_group': {'es': 'Crear Grupo de Compra', 'en': 'Create Purchase Group', 'pt': 'Criar Grupo de Compra', 'fr': 'Créer un groupe d\'achat', 'it': 'Crea gruppo d\'acquisto'},
    'confirm_purchase': {'es': 'Confirmar Compra', 'en': 'Confirm Purchase', 'pt': 'Confirmar Compra', 'fr': 'Confirmer l\'achat', 'it': 'Conferma acquisto'},
    'shipping_label': {'es': 'Envío:', 'en': 'Shipping:', 'pt': 'Envio:', 'fr': 'Livraison:', 'it': 'Spedizione:'},
    'confirm_and_pay': {'es': 'Confirmar y Pagar', 'en': 'Confirm and Pay', 'pt': 'Confirmar e Pagar', 'fr': 'Confirmer et payer', 'it': 'Conferma e paga'},
    'enter_your_code': {'es': 'Ingresa tu código', 'en': 'Enter your code', 'pt': 'Insira seu código', 'fr': 'Entrez votre code', 'it': 'Inserisci il tuo codice'},
    'qr_verification_code': {'es': 'Código QR de Verificación', 'en': 'QR Verification Code', 'pt': 'Código QR de Verificação', 'fr': 'Code QR de vérification', 'it': 'Codice QR di verifica'},
    'search_hint': {'es': 'Buscar...', 'en': 'Search...', 'pt': 'Buscar...', 'fr': 'Rechercher...', 'it': 'Cerca...'},
    'search_brand_model': {'es': 'Buscar marca, modelo, color o serial...', 'en': 'Search brand, model, color or serial...', 'pt': 'Buscar marca, modelo, cor ou serial...', 'fr': 'Rechercher marque, modèle, couleur ou série...', 'it': 'Cerca marca, modello, colore o seriale...'},
    'create_promotion': {'es': 'Crear Promoción', 'en': 'Create Promotion', 'pt': 'Criar Promoção', 'fr': 'Créer une promotion', 'it': 'Crea promozione'},
    'delete_promotion': {'es': 'Eliminar Promoción', 'en': 'Delete Promotion', 'pt': 'Excluir Promoção', 'fr': 'Supprimer la promotion', 'it': 'Elimina promozione'},
    'select_multiple_images': {'es': 'Seleccionar múltiples imágenes', 'en': 'Select multiple images', 'pt': 'Selecionar múltiplas imagens', 'fr': 'Sélectionner plusieurs images', 'it': 'Seleziona più immagini'},
    'record_video_max': {'es': 'Grabar video (máx 30s)', 'en': 'Record video (max 30s)', 'pt': 'Gravar vídeo (máx 30s)', 'fr': 'Enregistrer une vidéo (max 30s)', 'it': 'Registra video (max 30s)'},
    'delete_selected': {'es': 'Eliminar seleccionadas', 'en': 'Delete selected', 'pt': 'Excluir selecionadas', 'fr': 'Supprimer la sélection', 'it': 'Elimina selezionate'},
    'search_seller_serial_brand': {'es': 'Buscar vendedor, serial, marca...', 'en': 'Search seller, serial, brand...', 'pt': 'Buscar vendedor, serial, marca...', 'fr': 'Rechercher vendeur, série, marque...', 'it': 'Cerca venditore, seriale, marca...'},

    # ── Weather ──
    'visibility_label': {'es': 'Visibilidad', 'en': 'Visibility', 'pt': 'Visibilidade', 'fr': 'Visibilité', 'it': 'Visibilità'},

    # ── Groups ──
    'delete_group': {'es': 'Eliminar grupo', 'en': 'Delete group', 'pt': 'Excluir grupo', 'fr': 'Supprimer le groupe', 'it': 'Elimina gruppo'},
    'create_group': {'es': 'Crear Grupo', 'en': 'Create Group', 'pt': 'Criar Grupo', 'fr': 'Créer un groupe', 'it': 'Crea gruppo'},

    # ── Ride Recommendations ──
    'select_a_friend': {'es': 'Selecciona un amigo', 'en': 'Select a friend', 'pt': 'Selecione um amigo', 'fr': 'Sélectionnez un ami', 'it': 'Seleziona un amico'},
    'add_route_name': {'es': 'Agrega un nombre a la ruta', 'en': 'Add a route name', 'pt': 'Adicione um nome à rota', 'fr': 'Ajoutez un nom à l\'itinéraire', 'it': 'Aggiungi un nome al percorso'},
    'recommendation_sent': {'es': 'Recomendación enviada', 'en': 'Recommendation sent', 'pt': 'Recomendação enviada', 'fr': 'Recommandation envoyée', 'it': 'Raccomandazione inviata'},
    'there_was_error': {'es': 'Hubo un error', 'en': 'There was an error', 'pt': 'Houve um erro', 'fr': 'Une erreur est survenue', 'it': 'Si è verificato un errore'},
    'route_name_hint': {'es': 'Ej: Ruta al cerro, Ciclovia del rio...', 'en': 'E.g.: Route to the hill, Riverside bike path...', 'pt': 'Ex: Rota ao morro, Ciclovia do rio...', 'fr': 'Ex: Route vers la colline, Piste cyclable du fleuve...', 'it': 'Es: Percorso verso la collina, Pista ciclabile del fiume...'},
    'point_of_interest_hint': {'es': 'Ej: Mirador, Parque, Cafetería...', 'en': 'E.g.: Viewpoint, Park, Coffee shop...', 'pt': 'Ex: Mirante, Parque, Cafeteria...', 'fr': 'Ex: Belvédère, Parc, Café...', 'it': 'Es: Belvedere, Parco, Caffetteria...'},
    'my_recommendations': {'es': 'Mis Recomendaciones', 'en': 'My Recommendations', 'pt': 'Minhas Recomendações', 'fr': 'Mes recommandations', 'it': 'Le mie raccomandazioni'},

    # ── Age Verification ──
    'email_example': {'es': 'correo@ejemplo.com', 'en': 'email@example.com', 'pt': 'email@exemplo.com', 'fr': 'email@exemple.com', 'it': 'email@esempio.com'},
    'add_front_document': {'es': 'Agrega la parte frontal del documento', 'en': 'Add the front of the document', 'pt': 'Adicione a frente do documento', 'fr': 'Ajoutez le recto du document', 'it': 'Aggiungi la parte frontale del documento'},
    'add_back_document': {'es': 'Agrega la parte trasera del documento', 'en': 'Add the back of the document', 'pt': 'Adicione o verso do documento', 'fr': 'Ajoutez le verso du document', 'it': 'Aggiungi il retro del documento'},
    'tap_add_front': {'es': 'Toca para agregar la parte frontal', 'en': 'Tap to add the front side', 'pt': 'Toque para adicionar a frente', 'fr': 'Appuyez pour ajouter le recto', 'it': 'Tocca per aggiungere la parte frontale'},
    'tap_add_back': {'es': 'Toca para agregar la parte trasera', 'en': 'Tap to add the back side', 'pt': 'Toque para adicionar o verso', 'fr': 'Appuyez pour ajouter le verso', 'it': 'Tocca per aggiungere il retro'},
    'identity_verification': {'es': 'Verificación de Identidad', 'en': 'Identity Verification', 'pt': 'Verificação de Identidade', 'fr': 'Vérification d\'identité', 'it': 'Verifica dell\'identità'},

    # ── Notifications / Permissions Settings ──
    'notifications_label': {'es': 'Notificaciones', 'en': 'Notifications', 'pt': 'Notificações', 'fr': 'Notifications', 'it': 'Notifiche'},
    'contacts': {'es': 'Contactos', 'en': 'Contacts', 'pt': 'Contatos', 'fr': 'Contacts', 'it': 'Contatti'},

    # ── App Update ──
    'update_required': {'es': 'Actualización requerida', 'en': 'Update required', 'pt': 'Atualização necessária', 'fr': 'Mise à jour requise', 'it': 'Aggiornamento richiesto'},
    'new_version_available': {'es': 'Nueva versión disponible', 'en': 'New version available', 'pt': 'Nova versão disponível', 'fr': 'Nouvelle version disponible', 'it': 'Nuova versione disponibile'},
    'later': {'es': 'Más tarde', 'en': 'Later', 'pt': 'Mais tarde', 'fr': 'Plus tard', 'it': 'Più tardi'},

    # ── Login ──
    'invalid_phone_number': {'es': 'Número de teléfono inválido', 'en': 'Invalid phone number', 'pt': 'Número de telefone inválido', 'fr': 'Numéro de téléphone invalide', 'it': 'Numero di telefono non valido'},
}


def main():
    with open(TRANSLATIONS_FILE, 'r', encoding='utf-8') as f:
        content = f.read()
    
    lines = content.split('\n')
    
    # Find the insertion points - just before the closing }; of each section
    # We'll find each section and check which keys already exist
    sections_info = {}
    section_markers = {
        'es': ('_es = {', None),
        'en': ('_en = {', None),
        'pt': ('_pt = {', None),
        'fr': ('_fr = {', None),
        'it': ('_it = {', None),
    }
    
    current_section = None
    section_start = {}
    section_end = {}
    existing_keys = {'es': set(), 'en': set(), 'pt': set(), 'fr': set(), 'it': set()}
    
    brace_depth = 0
    for i, line in enumerate(lines):
        # Detect section starts
        for lang, (marker, _) in section_markers.items():
            if marker in line and 'static const' in line:
                current_section = lang
                section_start[lang] = i
                brace_depth = 1
                break
        
        if current_section:
            # Count braces
            brace_depth += line.count('{') - line.count('}')
            if '{' in line and i == section_start.get(current_section):
                brace_depth = 1  # Reset for the opening line
            
            # Extract existing keys
            m = re.match(r"\s*'([^']+)'\s*:", line)
            if m:
                existing_keys[current_section].add(m.group(1))
            
            # Detect section end
            if brace_depth <= 0 and i > section_start.get(current_section, i):
                section_end[current_section] = i
                current_section = None
    
    # Now insert missing keys at the end of each section (before the closing };)
    # Process in reverse order (IT, FR, PT, EN, ES) so line numbers stay valid
    for lang in ['it', 'fr', 'pt', 'en', 'es']:
        if lang not in section_end:
            print(f"WARNING: Could not find end of section '{lang}'")
            continue
        
        missing_keys = []
        for key, translations in NEW_KEYS.items():
            if key not in existing_keys[lang]:
                value = translations[lang]
                # Escape single quotes in value
                value = value.replace("'", "\\'")
                missing_keys.append(f"    '{key}': '{value}',")
        
        if missing_keys:
            insert_line = section_end[lang]
            # Insert before the closing };
            new_lines = ['\n    // ── Batch translations ──'] + missing_keys
            for j, new_line in enumerate(new_lines):
                lines.insert(insert_line + j, new_line)
            
            # Adjust subsequent section_end indices
            offset = len(new_lines)
            for other_lang in ['it', 'fr', 'pt', 'en', 'es']:
                if other_lang != lang and other_lang in section_end and section_end[other_lang] > insert_line:
                    section_end[other_lang] += offset
            
            print(f"[{lang}] Added {len(missing_keys)} missing keys")
        else:
            print(f"[{lang}] All keys already present")
    
    # Write back
    with open(TRANSLATIONS_FILE, 'w', encoding='utf-8') as f:
        f.write('\n'.join(lines))
    
    print("\nDone! Translation keys added successfully.")


if __name__ == '__main__':
    main()
