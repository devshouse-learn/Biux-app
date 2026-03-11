#!/usr/bin/env python3
"""
Script para reemplazar strings hardcodeados en español con l.t('key')
y agregar las traducciones faltantes a app_translations.dart.
"""
import re
import os

# Mapeo manual de strings españoles a keys y traducciones
# Formato: 'texto_español': ('key', 'english', 'portuguese', 'french')
TRANSLATIONS = {
    # === GENERAL / COMMON ===
    'Reintentar': ('retry', 'Retry', 'Tentar novamente', 'Réessayer'),
    'Cancelar': ('cancel', 'Cancel', 'Cancelar', 'Annuler'),
    'Guardar': ('save', 'Save', 'Salvar', 'Enregistrer'),
    'Eliminar': ('delete', 'Delete', 'Excluir', 'Supprimer'),
    'Confirmar': ('confirm', 'Confirm', 'Confirmar', 'Confirmer'),
    'Cerrar': ('close', 'Close', 'Fechar', 'Fermer'),
    'Error': ('error', 'Error', 'Erro', 'Erreur'),
    'Aceptar': ('accept', 'Accept', 'Aceitar', 'Accepter'),
    'Cargando...': ('loading', 'Loading...', 'Carregando...', 'Chargement...'),
    'Sin nombre': ('no_name', 'No name', 'Sem nome', 'Sans nom'),
    
    # === SESIÓN / CUENTA ===
    'Cerrar Sesión': ('logout', 'Log Out', 'Sair', 'Déconnexion'),
    'Eliminar Cuenta': ('delete_account', 'Delete Account', 'Excluir Conta', 'Supprimer le Compte'),
    'Opciones de Cuenta': ('account_options', 'Account Options', 'Opções da Conta', 'Options du Compte'),
    'Cierra tu sesión actual': ('close_current_session', 'Close your current session', 'Fechar sua sessão atual', 'Fermer votre session actuelle'),
    'Elimina permanentemente tu cuenta': ('delete_account_permanently', 'Permanently delete your account', 'Excluir permanentemente sua conta', 'Supprimer définitivement votre compte'),
    '¿Estás seguro que deseas cerrar sesión?': ('confirm_logout', 'Are you sure you want to log out?', 'Tem certeza que deseja sair?', 'Êtes-vous sûr de vouloir vous déconnecter?'),
    'Cerrando sesión...': ('logging_out', 'Logging out...', 'Saindo...', 'Déconnexion en cours...'),
    'Solicitud de eliminación enviada': ('deletion_request_sent', 'Deletion request sent', 'Solicitação de exclusão enviada', 'Demande de suppression envoyée'),

    # === PERFIL ===
    'Mi Perfil': ('my_profile', 'My Profile', 'Meu Perfil', 'Mon Profil'),
    'Editar Perfil': ('edit_profile', 'Edit Profile', 'Editar Perfil', 'Modifier le Profil'),
    'Editar perfil': ('edit_profile', 'Edit Profile', 'Editar Perfil', 'Modifier le Profil'),
    'Foto de Perfil': ('profile_photo', 'Profile Photo', 'Foto do Perfil', 'Photo de Profil'),
    'Nombre': ('name_label', 'Name', 'Nome', 'Nom'),
    'Tu nombre completo': ('your_full_name', 'Your full name', 'Seu nome completo', 'Votre nom complet'),
    'Nombre de Usuario': ('username_title', 'Username', 'Nome de Usuário', 'Nom d\'Utilisateur'),
    'tu_nombre_usuario': ('username_placeholder', 'your_username', 'seu_nome_usuario', 'votre_nom_utilisateur'),
    'Descripción / Bio': ('description_bio', 'Description / Bio', 'Descrição / Bio', 'Description / Bio'),
    'Cuéntales sobre ti': ('tell_about_yourself', 'Tell about yourself', 'Conte sobre você', 'Parlez de vous'),
    'Perfil actualizado correctamente': ('profile_updated_success', 'Profile updated successfully', 'Perfil atualizado com sucesso', 'Profil mis à jour avec succès'),
    'No se pudo cargar el perfil': ('could_not_load_profile', 'Could not load profile', 'Não foi possível carregar o perfil', 'Impossible de charger le profil'),
    'Verifica tu conexión e intenta nuevamente': ('check_connection_retry', 'Check your connection and try again', 'Verifique sua conexão e tente novamente', 'Vérifiez votre connexion et réessayez'),
    'Error cargando datos del perfil': ('error_loading_profile', 'Error loading profile data', 'Erro ao carregar dados do perfil', 'Erreur de chargement du profil'),
    'Compartir perfil': ('share_profile', 'Share profile', 'Compartilhar perfil', 'Partager le profil'),
    
    # === PUBLICACIONES ===
    'Publicaciones': ('posts_title', 'Posts', 'Publicações', 'Publications'),
    'Posts': ('posts', 'Posts', 'Posts', 'Posts'),
    'Sin publicaciones aún': ('no_posts_yet', 'No posts yet', 'Sem publicações ainda', 'Aucune publication encore'),
    'Sin publicaciones válidas': ('no_valid_posts', 'No valid posts', 'Sem publicações válidas', 'Aucune publication valide'),
    'Comienza a compartir tus historias': ('start_sharing_stories', 'Start sharing your stories', 'Comece a compartilhar suas histórias', 'Commencez à partager vos histoires'),
    'Error cargando publicaciones': ('error_loading_posts', 'Error loading posts', 'Erro ao carregar publicações', 'Erreur de chargement des publications'),
    'Editar publicación': ('edit_post', 'Edit post', 'Editar publicação', 'Modifier la publication'),
    'Eliminar publicación': ('delete_post', 'Delete post', 'Excluir publicação', 'Supprimer la publication'),
    '¿Eliminar publicación?': ('confirm_delete_post', 'Delete post?', 'Excluir publicação?', 'Supprimer la publication?'),
    'Esta acción no se puede deshacer': ('action_cannot_undo', 'This action cannot be undone', 'Esta ação não pode ser desfeita', 'Cette action ne peut pas être annulée'),
    'Publicación eliminada': ('post_deleted', 'Post deleted', 'Publicação excluída', 'Publication supprimée'),
    'Nueva Publicación': ('new_post', 'New Post', 'Nova Publicação', 'Nouvelle Publication'),
    'Publicación': ('post', 'Post', 'Publicação', 'Publication'),
    'Comparte tu experiencia con todos tus seguidores': ('share_experience_followers', 'Share your experience with all your followers', 'Compartilhe sua experiência com todos seus seguidores', 'Partagez votre expérience avec tous vos abonnés'),
    
    # === HISTORIAS ===
    'Agregar Historia': ('add_story', 'Add Story', 'Adicionar História', 'Ajouter une Story'),
    'Historia': ('story', 'Story', 'História', 'Story'),
    'Comparte un momento que desaparece en 24h': ('share_moment_24h', 'Share a moment that disappears in 24h', 'Compartilhe um momento que desaparece em 24h', 'Partagez un moment qui disparaît en 24h'),
    'Sin historias aún': ('no_stories_yet', 'No stories yet', 'Sem histórias ainda', 'Aucune story encore'),
    
    # === SEGUIDORES ===
    'Seguidores': ('followers', 'Followers', 'Seguidores', 'Abonnés'),
    'Siguiendo': ('following', 'Following', 'Seguindo', 'Abonnements'),
    'Sin seguidores aún': ('no_followers_yet', 'No followers yet', 'Sem seguidores ainda', 'Aucun abonné encore'),
    'No sigue a nadie aún': ('not_following_anyone', 'Not following anyone yet', 'Não segue ninguém ainda', 'Ne suit personne encore'),
    'Seguir': ('follow', 'Follow', 'Seguir', 'Suivre'),
    'Usuario': ('user', 'User', 'Usuário', 'Utilisateur'),
    
    # === CONTENIDO ===
    'Crear contenido': ('create_content', 'Create content', 'Criar conteúdo', 'Créer du contenu'),
    'Configuración': ('settings', 'Settings', 'Configurações', 'Paramètres'),
    
    # === DRAWER / NAVEGACIÓN ===
    'Inicio': ('home', 'Home', 'Início', 'Accueil'),
    'Tienda': ('shop', 'Shop', 'Loja', 'Boutique'),
    'Rodadas': ('rides', 'Rides', 'Pedaladas', 'Sorties'),
    'Grupos': ('groups', 'Groups', 'Grupos', 'Groupes'),
    'Bicicletas': ('bikes', 'Bikes', 'Bicicletas', 'Vélos'),
    'Mapas': ('maps', 'Maps', 'Mapas', 'Cartes'),
    'Ayuda': ('help', 'Help', 'Ajuda', 'Aide'),
    'Acerca de': ('about', 'About', 'Sobre', 'À propos'),
    'Versión': ('version', 'Version', 'Versão', 'Version'),
    'Términos y Condiciones': ('terms_conditions', 'Terms & Conditions', 'Termos e Condições', 'Termes et Conditions'),
    'Política de Privacidad': ('privacy_policy', 'Privacy Policy', 'Política de Privacidade', 'Politique de Confidentialité'),
    'Soporte': ('support', 'Support', 'Suporte', 'Support'),
    'Editar': ('edit', 'Edit', 'Editar', 'Modifier'),
    
    # === TIENDA / SHOP ===
    'Productos': ('products', 'Products', 'Produtos', 'Produits'),
    'Agregar al carrito': ('add_to_cart', 'Add to cart', 'Adicionar ao carrinho', 'Ajouter au panier'),
    'Carrito': ('cart', 'Cart', 'Carrinho', 'Panier'),
    'Comprar': ('buy', 'Buy', 'Comprar', 'Acheter'),
    'Precio': ('price', 'Price', 'Preço', 'Prix'),
    'Descripción': ('description', 'Description', 'Descrição', 'Description'),
    'Categoría': ('category', 'Category', 'Categoria', 'Catégorie'),
    'Categorías': ('categories', 'Categories', 'Categorias', 'Catégories'),
    'Buscar productos...': ('search_products', 'Search products...', 'Buscar produtos...', 'Rechercher des produits...'),
    'Sin productos': ('no_products', 'No products', 'Sem produtos', 'Aucun produit'),
    'Todos': ('all', 'All', 'Todos', 'Tous'),
    'Favoritos': ('favorites', 'Favorites', 'Favoritos', 'Favoris'),
    'Mis Pedidos': ('my_orders', 'My Orders', 'Meus Pedidos', 'Mes Commandes'),
    'Administrar': ('manage', 'Manage', 'Gerenciar', 'Gérer'),
    'Talla': ('size', 'Size', 'Tamanho', 'Taille'),
    'Color': ('color', 'Color', 'Cor', 'Couleur'),
    'Cantidad': ('quantity', 'Quantity', 'Quantidade', 'Quantité'),
    'Disponible': ('available', 'Available', 'Disponível', 'Disponible'),
    'Agotado': ('sold_out', 'Sold out', 'Esgotado', 'Épuisé'),
    'Nuevo': ('new_label', 'New', 'Novo', 'Nouveau'),
    'Oferta': ('offer', 'Offer', 'Oferta', 'Offre'),
    'Descuento': ('discount', 'Discount', 'Desconto', 'Réduction'),
    'Envío gratis': ('free_shipping', 'Free shipping', 'Frete grátis', 'Livraison gratuite'),
    'Añadir': ('add', 'Add', 'Adicionar', 'Ajouter'),
    'Vendedor': ('seller', 'Seller', 'Vendedor', 'Vendeur'),
    'Reseñas': ('reviews', 'Reviews', 'Avaliações', 'Avis'),
    'Calificación': ('rating', 'Rating', 'Avaliação', 'Évaluation'),
    'Detalles del producto': ('product_details', 'Product Details', 'Detalhes do Produto', 'Détails du Produit'),
    'Producto no encontrado': ('product_not_found', 'Product not found', 'Produto não encontrado', 'Produit introuvable'),
    'Producto agregado al carrito': ('product_added_to_cart', 'Product added to cart', 'Produto adicionado ao carrinho', 'Produit ajouté au panier'),
    'Error al agregar producto': ('error_adding_product', 'Error adding product', 'Erro ao adicionar produto', 'Erreur lors de l\'ajout du produit'),
    'Sin resultados': ('no_results', 'No results', 'Sem resultados', 'Aucun résultat'),
    'Ver todo': ('see_all', 'See all', 'Ver tudo', 'Voir tout'),
    'Filtrar': ('filter', 'Filter', 'Filtrar', 'Filtrer'),
    'Ordenar por': ('sort_by', 'Sort by', 'Ordenar por', 'Trier par'),
    'Más vendidos': ('best_sellers', 'Best sellers', 'Mais vendidos', 'Meilleures ventes'),
    'Novedades': ('new_arrivals', 'New arrivals', 'Novidades', 'Nouveautés'),
    'Menor precio': ('lowest_price', 'Lowest price', 'Menor preço', 'Prix le plus bas'),
    'Mayor precio': ('highest_price', 'Highest price', 'Maior preço', 'Prix le plus élevé'),
    'Artículo': ('item', 'Item', 'Artigo', 'Article'),
    'Artículos': ('items', 'Items', 'Artigos', 'Articles'),
    'Total': ('total', 'Total', 'Total', 'Total'),
    'Subtotal': ('subtotal', 'Subtotal', 'Subtotal', 'Sous-total'),
    'Impuestos': ('taxes', 'Taxes', 'Impostos', 'Taxes'),
    'Método de pago': ('payment_method', 'Payment method', 'Método de pagamento', 'Méthode de paiement'),
    'Dirección de envío': ('shipping_address', 'Shipping address', 'Endereço de envio', 'Adresse de livraison'),
    'Realizar pedido': ('place_order', 'Place order', 'Fazer pedido', 'Passer la commande'),
    'Pedido realizado': ('order_placed', 'Order placed', 'Pedido realizado', 'Commande passée'),
    'Mi tienda': ('my_shop', 'My Shop', 'Minha Loja', 'Ma Boutique'),
    'Panel de vendedor': ('seller_dashboard', 'Seller Dashboard', 'Painel do Vendedor', 'Tableau de Bord Vendeur'),
    'Ventas': ('sales', 'Sales', 'Vendas', 'Ventes'),
    'Ingresos': ('revenue', 'Revenue', 'Receitas', 'Revenus'),
    'Pedidos': ('orders', 'Orders', 'Pedidos', 'Commandes'),
    'Clientes': ('customers', 'Customers', 'Clientes', 'Clients'),
    'Estadísticas': ('statistics', 'Statistics', 'Estatísticas', 'Statistiques'),
    
    # === PROMOCIONES ===
    'Promociones': ('promotions', 'Promotions', 'Promoções', 'Promotions'),
    'Promoción': ('promotion', 'Promotion', 'Promoção', 'Promotion'),
    'Sin promociones': ('no_promotions', 'No promotions', 'Sem promoções', 'Aucune promotion'),
    'Crear Promoción': ('create_promotion', 'Create Promotion', 'Criar Promoção', 'Créer une Promotion'),
    'Editar Promoción': ('edit_promotion', 'Edit Promotion', 'Editar Promoção', 'Modifier la Promotion'),
    'Eliminar Promoción': ('delete_promotion', 'Delete Promotion', 'Excluir Promoção', 'Supprimer la Promotion'),
    'Válido hasta': ('valid_until', 'Valid until', 'Válido até', 'Valable jusqu\'à'),
    'Título': ('title_label', 'Title', 'Título', 'Titre'),
    'Activa': ('active', 'Active', 'Ativa', 'Active'),
    'Inactiva': ('inactive', 'Inactive', 'Inativa', 'Inactive'),
    'Cupón': ('coupon', 'Coupon', 'Cupom', 'Coupon'),
    'Aplicar': ('apply', 'Apply', 'Aplicar', 'Appliquer'),
    
    # === EXPERIENCIAS ===
    'Experiencias': ('experiences', 'Experiences', 'Experiências', 'Expériences'),
    'Crear Experiencia': ('create_experience', 'Create Experience', 'Criar Experiência', 'Créer une Expérience'),
    'Editar Experiencia': ('edit_experience', 'Edit Experience', 'Editar Experiência', 'Modifier l\'Expérience'),
    'Sin experiencias': ('no_experiences', 'No experiences', 'Sem experiências', 'Aucune expérience'),
    'Recortar': ('crop', 'Crop', 'Recortar', 'Recadrer'),
    'Rotar': ('rotate', 'Rotate', 'Girar', 'Pivoter'),
    'Restablecer': ('reset', 'Reset', 'Redefinir', 'Réinitialiser'),
    
    # === RODADAS ===
    'Detalles de la rodada': ('ride_details', 'Ride details', 'Detalhes da pedalada', 'Détails de la sortie'),
    'Asistentes': ('attendees', 'Attendees', 'Participantes', 'Participants'),
    'Inscribirse': ('join_ride', 'Join ride', 'Inscrever-se', 'S\'inscrire'),
    'Cancelar inscripción': ('cancel_registration', 'Cancel registration', 'Cancelar inscrição', 'Annuler l\'inscription'),
    'Ruta': ('route', 'Route', 'Rota', 'Itinéraire'),
    'Distancia': ('distance', 'Distance', 'Distância', 'Distance'),
    'Dificultad': ('difficulty', 'Difficulty', 'Dificuldade', 'Difficulté'),
    'Hora de salida': ('departure_time', 'Departure time', 'Hora de saída', 'Heure de départ'),
    'Punto de encuentro': ('meeting_point', 'Meeting point', 'Ponto de encontro', 'Point de rencontre'),
    
    # === EMERGENCIA / SEGURIDAD ===
    'Emergencia': ('emergency', 'Emergency', 'Emergência', 'Urgence'),
    'Llamar': ('call', 'Call', 'Ligar', 'Appeler'),
    'Policía': ('police', 'Police', 'Polícia', 'Police'),
    'Bomberos': ('firefighters', 'Firefighters', 'Bombeiros', 'Pompiers'),
    'Ambulancia': ('ambulance', 'Ambulance', 'Ambulância', 'Ambulance'),
    'Reportar robo': ('report_theft', 'Report theft', 'Reportar roubo', 'Signaler un vol'),
    'Reportar accidente': ('report_accident', 'Report accident', 'Reportar acidente', 'Signaler un accident'),
    
    # === CHAT ===
    'Chats': ('chats', 'Chats', 'Chats', 'Chats'),
    'Escribir mensaje...': ('write_message', 'Write a message...', 'Escrever mensagem...', 'Écrire un message...'),
    'Sin mensajes': ('no_messages', 'No messages', 'Sem mensagens', 'Aucun message'),
    'Sin conversaciones': ('no_conversations', 'No conversations', 'Sem conversas', 'Aucune conversation'),
    'Buscar...': ('search', 'Search...', 'Buscar...', 'Rechercher...'),
    
    # === LOGROS ===
    'Logros': ('achievements', 'Achievements', 'Conquistas', 'Réalisations'),
    'Desbloqueado': ('unlocked', 'Unlocked', 'Desbloqueado', 'Débloqué'),
    'Bloqueado': ('locked', 'Locked', 'Bloqueado', 'Verrouillé'),
    
    # === CYCLING STATS ===
    'Distancia total': ('total_distance', 'Total Distance', 'Distância Total', 'Distance Totale'),
    'Tiempo total': ('total_time', 'Total Time', 'Tempo Total', 'Temps Total'),
    'Velocidad promedio': ('average_speed', 'Average Speed', 'Velocidade Média', 'Vitesse Moyenne'),
    'Velocidad máxima': ('max_speed', 'Max Speed', 'Velocidade Máxima', 'Vitesse Maximale'),
    'Elevación ganada': ('elevation_gained', 'Elevation Gained', 'Elevação Ganha', 'Dénivelé Positif'),
    'Calorías quemadas': ('calories_burned', 'Calories Burned', 'Calorias Queimadas', 'Calories Brûlées'),
    
    # === RIDE TRACKER ===
    'Iniciar': ('start', 'Start', 'Iniciar', 'Démarrer'),
    'Pausar': ('pause', 'Pause', 'Pausar', 'Pause'),
    'Reanudar': ('resume', 'Resume', 'Retomar', 'Reprendre'),
    'Detener': ('stop', 'Stop', 'Parar', 'Arrêter'),
    'Finalizar rodada': ('finish_ride', 'Finish ride', 'Finalizar pedalada', 'Terminer la sortie'),
    'Guardando recorrido...': ('saving_ride', 'Saving ride...', 'Salvando percurso...', 'Enregistrement du parcours...'),
    'Recorrido guardado': ('ride_saved', 'Ride saved', 'Percurso salvo', 'Parcours enregistré'),
    'Velocidad': ('speed', 'Speed', 'Velocidade', 'Vitesse'),
    'Elevación': ('elevation', 'Elevation', 'Elevação', 'Altitude'),
    'Duración': ('duration', 'Duration', 'Duração', 'Durée'),
    
    # === REPORTES DE CARRETERAS ===
    'Reportes de carreteras': ('road_reports', 'Road Reports', 'Relatórios de Estradas', 'Rapports Routiers'),
    'Crear reporte': ('create_report', 'Create Report', 'Criar Relatório', 'Créer un Rapport'),
    'Tipo de reporte': ('report_type', 'Report Type', 'Tipo de Relatório', 'Type de Rapport'),
    'Ubicación': ('location', 'Location', 'Localização', 'Emplacement'),
    'Comentarios': ('comments', 'Comments', 'Comentários', 'Commentaires'),
    'Sin reportes': ('no_reports', 'No reports', 'Sem relatórios', 'Aucun rapport'),
    'Bache': ('pothole', 'Pothole', 'Buraco', 'Nid-de-poule'),
    'Accidente': ('accident', 'Accident', 'Acidente', 'Accident'),
    'Obras': ('construction', 'Construction', 'Obras', 'Travaux'),
    'Peligro': ('danger', 'Danger', 'Perigo', 'Danger'),
    'Foto del reporte': ('report_photo', 'Report photo', 'Foto do relatório', 'Photo du rapport'),
    
    # === BICLETAS ===
    'Registrar bicicleta': ('register_bike', 'Register Bike', 'Registrar Bicicleta', 'Enregistrer un Vélo'),
    'Mis bicicletas': ('my_bikes', 'My Bikes', 'Minhas Bicicletas', 'Mes Vélos'),
    'Reportar robo de bicicleta': ('report_bike_theft', 'Report bike theft', 'Reportar roubo de bicicleta', 'Signaler le vol d\'un vélo'),
    'Bicicletas robadas': ('stolen_bikes', 'Stolen Bikes', 'Bicicletas Roubadas', 'Vélos Volés'),
    'Información de la bicicleta': ('bike_info', 'Bike Information', 'Informações da Bicicleta', 'Informations du Vélo'),
    'Marca': ('brand', 'Brand', 'Marca', 'Marque'),
    'Modelo': ('model', 'Model', 'Modelo', 'Modèle'),
    'Número de serie': ('serial_number', 'Serial Number', 'Número de Série', 'Numéro de Série'),
    'Escanear QR': ('scan_qr', 'Scan QR', 'Escanear QR', 'Scanner QR'),
    
    # === SOCIAL / POST DETAIL ===
    'Me gusta': ('likes', 'Likes', 'Curtidas', 'J\'aime'),
    'Comentar': ('comment', 'Comment', 'Comentar', 'Commenter'),
    'Compartir': ('share', 'Share', 'Compartilhar', 'Partager'),
    'Reportar': ('report', 'Report', 'Reportar', 'Signaler'),
    'Copiar enlace': ('copy_link', 'Copy link', 'Copiar link', 'Copier le lien'),
    'Enlace copiado': ('link_copied', 'Link copied', 'Link copiado', 'Lien copié'),
    'Escribir comentario...': ('write_comment', 'Write a comment...', 'Escrever comentário...', 'Écrire un commentaire...'),
    'Sin comentarios aún': ('no_comments_yet', 'No comments yet', 'Sem comentários ainda', 'Aucun commentaire encore'),
    
    # === AYUDA ===
    'Centro de ayuda': ('help_center', 'Help Center', 'Central de Ajuda', 'Centre d\'Aide'),
    'Preguntas frecuentes': ('faq', 'FAQ', 'Perguntas Frequentes', 'FAQ'),
    'Contáctanos': ('contact_us', 'Contact us', 'Fale Conosco', 'Contactez-nous'),
    
    # === SELLER DASHBOARD ===
    'Resumen': ('summary', 'Summary', 'Resumo', 'Résumé'),
    'Hoy': ('today', 'Today', 'Hoje', 'Aujourd\'hui'),
    'Esta semana': ('this_week', 'This week', 'Esta semana', 'Cette semaine'),
    'Este mes': ('this_month', 'This month', 'Este mês', 'Ce mois'),
    'Pendientes': ('pending', 'Pending', 'Pendentes', 'En attente'),
    'Completados': ('completed', 'Completed', 'Concluídos', 'Terminés'),
    'Cancelados': ('cancelled', 'Cancelled', 'Cancelados', 'Annulés'),
    'Producto más vendido': ('top_product', 'Top product', 'Produto mais vendido', 'Produit le plus vendu'),
    'Sin ventas': ('no_sales', 'No sales', 'Sem vendas', 'Aucune vente'),
    
    # === STORY VIEW ===
    'Reproducir': ('play', 'Play', 'Reproduzir', 'Lire'),
    'Siguiente': ('next', 'Next', 'Próximo', 'Suivant'),
    'Anterior': ('previous', 'Previous', 'Anterior', 'Précédent'),
    'Responder...': ('reply', 'Reply...', 'Responder...', 'Répondre...'),

    # === EXTRA - Detected from search ===
    'Seleccionar': ('select', 'Select', 'Selecionar', 'Sélectionner'),
    'Guardar cambios': ('save_changes', 'Save changes', 'Salvar alterações', 'Enregistrer les modifications'),
    'No hay resultados': ('no_results_found', 'No results found', 'Nenhum resultado encontrado', 'Aucun résultat trouvé'),
    'Imagen no disponible': ('image_not_available', 'Image not available', 'Imagem não disponível', 'Image non disponible'),
    'Actualizar': ('update', 'Update', 'Atualizar', 'Mettre à jour'),
    'Enviar mensaje': ('send_message', 'Send message', 'Enviar mensagem', 'Envoyer un message'),
}


