const {onValueCreated} = require("firebase-functions/v2/database");
const {logger} = require("firebase-functions");
const admin = require("firebase-admin");

// Trigger cuando se crea un comentario en un post
exports.onCommentPostCreated = onValueCreated(
  "/comments/posts/{postId}/{commentId}",
  async (event) => {
    const commentData = event.data.val();
    const postId = event.params.postId;
    const commentId = event.params.commentId;

    logger.info("📝 Nuevo comentario en post:", {postId, commentId});

    try {
      // 1. Obtener datos del post desde Firestore
      const postDoc = await admin.firestore()
        .collection("experiences")
        .doc(postId)
        .get();

      if (!postDoc.exists) {
        logger.warn("⚠️ Experience/Post no encontrado:", postId);
        return null;
      }

      const postData = postDoc.data();
      
      // El campo correcto es user.id (no user.uid)
      const postAuthorId = postData.user?.id || postData.userId;
      
      if (!postAuthorId) {
        logger.warn("⚠️ No se pudo obtener el ID del autor del post");
        return null;
      }

      logger.info("👤 Autor del post:", postAuthorId);

      // No notificar si el comentario es del mismo autor del post
      if (commentData.userId === postAuthorId) {
        logger.info("⏭️ El autor comentó su propio post");
        return null;
      }

      // 2. Crear notificación para el autor del post
      const notificationRef = admin.database()
        .ref(`notifications/${postAuthorId}`)
        .push();

      const notification = {
        id: notificationRef.key,
        type: "comment_post",
        fromUserId: commentData.userId,
        fromUserName: commentData.userName,
        fromUserPhoto: commentData.userPhoto || null,
        targetType: "post",
        targetId: postId,
        targetPreview: postData.caption?.substring(0, 100) || "",
        message: `${commentData.userName} comentó tu publicación`,
        isRead: false,
        createdAt: Date.now(),
        metadata: {
          commentId: commentId,
          commentText: commentData.text?.substring(0, 100) || "",
        },
      };

      await notificationRef.set(notification);

      // 3. Incrementar contador de no leídas
      const unreadRef = admin.database()
        .ref(`notifications/unread/${postAuthorId}`);
      
      const unreadSnapshot = await unreadRef.get();
      const currentCount = unreadSnapshot.val()?.count || 0;

      await unreadRef.set({
        count: currentCount + 1,
        lastUpdated: Date.now(),
      });

      logger.info("✅ Notificación creada para:", postAuthorId);
      return null;
    } catch (error) {
      logger.error("❌ Error creando notificación:", error);
      return null;
    }
  },
);

// Trigger cuando se crea un comentario en una rodada
exports.onCommentRideCreated = onValueCreated(
  "/comments/rides/{rideId}/{commentId}",
  async (event) => {
    const commentData = event.data.val();
    const rideId = event.params.rideId;
    const commentId = event.params.commentId;

    logger.info("📝 Nuevo comentario en rodada:", {rideId, commentId});

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
      
      // El campo puede ser userId directamente o creatorId
      const rideAuthorId = rideData.userId || rideData.creatorId || rideData.creator?.uid;
      
      if (!rideAuthorId) {
        logger.warn("⚠️ No se pudo obtener el ID del autor de la rodada");
        return null;
      }

      logger.info("👤 Autor de la rodada:", rideAuthorId);

      // No notificar si el comentario es del mismo autor de la rodada
      if (commentData.userId === rideAuthorId) {
        logger.info("⏭️ El autor comentó su propia rodada");
        return null;
      }

      // 2. Crear notificación para el autor de la rodada
      const notificationRef = admin.database()
        .ref(`notifications/${rideAuthorId}`)
        .push();

      const notification = {
        id: notificationRef.key,
        type: "comment_ride",
        fromUserId: commentData.userId,
        fromUserName: commentData.userName,
        fromUserPhoto: commentData.userPhoto || null,
        targetType: "ride",
        targetId: rideId,
        targetPreview: rideData.name?.substring(0, 100) || "",
        message: `${commentData.userName} comentó tu rodada`,
        isRead: false,
        createdAt: Date.now(),
        metadata: {
          commentId: commentId,
          commentText: commentData.text?.substring(0, 100) || "",
        },
      };

      await notificationRef.set(notification);

      // 3. Incrementar contador de no leídas
      const unreadRef = admin.database()
        .ref(`notifications/unread/${rideAuthorId}`);
      
      const unreadSnapshot = await unreadRef.get();
      const currentCount = unreadSnapshot.val()?.count || 0;

      await unreadRef.set({
        count: currentCount + 1,
        lastUpdated: Date.now(),
      });

      logger.info("✅ Notificación creada para:", rideAuthorId);
      return null;
    } catch (error) {
      logger.error("❌ Error creando notificación:", error);
      return null;
    }
  },
);
