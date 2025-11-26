const functions = require("firebase-functions");
const admin = require("firebase-admin");

/**
 * Envía código OTP por WhatsApp usando Twilio
 *
 * Flujo:
 * 1. Cliente envía número telefónico
 * 2. Backend genera código OTP
 * 3. Backend envía por WhatsApp (Twilio)
 * 4. Backend guarda código en Firestore (temporal, expira en 10 min)
 * 5. Cliente recibe confirmación
 *
 * REQUISITOS:
 * - Configurar variables de entorno con credenciales Twilio
 * - npm install twilio
 */

const logger = functions.logger;

/**
 * HTTP Cloud Function para enviar OTP por WhatsApp
 * POST /sendWhatsAppOTP
 * Body: { phone: "3123456789" }
 *
 * Response: { success: true, message: "..." }
 */
exports.sendWhatsAppOTP = functions.https.onRequest(async (req, res) => {
  // Validar método HTTP
  if (req.method !== "POST") {
    return res.status(405).json({ error: "Method not allowed" });
  }

  try {
    const { phone } = req.body;

    // ✅ 1. Validar entrada
    if (!phone) {
      logger.warn("❌ sendWhatsAppOTP: Número no proporcionado");
      return res.status(400).json({
        error: "Número de teléfono requerido",
        code: "INVALID_PHONE",
      });
    }

    // Limpiar número (remover caracteres especiales)
    const cleanPhone = phone.replace(/\D/g, "");

    if (cleanPhone.length < 10) {
      logger.warn(`❌ sendWhatsAppOTP: Número inválido: ${phone}`);
      return res.status(400).json({
        error: "Número de teléfono inválido",
        code: "INVALID_FORMAT",
      });
    }

    logger.info(`📱 sendWhatsAppOTP: Enviando OTP a ${cleanPhone}`);

    // ✅ 2. Verificar rate limiting (máx 3 intentos por hora)
    const rateLimitDoc = await admin
      .firestore()
      .collection("otpAttempts")
      .doc(cleanPhone)
      .get();

    if (rateLimitDoc.exists) {
      const data = rateLimitDoc.data();
      const hourAgo = Date.now() - 60 * 60 * 1000;

      if (data.lastAttempt > hourAgo) {
        if (data.attempts >= 3) {
          logger.warn(`⚠️ sendWhatsAppOTP: Rate limit excedido para ${cleanPhone}`);
          return res.status(429).json({
            error: "Demasiados intentos. Intenta en una hora.",
            code: "RATE_LIMIT",
            retryAfter: 3600,
          });
        }
      }
    }

    // ✅ 3. Generar código OTP (6 dígitos)
    const code = Math.floor(100000 + Math.random() * 900000).toString();
    logger.info(`🔐 sendWhatsAppOTP: Código generado para ${cleanPhone}`);

    // ✅ 4. Guardar código en Firestore (temporal)
    const expirationTime = admin.firestore.Timestamp.fromDate(
      new Date(Date.now() + 10 * 60 * 1000) // Expira en 10 minutos
    );

    await admin.firestore().collection("otpCodes").doc(cleanPhone).set(
      {
        code: code,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        expiresAt: expirationTime,
        attempts: 0,
        verified: false,
      },
      { merge: true }
    );

    // ✅ 5. Actualizar contador de intentos
    const hourAgo = Date.now() - 60 * 60 * 1000;
    await admin.firestore().collection("otpAttempts").doc(cleanPhone).set(
      {
        attempts: admin.firestore.FieldValue.increment(1),
        lastAttempt: Date.now(),
        firstAttempt: (rateLimitDoc.exists ? rateLimitDoc.data().firstAttempt : Date.now()),
      },
      { merge: true }
    );

    // ✅ 6. Enviar por WhatsApp (TODO: Integrar Twilio)
    // Por ahora, simulamos el envío
    logger.info(`✉️ sendWhatsAppOTP: Código ${code} para ${cleanPhone} guardado en Firestore`);

    // IMPORTANTE: Aquí va la integración con Twilio
    // await sendViaWhatsApp(cleanPhone, code);

    // 🚀 Respuesta exitosa
    return res.json({
      success: true,
      message: `Código enviado a WhatsApp al +${cleanPhone}`,
      phone: `+${cleanPhone}`, // Retornar número formateado (util para confirmar)
      expiresIn: 600, // 10 minutos en segundos
    });
  } catch (error) {
    logger.error(`❌ sendWhatsAppOTP Error: ${error.message}`, error);
    return res.status(500).json({
      error: "Error al enviar código OTP",
      code: "SEND_FAILED",
      message: error.message,
    });
  }
});

/**
 * HTTP Cloud Function para validar OTP
 * POST /validateOTP
 * Body: { phone: "3123456789", code: "123456" }
 *
 * Response: { valid: true, token: "...", userId: "..." }
 */
