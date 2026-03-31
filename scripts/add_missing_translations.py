#!/usr/bin/env python3
"""
Adds all missing translation keys to app_translations.dart.
Run from project root: python scripts/add_missing_translations.py
"""

import re
import os

TRANSLATIONS_FILE = os.path.join(
    os.path.dirname(os.path.dirname(os.path.abspath(__file__))),
    'lib', 'core', 'config', 'app_translations.dart'
)

# ─── ALL MISSING KEYS WITH TRANSLATIONS ────────────────────────────

MISSING = {
    # ── Authentication ──
    'ok': {
        'es': 'Aceptar',
        'en': 'OK',
        'pt': 'OK',
        'fr': 'OK',
    },

    # ── Bikes — detail ──
    'theft_location_hint': {
        'es': 'Ej: Calle 50 con Carrera 7, Bogotá',
        'en': 'E.g.: 50th St & 7th Ave, Bogotá',
        'pt': 'Ex: Rua 50 com Carrera 7, Bogotá',
        'fr': 'Ex: Rue 50 avec Carrera 7, Bogotá',
    },
    'theft_description_hint': {
        'es': 'Describe cómo ocurrió el robo...',
        'en': 'Describe how the theft occurred...',
        'pt': 'Descreva como o roubo aconteceu...',
        'fr': 'Décrivez comment le vol s\'est produit...',
    },
    'theft_reported_success': {
        'es': 'Robo reportado exitosamente',
        'en': 'Theft reported successfully',
        'pt': 'Roubo reportado com sucesso',
        'fr': 'Vol signalé avec succès',
    },
    'mark_recovered_confirm': {
        'es': '¿Estás seguro de que deseas marcar esta bicicleta como recuperada?',
        'en': 'Are you sure you want to mark this bike as recovered?',
        'pt': 'Tem certeza de que deseja marcar esta bicicleta como recuperada?',
        'fr': 'Êtes-vous sûr de vouloir marquer ce vélo comme récupéré ?',
    },
    'bike_recovered_success': {
        'es': 'Bicicleta marcada como recuperada',
        'en': 'Bike marked as recovered',
        'pt': 'Bicicleta marcada como recuperada',
        'fr': 'Vélo marqué comme récupéré',
    },
    'new_owner_id': {
        'es': 'ID del nuevo propietario',
        'en': 'New owner ID',
        'pt': 'ID do novo proprietário',
        'fr': 'ID du nouveau propriétaire',
    },
    'enter_user_id': {
        'es': 'Ingresa el ID del usuario',
        'en': 'Enter user ID',
        'pt': 'Insira o ID do usuário',
        'fr': 'Entrez l\'ID de l\'utilisateur',
    },
    'message_optional': {
        'es': 'Mensaje (opcional)',
        'en': 'Message (optional)',
        'pt': 'Mensagem (opcional)',
        'fr': 'Message (optionnel)',
    },
    'transfer_requested_success': {
        'es': 'Solicitud de transferencia enviada',
        'en': 'Transfer request sent',
        'pt': 'Pedido de transferência enviado',
        'fr': 'Demande de transfert envoyée',
    },

    # ── Bikes — registration step 1 ──
    'bike_type_label': {
        'es': 'Tipo de bicicleta',
        'en': 'Bike type',
        'pt': 'Tipo de bicicleta',
        'fr': 'Type de vélo',
    },
    'brand_min_chars': {
        'es': 'La marca debe tener al menos 2 caracteres',
        'en': 'Brand must have at least 2 characters',
        'pt': 'A marca deve ter pelo menos 2 caracteres',
        'fr': 'La marque doit comporter au moins 2 caractères',
    },
    'brand_max_chars': {
        'es': 'La marca no puede exceder 100 caracteres',
        'en': 'Brand cannot exceed 100 characters',
        'pt': 'A marca não pode exceder 100 caracteres',
        'fr': 'La marque ne peut pas dépasser 100 caractères',
    },
    'only_letters_numbers_spaces_hyphens': {
        'es': 'Solo se permiten letras, números, espacios y guiones',
        'en': 'Only letters, numbers, spaces and hyphens allowed',
        'pt': 'Somente letras, números, espaços e hífens permitidos',
        'fr': 'Seuls les lettres, chiffres, espaces et tirets sont autorisés',
    },
    'model_min_chars': {
        'es': 'El modelo debe tener al menos 2 caracteres',
        'en': 'Model must have at least 2 characters',
        'pt': 'O modelo deve ter pelo menos 2 caracteres',
        'fr': 'Le modèle doit comporter au moins 2 caractères',
    },
    'model_max_chars': {
        'es': 'El modelo no puede exceder 100 caracteres',
        'en': 'Model cannot exceed 100 characters',
        'pt': 'O modelo não pode exceder 100 caracteres',
        'fr': 'Le modèle ne peut pas dépasser 100 caractères',
    },
    'only_letters_numbers_spaces_hyphens_slashes': {
        'es': 'Solo se permiten letras, números, espacios, guiones y barras',
        'en': 'Only letters, numbers, spaces, hyphens and slashes allowed',
        'pt': 'Somente letras, números, espaços, hífens e barras permitidos',
        'fr': 'Seuls les lettres, chiffres, espaces, tirets et barres obliques sont autorisés',
    },
    'color_min_chars': {
        'es': 'El color debe tener al menos 2 caracteres',
        'en': 'Color must have at least 2 characters',
        'pt': 'A cor deve ter pelo menos 2 caracteres',
        'fr': 'La couleur doit comporter au moins 2 caractères',
    },
    'color_max_chars': {
        'es': 'El color no puede exceder 100 caracteres',
        'en': 'Color cannot exceed 100 characters',
        'pt': 'A cor não pode exceder 100 caracteres',
        'fr': 'La couleur ne peut pas dépasser 100 caractères',
    },
    'size_max_chars': {
        'es': 'La talla no puede exceder 10 caracteres',
        'en': 'Size cannot exceed 10 characters',
        'pt': 'O tamanho não pode exceder 10 caracteres',
        'fr': 'La taille ne peut pas dépasser 10 caractères',
    },
    'valid_size_hint': {
        'es': 'Ingresa una talla válida (ej: S, M, L, XL, 16, 18")',
        'en': 'Enter a valid size (e.g. S, M, L, XL, 16, 18")',
        'pt': 'Insira um tamanho válido (ex: S, M, L, XL, 16, 18")',
        'fr': 'Entrez une taille valide (ex: S, M, L, XL, 16, 18")',
    },
    'serial_min_chars': {
        'es': 'El número de serie debe tener al menos 4 caracteres',
        'en': 'Serial number must have at least 4 characters',
        'pt': 'O número de série deve ter pelo menos 4 caracteres',
        'fr': 'Le numéro de série doit comporter au moins 4 caractères',
    },
    'serial_max_chars': {
        'es': 'El número de serie no puede exceder 100 caracteres',
        'en': 'Serial number cannot exceed 100 characters',
        'pt': 'O número de série não pode exceder 100 caracteres',
        'fr': 'Le numéro de série ne peut pas dépasser 100 caractères',
    },
    'only_letters_numbers_hyphens': {
        'es': 'Solo se permiten letras, números y guiones',
        'en': 'Only letters, numbers and hyphens allowed',
        'pt': 'Somente letras, números e hífens permitidos',
        'fr': 'Seuls les lettres, chiffres et tirets sont autorisés',
    },
    'frame_serial_help': {
        'es': 'Busca el número de serie grabado en el cuadro de tu bicicleta',
        'en': 'Look for the serial number engraved on your bike frame',
        'pt': 'Procure o número de série gravado no quadro da sua bicicleta',
        'fr': 'Cherchez le numéro de série gravé sur le cadre de votre vélo',
    },
    'city_department_label': {
        'es': 'Ciudad, Departamento',
        'en': 'City, State',
        'pt': 'Cidade, Estado',
        'fr': 'Ville, Département',
    },
    'city_format_hint': {
        'es': 'Ingresa en formato: Ciudad, Departamento',
        'en': 'Enter in format: City, State',
        'pt': 'Insira no formato: Cidade, Estado',
        'fr': 'Entrez au format : Ville, Département',
    },
    'city_and_department_required': {
        'es': 'La ciudad y el departamento son obligatorios',
        'en': 'City and state are required',
        'pt': 'A cidade e o estado são obrigatórios',
        'fr': 'La ville et le département sont obligatoires',
    },
    'city_min_chars': {
        'es': 'La ciudad debe tener al menos 2 caracteres',
        'en': 'City must have at least 2 characters',
        'pt': 'A cidade deve ter pelo menos 2 caracteres',
        'fr': 'La ville doit comporter au moins 2 caractères',
    },
    'department_min_chars': {
        'es': 'El departamento debe tener al menos 2 caracteres',
        'en': 'State must have at least 2 characters',
        'pt': 'O estado deve ter pelo menos 2 caracteres',
        'fr': 'Le département doit comporter au moins 2 caractères',
    },
    'text_max_150_chars': {
        'es': 'El texto no puede exceder 150 caracteres',
        'en': 'Text cannot exceed 150 characters',
        'pt': 'O texto não pode exceder 150 caracteres',
        'fr': 'Le texte ne peut pas dépasser 150 caractères',
    },
    'only_letters_spaces_commas_hyphens': {
        'es': 'Solo se permiten letras, espacios, comas y guiones',
        'en': 'Only letters, spaces, commas and hyphens allowed',
        'pt': 'Somente letras, espaços, vírgulas e hífens permitidos',
        'fr': 'Seuls les lettres, espaces, virgules et tirets sont autorisés',
    },
    'city_example_hint': {
        'es': 'Ej: Bogotá, Cundinamarca',
        'en': 'E.g.: Miami, Florida',
        'pt': 'Ex: São Paulo, SP',
        'fr': 'Ex : Paris, Île-de-France',
    },
    'select_bike_type': {
        'es': 'Selecciona el tipo de bicicleta',
        'en': 'Select bike type',
        'pt': 'Selecione o tipo de bicicleta',
        'fr': 'Sélectionnez le type de vélo',
    },
    'select_bike_type_title': {
        'es': 'Seleccionar tipo de bicicleta',
        'en': 'Select bike type',
        'pt': 'Selecionar tipo de bicicleta',
        'fr': 'Sélectionner le type de vélo',
    },
    'select_bike_year': {
        'es': 'Selecciona el año',
        'en': 'Select year',
        'pt': 'Selecione o ano',
        'fr': 'Sélectionnez l\'année',
    },
    'select_year_title': {
        'es': 'Seleccionar año',
        'en': 'Select year',
        'pt': 'Selecionar ano',
        'fr': 'Sélectionner l\'année',
    },
    'done': {
        'es': 'Listo',
        'en': 'Done',
        'pt': 'Pronto',
        'fr': 'Terminé',
    },

    # ── Bikes — registration step 4 ──
    'bike_summary_title': {
        'es': 'Resumen de la bicicleta',
        'en': 'Bike summary',
        'pt': 'Resumo da bicicleta',
        'fr': 'Résumé du vélo',
    },
    'step4_description': {
        'es': 'Verifica que todos los datos de tu bicicleta estén correctos antes de finalizar',
        'en': 'Verify that all your bike data is correct before finishing',
        'pt': 'Verifique se todos os dados da sua bicicleta estão corretos antes de finalizar',
        'fr': 'Vérifiez que toutes les données de votre vélo sont correctes avant de terminer',
    },
    'finalize_bike_info': {
        'es': 'Al finalizar, tu bicicleta quedará registrada y podrás generar su código QR',
        'en': 'Once finished, your bike will be registered and you can generate its QR code',
        'pt': 'Ao finalizar, sua bicicleta ficará registrada e você poderá gerar o código QR',
        'fr': 'Une fois terminé, votre vélo sera enregistré et vous pourrez générer son code QR',
    },
    'brand_colon': {
        'es': 'Marca:',
        'en': 'Brand:',
        'pt': 'Marca:',
        'fr': 'Marque :',
    },
    'model_colon': {
        'es': 'Modelo:',
        'en': 'Model:',
        'pt': 'Modelo:',
        'fr': 'Modèle :',
    },
    'year_colon': {
        'es': 'Año:',
        'en': 'Year:',
        'pt': 'Ano:',
        'fr': 'Année :',
    },
    'color_colon': {
        'es': 'Color:',
        'en': 'Color:',
        'pt': 'Cor:',
        'fr': 'Couleur :',
    },
    'size_colon': {
        'es': 'Talla:',
        'en': 'Size:',
        'pt': 'Tamanho:',
        'fr': 'Taille :',
    },
    'type_colon': {
        'es': 'Tipo:',
        'en': 'Type:',
        'pt': 'Tipo:',
        'fr': 'Type :',
    },
    'city_colon': {
        'es': 'Ciudad:',
        'en': 'City:',
        'pt': 'Cidade:',
        'fr': 'Ville :',
    },
    'neighborhood_colon': {
        'es': 'Barrio:',
        'en': 'Neighborhood:',
        'pt': 'Bairro:',
        'fr': 'Quartier :',
    },
    'main_photo': {
        'es': 'Foto principal',
        'en': 'Main photo',
        'pt': 'Foto principal',
        'fr': 'Photo principale',
    },
    'serial_number_short': {
        'es': 'Número de serie',
        'en': 'Serial number',
        'pt': 'Número de série',
        'fr': 'Numéro de série',
    },
    'photo': {
        'es': 'Foto',
        'en': 'Photo',
        'pt': 'Foto',
        'fr': 'Photo',
    },
    'invoice': {
        'es': 'Factura',
        'en': 'Invoice',
        'pt': 'Nota fiscal',
        'fr': 'Facture',
    },
    'tap_to_enlarge_photo': {
        'es': 'Toca para ampliar la foto',
        'en': 'Tap to enlarge photo',
        'pt': 'Toque para ampliar a foto',
        'fr': 'Appuyez pour agrandir la photo',
    },

    # ── Experiences ──
    'delete_photo_title': {
        'es': 'Eliminar foto',
        'en': 'Delete photo',
        'pt': 'Excluir foto',
        'fr': 'Supprimer la photo',
    },
    'delete_photo_description': {
        'es': '¿Estás seguro de que deseas eliminar esta foto?',
        'en': 'Are you sure you want to delete this photo?',
        'pt': 'Tem certeza de que deseja excluir esta foto?',
        'fr': 'Êtes-vous sûr de vouloir supprimer cette photo ?',
    },
    'media_deleted_success': {
        'es': 'Archivo multimedia eliminado',
        'en': 'Media file deleted',
        'pt': 'Arquivo de mídia excluído',
        'fr': 'Fichier multimédia supprimé',
    },

    # ── Roads ──
    'no_rides_available': {
        'es': 'No hay rodadas disponibles',
        'en': 'No rides available',
        'pt': 'Nenhuma pedalada disponível',
        'fr': 'Aucune sortie disponible',
    },
    'n_participants': {
        'es': 'participantes',
        'en': 'participants',
        'pt': 'participantes',
        'fr': 'participants',
    },
    'n_maybe': {
        'es': 'tal vez',
        'en': 'maybe',
        'pt': 'talvez',
        'fr': 'peut-être',
    },
    'tomorrow': {
        'es': 'Mañana',
        'en': 'Tomorrow',
        'pt': 'Amanhã',
        'fr': 'Demain',
    },

    # ── Help ──
    'help_support': {
        'es': 'Ayuda y Soporte',
        'en': 'Help & Support',
        'pt': 'Ajuda e Suporte',
        'fr': 'Aide et Support',
    },
    'welcome_biux': {
        'es': '¡Bienvenido a BiUX!',
        'en': 'Welcome to BiUX!',
        'pt': 'Bem-vindo ao BiUX!',
        'fr': 'Bienvenue sur BiUX !',
    },
    'welcome_biux_desc': {
        'es': 'BiUX es tu compañera ideal para el ciclismo. Aquí encontrarás toda la información que necesitas para sacar el máximo provecho de la app.',
        'en': 'BiUX is your ideal cycling companion. Here you will find all the information you need to get the most out of the app.',
        'pt': 'BiUX é sua companheira ideal para o ciclismo. Aqui você encontrará todas as informações necessárias para aproveitar ao máximo o app.',
        'fr': 'BiUX est votre compagnon idéal pour le cyclisme. Vous trouverez ici toutes les informations nécessaires pour tirer le meilleur parti de l\'application.',
    },
    'faq_create_story_q': {
        'es': '¿Cómo puedo crear una historia?',
        'en': 'How can I create a story?',
        'pt': 'Como posso criar uma história?',
        'fr': 'Comment puis-je créer une story ?',
    },
    'faq_create_story_a': {
        'es': 'Ve a la pantalla principal y toca el botón "+" en la sección de historias. Puedes agregar fotos, videos y texto.',
        'en': 'Go to the main screen and tap the "+" button in the stories section. You can add photos, videos and text.',
        'pt': 'Vá para a tela principal e toque no botão "+" na seção de histórias. Você pode adicionar fotos, vídeos e texto.',
        'fr': 'Allez à l\'écran principal et appuyez sur le bouton "+" dans la section stories. Vous pouvez ajouter des photos, des vidéos et du texte.',
    },
    'faq_register_bike_q': {
        'es': '¿Cómo registro mi bicicleta?',
        'en': 'How do I register my bike?',
        'pt': 'Como registro minha bicicleta?',
        'fr': 'Comment enregistrer mon vélo ?',
    },
    'faq_register_bike_a': {
        'es': 'Entra a tu perfil, selecciona "Mis bicicletas" y toca "Agregar bicicleta". Llena los datos de tu bici.',
        'en': 'Go to your profile, select "My bikes" and tap "Add bike". Fill in your bike details.',
        'pt': 'Acesse seu perfil, selecione "Minhas bicicletas" e toque em "Adicionar bicicleta". Preencha os dados da sua bike.',
        'fr': 'Accédez à votre profil, sélectionnez "Mes vélos" et appuyez sur "Ajouter un vélo". Remplissez les informations de votre vélo.',
    },
    'faq_join_ride_q': {
        'es': '¿Cómo me uno a una rodada?',
        'en': 'How do I join a ride?',
        'pt': 'Como me junto a uma pedalada?',
        'fr': 'Comment rejoindre une sortie ?',
    },
    'faq_join_ride_a': {
        'es': 'Busca rodadas disponibles en la sección "Rodadas" y toca "Unirme" en la que te interese.',
        'en': 'Browse available rides in the "Rides" section and tap "Join" on the one you\'re interested in.',
        'pt': 'Procure pedaladas disponíveis na seção "Pedaladas" e toque em "Participar" na que te interessar.',
        'fr': 'Parcourez les sorties disponibles dans la section "Sorties" et appuyez sur "Rejoindre" sur celle qui vous intéresse.',
    },
    'faq_create_group_q': {
        'es': '¿Cómo creo un grupo?',
        'en': 'How do I create a group?',
        'pt': 'Como crio um grupo?',
        'fr': 'Comment créer un groupe ?',
    },
    'faq_create_group_a': {
        'es': 'En la sección "Grupos", toca el botón "+" para crear un nuevo grupo. Invita a otros ciclistas a unirse.',
        'en': 'In the "Groups" section, tap the "+" button to create a new group. Invite other cyclists to join.',
        'pt': 'Na seção "Grupos", toque no botão "+" para criar um novo grupo. Convide outros ciclistas para participar.',
        'fr': 'Dans la section "Groupes", appuyez sur le bouton "+" pour créer un nouveau groupe. Invitez d\'autres cyclistes à rejoindre.',
    },
    'faq_media_space_q': {
        'es': '¿Cuánto espacio usan las fotos y videos?',
        'en': 'How much space do photos and videos use?',
        'pt': 'Quanto espaço as fotos e vídeos usam?',
        'fr': 'Combien d\'espace les photos et vidéos utilisent-elles ?',
    },
    'faq_media_space_a': {
        'es': 'Las imágenes se comprimen automáticamente. Los videos tienen un límite de duración para optimizar el almacenamiento.',
        'en': 'Images are automatically compressed. Videos have a duration limit to optimize storage.',
        'pt': 'As imagens são comprimidas automaticamente. Os vídeos têm um limite de duração para otimizar o armazenamento.',
        'fr': 'Les images sont automatiquement compressées. Les vidéos ont une limite de durée pour optimiser le stockage.',
    },
    'faq_text_posts_q': {
        'es': '¿Puedo publicar solo texto?',
        'en': 'Can I post text only?',
        'pt': 'Posso publicar apenas texto?',
        'fr': 'Puis-je publier uniquement du texte ?',
    },
    'faq_text_posts_a': {
        'es': 'Sí, puedes crear publicaciones de solo texto en tu feed o en los grupos a los que pertenezcas.',
        'en': 'Yes, you can create text-only posts in your feed or in groups you belong to.',
        'pt': 'Sim, você pode criar publicações apenas de texto no seu feed ou nos grupos aos quais pertence.',
        'fr': 'Oui, vous pouvez créer des publications textuelles dans votre fil ou dans les groupes auxquels vous appartenez.',
    },
    'main_features': {
        'es': 'Características Principales',
        'en': 'Main Features',
        'pt': 'Principais Recursos',
        'fr': 'Fonctionnalités Principales',
    },
    'feature_stories_title': {
        'es': 'Historias',
        'en': 'Stories',
        'pt': 'Histórias',
        'fr': 'Stories',
    },
    'feature_stories_desc': {
        'es': 'Comparte tus momentos ciclistas con fotos y videos que desaparecen en 24 horas.',
        'en': 'Share your cycling moments with photos and videos that disappear in 24 hours.',
        'pt': 'Compartilhe seus momentos ciclísticos com fotos e vídeos que desaparecem em 24 horas.',
        'fr': 'Partagez vos moments cyclistes avec des photos et des vidéos qui disparaissent en 24 heures.',
    },
    'feature_rides_title': {
        'es': 'Rodadas',
        'en': 'Rides',
        'pt': 'Pedaladas',
        'fr': 'Sorties',
    },
    'feature_rides_desc': {
        'es': 'Organiza y participa en rodadas con otros ciclistas de tu zona.',
        'en': 'Organize and join rides with other cyclists in your area.',
        'pt': 'Organize e participe de pedaladas com outros ciclistas da sua região.',
        'fr': 'Organisez et participez à des sorties avec d\'autres cyclistes de votre zone.',
    },
    'feature_bikes_title': {
        'es': 'Bicicletas',
        'en': 'Bikes',
        'pt': 'Bicicletas',
        'fr': 'Vélos',
    },
    'feature_bikes_desc': {
        'es': 'Registra tus bicicletas, lleva el control de mantenimiento y comparte tu equipo.',
        'en': 'Register your bikes, track maintenance and share your equipment.',
        'pt': 'Registre suas bicicletas, acompanhe a manutenção e compartilhe seu equipamento.',
        'fr': 'Enregistrez vos vélos, suivez l\'entretien et partagez votre équipement.',
    },
    'feature_groups_title': {
        'es': 'Grupos',
        'en': 'Groups',
        'pt': 'Grupos',
        'fr': 'Groupes',
    },
    'feature_groups_desc': {
        'es': 'Crea o únete a grupos de ciclistas para conectar con tu comunidad.',
        'en': 'Create or join cyclist groups to connect with your community.',
        'pt': 'Crie ou participe de grupos de ciclistas para conectar-se com sua comunidade.',
        'fr': 'Créez ou rejoignez des groupes de cyclistes pour vous connecter avec votre communauté.',
    },
    'feature_maps_title': {
        'es': 'Mapas',
        'en': 'Maps',
        'pt': 'Mapas',
        'fr': 'Cartes',
    },
    'feature_maps_desc': {
        'es': 'Explora y comparte rutas ciclistas con mapas interactivos y seguimiento GPS.',
        'en': 'Explore and share cycling routes with interactive maps and GPS tracking.',
        'pt': 'Explore e compartilhe rotas ciclísticas com mapas interativos e rastreamento GPS.',
        'fr': 'Explorez et partagez des itinéraires cyclistes avec des cartes interactives et le suivi GPS.',
    },
    'feature_social_title': {
        'es': 'Social',
        'en': 'Social',
        'pt': 'Social',
        'fr': 'Social',
    },
    'feature_social_desc': {
        'es': 'Conecta con ciclistas, dale me gusta y comenta publicaciones de la comunidad.',
        'en': 'Connect with cyclists, like and comment on community posts.',
        'pt': 'Conecte-se com ciclistas, curta e comente publicações da comunidade.',
        'fr': 'Connectez-vous avec des cyclistes, aimez et commentez les publications de la communauté.',
    },
    'safety_helmet_title': {
        'es': 'Usa casco siempre',
        'en': 'Always wear a helmet',
        'pt': 'Use capacete sempre',
        'fr': 'Portez toujours un casque',
    },
    'safety_helmet_desc': {
        'es': 'El casco es tu mejor protección. Úsalo en cada salida sin importar la distancia.',
        'en': 'The helmet is your best protection. Wear it on every ride regardless of distance.',
        'pt': 'O capacete é sua melhor proteção. Use-o em cada saída independentemente da distância.',
        'fr': 'Le casque est votre meilleure protection. Portez-le à chaque sortie quelle que soit la distance.',
    },
    'safety_visible_title': {
        'es': 'Sé visible',
        'en': 'Be visible',
        'pt': 'Seja visível',
        'fr': 'Soyez visible',
    },
    'safety_visible_desc': {
        'es': 'Usa ropa de colores brillantes o con elementos reflectantes para que los conductores te vean.',
        'en': 'Wear bright-colored clothing or with reflective elements so drivers can see you.',
        'pt': 'Use roupas de cores brilhantes ou com elementos reflexivos para que os motoristas o vejam.',
        'fr': 'Portez des vêtements de couleurs vives ou avec des éléments réfléchissants pour que les conducteurs vous voient.',
    },
    'safety_lights_title': {
        'es': 'Usa luces',
        'en': 'Use lights',
        'pt': 'Use luzes',
        'fr': 'Utilisez des lumières',
    },
    'safety_lights_desc': {
        'es': 'Lleva luz delantera blanca y trasera roja, especialmente al rodar de noche o con poca visibilidad.',
        'en': 'Use a white front light and red rear light, especially when riding at night or in low visibility.',
        'pt': 'Use luz dianteira branca e traseira vermelha, especialmente ao pedalar à noite ou com pouca visibilidade.',
        'fr': 'Utilisez un feu avant blanc et un feu arrière rouge, surtout la nuit ou par faible visibilité.',
    },
    'safety_register_title': {
        'es': 'Registra tu bicicleta',
        'en': 'Register your bike',
        'pt': 'Registre sua bicicleta',
        'fr': 'Enregistrez votre vélo',
    },
    'safety_register_desc': {
        'es': 'Registra el número de serie de tu bici para facilitar su recuperación en caso de robo.',
        'en': 'Register your bike\'s serial number to help recover it in case of theft.',
        'pt': 'Registre o número de série da sua bike para facilitar a recuperação em caso de roubo.',
        'fr': 'Enregistrez le numéro de série de votre vélo pour faciliter sa récupération en cas de vol.',
    },
    'safety_group_title': {
        'es': 'Rueda en grupo',
        'en': 'Ride in a group',
        'pt': 'Pedale em grupo',
        'fr': 'Roulez en groupe',
    },
    'safety_group_desc': {
        'es': 'Siempre que puedas, sal a rodar acompañado. Es más seguro y más divertido.',
        'en': 'Whenever possible, ride with company. It\'s safer and more fun.',
        'pt': 'Sempre que puder, saia para pedalar acompanhado. É mais seguro e mais divertido.',
        'fr': 'Chaque fois que possible, roulez accompagné. C\'est plus sûr et plus amusant.',
    },
    'safety_signals_title': {
        'es': 'Usa señales',
        'en': 'Use hand signals',
        'pt': 'Use sinais',
        'fr': 'Utilisez des signaux',
    },
    'safety_signals_desc': {
        'es': 'Indica tus giros y paradas con señales de mano para que otros usuarios de la vía te entiendan.',
        'en': 'Signal your turns and stops with hand signals so other road users can understand you.',
        'pt': 'Indique suas curvas e paradas com sinais de mão para que outros usuários da via o entendam.',
        'fr': 'Indiquez vos virages et arrêts avec des signaux de main pour que les autres usagers de la route vous comprennent.',
    },
    'support_contact': {
        'es': 'Soporte y Contacto',
        'en': 'Support & Contact',
        'pt': 'Suporte e Contato',
        'fr': 'Support et Contact',
    },
    'email_support': {
        'es': 'Soporte por email',
        'en': 'Email support',
        'pt': 'Suporte por email',
        'fr': 'Support par email',
    },
    'website': {
        'es': 'Sitio web',
        'en': 'Website',
        'pt': 'Site',
        'fr': 'Site web',
    },
    'report_bug': {
        'es': 'Reportar un error',
        'en': 'Report a bug',
        'pt': 'Reportar um erro',
        'fr': 'Signaler un bug',
    },
    'report_bug_subtitle': {
        'es': 'Ayúdanos a mejorar reportando errores',
        'en': 'Help us improve by reporting bugs',
        'pt': 'Ajude-nos a melhorar reportando erros',
        'fr': 'Aidez-nous à nous améliorer en signalant des bugs',
    },
    'bug_report_subject': {
        'es': 'Reporte de error - BiUX App',
        'en': 'Bug report - BiUX App',
        'pt': 'Relatório de erro - BiUX App',
        'fr': 'Rapport de bug - BiUX App',
    },
    'legal_info': {
        'es': 'Información Legal',
        'en': 'Legal Information',
        'pt': 'Informação Legal',
        'fr': 'Informations Légales',
    },
    'software_licenses': {
        'es': 'Licencias de software',
        'en': 'Software licenses',
        'pt': 'Licenças de software',
        'fr': 'Licences logicielles',
    },
    'app_legalese': {
        'es': '© 2024 BiUX. Todos los derechos reservados.',
        'en': '© 2024 BiUX. All rights reserved.',
        'pt': '© 2024 BiUX. Todos os direitos reservados.',
        'fr': '© 2024 BiUX. Tous droits réservés.',
    },
    'biux_app_cyclists': {
        'es': 'BiUX — App para ciclistas',
        'en': 'BiUX — App for cyclists',
        'pt': 'BiUX — App para ciclistas',
        'fr': 'BiUX — App pour cyclistes',
    },
    'all_rights_reserved': {
        'es': '© 2024 BiUX. Todos los derechos reservados.',
        'en': '© 2024 BiUX. All rights reserved.',
        'pt': '© 2024 BiUX. Todos os direitos reservados.',
        'fr': '© 2024 BiUX. Tous droits réservés.',
    },
    'terms_conditions_body': {
        'es': 'Al usar BiUX, aceptas estos términos y condiciones. BiUX es una plataforma de uso personal para ciclistas. Los usuarios son responsables del contenido que publican. BiUX se reserva el derecho de moderar y eliminar contenido que viole las normas de la comunidad. Los datos personales se manejan conforme a nuestra política de privacidad. Nos reservamos el derecho de actualizar estos términos en cualquier momento.',
        'en': 'By using BiUX, you accept these terms and conditions. BiUX is a personal use platform for cyclists. Users are responsible for the content they post. BiUX reserves the right to moderate and remove content that violates community guidelines. Personal data is handled in accordance with our privacy policy. We reserve the right to update these terms at any time.',
        'pt': 'Ao usar o BiUX, você aceita estes termos e condições. O BiUX é uma plataforma de uso pessoal para ciclistas. Os usuários são responsáveis pelo conteúdo que publicam. O BiUX se reserva o direito de moderar e remover conteúdo que viole as normas da comunidade. Os dados pessoais são tratados conforme nossa política de privacidade. Reservamo-nos o direito de atualizar estes termos a qualquer momento.',
        'fr': 'En utilisant BiUX, vous acceptez ces conditions d\'utilisation. BiUX est une plateforme d\'usage personnel pour les cyclistes. Les utilisateurs sont responsables du contenu qu\'ils publient. BiUX se réserve le droit de modérer et de supprimer le contenu qui enfreint les règles de la communauté. Les données personnelles sont traitées conformément à notre politique de confidentialité. Nous nous réservons le droit de mettre à jour ces conditions à tout moment.',
    },
    'privacy_policy_body': {
        'es': 'BiUX recopila y utiliza tu información personal para brindarte una mejor experiencia. Recopilamos datos como tu nombre, email, ubicación y actividad dentro de la app. Tus datos se almacenan de forma segura y no se comparten con terceros sin tu consentimiento, excepto cuando la ley lo requiera. Puedes solicitar la eliminación de tus datos en cualquier momento desde la configuración de tu cuenta.',
        'en': 'BiUX collects and uses your personal information to provide you with a better experience. We collect data such as your name, email, location and activity within the app. Your data is stored securely and is not shared with third parties without your consent, except when required by law. You can request the deletion of your data at any time from your account settings.',
        'pt': 'O BiUX coleta e utiliza suas informações pessoais para proporcionar uma melhor experiência. Coletamos dados como seu nome, email, localização e atividade dentro do app. Seus dados são armazenados de forma segura e não são compartilhados com terceiros sem seu consentimento, exceto quando exigido por lei. Você pode solicitar a exclusão dos seus dados a qualquer momento nas configurações da sua conta.',
        'fr': 'BiUX collecte et utilise vos informations personnelles pour vous offrir une meilleure expérience. Nous collectons des données telles que votre nom, email, localisation et activité dans l\'application. Vos données sont stockées de manière sécurisée et ne sont pas partagées avec des tiers sans votre consentement, sauf si la loi l\'exige. Vous pouvez demander la suppression de vos données à tout moment depuis les paramètres de votre compte.',
    },

    # ── Promotions ──
    'promotions_businesses_and_events': {
        'es': 'Negocios y Eventos',
        'en': 'Businesses & Events',
        'pt': 'Negócios e Eventos',
        'fr': 'Commerces et Événements',
    },
    'promotions_businesses': {
        'es': 'Negocios',
        'en': 'Businesses',
        'pt': 'Negócios',
        'fr': 'Commerces',
    },
    'promotions_events': {
        'es': 'Eventos',
        'en': 'Events',
        'pt': 'Eventos',
        'fr': 'Événements',
    },
    'promotions_admin_panel': {
        'es': 'Panel de administración',
        'en': 'Admin panel',
        'pt': 'Painel de administração',
        'fr': 'Panneau d\'administration',
    },
    'promotions_become_promoter': {
        'es': 'Ser promotor',
        'en': 'Become a promoter',
        'pt': 'Ser promotor',
        'fr': 'Devenir promoteur',
    },
    'promotions_type_bike_shop': {
        'es': 'Tienda de bicicletas',
        'en': 'Bike shop',
        'pt': 'Loja de bicicletas',
        'fr': 'Magasin de vélos',
    },
    'promotions_type_repair_shop': {
        'es': 'Taller de reparación',
        'en': 'Repair shop',
        'pt': 'Oficina de reparação',
        'fr': 'Atelier de réparation',
    },
    'promotions_type_accessories': {
        'es': 'Accesorios',
        'en': 'Accessories',
        'pt': 'Acessórios',
        'fr': 'Accessoires',
    },
    'promotions_type_cycling_clothing': {
        'es': 'Ropa de ciclismo',
        'en': 'Cycling clothing',
        'pt': 'Roupas de ciclismo',
        'fr': 'Vêtements de cyclisme',
    },
    'promotions_type_event_organizer': {
        'es': 'Organizador de eventos',
        'en': 'Event organizer',
        'pt': 'Organizador de eventos',
        'fr': 'Organisateur d\'événements',
    },
    'promotions_type_cafe': {
        'es': 'Café ciclista',
        'en': 'Cyclist café',
        'pt': 'Café ciclista',
        'fr': 'Café cycliste',
    },
    'promotions_type_bike_tourism': {
        'es': 'Cicloturismo',
        'en': 'Bike tourism',
        'pt': 'Cicloturismo',
        'fr': 'Cyclotourisme',
    },
    'promotions_type_other': {
        'es': 'Otro',
        'en': 'Other',
        'pt': 'Outro',
        'fr': 'Autre',
    },
    'promotions_verify_business': {
        'es': 'Verificar negocio',
        'en': 'Verify business',
        'pt': 'Verificar negócio',
        'fr': 'Vérifier le commerce',
    },
    'promotions_next': {
        'es': 'Siguiente',
        'en': 'Next',
        'pt': 'Próximo',
        'fr': 'Suivant',
    },
    'promotions_sending': {
        'es': 'Enviando...',
        'en': 'Sending...',
        'pt': 'Enviando...',
        'fr': 'Envoi en cours...',
    },
    'promotions_send_request': {
        'es': 'Enviar solicitud',
        'en': 'Send request',
        'pt': 'Enviar solicitação',
        'fr': 'Envoyer la demande',
    },
    'promotions_back': {
        'es': 'Atrás',
        'en': 'Back',
        'pt': 'Voltar',
        'fr': 'Retour',
    },
    'promotions_complete_name_and_description': {
        'es': 'Completa el nombre y la descripción',
        'en': 'Complete the name and description',
        'pt': 'Complete o nome e a descrição',
        'fr': 'Complétez le nom et la description',
    },
    'promotions_complete_address_and_phone': {
        'es': 'Completa la dirección y el teléfono',
        'en': 'Complete the address and phone number',
        'pt': 'Complete o endereço e o telefone',
        'fr': 'Complétez l\'adresse et le téléphone',
    },
    'promotions_business_data': {
        'es': 'Datos del negocio',
        'en': 'Business data',
        'pt': 'Dados do negócio',
        'fr': 'Données du commerce',
    },
    'promotions_basic_info': {
        'es': 'Información básica',
        'en': 'Basic information',
        'pt': 'Informação básica',
        'fr': 'Informations de base',
    },
    'promotions_business_name_required': {
        'es': 'Nombre del negocio *',
        'en': 'Business name *',
        'pt': 'Nome do negócio *',
        'fr': 'Nom du commerce *',
    },
    'promotions_business_type': {
        'es': 'Tipo de negocio',
        'en': 'Business type',
        'pt': 'Tipo de negócio',
        'fr': 'Type de commerce',
    },
    'promotions_business_description_required': {
        'es': 'Descripción del negocio *',
        'en': 'Business description *',
        'pt': 'Descrição do negócio *',
        'fr': 'Description du commerce *',
    },
    'promotions_products_services_hint': {
        'es': '¿Qué productos o servicios ofreces?',
        'en': 'What products or services do you offer?',
        'pt': 'Quais produtos ou serviços você oferece?',
        'fr': 'Quels produits ou services proposez-vous ?',
    },
    'promotions_verification': {
        'es': 'Verificación',
        'en': 'Verification',
        'pt': 'Verificação',
        'fr': 'Vérification',
    },
    'promotions_verification_data': {
        'es': 'Datos de verificación',
        'en': 'Verification data',
        'pt': 'Dados de verificação',
        'fr': 'Données de vérification',
    },
    'promotions_verification_info_text': {
        'es': 'Esta información nos ayuda a verificar tu negocio. Se revisará manualmente antes de aprobar tu solicitud.',
        'en': 'This information helps us verify your business. It will be manually reviewed before approving your request.',
        'pt': 'Essas informações nos ajudam a verificar seu negócio. Serão revisadas manualmente antes de aprovar sua solicitação.',
        'fr': 'Ces informations nous aident à vérifier votre commerce. Elles seront examinées manuellement avant d\'approuver votre demande.',
    },
    'promotions_nit_optional': {
        'es': 'NIT (opcional)',
        'en': 'Tax ID (optional)',
        'pt': 'CNPJ (opcional)',
        'fr': 'SIRET (optionnel)',
    },
    'promotions_nit_hint': {
        'es': 'Número de identificación tributaria',
        'en': 'Tax identification number',
        'pt': 'Número de identificação fiscal',
        'fr': 'Numéro d\'identification fiscale',
    },
    'promotions_has_physical_store': {
        'es': '¿Tiene local físico?',
        'en': 'Has physical store?',
        'pt': 'Tem loja física?',
        'fr': 'A un local physique ?',
    },
    'promotions_address_required': {
        'es': 'Dirección *',
        'en': 'Address *',
        'pt': 'Endereço *',
        'fr': 'Adresse *',
    },
    'promotions_city': {
        'es': 'Ciudad',
        'en': 'City',
        'pt': 'Cidade',
        'fr': 'Ville',
    },
    'promotions_city_hint': {
        'es': 'Ej: Bogotá, Medellín...',
        'en': 'E.g.: Miami, New York...',
        'pt': 'Ex: São Paulo, Rio...',
        'fr': 'Ex : Paris, Lyon...',
    },
    'promotions_phone_required': {
        'es': 'Teléfono *',
        'en': 'Phone *',
        'pt': 'Telefone *',
        'fr': 'Téléphone *',
    },
    'promotions_email_optional': {
        'es': 'Email (opcional)',
        'en': 'Email (optional)',
        'pt': 'Email (opcional)',
        'fr': 'Email (optionnel)',
    },
    'promotions_social_web_optional': {
        'es': 'Web o redes sociales (opcional)',
        'en': 'Website or social media (optional)',
        'pt': 'Site ou redes sociais (opcional)',
        'fr': 'Web ou réseaux sociaux (optionnel)',
    },
    'promotions_social_web_hint': {
        'es': 'Instagram, Facebook, sitio web...',
        'en': 'Instagram, Facebook, website...',
        'pt': 'Instagram, Facebook, site...',
        'fr': 'Instagram, Facebook, site web...',
    },
    'promotions_confirmation': {
        'es': 'Confirmación',
        'en': 'Confirmation',
        'pt': 'Confirmação',
        'fr': 'Confirmation',
    },
    'promotions_review_and_send': {
        'es': 'Revisa y envía',
        'en': 'Review and send',
        'pt': 'Revise e envie',
        'fr': 'Vérifiez et envoyez',
    },
    'promotions_request_summary': {
        'es': 'Resumen de la solicitud',
        'en': 'Request summary',
        'pt': 'Resumo da solicitação',
        'fr': 'Résumé de la demande',
    },
    'promotions_business': {
        'es': 'Negocio',
        'en': 'Business',
        'pt': 'Negócio',
        'fr': 'Commerce',
    },
    'promotions_type': {
        'es': 'Tipo',
        'en': 'Type',
        'pt': 'Tipo',
        'fr': 'Type',
    },
    'promotions_address': {
        'es': 'Dirección',
        'en': 'Address',
        'pt': 'Endereço',
        'fr': 'Adresse',
    },
    'promotions_phone': {
        'es': 'Teléfono',
        'en': 'Phone',
        'pt': 'Telefone',
        'fr': 'Téléphone',
    },
    'promotions_nit': {
        'es': 'NIT',
        'en': 'Tax ID',
        'pt': 'CNPJ',
        'fr': 'SIRET',
    },
    'promotions_email': {
        'es': 'Email',
        'en': 'Email',
        'pt': 'Email',
        'fr': 'Email',
    },
    'promotions_web_social': {
        'es': 'Web/Redes',
        'en': 'Web/Social',
        'pt': 'Web/Redes',
        'fr': 'Web/Réseaux',
    },
    'promotions_physical_store': {
        'es': 'Local físico',
        'en': 'Physical store',
        'pt': 'Loja física',
        'fr': 'Local physique',
    },
    'promotions_yes': {
        'es': 'Sí',
        'en': 'Yes',
        'pt': 'Sim',
        'fr': 'Oui',
    },
    'promotions_no': {
        'es': 'No',
        'en': 'No',
        'pt': 'Não',
        'fr': 'Non',
    },
    'promotions_once_approved': {
        'es': 'Una vez aprobado podrás:',
        'en': 'Once approved you can:',
        'pt': 'Uma vez aprovado você poderá:',
        'fr': 'Une fois approuvé, vous pourrez :',
    },
    'promotions_benefit_publish_ads': {
        'es': 'Publicar anuncios de tu negocio',
        'en': 'Publish ads for your business',
        'pt': 'Publicar anúncios do seu negócio',
        'fr': 'Publier des annonces pour votre commerce',
    },
    'promotions_benefit_create_events': {
        'es': 'Crear eventos para la comunidad',
        'en': 'Create events for the community',
        'pt': 'Criar eventos para a comunidade',
        'fr': 'Créer des événements pour la communauté',
    },
    'promotions_benefit_verified_badge': {
        'es': 'Obtener la insignia de verificado',
        'en': 'Get the verified badge',
        'pt': 'Obter o selo de verificado',
        'fr': 'Obtenir le badge vérifié',
    },
    'promotions_benefit_auto_approved': {
        'es': 'Publicaciones aprobadas automáticamente',
        'en': 'Posts automatically approved',
        'pt': 'Publicações aprovadas automaticamente',
        'fr': 'Publications approuvées automatiquement',
    },
    'promotions_terms_confirmation': {
        'es': 'Confirmo que la información proporcionada es verídica y acepto los términos de uso',
        'en': 'I confirm the information provided is truthful and I accept the terms of use',
        'pt': 'Confirmo que as informações fornecidas são verdadeiras e aceito os termos de uso',
        'fr': 'Je confirme que les informations fournies sont véridiques et j\'accepte les conditions d\'utilisation',
    },
    'promotions_request_sent': {
        'es': '¡Solicitud enviada!',
        'en': 'Request sent!',
        'pt': 'Solicitação enviada!',
        'fr': 'Demande envoyée !',
    },
    'promotions_admin_will_verify': {
        'es': 'Un administrador verificará tu información. Te notificaremos cuando sea aprobada.',
        'en': 'An administrator will verify your information. We will notify you when it is approved.',
        'pt': 'Um administrador verificará suas informações. Notificaremos quando for aprovada.',
        'fr': 'Un administrateur vérifiera vos informations. Nous vous informerons lorsqu\'elle sera approuvée.',
    },
    'promotions_understood': {
        'es': 'Entendido',
        'en': 'Got it',
        'pt': 'Entendido',
        'fr': 'Compris',
    },
    'promotions_send_error': {
        'es': 'Error al enviar la solicitud. Inténtalo de nuevo.',
        'en': 'Error sending the request. Please try again.',
        'pt': 'Erro ao enviar a solicitação. Tente novamente.',
        'fr': 'Erreur lors de l\'envoi de la demande. Veuillez réessayer.',
    },
    'promotions_publish_business': {
        'es': 'Publicar negocio',
        'en': 'Publish business',
        'pt': 'Publicar negócio',
        'fr': 'Publier commerce',
    },
    'promotions_new_business': {
        'es': 'Nuevo negocio',
        'en': 'New business',
        'pt': 'Novo negócio',
        'fr': 'Nouveau commerce',
    },
    'promotions_publish_for_community': {
        'es': 'Publica tu negocio para la comunidad ciclista',
        'en': 'Publish your business for the cycling community',
        'pt': 'Publique seu negócio para a comunidade ciclista',
        'fr': 'Publiez votre commerce pour la communauté cycliste',
    },
    'promotions_business_info': {
        'es': 'Información del negocio',
        'en': 'Business information',
        'pt': 'Informação do negócio',
        'fr': 'Informations du commerce',
    },
    'promotions_name_required_error': {
        'es': 'El nombre es obligatorio',
        'en': 'Name is required',
        'pt': 'O nome é obrigatório',
        'fr': 'Le nom est obligatoire',
    },
    'promotions_description_required': {
        'es': 'Descripción *',
        'en': 'Description *',
        'pt': 'Descrição *',
        'fr': 'Description *',
    },
    'promotions_describe_hint': {
        'es': 'Describe tu negocio, productos y servicios...',
        'en': 'Describe your business, products and services...',
        'pt': 'Descreva seu negócio, produtos e serviços...',
        'fr': 'Décrivez votre commerce, produits et services...',
    },
    'promotions_description_required_error': {
        'es': 'La descripción es obligatoria',
        'en': 'Description is required',
        'pt': 'A descrição é obrigatória',
        'fr': 'La description est obligatoire',
    },
    'promotions_location_and_contact': {
        'es': 'Ubicación y contacto',
        'en': 'Location and contact',
        'pt': 'Localização e contato',
        'fr': 'Emplacement et contact',
    },
    'promotions_address_location_required': {
        'es': 'Dirección / Ubicación *',
        'en': 'Address / Location *',
        'pt': 'Endereço / Localização *',
        'fr': 'Adresse / Emplacement *',
    },
    'promotions_address_hint': {
        'es': 'Ej: Cra 7 #45-12, Bogotá',
        'en': 'E.g.: 123 Main St, Miami',
        'pt': 'Ex: Rua das Flores, 123, São Paulo',
        'fr': 'Ex : 12 Rue de la Paix, Paris',
    },
    'promotions_address_required_error': {
        'es': 'La dirección es obligatoria',
        'en': 'Address is required',
        'pt': 'O endereço é obrigatório',
        'fr': 'L\'adresse est obligatoire',
    },
    'promotions_contact_phone_email': {
        'es': 'Contacto (teléfono, email)',
        'en': 'Contact (phone, email)',
        'pt': 'Contato (telefone, email)',
        'fr': 'Contact (téléphone, email)',
    },
    'promotions_phone_hint': {
        'es': 'Ej: 300 123 4567',
        'en': 'E.g.: 555 123 4567',
        'pt': 'Ex: 11 91234 5678',
        'fr': 'Ex : 06 12 34 56 78',
    },
    'promotions_publishing': {
        'es': 'Publicando...',
        'en': 'Publishing...',
        'pt': 'Publicando...',
        'fr': 'Publication en cours...',
    },
    'promotions_business_published': {
        'es': '¡Negocio publicado exitosamente!',
        'en': 'Business published successfully!',
        'pt': 'Negócio publicado com sucesso!',
        'fr': 'Commerce publié avec succès !',
    },
    'promotions_create_event': {
        'es': 'Crear evento',
        'en': 'Create event',
        'pt': 'Criar evento',
        'fr': 'Créer un événement',
    },
    'promotions_new_event': {
        'es': 'Nuevo evento',
        'en': 'New event',
        'pt': 'Novo evento',
        'fr': 'Nouvel événement',
    },
    'promotions_create_event_subtitle': {
        'es': 'Organiza un evento para la comunidad ciclista',
        'en': 'Organize an event for the cycling community',
        'pt': 'Organize um evento para a comunidade ciclista',
        'fr': 'Organisez un événement pour la communauté cycliste',
    },
    'promotions_event_info': {
        'es': 'Información del evento',
        'en': 'Event information',
        'pt': 'Informação do evento',
        'fr': 'Informations de l\'événement',
    },
    'promotions_event_name_required': {
        'es': 'Nombre del evento *',
        'en': 'Event name *',
        'pt': 'Nome do evento *',
        'fr': 'Nom de l\'événement *',
    },
    'promotions_required': {
        'es': 'Este campo es obligatorio',
        'en': 'This field is required',
        'pt': 'Este campo é obrigatório',
        'fr': 'Ce champ est obligatoire',
    },
    'promotions_event_description_required': {
        'es': 'Descripción del evento *',
        'en': 'Event description *',
        'pt': 'Descrição do evento *',
        'fr': 'Description de l\'événement *',
    },
    'promotions_event_describe_hint': {
        'es': 'Describe el evento, actividades, requisitos...',
        'en': 'Describe the event, activities, requirements...',
        'pt': 'Descreva o evento, atividades, requisitos...',
        'fr': 'Décrivez l\'événement, les activités, les prérequis...',
    },
    'promotions_date_and_time': {
        'es': 'Fecha y hora',
        'en': 'Date and time',
        'pt': 'Data e hora',
        'fr': 'Date et heure',
    },
    'promotions_location_and_spots': {
        'es': 'Ubicación y cupos',
        'en': 'Location and spots',
        'pt': 'Localização e vagas',
        'fr': 'Emplacement et places',
    },
    'promotions_event_location_required': {
        'es': 'Lugar del evento *',
        'en': 'Event location *',
        'pt': 'Local do evento *',
        'fr': 'Lieu de l\'événement *',
    },
    'promotions_event_location_hint': {
        'es': 'Ej: Parque Simón Bolívar, Bogotá',
        'en': 'E.g.: Central Park, New York',
        'pt': 'Ex: Parque Ibirapuera, São Paulo',
        'fr': 'Ex : Parc de la Tête d\'Or, Lyon',
    },
    'promotions_max_spots_optional': {
        'es': 'Cupos máximos (opcional)',
        'en': 'Maximum spots (optional)',
        'pt': 'Vagas máximas (opcional)',
        'fr': 'Places maximales (optionnel)',
    },
    'promotions_unlimited_spots_hint': {
        'es': 'Dejar vacío para cupos ilimitados',
        'en': 'Leave empty for unlimited spots',
        'pt': 'Deixe vazio para vagas ilimitadas',
        'fr': 'Laisser vide pour des places illimitées',
    },
    'promotions_contact_info': {
        'es': 'Información de contacto',
        'en': 'Contact information',
        'pt': 'Informação de contato',
        'fr': 'Informations de contact',
    },
    'promotions_creating': {
        'es': 'Creando...',
        'en': 'Creating...',
        'pt': 'Criando...',
        'fr': 'Création en cours...',
    },
    'promotions_date_required': {
        'es': 'Fecha *',
        'en': 'Date *',
        'pt': 'Data *',
        'fr': 'Date *',
    },
    'promotions_time_required': {
        'es': 'Hora *',
        'en': 'Time *',
        'pt': 'Hora *',
        'fr': 'Heure *',
    },
    'promotions_select_event_date': {
        'es': 'Selecciona la fecha del evento',
        'en': 'Select the event date',
        'pt': 'Selecione a data do evento',
        'fr': 'Sélectionnez la date de l\'événement',
    },
    'promotions_select_event_time': {
        'es': 'Selecciona la hora del evento',
        'en': 'Select the event time',
        'pt': 'Selecione a hora do evento',
        'fr': 'Sélectionnez l\'heure de l\'événement',
    },
    'promotions_event_created': {
        'es': '¡Evento creado exitosamente!',
        'en': 'Event created successfully!',
        'pt': 'Evento criado com sucesso!',
        'fr': 'Événement créé avec succès !',
    },
    'promotions_no_businesses': {
        'es': 'No hay negocios aún',
        'en': 'No businesses yet',
        'pt': 'Nenhum negócio ainda',
        'fr': 'Aucun commerce pour le moment',
    },
    'promotions_no_businesses_subtitle': {
        'es': 'Sé el primero en publicar tu negocio ciclista',
        'en': 'Be the first to publish your cycling business',
        'pt': 'Seja o primeiro a publicar seu negócio ciclista',
        'fr': 'Soyez le premier à publier votre commerce cycliste',
    },
    'promotions_no_events': {
        'es': 'No hay eventos aún',
        'en': 'No events yet',
        'pt': 'Nenhum evento ainda',
        'fr': 'Aucun événement pour le moment',
    },
    'promotions_no_events_subtitle': {
        'es': 'Crea un evento para la comunidad ciclista',
        'en': 'Create an event for the cycling community',
        'pt': 'Crie um evento para a comunidade ciclista',
        'fr': 'Créez un événement pour la communauté cycliste',
    },
    'promotions_registered_count': {
        'es': 'registrados',
        'en': 'registered',
        'pt': 'registrados',
        'fr': 'inscrits',
    },
    'promotions_spots': {
        'es': 'cupos',
        'en': 'spots',
        'pt': 'vagas',
        'fr': 'places',
    },
    'promotions_full': {
        'es': 'LLENO',
        'en': 'FULL',
        'pt': 'LOTADO',
        'fr': 'COMPLET',
    },
    'promotions_enrolled': {
        'es': 'Inscrito',
        'en': 'Enrolled',
        'pt': 'Inscrito',
        'fr': 'Inscrit',
    },
    'promotions_cancel_error': {
        'es': 'Error al cancelar el registro',
        'en': 'Error canceling registration',
        'pt': 'Erro ao cancelar o registro',
        'fr': 'Erreur lors de l\'annulation de l\'inscription',
    },
    'promotions_cancel_registration': {
        'es': 'Cancelar registro',
        'en': 'Cancel registration',
        'pt': 'Cancelar registro',
        'fr': 'Annuler l\'inscription',
    },
    'promotions_register_to_event': {
        'es': 'Registrarse al evento',
        'en': 'Register for event',
        'pt': 'Registrar-se no evento',
        'fr': 'S\'inscrire à l\'événement',
    },
    'promotions_admin_panel_title': {
        'es': 'Panel de Administración',
        'en': 'Administration Panel',
        'pt': 'Painel de Administração',
        'fr': 'Panneau d\'Administration',
    },
    'promotions_pending': {
        'es': 'Pendientes',
        'en': 'Pending',
        'pt': 'Pendentes',
        'fr': 'En attente',
    },
    'promotions_all_up_to_date': {
        'es': '¡Todo al día!',
        'en': 'All up to date!',
        'pt': 'Tudo em dia!',
        'fr': 'Tout est à jour !',
    },
    'promotions_no_pending_requests': {
        'es': 'No hay solicitudes pendientes',
        'en': 'No pending requests',
        'pt': 'Nenhuma solicitação pendente',
        'fr': 'Aucune demande en attente',
    },
    'promotions_by': {
        'es': 'Por',
        'en': 'By',
        'pt': 'Por',
        'fr': 'Par',
    },
    'promotions_request_rejected': {
        'es': 'Solicitud rechazada',
        'en': 'Request rejected',
        'pt': 'Solicitação rejeitada',
        'fr': 'Demande rejetée',
    },
    'promotions_reject': {
        'es': 'Rechazar',
        'en': 'Reject',
        'pt': 'Rejeitar',
        'fr': 'Rejeter',
    },
    'promotions_request_approved': {
        'es': 'Solicitud aprobada',
        'en': 'Request approved',
        'pt': 'Solicitação aprovada',
        'fr': 'Demande approuvée',
    },
    'promotions_approve': {
        'es': 'Aprobar',
        'en': 'Approve',
        'pt': 'Aprovar',
        'fr': 'Approuver',
    },

    # ── Shop — seller requests ──
    'confirm_approve_request_of': {
        'es': '¿Aprobar la solicitud de',
        'en': 'Approve the request of',
        'pt': 'Aprovar a solicitação de',
        'fr': 'Approuver la demande de',
    },
    'confirm_reject_request_of': {
        'es': '¿Rechazar la solicitud de',
        'en': 'Reject the request of',
        'pt': 'Rejeitar a solicitação de',
        'fr': 'Rejeter la demande de',
    },
    'default_approve_comment': {
        'es': 'Solicitud aprobada. ¡Bienvenido al equipo!',
        'en': 'Request approved. Welcome to the team!',
        'pt': 'Solicitação aprovada. Bem-vindo à equipe!',
        'fr': 'Demande approuvée. Bienvenue dans l\'équipe !',
    },

    # ── Shop — admin ──
    'admin_no_sellers_registered': {
        'es': 'No hay vendedores registrados',
        'en': 'No sellers registered',
        'pt': 'Nenhum vendedor registrado',
        'fr': 'Aucun vendeur enregistré',
    },
    'admin_sellers_permissions': {
        'es': 'Permisos de vendedores',
        'en': 'Seller permissions',
        'pt': 'Permissões de vendedores',
        'fr': 'Permissions des vendeurs',
    },
    'admin_modify_prices_perm': {
        'es': 'Modificar precios',
        'en': 'Modify prices',
        'pt': 'Modificar preços',
        'fr': 'Modifier les prix',
    },
    'admin_add_products_perm': {
        'es': 'Agregar productos',
        'en': 'Add products',
        'pt': 'Adicionar produtos',
        'fr': 'Ajouter des produits',
    },
    'admin_delete_products_perm': {
        'es': 'Eliminar productos',
        'en': 'Delete products',
        'pt': 'Excluir produtos',
        'fr': 'Supprimer des produits',
    },
    'admin_view_reports_perm': {
        'es': 'Ver reportes',
        'en': 'View reports',
        'pt': 'Ver relatórios',
        'fr': 'Voir les rapports',
    },
    'admin_enabled': {
        'es': 'Habilitado',
        'en': 'Enabled',
        'pt': 'Habilitado',
        'fr': 'Activé',
    },
    'admin_disabled': {
        'es': 'Deshabilitado',
        'en': 'Disabled',
        'pt': 'Desabilitado',
        'fr': 'Désactivé',
    },
    'admin_confirm_delete_seller': {
        'es': '¿Eliminar a',
        'en': 'Remove',
        'pt': 'Excluir',
        'fr': 'Supprimer',
    },
    'admin_from_team': {
        'es': 'del equipo',
        'en': 'from the team',
        'pt': 'da equipe',
        'fr': 'de l\'équipe',
    },
    'admin_top5_by_price': {
        'es': 'Top 5 productos por precio',
        'en': 'Top 5 products by price',
        'pt': 'Top 5 produtos por preço',
        'fr': 'Top 5 des produits par prix',
    },
    'admin_total_inventory': {
        'es': 'Inventario total',
        'en': 'Total inventory',
        'pt': 'Inventário total',
        'fr': 'Inventaire total',
    },
    'admin_units_in': {
        'es': 'unidades en',
        'en': 'units in',
        'pt': 'unidades em',
        'fr': 'unités dans',
    },
    'admin_inactive': {
        'es': 'Inactivos',
        'en': 'Inactive',
        'pt': 'Inativos',
        'fr': 'Inactifs',
    },
    'admin_no_out_of_stock': {
        'es': '¡No hay productos agotados!',
        'en': 'No out of stock products!',
        'pt': 'Nenhum produto esgotado!',
        'fr': 'Aucun produit en rupture de stock !',
    },
    'admin_products_by_category': {
        'es': 'Productos por categoría',
        'en': 'Products by category',
        'pt': 'Produtos por categoria',
        'fr': 'Produits par catégorie',
    },
    'admin_report_generated_success': {
        'es': 'Reporte generado exitosamente',
        'en': 'Report generated successfully',
        'pt': 'Relatório gerado com sucesso',
        'fr': 'Rapport généré avec succès',
    },
    'admin_min_price': {
        'es': 'Precio mínimo',
        'en': 'Minimum price',
        'pt': 'Preço mínimo',
        'fr': 'Prix minimum',
    },
    'admin_max_price': {
        'es': 'Precio máximo',
        'en': 'Maximum price',
        'pt': 'Preço máximo',
        'fr': 'Prix maximum',
    },
    'admin_in_this_period': {
        'es': 'En este período',
        'en': 'In this period',
        'pt': 'Neste período',
        'fr': 'Durant cette période',
    },
    'admin_products_created': {
        'es': 'productos creados',
        'en': 'products created',
        'pt': 'produtos criados',
        'fr': 'produits créés',
    },
    'admin_distribution_by_category': {
        'es': 'Distribución por categoría',
        'en': 'Distribution by category',
        'pt': 'Distribuição por categoria',
        'fr': 'Distribution par catégorie',
    },
    'admin_notifications': {
        'es': 'Notificaciones',
        'en': 'Notifications',
        'pt': 'Notificações',
        'fr': 'Notifications',
    },
    'admin_lock_after_5_attempts': {
        'es': 'Bloquear después de 5 intentos fallidos',
        'en': 'Lock after 5 failed attempts',
        'pt': 'Bloquear após 5 tentativas falhas',
        'fr': 'Bloquer après 5 tentatives échouées',
    },
    'admin_lock': {
        'es': 'Bloqueo',
        'en': 'Lock',
        'pt': 'Bloqueio',
        'fr': 'Verrouillage',
    },
    'admin_password_min_6_chars': {
        'es': 'La contraseña debe tener al menos 6 caracteres',
        'en': 'Password must be at least 6 characters',
        'pt': 'A senha deve ter pelo menos 6 caracteres',
        'fr': 'Le mot de passe doit comporter au moins 6 caractères',
    },
    'admin_password_updated_success': {
        'es': 'Contraseña actualizada exitosamente',
        'en': 'Password updated successfully',
        'pt': 'Senha atualizada com sucesso',
        'fr': 'Mot de passe mis à jour avec succès',
    },
    'admin_current': {
        'es': 'Actual',
        'en': 'Current',
        'pt': 'Atual',
        'fr': 'Actuel',
    },
    'admin_all_remote_sessions_closed': {
        'es': 'Todas las sesiones remotas han sido cerradas',
        'en': 'All remote sessions have been closed',
        'pt': 'Todas as sessões remotas foram encerradas',
        'fr': 'Toutes les sessions distantes ont été fermées',
    },

    # ── Shop — stats ──
    'count_products': {
        'es': 'productos',
        'en': 'products',
        'pt': 'produtos',
        'fr': 'produits',
    },
    'in_preposition': {
        'es': 'en',
        'en': 'in',
        'pt': 'em',
        'fr': 'dans',
    },
    'count_categories': {
        'es': 'categorías',
        'en': 'categories',
        'pt': 'categorias',
        'fr': 'catégories',
    },

    # ── Shop — seller request dialog ──
    'default_seller_request_message': {
        'es': 'Me gustaría obtener permiso para vender productos en la tienda. Tengo experiencia en el sector ciclista.',
        'en': 'I would like to get permission to sell products in the store. I have experience in the cycling sector.',
        'pt': 'Gostaria de obter permissão para vender produtos na loja. Tenho experiência no setor ciclístico.',
        'fr': 'Je souhaiterais obtenir la permission de vendre des produits dans la boutique. J\'ai de l\'expérience dans le secteur cycliste.',
    },

    # ── Users — account settings ──
    'linked_devices': {
        'es': 'Dispositivos vinculados',
        'en': 'Linked devices',
        'pt': 'Dispositivos vinculados',
        'fr': 'Appareils liés',
    },
    'this_device': {
        'es': 'Este dispositivo',
        'en': 'This device',
        'pt': 'Este dispositivo',
        'fr': 'Cet appareil',
    },
    'currently_logged_in': {
        'es': 'Sesión activa actualmente',
        'en': 'Currently logged in',
        'pt': 'Sessão ativa atualmente',
        'fr': 'Actuellement connecté',
    },
    'not_linked': {
        'es': 'No vinculado',
        'en': 'Not linked',
        'pt': 'Não vinculado',
        'fr': 'Non lié',
    },
    'see_where_logged_in': {
        'es': 'Revisa dónde has iniciado sesión',
        'en': 'See where you\'re logged in',
        'pt': 'Veja onde você está logado',
        'fr': 'Voir où vous êtes connecté',
    },
    'confirm_identity': {
        'es': 'Confirma tu identidad',
        'en': 'Confirm your identity',
        'pt': 'Confirme sua identidade',
        'fr': 'Confirmez votre identité',
    },
    'privacy_security': {
        'es': 'Privacidad y Seguridad',
        'en': 'Privacy & Security',
        'pt': 'Privacidade e Segurança',
        'fr': 'Confidentialité et Sécurité',
    },
    'permanently_delete_account': {
        'es': 'Eliminar cuenta permanentemente',
        'en': 'Permanently delete account',
        'pt': 'Excluir conta permanentemente',
        'fr': 'Supprimer le compte définitivement',
    },

    # ── Users — edit username ──
    'username_info_desc': {
        'es': 'Tu nombre de usuario es único y permite que otros te encuentren fácilmente',
        'en': 'Your username is unique and allows others to find you easily',
        'pt': 'Seu nome de usuário é único e permite que outros te encontrem facilmente',
        'fr': 'Votre nom d\'utilisateur est unique et permet aux autres de vous trouver facilement',
    },
    'username_hint': {
        'es': 'nombre_de_usuario',
        'en': 'username',
        'pt': 'nome_de_usuario',
        'fr': 'nom_utilisateur',
    },
    'username_required': {
        'es': 'El nombre de usuario es obligatorio',
        'en': 'Username is required',
        'pt': 'O nome de usuário é obrigatório',
        'fr': 'Le nom d\'utilisateur est obligatoire',
    },
    'username_min_chars': {
        'es': 'El nombre de usuario debe tener al menos 3 caracteres',
        'en': 'Username must have at least 3 characters',
        'pt': 'O nome de usuário deve ter pelo menos 3 caracteres',
        'fr': 'Le nom d\'utilisateur doit comporter au moins 3 caractères',
    },
    'username_max_chars': {
        'es': 'El nombre de usuario no puede exceder 30 caracteres',
        'en': 'Username cannot exceed 30 characters',
        'pt': 'O nome de usuário não pode exceder 30 caracteres',
        'fr': 'Le nom d\'utilisateur ne peut pas dépasser 30 caractères',
    },
    'username_only_valid_chars': {
        'es': 'Solo se permiten letras, números y guion bajo',
        'en': 'Only letters, numbers and underscores allowed',
        'pt': 'Somente letras, números e sublinhado permitidos',
        'fr': 'Seuls les lettres, chiffres et tirets bas sont autorisés',
    },
    'username_updated_success': {
        'es': 'Nombre de usuario actualizado',
        'en': 'Username updated',
        'pt': 'Nome de usuário atualizado',
        'fr': 'Nom d\'utilisateur mis à jour',
    },

    # ── Users — search ──
    'search_users_empty_title': {
        'es': 'Buscar usuarios',
        'en': 'Search users',
        'pt': 'Buscar usuários',
        'fr': 'Rechercher des utilisateurs',
    },
    'searching_users': {
        'es': 'Buscando usuarios...',
        'en': 'Searching users...',
        'pt': 'Buscando usuários...',
        'fr': 'Recherche d\'utilisateurs...',
    },
    'no_users_found': {
        'es': 'No se encontraron usuarios',
        'en': 'No users found',
        'pt': 'Nenhum usuário encontrado',
        'fr': 'Aucun utilisateur trouvé',
    },
    'try_another_search': {
        'es': 'Intenta con otro término de búsqueda',
        'en': 'Try another search term',
        'pt': 'Tente outro termo de busca',
        'fr': 'Essayez un autre terme de recherche',
    },
    'follower_singular': {
        'es': 'seguidor',
        'en': 'follower',
        'pt': 'seguidor',
        'fr': 'abonné',
    },

    # ── Users — profile image picker ──
    'change_profile_photo': {
        'es': 'Cambiar foto de perfil',
        'en': 'Change profile photo',
        'pt': 'Alterar foto de perfil',
        'fr': 'Changer la photo de profil',
    },
    'use_camera': {
        'es': 'Usar la cámara del dispositivo',
        'en': 'Use device camera',
        'pt': 'Usar a câmera do dispositivo',
        'fr': 'Utiliser la caméra de l\'appareil',
    },
    'choose_existing_photo': {
        'es': 'Elige una foto existente',
        'en': 'Choose an existing photo',
        'pt': 'Escolha uma foto existente',
        'fr': 'Choisir une photo existante',
    },
    'use_default_avatar': {
        'es': 'Usar avatar predeterminado',
        'en': 'Use default avatar',
        'pt': 'Usar avatar padrão',
        'fr': 'Utiliser l\'avatar par défaut',
    },
}


