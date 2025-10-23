const {onDocumentCreated} = require('firebase-functions/v2/firestore');
const {logger} = require('firebase-functions/v2');
const admin = require('firebase-admin');

async function shouldSendPushNotification(userId, notificationType) {
  try {
    // ✅ CORREGIDO: Leer preferencias del documento preferences en la subcolección
    const preferencesDoc = await admin.firestore()
      .collection('users')
      .doc(userId)
      .collection('notificationSettings')
      .doc('preferences')
      .get();

    // Si no existen preferencias, permitir todas por defecto
    if (!preferencesDoc.exists) {
      logger.info(`No preferences found for user ${userId}, allowing notification by default`);
      return true;
    }

    const preferences = preferencesDoc.data();
    logger.info(`User ${userId} preferences:`, preferences);

    // Mapear el tipo de notificación al campo en preferences
    const preferenceKey = {
      'like': 'likes',
      'comment': 'comments',
      'follow': 'follows',
      'ride_invitation': 'ride_invitations',
      'group_invitation': 'group_invitations',
      'group_join_request': 'group_updates', // Solicitudes de ingreso como actualizaciones de grupo
      'story': 'stories',
      'ride_reminder': 'ride_reminders',
      'group_update': 'group_updates',
      'system': 'system'
    }[notificationType];

    if (!preferenceKey) {
      logger.warn(`Unknown notification type: ${notificationType}`);
      return true;
    }

    // Si el campo no existe, permitir por defecto (true)
    const isEnabled = preferences[preferenceKey] !== false;
    logger.info(`Notification ${notificationType} (${preferenceKey}) for user ${userId}: ${isEnabled ? 'ENABLED' : 'DISABLED'}`);
    
    return isEnabled;
  } catch (error) {
    logger.error('Error checking notification settings:', error);
    return true; // En caso de error, permitir la notificación
  }
}

async function sendPushNotificationIfEnabled(userId, notificationType, notification) {
  try {
    const shouldSendPush = await shouldSendPushNotification(userId, notificationType);
    if (!shouldSendPush) {
      logger.info(`Push notification ${notificationType} disabled for user ${userId}`);
      return;
    }

    // ✅ CORREGIDO: Leer tokens de la SUBCOLECCIÓN fcmTokens
    const tokensSnapshot = await admin.firestore()
      .collection('users')
      .doc(userId)
      .collection('fcmTokens')
      .get();

    if (tokensSnapshot.empty) {
      logger.warn(`No FCM tokens found in subcollection for user ${userId}`);
      return;
    }

    // Extraer los tokens de los documentos
    const fcmTokens = tokensSnapshot.docs.map(doc => doc.data().token);
    const tokenIds = tokensSnapshot.docs.map(doc => doc.id);

    logger.info(`Found ${fcmTokens.length} FCM token(s) for user ${userId}`);

    const message = {
      notification: {
        title: notification.title,
        body: notification.body,
      },
      data: {
        type: notificationType,
        senderId: notification.senderId || '',
        relatedId: notification.relatedId || '',
        click_action: 'FLUTTER_NOTIFICATION_CLICK',
      },
      tokens: fcmTokens,
    };

    const response = await admin.messaging().sendEachForMulticast(message);
    logger.info(`Push notification sent to user ${userId}: ${response.successCount} success, ${response.failureCount} failures`);

    // Eliminar tokens inválidos de la subcolección
    if (response.failureCount > 0) {
      const deletePromises = [];
      response.responses.forEach((resp, idx) => {
        if (!resp.success) {
          const tokenId = tokenIds[idx];
          logger.warn(`Removing invalid token: ${tokenId}`);
          deletePromises.push(
            admin.firestore()
              .collection('users')
              .doc(userId)
              .collection('fcmTokens')
              .doc(tokenId)
              .delete()
          );
        }
      });

      if (deletePromises.length > 0) {
        await Promise.all(deletePromises);
        logger.info(`Removed ${deletePromises.length} invalid token(s)`);
      }
    }
  } catch (error) {
    logger.error('Error sending push notification:', error);
  }
}

exports.onNotificationCreated = onDocumentCreated('users/{userId}/notifications/{notificationId}', async (event) => {
  try {
    const notification = event.data.data();
    const userId = event.params.userId;
    if (!notification.type || !notification.title || !notification.body) {
      logger.warn('Notification missing required fields:', notification);
      return;
    }
    logger.info(`New notification created for user ${userId}, type: ${notification.type}`);
    await sendPushNotificationIfEnabled(userId, notification.type, notification);
  } catch (error) {
    logger.error('Error in onNotificationCreated:', error);
  }
});
