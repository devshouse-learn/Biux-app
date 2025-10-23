const {onValueCreated} = require("firebase-functions/v2/database");
const {logger} = require("firebase-functions");
const admin = require("firebase-admin");

// Trigger cuando se da like a una rodada
exports.onLikeRideCreated = onValueCreated(
  "/likes/rides/{rideId}/{userId}",
  async (event) => {
    const likeData = event.data.val();
    const rideId = event.params.rideId;
    const userId = event.params.userId;

    logger.info("❤️ Nuevo like en rodada:", {rideId, userId});

    try {
      // 1. Obtener datos de la rodada desde Firestore
      const rideDoc = await admin.firestore()
        .collection("roads")
        .doc(rideId)
        .get();

      if (!rideDoc.exists) {
        logger.warn("⚠️ Rodada no encontrada:", rideId);
        return null;
      }

      const rideData = rideDoc.data();
      const rideOwnerId = rideData.owner?.id || rideData.ownerId;

      if (!rideOwnerId) {
        logger.warn("⚠️ No se pudo obtener el ID del organizador de la rodada");
        return null;
      }

      // No notificar si el like es del mismo organizador
      if (userId === rideOwnerId) {
        logger.info("⏭️ El organizador dio like a su propia rodada");
        return null;
      }

      // 2. Obtener datos del usuario que dio like
      const userDoc = await admin.firestore()
        .collection("users")
        .doc(userId)
        .get();

      const userData = userDoc.exists ? userDoc.data() : {};
      const userName = userData.name || userData.username || userData.fullName || "Usuario";
      const userPhoto = userData.photoUrl || userData.photo || null;

      // 3. Crear notificación para el organizador
      const notificationRef = admin.database()
        .ref(`notifications/${rideOwnerId}`)
        .push();

      const notification = {
        id: notificationRef.key,
        type: "like_ride",
        fromUserId: userId,
        fromUserName: userName,
        fromUserPhoto: userPhoto,
        targetType: "ride",
        targetId: rideId,
        targetPreview: rideData.title || rideData.name || "",
        message: `A ${userName} le gustó tu rodada`,
        isRead: false,
        createdAt: Date.now(),
      };

      await notificationRef.set(notification);

      // 4. Incrementar contador de no leídas
      const unreadRef = admin.database()
        .ref(`notifications/unread/${rideOwnerId}`);
      
      const unreadSnapshot = await unreadRef.get();
      const currentCount = unreadSnapshot.val()?.count || 0;

      await unreadRef.set({
        count: currentCount + 1,
        lastUpdated: Date.now(),
      });

      logger.info("✅ Notificación de like en rodada creada para:", rideOwnerId);
      return null;
    } catch (error) {
      logger.error("❌ Error creando notificación de like en rodada:", error);
      return null;
    }
  },
);

// Trigger cuando un usuario se une a una rodada
exports.onRideJoinCreated = onValueCreated(
  "/attendees/rides/{rideId}/{userId}",
  async (event) => {
    const attendeeData = event.data.val();
    const rideId = event.params.rideId;
    const userId = event.params.userId;

    logger.info("🚴 Nuevo asistente en rodada:", {rideId, userId});

    try {
      // 1. Obtener datos de la rodada desde Firestore
      const rideDoc = await admin.firestore()
        .collection("roads")
        .doc(rideId)
        .get();

      if (!rideDoc.exists) {
        logger.warn("⚠️ Rodada no encontrada:", rideId);
        return null;
      }

      const rideData = rideDoc.data();
      const rideOwnerId = rideData.owner?.id || rideData.ownerId;

      if (!rideOwnerId) {
        logger.warn("⚠️ No se pudo obtener el ID del organizador de la rodada");
        return null;
      }

      // No notificar si el organizador se une a su propia rodada
      if (userId === rideOwnerId) {
        logger.info("⏭️ El organizador se unió a su propia rodada");
        return null;
      }

      // 2. Obtener datos del usuario que se unió
      const userDoc = await admin.firestore()
        .collection("users")
        .doc(userId)
        .get();

      const userData = userDoc.exists ? userDoc.data() : {};
      const userName = userData.name || userData.username || userData.fullName || "Usuario";
      const userPhoto = userData.photoUrl || userData.photo || null;

      // 3. Crear notificación para el organizador
      const notificationRef = admin.database()
        .ref(`notifications/${rideOwnerId}`)
        .push();

      const notification = {
        id: notificationRef.key,
        type: "ride_join",
        fromUserId: userId,
        fromUserName: userName,
        fromUserPhoto: userPhoto,
        targetType: "ride",
        targetId: rideId,
        targetPreview: rideData.title || rideData.name || "",
        message: `${userName} se unió a tu rodada`,
        isRead: false,
        createdAt: Date.now(),
      };

      await notificationRef.set(notification);

      // 4. Incrementar contador de no leídas
      const unreadRef = admin.database()
        .ref(`notifications/unread/${rideOwnerId}`);
      
      const unreadSnapshot = await unreadRef.get();
      const currentCount = unreadSnapshot.val()?.count || 0;

      await unreadRef.set({
        count: currentCount + 1,
        lastUpdated: Date.now(),
      });

      logger.info("✅ Notificación de unión a rodada creada para:", rideOwnerId);
      return null;
    } catch (error) {
      logger.error("❌ Error creando notificación de unión a rodada:", error);
      return null;
    }
  },
);
