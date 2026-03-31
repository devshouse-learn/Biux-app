/**
 * Script para eliminar grupos con 0 miembros de Firestore
 * 
 * USO:
 *   node delete_empty_groups.js <email> <password>
 * 
 * Ejemplo:
 *   node delete_empty_groups.js admin@biux.com miContrasena123
 */

const https = require('https');

const API_KEY = 'AIzaSyAo-m8HwLX29RWt-24qItFMtskNCb6ahjE';
const PROJECT_ID = 'biux-1576614678644';

const email = process.argv[2];
const password = process.argv[3];

if (!email || !password) {
  console.error('❌ Uso: node delete_empty_groups.js <email> <password>');
  process.exit(1);
}

// Función para hacer peticiones HTTPS
function httpsRequest(options, body) {
  return new Promise((resolve, reject) => {
    const req = https.request(options, (res) => {
      let data = '';
      res.on('data', (chunk) => data += chunk);
      res.on('end', () => {
        try {
          resolve({ status: res.statusCode, data: JSON.parse(data) });
        } catch {
          resolve({ status: res.statusCode, data });
        }
      });
    });
    req.on('error', reject);
    if (body) req.write(JSON.stringify(body));
    req.end();
  });
}

async function main() {
  console.log('🔐 Iniciando sesión en Firebase...');

  // 1. Autenticar con email/password
  const authRes = await httpsRequest({
    hostname: 'identitytoolkit.googleapis.com',
    path: `/v1/accounts:signInWithPassword?key=${API_KEY}`,
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
  }, { email, password, returnSecureToken: true });

  if (authRes.status !== 200) {
    console.error('❌ Error de autenticación:', authRes.data.error?.message || authRes.data);
    process.exit(1);
  }

  const token = authRes.data.idToken;
  console.log('✅ Sesión iniciada como:', authRes.data.displayName || email);

  // 2. Obtener todos los grupos
  console.log('\n📋 Obteniendo lista de grupos...');
  const groupsRes = await httpsRequest({
    hostname: 'firestore.googleapis.com',
    path: `/v1/projects/${PROJECT_ID}/databases/(default)/documents/groups?pageSize=300`,
    method: 'GET',
    headers: { 'Authorization': `Bearer ${token}` },
  });

  if (groupsRes.status !== 200) {
    console.error('❌ Error obteniendo grupos:', groupsRes.data);
    process.exit(1);
  }

  const docs = groupsRes.data.documents || [];
  console.log(`📦 Total grupos encontrados: ${docs.length}`);

  // 3. Filtrar grupos con 0 miembros
  const emptyGroups = docs.filter(doc => {
    const memberIds = doc.fields?.memberIds?.arrayValue?.values || [];
    return memberIds.length === 0;
  });

  if (emptyGroups.length === 0) {
    console.log('\n✅ No hay grupos con 0 miembros. Nada que eliminar.');
    return;
  }

  console.log(`\n🗑️  Grupos con 0 miembros a eliminar (${emptyGroups.length}):`);
  for (const doc of emptyGroups) {
    const name = doc.fields?.name?.stringValue || '(sin nombre)';
    const docId = doc.name.split('/').pop();
    console.log(`   - ${name} (ID: ${docId})`);
  }

  // 4. Eliminar grupos vacíos
  console.log('\n🗑️  Eliminando...');
  let deleted = 0;
  let errors = 0;

  for (const doc of emptyGroups) {
    const name = doc.fields?.name?.stringValue || '(sin nombre)';
    const docPath = doc.name.replace('projects/', '').replace('databases/', '');
    
    const delRes = await httpsRequest({
      hostname: 'firestore.googleapis.com',
      path: `/v1/${doc.name}`,
      method: 'DELETE',
      headers: { 'Authorization': `Bearer ${token}` },
    });

    if (delRes.status === 200 || delRes.status === 204) {
      console.log(`   ✅ Eliminado: ${name}`);
      deleted++;
    } else {
      console.log(`   ❌ Error eliminando "${name}":`, delRes.data);
      errors++;
    }
  }

  console.log(`\n🏁 Resultado: ${deleted} eliminados, ${errors} errores.`);
}

main().catch(err => {
  console.error('❌ Error inesperado:', err.message);
  process.exit(1);
});
