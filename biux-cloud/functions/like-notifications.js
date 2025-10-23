const {onValueCreated} = require("firebase-functions/v2/database");
const {logger} = require("firebase-functions");
const admin = require("firebase-admin");

// Trigger cuando se da like a un post
exports.onLikePostCreated = onValueCreated(
  "/likes/posts/{postId}/{userId}",
  async (event) => {
    const likeData = event.data.val();
    const postId = event.params.postId;
    const userId = event.params.userId;

    logger.info("❤️ Nuevo like en post:", {postId, userId});

    try {
      // 1. Obtener datos del post desde Firestore
      const postDoc = await admin.firestore()
        .collection("experiences")
        .doc(postId)
        .get();

      if (!postDoc.exists) {
        logger.warn("⚠️ Post no encontrado:", postId);
        return null;
      }

      const postData = postDoc.data();
      const postAuthorId = postData.user?.id || postData.userId;

      if (!postAuthorId) {
        logger.warn("⚠️ No se pudo obtener el ID del autor del post");
        return null;
      }

      // No notificar si el like es del mismo autor del post
      if (userId === postAuthorId) {
        logger.info("⏭️ El autor dio like a su propio post");
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

      // 3. Crear notificación para el autor del post
      const notificationRef = admin.database()
        .ref(`notifications/${postAuthorId}`)
        .push();

      const notification = {
        id: notificationRef.key,
        type: "like_post",
        fromUserId: userId,
        fromUserName: userName,
        fromUserPhoto: userPhoto,
        targetType: "post",
        targetId: postId,
        targetPreview: postData.description?.substring(0, 100) || "",
        message: `A ${userName} le gustó tu publicación`,
        isRead: false,
        createdAt: Date.now(),
      };

      await notificationRef.set(notification);

      // 4. Incrementar contador de no leídas
      const unreadRef = admin.database()
        .ref(`notifications/unread/${postAuthorId}`);
      
      const unreadSnapshot = await unreadRef.get();
      const currentCount = unreadSnapshot.val()?.count || 0;

      await unreadRef.set({
        count: currentCount + 1,
        lastUpdated: Date.now(),
      });

      logger.info("✅ Notificación de like creada para:", postAuthorId);
      return null;
    } catch (error) {
      logger.error("❌ Error creando notificación de like:", error);
      return null;
    }
  },
);

// Trigger cuando se da like a un comentario
exports.onLikeCommentCreated = onValueCreated(
  "/likes/comments/{commentPath}/{userId}",
  async (event) => {
    const likeData = event.data.val();
    const commentPath = event.params.commentPath;
    const userId = event.params.userId;

    logger.info("❤️ Nuevo like en comentario:", {commentPath, userId});

    try {
      // El commentPath tiene formato: type_targetId_commentId
      const parts = commentPath.split("_");
      if (parts.length < 3) {
        logger.warn("⚠️ Formato de commentPath inválido:", commentPath);
        return null;
      }

      const type = parts[0]; // 'post' o 'ride'
      const targetId = parts[1];
      const commentId = parts.slice(2).join("_");

      // 1. Obtener datos del comentario desde Realtime Database
      const commentRef = admin.database()
        .ref(`comments/${type}s/${targetId}/${commentId}`);
      
      const commentSnapshot = await commentRef.get();
      if (!commentSnapshot.exists()) {
        logger.warn("⚠️ Comentario no encontrado:", commentPath);
        return null;
      }

      const commentData = commentSnapshot.val();
      const commentAuthorId = commentData.userId;

      if (!commentAuthorId) {
        logger.warn("⚠️ No se pudo obtener el ID del autor del comentario");
        return null;
      }

      // No notificar si el like es del mismo autor del comentario
      if (userId === commentAuthorId) {
        logger.info("⏭️ El autor dio like a su propio comentario");
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

      // 3. Crear notificación para el autor del comentario
      const notificationRef = admin.database()
        .ref(`notifications/${commentAuthorId}`)
        .push();

      const notification = {
        id: notificationRef.key,
        type: "like_comment",
        fromUserId: userId,
        fromUserName: userName,
        fromUserPhoto: userPhoto,
        targetType: type,
        targetId: targetId,
        targetPreview: commentData.text?.substring(0, 100) || "",
        message: `A ${userName} le gustó tu comentario`,
        isRead: false,
        createdAt: Date.now(),
        metadata: {
          commentId: commentId,
        },
      };

      await notificationRef.set(notification);

      // 4. Incrementar contador de no leídas
      const unreadRef = admin.database()
        .ref(`notifications/unread/${commentAuthorId}`);
      
      const unreadSnapshot = await unreadRef.get();
      const currentCount = unreadSnapshot.val()?.count || 0;

      await unreadRef.set({
        count: currentCount + 1,
        lastUpdated: Date.now(),
      });

      // 5. Enviar notificación push
      await sendPushNotification(
        commentAuthorId,
        `A ${userName} le gustó tu comentario`,
        commentData.text?.substring(0, 100) || "Ver comentario",
        {
          type: "like_comment",
          targetId: contextTargetId,
          commentId: commentId,
          fromUserId: userId,
        },
      );

      logger.info("✅ Notificación de like en comentario creada para:", commentAuthorId);
      return null;
    } catch (error) {
      logger.error("❌ Error creando notificación de like:", error);
      return null;
    }
  },
);