def main():
    print(f"Reading {TRANSLATIONS_FILE}...")
    with open(TRANSLATIONS_FILE, 'r', encoding='utf-8') as f:
        content = f.read()

    lines = content.split('\n')
    total_lines = len(lines)
    print(f"  File has {total_lines} lines, {len(MISSING)} keys to add.")

    # Check which keys already exist to avoid duplicates
    existing_keys = set()
    for line in lines:
        m = re.match(r"\s+'([a-zA-Z0-9_]+)'\s*:", line)
        if m:
            existing_keys.add(m.group(1))

    new_keys = {k: v for k, v in MISSING.items() if k not in existing_keys}
    skipped = set(MISSING.keys()) - set(new_keys.keys())
    if skipped:
        print(f"  Skipping {len(skipped)} keys already in translations: {sorted(skipped)}")
    print(f"  Adding {len(new_keys)} new keys.")

    if not new_keys:
        print("Nothing to add!")
        return

    # Find insertion points (line numbers right before each closing '};')
    # _es ends before _en starts, _en before _pt, _pt before _fr, _fr before class end
    lang_sections = []
    lang_codes = ['es', 'en', 'pt', 'fr']
    
    # Find lines that start each map
    map_starts = {}
    for i, line in enumerate(lines):
        m = re.match(r"\s+static const Map<String, String> _(\w+) = \{", line)
        if m:
            map_starts[m.group(1)] = i

    # For each lang, find its closing '};'
    for lang in lang_codes:
        start = map_starts.get(lang)
        if start is None:
            print(f"  ERROR: Could not find start of _{lang} map!")
            return
        
        # Find the matching closing '};' by counting braces
        brace_count = 0
        close_line = None
        for i in range(start, total_lines):
            line = lines[i]
            brace_count += line.count('{') - line.count('}')
            if brace_count == 0 and i > start:
                close_line = i
                break
        
        if close_line is None:
            print(f"  ERROR: Could not find closing of _{lang} map!")
            return
        
        lang_sections.append((lang, close_line))
        print(f"  _{lang}: starts at line {start+1}, closes at line {close_line+1}")

    # Build insertion text for each language
    # Process in reverse order so line numbers don't shift
    for lang, close_line in reversed(lang_sections):
        entries = []
        for key in sorted(new_keys.keys()):
            translations = new_keys[key]
            value = translations.get(lang, translations.get('es', key))
            # Escape single quotes in values
            value = value.replace("'", "\\'")
            entries.append(f"    '{key}': '{value}',")
        
        block = '\n'.join([
            '',
            '    // ── Traducciones añadidas automáticamente ──',
            *entries,
        ])
        
        # Insert before the closing '};'
        lines.insert(close_line, block)
        print(f"  Inserted {len(entries)} entries in _{lang} before line {close_line+1}")

    new_content = '\n'.join(lines)
    with open(TRANSLATIONS_FILE, 'w', encoding='utf-8') as f:
        f.write(new_content)

    print(f"\nDone! File updated with {len(new_keys)} new keys in {len(lang_codes)} languages.")
    print(f"Total new lines added: ~{len(new_keys) * len(lang_codes)}")


if __name__ == '__main__':
    main()