def get_existing_keys(translations_path):
    """Read existing keys from the _es map in app_translations.dart"""
    with open(translations_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    keys = set()
    # Find all keys in the file
    for match in re.finditer(r"'(\w+)'\s*:", content):
        keys.add(match.group(1))
    return keys


def add_translations_to_file(translations_path, new_translations):
    """Add new translation entries to each language map"""
    with open(translations_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    existing_keys = get_existing_keys(translations_path)
    
    # Prepare new entries per language
    new_es = []
    new_en = []
    new_pt = []
    new_fr = []
    
    added_keys = set()
    for es_text, (key, en, pt, fr) in new_translations.items():
        if key not in existing_keys and key not in added_keys:
            new_es.append(f"    '{key}': '{es_text}',")
            new_en.append(f"    '{key}': '{en}',")
            new_pt.append(f"    '{key}': '{pt}',")
            new_fr.append(f"    '{key}': '{fr}',")
            added_keys.add(key)
    
    if not new_es:
        print("No new translations to add - all keys already exist.")
        return 0
    
    # Find the closing }; of each map and insert before it
    # _es map ends before _en starts
    es_insert = "\n    // === Auto-generated translations ===\n" + "\n".join(new_es) + "\n"
    en_insert = "\n    // === Auto-generated translations ===\n" + "\n".join(new_en) + "\n"
    pt_insert = "\n    // === Auto-generated translations ===\n" + "\n".join(new_pt) + "\n"
    fr_insert = "\n    // === Auto-generated translations ===\n" + "\n".join(new_fr) + "\n"
    
    # Find positions of each map's closing
    # Strategy: find "static const Map<String, String> _XX = {" and then find its closing "};"
    maps_order = ['_es', '_en', '_pt', '_fr']
    inserts = [es_insert, en_insert, pt_insert, fr_insert]
    
    lines = content.split('\n')
    result_lines = []
    current_map_idx = -1
    brace_depth = 0
    in_map = False
    
    for i, line in enumerate(lines):
        # Check if we're entering a new map
        for idx, map_name in enumerate(maps_order):
            if f'static const Map<String, String> {map_name} = {{' in line:
                current_map_idx = idx
                in_map = True
                brace_depth = 1
                result_lines.append(line)
                break
        else:
            if in_map:
                brace_depth += line.count('{') - line.count('}')
                if brace_depth <= 0:
                    # This is the closing }; of the current map
                    # Insert new translations before the closing
                    result_lines.append(inserts[current_map_idx])
                    result_lines.append(line)
                    in_map = False
                    current_map_idx = -1
                else:
                    result_lines.append(line)
            else:
                result_lines.append(line)
    
    with open(translations_path, 'w', encoding='utf-8') as f:
        f.write('\n'.join(result_lines))
    
    print(f"Added {len(new_es)} new translation keys to all 4 languages.")
    return len(new_es)


def main():
    base = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    translations_path = os.path.join(base, 'lib', 'core', 'config', 'app_translations.dart')
    
    # Step 1: Add missing translation keys
    print("=== Adding missing translations ===")
    added = add_translations_to_file(translations_path, TRANSLATIONS)
    print(f"Done. Added {added} keys.\n")
    
    # Step 2: Show summary of what keys map to
    print("=== Translation key mapping ===")
    for es_text, (key, en, pt, fr) in sorted(TRANSLATIONS.items(), key=lambda x: x[1][0]):
        print(f"  '{es_text}' => l.t('{key}')")


if __name__ == '__main__':
    main()