exports.validateOTP = functions.https.onRequest(async (req, res) => {
  // Validar método HTTP
  if (req.method !== "POST") {
    return res.status(405).json({ error: "Method not allowed" });
  }

  try {
    const { phone, code } = req.body;

    // ✅ 1. Validar entrada
    if (!phone || !code) {
      logger.warn("❌ validateOTP: Datos incompletos");
      return res.status(400).json({
        error: "Número y código requeridos",
        code: "MISSING_DATA",
      });
    }

    const cleanPhone = phone.replace(/\D/g, "");
    logger.info(`🔍 validateOTP: Validando código para ${cleanPhone}`);

    // ✅ 2. Obtener documento OTP
    const otpDoc = await admin
      .firestore()
      .collection("otpCodes")
      .doc(cleanPhone)
      .get();

    if (!otpDoc.exists) {
      logger.warn(`❌ validateOTP: No hay OTP para ${cleanPhone}`);
      return res.status(400).json({
        error: "Código OTP no encontrado o expirado",
        code: "OTP_NOT_FOUND",
      });
    }

    const otpData = otpDoc.data();

    // ✅ 3. Verificar que no esté expirado
    const now = Date.now();
    const expiryTime = otpData.expiresAt.toDate().getTime();

    if (now > expiryTime) {
      logger.warn(`❌ validateOTP: OTP expirado para ${cleanPhone}`);
      await admin
        .firestore()
        .collection("otpCodes")
        .doc(cleanPhone)
        .delete();
      return res.status(400).json({
        error: "Código OTP expirado",
        code: "OTP_EXPIRED",
      });
    }

    // ✅ 4. Verificar intentos
    if (otpData.attempts >= 5) {
      logger.warn(`❌ validateOTP: Demasiados intentos para ${cleanPhone}`);
      await admin
        .firestore()
        .collection("otpCodes")
        .doc(cleanPhone)
        .delete();
      return res.status(429).json({
        error: "Demasiados intentos fallidos",
        code: "MAX_ATTEMPTS",
      });
    }

    // ✅ 5. Validar código
    if (code !== otpData.code) {
      logger.warn(`❌ validateOTP: Código incorrecto para ${cleanPhone}`);
      await admin
        .firestore()
        .collection("otpCodes")
        .doc(cleanPhone)
        .update({
          attempts: admin.firestore.FieldValue.increment(1),
        });
      return res.status(400).json({
        error: "Código OTP incorrecto",
        code: "INVALID_CODE",
        attemptsRemaining: 5 - (otpData.attempts + 1),
      });
    }

    // ✅ 6. Código válido - crear/actualizar usuario
    logger.info(`✅ validateOTP: Código válido para ${cleanPhone}`);

    const uid = `phone_${cleanPhone}`;

    // Crear usuario en Firebase Auth si no existe
    let user;
    try {
      user = await admin.auth().getUser(uid);
      logger.info(`👤 Usuario existente: ${uid}`);
    } catch (error) {
      if (error.code === "auth/user-not-found") {
        user = await admin.auth().createUser({
          uid: uid,
          phoneNumber: `+${cleanPhone}`,
        });
        logger.info(`✨ Usuario creado: ${uid}`);
      } else {
        throw error;
      }
    }

    // ✅ 7. Generar custom token
    const customToken = await admin.auth().createCustomToken(uid, {
      phoneNumber: cleanPhone,
      provider: "phone_otp",
    });

    logger.info(`🔑 Token generado para ${uid}`);

    // ✅ 8. Marcar OTP como usado y eliminar
    await admin
      .firestore()
      .collection("otpCodes")
      .doc(cleanPhone)
      .update({
        verified: true,
        verifiedAt: admin.firestore.FieldValue.serverTimestamp(),
      });

    // Limpiar después de 1 minuto
    setTimeout(async () => {
      await admin
        .firestore()
        .collection("otpCodes")
        .doc(cleanPhone)
        .delete();
    }, 60000);

    // ✅ 9. Registrar en audit log
    await admin.firestore().collection("authLogs").add({
      phoneNumber: cleanPhone,
      action: "otp_validated",
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
      success: true,
    });

    // 🚀 Respuesta exitosa
    return res.json({
      success: true,
      token: customToken,
      userId: uid,
      message: "Autenticación exitosa",
    });
  } catch (error) {
    logger.error(`❌ validateOTP Error: ${error.message}`, error);
    return res.status(500).json({
      error: "Error al validar OTP",
      code: "VALIDATION_FAILED",
      message: error.message,
    });
  }
});

/**
 * ⭐ PRÓXIMO PASO: Integración con Twilio
 *
 * Instrucciones:
 * 1. npm install twilio
 * 2. Configurar variables de entorno:
 *    - TWILIO_ACCOUNT_SID
 *    - TWILIO_AUTH_TOKEN
 *    - TWILIO_PHONE_NUMBER (tu número Twilio)
 *
 * 3. Descomentar la función sendViaWhatsApp() abajo
 * 4. En sendWhatsAppOTP, reemplazar la línea de simulación con:
 *    await sendViaWhatsApp(cleanPhone, code);
 */

/*
const twilio = require("twilio");

async function sendViaWhatsApp(phoneNumber, code) {
  try {
    const accountSid = process.env.TWILIO_ACCOUNT_SID;
    const authToken = process.env.TWILIO_AUTH_TOKEN;
    const twilioPhoneNumber = process.env.TWILIO_PHONE_NUMBER;

    if (!accountSid || !authToken || !twilioPhoneNumber) {
      logger.error("❌ Credenciales Twilio no configuradas");
      throw new Error("Credenciales Twilio no configuradas");
    }

    const client = twilio(accountSid, authToken);

    const message = await client.messages.create({
      from: `whatsapp:${twilioPhoneNumber}`,
      to: `whatsapp:+${phoneNumber}`,
      body: `Tu código de verificación BIUX es: ${code}

No compartir este código con nadie. Válido por 10 minutos.`,
    });

    logger.info(`✉️ WhatsApp enviado: ${message.sid}`);
    return message;
  } catch (error) {
    logger.error(`❌ Error enviando WhatsApp: ${error.message}`);
    throw error;
  }
}
*/
