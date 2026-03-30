/**
 * Script para eliminar grupos con 0 miembros usando firebase-admin + ADC
 * 
 * PASOS:
 *   1. Ejecutar primero: npx firebase login
 *   2. Luego: node delete_empty_groups_admin.js
 */

const { initializeApp, cert, getApp } = require('firebase-admin/app');
const { getFirestore } = require('firebase-admin/firestore');

const PROJECT_ID = 'biux-1576614678644';

// Inicializar con Application Default Credentials (ADC de Firebase CLI)
try {
  initializeApp({ projectId: PROJECT_ID });
} catch (e) {
  getApp();
}

const db = getFirestore();

async function main() {
  console.log('📋 Obteniendo todos los grupos de Firestore...');

  const snapshot = await db.collection('groups').get();
  console.log(`📦 Total grupos: ${snapshot.size}`);

  const toDelete = [];

  snapshot.forEach((doc) => {
    const data = doc.data();
    const members = data.memberIds || data.members || [];
    const count = Array.isArray(members) ? members.length : 0;

    if (count === 0) {
      console.log(`  🗑️  [0 miembros] "${data.name || doc.id}" → ${doc.id}`);
      toDelete.push(doc.ref);
    } else {
      console.log(`  ✅ [${count} miembros] "${data.name || doc.id}"`);
    }
  });

  if (toDelete.length === 0) {
    console.log('\n✅ No hay grupos con 0 miembros. Nada que eliminar.');
    return;
  }

  console.log(`\n⚠️  Se van a eliminar ${toDelete.length} grupos con 0 miembros.`);
  console.log('🔥 Eliminando...');

  const batch = db.batch();
  toDelete.forEach((ref) => batch.delete(ref));
  await batch.commit();

  console.log(`✅ ${toDelete.length} grupos eliminados correctamente.`);
}

main().catch((err) => {
  console.error('❌ Error:', err.message || err);
  process.exit(1);
});
