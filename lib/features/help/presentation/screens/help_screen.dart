import 'package:flutter/material.dart';
import 'package:biux/core/design_system/color_tokens.dart';
import 'package:url_launcher/url_launcher.dart';

/// Pantalla de Ayuda con información importante para los usuarios
class HelpScreen extends StatelessWidget {
  const HelpScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ayuda y Soporte'),
        backgroundColor: ColorTokens.primary30,
        foregroundColor: ColorTokens.neutral100,
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          // Bienvenida
          _buildWelcomeCard(),
          SizedBox(height: 16),

          // Preguntas Frecuentes
          _buildSectionTitle('Preguntas Frecuentes'),
          _buildFAQItem(
            '¿Cómo crear una historia?',
            'Ve a la sección de Experiencias, toca el botón +, agrega una foto o video (máx. 30 segundos), escribe una descripción corta y publica. Las historias desaparecen en 24 horas.',
          ),
          _buildFAQItem(
            '¿Cómo registrar mi bicicleta?',
            'Ve a "Mis Bicis", toca el botón +, completa la información de tu bici (marca, modelo, color, número de serie). Esto te ayudará si la pierdes o es robada.',
          ),
          _buildFAQItem(
            '¿Cómo unirme a una rodada?',
            'Ve a la sección de Rodadas, busca una que te interese, toca en ella y presiona "Unirse". Recibirás notificaciones sobre actualizaciones de la rodada.',
          ),
          _buildFAQItem(
            '¿Cómo crear un grupo?',
            'Ve a Grupos, toca "Crear Grupo", completa la información (nombre, descripción, foto) y decide si será público o privado. Luego invita a otros ciclistas.',
          ),
          _buildFAQItem(
            '¿Las fotos y videos ocupan mucho espacio?',
            'No. La app comprime automáticamente las fotos a 1080x1350px y los videos se limitan a 30 segundos para optimizar el almacenamiento.',
          ),
          _buildFAQItem(
            '¿Puedo publicar posts sin fotos?',
            'Sí, pero solo los posts de texto son permanentes. Si agregas multimedia, se publicará automáticamente como historia (24 horas).',
          ),

          SizedBox(height: 24),

          // Características Principales
          _buildSectionTitle('Características Principales'),
          _buildFeatureCard(
            icon: Icons.camera_alt,
            title: 'Historias y Experiencias',
            description:
                'Comparte momentos de tus rodadas con fotos y videos. Las historias duran 24 horas.',
            color: ColorTokens.primary50,
          ),
          _buildFeatureCard(
            icon: Icons.directions_bike,
            title: 'Rodadas Organizadas',
            description:
                'Crea o únete a rodadas con otros ciclistas. Coordina rutas, horarios y puntos de encuentro.',
            color: ColorTokens.secondary50,
          ),
          _buildFeatureCard(
            icon: Icons.pedal_bike,
            title: 'Registro de Bicicletas',
            description:
                'Registra tus bicis con QR único. Si la pierdes, otros usuarios pueden ayudarte a encontrarla.',
            color: Colors.green,
          ),
          _buildFeatureCard(
            icon: Icons.group,
            title: 'Grupos y Comunidad',
            description:
                'Crea grupos de ciclismo, comparte rutas, organiza eventos y conecta con otros riders.',
            color: ColorTokens.primary30,
          ),
          _buildFeatureCard(
            icon: Icons.map,
            title: 'Mapas y Rutas',
            description:
                'Explora rutas de ciclismo, guarda tus favoritas y compártelas con la comunidad.',
            color: ColorTokens.secondary30,
          ),
          _buildFeatureCard(
            icon: Icons.favorite,
            title: 'Interacción Social',
            description:
                'Da like, comenta y sigue a otros ciclistas. Recibe notificaciones de actividad.',
            color: Colors.pink,
          ),

          SizedBox(height: 24),

