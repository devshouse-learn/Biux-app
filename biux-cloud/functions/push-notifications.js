const {onValueCreated} = require("firebase-functions/v2/database");
const {logger} = require("firebase-functions");
const admin = require("firebase-admin");

/**
 * Trigger centralizado que envía notificaciones push cuando se crea
 * cualquier notificación en /notifications/{userId}/{notificationId}
 */
exports.onNotificationCreated = onValueCreated(
  "/notifications/{userId}/{notificationId}",
  async (event) => {
    const notification = event.data.val();
    const userId = event.params.userId;
    const notificationId = event.params.notificationId;

    logger.info("🔔 Nueva notificación creada:", {userId, notificationId, type: notification.type});

    try {
      // Obtener tokens FCM del usuario desde Firestore
      const userDoc = await admin.firestore()
        .collection("users")
        .doc(userId)
        .get();

      if (!userDoc.exists) {
        logger.warn("⚠️ Usuario no encontrado:", userId);
        return null;
      }

      const userData = userDoc.data();
      const fcmTokens = userData.fcmTokens || [];

      if (fcmTokens.length === 0) {
        logger.info("⏭️ Usuario sin tokens FCM:", userId);
        return null;
      }

      logger.info(`📱 Enviando push a ${fcmTokens.length} dispositivo(s)`);

      // Preparar el mensaje push
      const pushMessage = {
        notification: {
          title: getTitleFromNotification(notification),
          body: notification.message || "",
        },
        data: {
          type: notification.type || "",
          notificationId: notificationId,
          targetType: notification.targetType || "",
          targetId: notification.targetId || "",
          fromUserId: notification.fromUserId || "",
          click_action: "FLUTTER_NOTIFICATION_CLICK",
        },
        android: {
          priority: "high",
          notification: {
            sound: "default",
            channelId: "biux_notifications",
          },
        },
        apns: {
          headers: {
            "apns-priority": "10", // Máxima prioridad para iOS
          },
          payload: {
            aps: {
              alert: {
                title: getTitleFromNotification(notification),
                body: notification.message || "",
              },
              sound: "default",
              badge: 1,
              "content-available": 1, // Para actualizar en background
              "mutable-content": 1, // Para modificar la notificación
            },
          },
        },
      };

      // Enviar a todos los tokens del usuario
      const sendPromises = fcmTokens.map(async (token) => {
        try {
          await admin.messaging().send({
            ...pushMessage,
            token: token,
          });
          logger.info("✅ Push enviado al token:", token.substring(0, 20) + "...");
        } catch (error) {
          // Si el token es inválido, eliminarlo
          if (error.code === "messaging/invalid-registration-token" ||
              error.code === "messaging/registration-token-not-registered") {
            logger.warn("🗑️ Token inválido, eliminando:", token.substring(0, 20) + "...");
            await admin.firestore()
              .collection("users")
              .doc(userId)
              .update({
                fcmTokens: admin.firestore.FieldValue.arrayRemove(token),
              });
          } else {
            logger.error("❌ Error enviando push:", error.message);
          }
        }
      });

      await Promise.all(sendPromises);
      logger.info("✅ Proceso de envío de push completado para:", userId);
      
      return null;
    } catch (error) {
      logger.error("❌ Error en onNotificationCreated:", error);
      return null;
    }
  },
);

/**
 * Extrae un título apropiado de la notificación según su tipo
 */
function getTitleFromNotification(notification) {
  const typeMap = {
    like_post: "Nuevo me gusta",
    like_comment: "Nuevo me gusta",
    like_ride: "Nuevo me gusta",
    comment_post: "Nuevo comentario",
    comment_ride: "Nuevo comentario",
    follow: "Nuevo seguidor",
    ride_invitation: "Invitación a rodada",
    group_invitation: "Invitación a grupo",
    ride_update: "Actualización de rodada",
    group_update: "Actualización de grupo",
  };

  return typeMap[notification.type] || "Biux";
}
