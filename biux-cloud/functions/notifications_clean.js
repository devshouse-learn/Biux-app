const {onDocumentCreated} = require("firebase-functions/v2/firestore");
const {onSchedule} = require("firebase-functions/v2/scheduler");
const {logger} = require("firebase-functions");
const admin = require("firebase-admin");

/**
 * Verifica si el usuario tiene habilitado un tipo de notificación
 * @param {string} userId - ID del usuario
 * @param {string} notificationType - Tipo de notificación
 * @returns {Promise<boolean>}
 */
async function isNotificationEnabled(userId, notificationType) {
  try {
    const userDoc = await admin
      .firestore()
      .collection("users")
      .doc(userId)
      .get();

    if (!userDoc.exists) {
      return false;
    }

    const userData = userDoc.data();
    const settings = userData.notificationSettings || {};

    // Si las notificaciones push están desactivadas, no enviar nada
    if (settings.enablePushNotifications === false) {
      return false;
    }

    // Verificar tipo específico
    switch (notificationType) {
      case "like":
        return settings.enableLikes !== false;
      case "comment":
        return settings.enableComments !== false;
      case "follow":
        return settings.enableFollows !== false;
      case "ride_invitation":
        return settings.enableRideInvitations !== false;
      case "group_invitation":
        return settings.enableGroupInvitations !== false;
      case "story":
        return settings.enableStories !== false;
      case "ride_reminder":
        return settings.enableRideReminders !== false;
      case "group_update":
        return settings.enableGroupUpdates !== false;
      case "system":
        return settings.enableSystemNotifications !== false;
      default:
        return true; // Por defecto, enviar si no se especifica
    }
  } catch (error) {
    console.error("Error checking notification settings:", error);
    return true; // En caso de error, enviar la notificación
  }
}

/**
 * Envía una notificación push a un usuario
 * @param {string} userId - ID del usuario destinatario
 * @param {Object} notification - Datos de la notificación
 */
async function sendNotificationToUser(userId, notification) {
  try {
    // Verificar si el usuario tiene este tipo de notificación habilitado
    const isEnabled = await isNotificationEnabled(userId, notification.type);
    if (!isEnabled) {
      console.log(
        `Notification ${notification.type} disabled for user ${userId}`
      );
      return;
    }

    // Obtener tokens FCM del usuario
    const userDoc = await admin
      .firestore()
      .collection("users")
      .doc(userId)
      .get();

    if (!userDoc.exists) {
      console.log(`User ${userId} not found`);
      return;
    }

    const userData = userDoc.data();
    const fcmTokens = userData.fcmTokens || [];

    if (fcmTokens.length === 0) {
      console.log(`No FCM tokens for user ${userId}`);
      return;
    }

    // Guardar notificación en Firestore
    await admin
      .firestore()
      .collection("users")
      .doc(userId)
      .collection("notifications")
      .add({
        title: notification.title,
        body: notification.body,
        type: notification.type,
        senderId: notification.senderId || null,
        relatedId: notification.relatedId || null,
        timestamp: admin.firestore.FieldValue.serverTimestamp(),
        read: false,
      });

    // Preparar mensaje FCM
    const message = {
      notification: {
        title: notification.title,
        body: notification.body,
      },
      data: {
        type: notification.type,
        senderId: notification.senderId || "",
        relatedId: notification.relatedId || "",
        click_action: "FLUTTER_NOTIFICATION_CLICK",
      },
      tokens: fcmTokens,
    };

    // Enviar notificación
    const response = await admin.messaging().sendEachForMulticast(message);

    console.log(
      `Notification sent to user ${userId}: ${response.successCount} success, ${response.failureCount} failures`
    );

    // Limpiar tokens inválidos
    if (response.failureCount > 0) {
      const tokensToRemove = [];
      response.responses.forEach((resp, idx) => {
        if (!resp.success) {
          tokensToRemove.push(fcmTokens[idx]);
        }
      });

      if (tokensToRemove.length > 0) {
        await admin
          .firestore()
          .collection("users")
          .doc(userId)
          .update({
            fcmTokens: admin.firestore.FieldValue.arrayRemove(
              ...tokensToRemove
            ),
          });
        console.log(`Removed ${tokensToRemove.length} invalid tokens`);
      }
    }
  } catch (error) {
    console.error("Error sending notification:", error);
  }
}

// ==================== TRIGGERS ====================

/**
 * Trigger: Cuando alguien le da like a una experiencia
 */