          // Consejos de Seguridad
          _buildSectionTitle('Consejos de Seguridad'),
          _buildSafetyTip(
            '🚴‍♂️ Usa siempre casco',
            'El casco puede salvar tu vida. Es obligatorio para rodadas organizadas.',
          ),
          _buildSafetyTip(
            '🦺 Usa ropa visible',
            'Colores brillantes y reflectivos te hacen más visible, especialmente de noche.',
          ),
          _buildSafetyTip(
            '💡 Luces en tu bici',
            'Luz blanca adelante, roja atrás. Obligatorio para rodadas nocturnas.',
          ),
          _buildSafetyTip(
            '📱 Registra tu bici',
            'Si registras tu bicicleta en la app, será más fácil recuperarla si la pierdes.',
          ),
          _buildSafetyTip(
            '👥 Rueda en grupo',
            'Es más seguro rodar con otros. Usa las rodadas organizadas de la app.',
          ),
          _buildSafetyTip(
            '🛣️ Respeta las señales',
            'Los ciclistas también deben respetar semáforos y señales de tránsito.',
          ),

          SizedBox(height: 24),

          // Soporte y Contacto
          _buildSectionTitle('Soporte y Contacto'),
          _buildContactCard(
            icon: Icons.email,
            title: 'Email de Soporte',
            subtitle: 'soporte@biux.app',
            onTap: () => _launchEmail('soporte@biux.app'),
          ),
          _buildContactCard(
            icon: Icons.phone,
            title: 'WhatsApp',
            subtitle: '+57 300 123 4567',
            onTap: () => _launchWhatsApp('+573001234567'),
          ),
          _buildContactCard(
            icon: Icons.web,
            title: 'Sitio Web',
            subtitle: 'www.biux.app',
            onTap: () => _launchURL('https://biux.devshouse.org'),
          ),
          _buildContactCard(
            icon: Icons.bug_report,
            title: 'Reportar un Error',
            subtitle: 'Ayúdanos a mejorar reportando bugs',
            onTap: () => _launchEmail(
              'bugs@biux.app',
              subject: 'Reporte de Error - BiUX App',
            ),
          ),

          SizedBox(height: 24),

          // Información Legal
          _buildSectionTitle('Información Legal'),
          _buildLegalItem('Términos y Condiciones', () {
            _showTermsDialog(context);
          }),
          _buildLegalItem('Política de Privacidad', () {
            _showPrivacyDialog(context);
          }),
          _buildLegalItem('Licencias de Software', () {
            showLicensePage(
              context: context,
              applicationName: 'BiUX',
              applicationVersion: '1.0.0',
              applicationLegalese:
                  '© 2025 BiUX. Todos los derechos reservados.',
            );
          }),

          SizedBox(height: 24),

