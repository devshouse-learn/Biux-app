const functions = require("firebase-functions");
const admin = require("firebase-admin");

// Initialize Firebase Admin
admin.initializeApp();

// Import notification functions
const {onNotificationCreated} = require("./notifications");
const {onNotificationCreated: onPushNotificationCreated} = require("./push-notifications");
const {
  onCommentPostCreated,
  onCommentRideCreated,
} = require("./comment-notifications");
const {
  onLikePostCreated,
  onLikeCommentCreated,
} = require("./like-notifications");
const {
  onLikeRideCreated,
  onRideJoinCreated,
} = require("./ride-notifications");

// Export notification triggers
exports.onNotificationCreated = onNotificationCreated;
exports.onPushNotificationCreated = onPushNotificationCreated;

// Export comment notification triggers
exports.onCommentPostCreated = onCommentPostCreated;
exports.onCommentRideCreated = onCommentRideCreated;

// Export like notification triggers
exports.onLikePostCreated = onLikePostCreated;
exports.onLikeCommentCreated = onLikeCommentCreated;

// Export ride notification triggers
exports.onLikeRideCreated = onLikeRideCreated;
exports.onRideJoinCreated = onRideJoinCreated;

// Cloud Function HTTPS que genera un custom token
exports.createCustomToken = functions.https.onRequest(async (req, res) => {
  try {
    const { phoneNumber } = req.body; // lo envía n8n

    if (!phoneNumber) {
      return res.status(400).json({ error: "Missing phoneNumber" });
    }

    // Generar un UID basado en el teléfono
    const uid = `phone_${phoneNumber}`;

    // Crear el custom token con claims para Realtime Database
    // CRÍTICO: additionalClaims permite que Realtime Database reconozca la autenticación
    const customToken = await admin.auth().createCustomToken(uid, {
      // Claims adicionales para Realtime Database
      phoneNumber: phoneNumber,
      provider: 'custom',
    });

    return res.json({ token: customToken });
  } catch (err) {
    console.error("Error creating token:", err);
    return res.status(500).json({ error: "Internal error" });
  }
});