exports.onLikeCreated = onDocumentCreated(
  "experiences/{experienceId}/likes/{likeId}",
  async (event) => {
    try {
      const like = event.data.data();
      const experienceId = event.params.experienceId;

      // Obtener la experiencia
      const experienceDoc = await admin
        .firestore()
        .collection("experiences")
        .doc(experienceId)
        .get();

      if (!experienceDoc.exists) {
        return;
      }

      const experience = experienceDoc.data();
      const ownerId = experience.userId;

      // No notificar si el usuario se da like a sí mismo
      if (like.userId === ownerId) {
        return;
      }

      // Obtener nombre del usuario que dio like
      const likerDoc = await admin
        .firestore()
        .collection("users")
        .doc(like.userId)
        .get();

      const likerName = likerDoc.exists
        ? likerDoc.data().username || "Alguien"
        : "Alguien";

      // Enviar notificación
      await sendNotificationToUser(ownerId, {
        title: "Nuevo like",
        body: `A ${likerName} le gustó tu publicación`,
        type: "like",
        senderId: like.userId,
        relatedId: experienceId,
      });
    } catch (error) {
      console.error("Error in onLikeCreated:", error);
    }
  });

/**
 * Trigger: Cuando alguien comenta en una experiencia
 */
exports.onCommentCreated = functions.firestore
  .document("experiences/{experienceId}/comments/{commentId}")
  .onCreate(async (snap, context) => {
    try {
      const comment = snap.data();
      const experienceId = context.params.experienceId;

      // Obtener la experiencia
      const experienceDoc = await admin
        .firestore()
        .collection("experiences")
        .doc(experienceId)
        .get();

      if (!experienceDoc.exists) {
        return;
      }

      const experience = experienceDoc.data();
      const ownerId = experience.userId;

      // No notificar si el usuario comenta en su propia publicación
      if (comment.userId === ownerId) {
        return;
      }

      // Obtener nombre del usuario que comentó
      const commenterDoc = await admin
        .firestore()
        .collection("users")
        .doc(comment.userId)
        .get();

      const commenterName = commenterDoc.exists
        ? commenterDoc.data().username || "Alguien"
        : "Alguien";

      // Truncar comentario si es muy largo
      const commentPreview =
        comment.text.length > 50
          ? comment.text.substring(0, 50) + "..."
          : comment.text;

      // Enviar notificación
      await sendNotificationToUser(ownerId, {
        title: "Nuevo comentario",
        body: `${commenterName}: ${commentPreview}`,
        type: "comment",
        senderId: comment.userId,
        relatedId: experienceId,
      });
    } catch (error) {
      console.error("Error in onCommentCreated:", error);
    }
  });

/**
 * Trigger: Cuando alguien comienza a seguir a un usuario
 */
exports.onFollowCreated = functions.firestore
  .document("users/{userId}/followers/{followerId}")
  .onCreate(async (snap, context) => {
    try {
      const follower = snap.data();
      const userId = context.params.userId;
      const followerId = context.params.followerId;

      // Obtener nombre del seguidor
      const followerDoc = await admin
        .firestore()
        .collection("users")
        .doc(followerId)
        .get();

      const followerName = followerDoc.exists
        ? followerDoc.data().username || "Alguien"
        : "Alguien";

      // Enviar notificación
      await sendNotificationToUser(userId, {
        title: "Nuevo seguidor",
        body: `${followerName} comenzó a seguirte`,
        type: "follow",
        senderId: followerId,
      });
    } catch (error) {
      console.error("Error in onFollowCreated:", error);
    }
  });

/**
 * Trigger: Cuando alguien invita a una rodada
 */
exports.onRideInvitationCreated = functions.firestore
  .document("rides/{rideId}/invitations/{invitationId}")
  .onCreate(async (snap, context) => {
    try {
      const invitation = snap.data();
      const rideId = context.params.rideId;

      // Obtener información de la rodada
      const rideDoc = await admin
        .firestore()
        .collection("rides")
        .doc(rideId)
        .get();

      if (!rideDoc.exists) {
        return;
      }

      const ride = rideDoc.data();

      // Obtener nombre del que invita
      const inviterDoc = await admin
        .firestore()
        .collection("users")
        .doc(invitation.inviterId)
        .get();

      const inviterName = inviterDoc.exists
        ? inviterDoc.data().username || "Alguien"
        : "Alguien";

      // Enviar notificación al invitado
      await sendNotificationToUser(invitation.invitedUserId, {
        title: "Invitación a rodada",
        body: `${inviterName} te invitó a "${ride.title || "una rodada"}"`,
        type: "ride_invitation",
        senderId: invitation.inviterId,
        relatedId: rideId,
      });
    } catch (error) {
      console.error("Error in onRideInvitationCreated:", error);
    }
  });

/**
 * Trigger: Cuando alguien invita a un grupo
 */