          // Versión de la App
          Center(
            child: Column(
              children: [
                Icon(Icons.pedal_bike, size: 48, color: ColorTokens.primary50),
                SizedBox(height: 8),
                Text(
                  'BiUX - App para Ciclistas',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: ColorTokens.primary50,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Versión 1.0.0',
                  style: TextStyle(fontSize: 12, color: ColorTokens.neutral60),
                ),
                SizedBox(height: 4),
                Text(
                  '© 2025 BiUX. Todos los derechos reservados.',
                  style: TextStyle(fontSize: 10, color: ColorTokens.neutral60),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Card(
      color: ColorTokens.primary50,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.help_outline, color: Colors.white, size: 32),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '¡Bienvenido a BiUX!',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Text(
              'Aquí encontrarás respuestas a las preguntas más frecuentes, consejos de seguridad y cómo contactarnos si necesitas ayuda.',
              style: TextStyle(fontSize: 14, color: Colors.white, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: ColorTokens.primary50,
        ),
      ),
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return Card(
      margin: EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        title: Text(
          question,
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              answer,
              style: TextStyle(
                fontSize: 14,
                color: ColorTokens.neutral60,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: ColorTokens.neutral80,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 13,
                      color: ColorTokens.neutral60,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSafetyTip(String title, String description) {
    return Card(
      margin: EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(Icons.warning_amber, color: Colors.orange),
        title: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        subtitle: Padding(
          padding: EdgeInsets.only(top: 4),
          child: Text(description, style: TextStyle(fontSize: 13)),
        ),
      ),
    );
  }

  Widget _buildContactCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: ColorTokens.primary50.withValues(alpha: 0.1),
          child: Icon(icon, color: ColorTokens.primary50),
        ),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  Widget _buildLegalItem(String title, VoidCallback onTap) {
    return Card(
      margin: EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(Icons.description, color: ColorTokens.neutral60),
        title: Text(title),
        trailing: Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  void _launchEmail(String email, {String? subject}) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      query: subject != null ? 'subject=${Uri.encodeComponent(subject)}' : null,
    );

    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    }
  }

  void _launchWhatsApp(String phone) async {
    final Uri whatsappUri = Uri.parse('https://wa.me/$phone');

    if (await canLaunchUrl(whatsappUri)) {
      await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
    }
  }

  void _launchURL(String url) async {
    final Uri uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _showTermsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Términos y Condiciones'),
        content: SingleChildScrollView(
          child: Text(
            'TÉRMINOS Y CONDICIONES DE USO DE BIUX\n\n'
            '1. ACEPTACIÓN DE TÉRMINOS\n'
            'Al usar BiUX, aceptas estos términos y condiciones.\n\n'
            '2. USO DE LA APLICACIÓN\n'
            '- Debes ser mayor de 18 años o tener autorización de tus padres\n'
            '- Eres responsable de la seguridad de tu cuenta\n'
            '- No puedes usar la app para actividades ilegales\n\n'
            '3. CONTENIDO\n'
            '- Eres dueño del contenido que publicas\n'
            '- Nos otorgas licencia para usar tu contenido en la plataforma\n'
            '- No publiques contenido ofensivo, violento o ilegal\n\n'
            '4. PRIVACIDAD\n'
            '- Respetamos tu privacidad según nuestra Política de Privacidad\n'
            '- No vendemos tus datos personales\n\n'
            '5. RESPONSABILIDAD\n'
            '- BiUX no se hace responsable de accidentes durante rodadas\n'
            '- Los usuarios son responsables de su seguridad\n'
            '- Usa equipo de protección adecuado\n\n'
            '6. MODIFICACIONES\n'
            'Podemos modificar estos términos en cualquier momento.\n\n'
            'Fecha de última actualización: 29 de noviembre de 2025',
            style: TextStyle(fontSize: 12),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Política de Privacidad'),
        content: SingleChildScrollView(
          child: Text(
            'POLÍTICA DE PRIVACIDAD DE BIUX\n\n'
            '1. INFORMACIÓN QUE RECOPILAMOS\n'
            '- Nombre, teléfono y foto de perfil\n'
            '- Ubicación durante rodadas (con tu permiso)\n'
            '- Fotos y videos que publicas\n'
            '- Información de tus bicicletas registradas\n\n'
            '2. CÓMO USAMOS TU INFORMACIÓN\n'
            '- Para proporcionarte los servicios de la app\n'
            '- Para conectarte con otros ciclistas\n'
            '- Para mejorar la experiencia de usuario\n'
            '- Para enviarte notificaciones relevantes\n\n'
            '3. COMPARTIR INFORMACIÓN\n'
            '- Tu perfil es visible para otros usuarios\n'
            '- Tus publicaciones son públicas o visibles para tu grupo\n'
            '- No vendemos tu información a terceros\n'
            '- Solo compartimos con servicios necesarios (Firebase, Google Maps)\n\n'
            '4. SEGURIDAD\n'
            '- Usamos encriptación para proteger tus datos\n'
            '- Servidores seguros de Firebase\n'
            '- Autenticación segura\n\n'
            '5. TUS DERECHOS\n'
            '- Puedes ver, editar o eliminar tu información\n'
            '- Puedes desactivar tu cuenta en cualquier momento\n'
            '- Puedes solicitar una copia de tus datos\n\n'
            '6. COOKIES Y TRACKING\n'
            '- Usamos Firebase Analytics para mejorar la app\n'
            '- Puedes desactivar el tracking en configuración\n\n'
            '7. MENORES DE EDAD\n'
            '- La app es para mayores de 18 años\n'
            '- Menores requieren autorización de padres\n\n'
            'Contacto: privacidad@biux.app\n\n'
            'Fecha de última actualización: 29 de noviembre de 2025',
            style: TextStyle(fontSize: 12),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cerrar'),
          ),
        ],
      ),
    );
  }
}