exports.onGroupInvitationCreated = functions.firestore
  .document("groups/{groupId}/invitations/{invitationId}")
  .onCreate(async (snap, context) => {
    try {
      const invitation = snap.data();
      const groupId = context.params.groupId;

      // Obtener información del grupo
      const groupDoc = await admin
        .firestore()
        .collection("groups")
        .doc(groupId)
        .get();

      if (!groupDoc.exists) {
        return;
      }

      const group = groupDoc.data();

      // Obtener nombre del que invita
      const inviterDoc = await admin
        .firestore()
        .collection("users")
        .doc(invitation.inviterId)
        .get();

      const inviterName = inviterDoc.exists
        ? inviterDoc.data().username || "Alguien"
        : "Alguien";

      // Enviar notificación al invitado
      await sendNotificationToUser(invitation.invitedUserId, {
        title: "Invitación a grupo",
        body: `${inviterName} te invitó a unirte a "${
          group.name || "un grupo"
        }"`,
        type: "group_invitation",
        senderId: invitation.inviterId,
        relatedId: groupId,
      });
    } catch (error) {
      console.error("Error in onGroupInvitationCreated:", error);
    }
  });

/**
 * Trigger: Cuando alguien publica una nueva historia
 */
exports.onStoryCreated = functions.firestore
  .document("stories/{storyId}")
  .onCreate(async (snap, context) => {
    try {
      const story = snap.data();

      // Obtener seguidores del usuario
      const followersSnapshot = await admin
        .firestore()
        .collection("users")
        .doc(story.userId)
        .collection("followers")
        .get();

      if (followersSnapshot.empty) {
        return;
      }

      // Obtener nombre del usuario que publicó la historia
      const userDoc = await admin
        .firestore()
        .collection("users")
        .doc(story.userId)
        .get();

      const userName = userDoc.exists
        ? userDoc.data().username || "Alguien"
        : "Alguien";

      // Enviar notificación a cada seguidor
      const notifications = [];
      followersSnapshot.forEach((doc) => {
        notifications.push(
          sendNotificationToUser(doc.id, {
            title: "Nueva historia",
            body: `${userName} publicó una nueva historia`,
            type: "story",
            senderId: story.userId,
          })
        );
      });

      await Promise.all(notifications);
    } catch (error) {
      console.error("Error in onStoryCreated:", error);
    }
  });

/**
 * Trigger: Recordatorio de rodada (24 horas antes)
 * Se ejecuta diariamente y verifica rodadas próximas
 */
exports.sendRideReminders = functions.pubsub
  .schedule("every 24 hours")
  .onRun(async (context) => {
    try {
      const now = admin.firestore.Timestamp.now();
      const tomorrow = new Date(now.toDate());
      tomorrow.setDate(tomorrow.getDate() + 1);
      const tomorrowStart = admin.firestore.Timestamp.fromDate(
        new Date(tomorrow.setHours(0, 0, 0, 0))
      );
      const tomorrowEnd = admin.firestore.Timestamp.fromDate(
        new Date(tomorrow.setHours(23, 59, 59, 999))
      );

      // Buscar rodadas que sean mañana
      const ridesSnapshot = await admin
        .firestore()
        .collection("rides")
        .where("date", ">=", tomorrowStart)
        .where("date", "<=", tomorrowEnd)
        .get();

      if (ridesSnapshot.empty) {
        return;
      }

      // Para cada rodada, notificar a los participantes
      const notifications = [];
      for (const rideDoc of ridesSnapshot.docs) {
        const ride = rideDoc.data();
        const participants = ride.participants || [];

        participants.forEach((userId) => {
          notifications.push(
            sendNotificationToUser(userId, {
              title: "Recordatorio de rodada",
              body: `La rodada "${
                ride.title || "sin título"
              }" es mañana a las ${ride.time || "hora no especificada"}`,
              type: "ride_reminder",
              relatedId: rideDoc.id,
            })
          );
        });
      }

      await Promise.all(notifications);
      console.log(`Sent ${notifications.length} ride reminders`);
    } catch (error) {
      console.error("Error in sendRideReminders:", error);
    }
  });

/**
 * Trigger: Cuando hay una actualización importante en un grupo
 * (nuevo evento, nueva publicación, etc.)
 */
exports.onGroupUpdate = functions.firestore
  .document("groups/{groupId}/posts/{postId}")
  .onCreate(async (snap, context) => {
    try {
      const post = snap.data();
      const groupId = context.params.groupId;

      // Obtener información del grupo
      const groupDoc = await admin
        .firestore()
        .collection("groups")
        .doc(groupId)
        .get();

      if (!groupDoc.exists) {
        return;
      }

      const group = groupDoc.data();
      const members = group.members || [];

      // Obtener nombre del usuario que publicó
      const posterDoc = await admin
        .firestore()
        .collection("users")
        .doc(post.userId)
        .get();

      const posterName = posterDoc.exists
        ? posterDoc.data().username || "Alguien"
        : "Alguien";

      // Notificar a todos los miembros excepto al que publicó
      const notifications = [];
      members.forEach((memberId) => {
        if (memberId !== post.userId) {
          notifications.push(
            sendNotificationToUser(memberId, {
              title: `Actualización en ${group.name}`,
              body: `${posterName} publicó en el grupo`,
              type: "group_update",
              senderId: post.userId,
              relatedId: groupId,
            })
          );
        }
      });

      await Promise.all(notifications);
    } catch (error) {
      console.error("Error in onGroupUpdate:", error);
    }
  });
