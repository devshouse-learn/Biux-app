#!/usr/bin/env python3
"""
Script to replace _buildPromoBanner() with improved version
and remove duplicate _showPromotionsBottomSheet
"""

filepath = '/Users/macmini/biux/lib/features/shop/presentation/screens/shop_screen_pro.dart'

with open(filepath, 'r') as f:
    lines = f.readlines()

print(f"Total lines: {len(lines)}")

# Find _buildPromoBanner method (lines 1443-1712, 0-indexed: 1442-1711)
promo_start = None
promo_end = None
for i, line in enumerate(lines):
    if 'Widget _buildPromoBanner()' in line:
        promo_start = i
        print(f"Found _buildPromoBanner at line {i+1}: {line.rstrip()}")
        break

if promo_start is None:
    print("ERROR: Could not find _buildPromoBanner")
    exit(1)

# Find end by counting braces
depth = 0
for i in range(promo_start, len(lines)):
    for ch in lines[i]:
        if ch == '{':
            depth += 1
        elif ch == '}':
            depth -= 1
            if depth == 0:
                promo_end = i
                break
    if promo_end is not None:
        break

print(f"_buildPromoBanner spans lines {promo_start+1} to {promo_end+1} ({promo_end - promo_start + 1} lines)")

# New _buildPromoBanner with light colors and better form
new_promo_banner = '''  /// Banner promocional integrado con Biux - Colores claros
  Widget _buildPromoBanner() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: const Color(0xFF16242D).withOpacity(0.1)),
      ),
      color: const Color(0xFFF0F7FF),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF16242D).withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.campaign_outlined,
                    color: Color(0xFF16242D),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Promociones de la Comunidad',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF16242D),
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Comparte ofertas y eventos con otros ciclistas',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF5A7A8A),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Campo: Título de la promoción
            const Text(
              'Título de la promoción',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2C4A5A),
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              decoration: InputDecoration(
                hintText: 'Ej: Descuento en cascos de ciclismo',
                hintStyle: TextStyle(
                  color: const Color(0xFF16242D).withOpacity(0.35),
                  fontSize: 14,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: const Color(0xFF16242D).withOpacity(0.12),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: const Color(0xFF16242D).withOpacity(0.12),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                    color: Color(0xFF16242D),
                    width: 1.5,
                  ),
                ),
                prefixIcon: Icon(
                  Icons.title,
                  color: const Color(0xFF16242D).withOpacity(0.4),
                  size: 20,
                ),
              ),
              style: const TextStyle(
                color: Color(0xFF16242D),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),

            // Campo: Descripción
            const Text(
              'Descripción',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2C4A5A),
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Describe tu promoción, incluye detalles importantes como ubicación, horarios, condiciones...',
                hintStyle: TextStyle(
                  color: const Color(0xFF16242D).withOpacity(0.35),
                  fontSize: 14,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: const Color(0xFF16242D).withOpacity(0.12),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: const Color(0xFF16242D).withOpacity(0.12),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                    color: Color(0xFF16242D),
                    width: 1.5,
                  ),
                ),
                prefixIcon: Padding(
                  padding: const EdgeInsets.only(bottom: 40),
                  child: Icon(
                    Icons.description_outlined,
                    color: const Color(0xFF16242D).withOpacity(0.4),
                    size: 20,
                  ),
                ),
              ),
              style: const TextStyle(
                color: Color(0xFF16242D),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),

            // Fila: Tipo + Fecha
            Row(
              children: [
                // Tipo de promoción
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Tipo',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2C4A5A),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: const Color(0xFF16242D).withOpacity(0.12),
                          ),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: 'descuento',
                            isExpanded: true,
                            icon: Icon(
                              Icons.keyboard_arrow_down,
                              color: const Color(0xFF16242D).withOpacity(0.5),
                            ),
                            style: const TextStyle(
                              color: Color(0xFF16242D),
                              fontSize: 14,
                            ),
                            dropdownColor: Colors.white,
                            items: const [
                              DropdownMenuItem(
                                value: 'descuento',
                                child: Row(
                                  children: [
                                    Text('🏷️', style: TextStyle(fontSize: 16)),
                                    SizedBox(width: 8),
                                    Text('Descuento'),
                                  ],
                                ),
                              ),
                              DropdownMenuItem(
                                value: 'oferta',
                                child: Row(
                                  children: [
                                    Text('🎁', style: TextStyle(fontSize: 16)),
                                    SizedBox(width: 8),
                                    Text('Oferta'),
                                  ],
                                ),
                              ),
                              DropdownMenuItem(
                                value: 'evento',
                                child: Row(
                                  children: [
                                    Text('🚴', style: TextStyle(fontSize: 16)),
                                    SizedBox(width: 8),
                                    Text('Evento'),
                                  ],
                                ),
                              ),
                              DropdownMenuItem(
                                value: 'novedad',
                                child: Row(
                                  children: [
                                    Text('✨', style: TextStyle(fontSize: 16)),
                                    SizedBox(width: 8),
                                    Text('Novedad'),
                                  ],
                                ),
                              ),
                            ],
                            onChanged: (value) {},
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),

                // Fecha de expiración
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Expira',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2C4A5A),
                        ),
                      ),
                      const SizedBox(height: 6),
                      GestureDetector(
                        onTap: () async {
                          await showDatePicker(
                            context: context,
                            initialDate: DateTime.now().add(
                              const Duration(days: 7),
                            ),
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(
                              const Duration(days: 365),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 13,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: const Color(0xFF16242D).withOpacity(0.12),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.calendar_today_outlined,
                                size: 18,
                                color: const Color(0xFF16242D).withOpacity(0.4),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Seleccionar',
                                style: TextStyle(
                                  color: const Color(0xFF16242D).withOpacity(0.5),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Campo: Ubicación (nuevo)
            const Text(
              'Ubicación (opcional)',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2C4A5A),
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              decoration: InputDecoration(
                hintText: 'Ej: Tienda de ciclismo Calle 80, Bogotá',
                hintStyle: TextStyle(
                  color: const Color(0xFF16242D).withOpacity(0.35),
                  fontSize: 14,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: const Color(0xFF16242D).withOpacity(0.12),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: const Color(0xFF16242D).withOpacity(0.12),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                    color: Color(0xFF16242D),
                    width: 1.5,
                  ),
                ),
                prefixIcon: Icon(
                  Icons.location_on_outlined,
                  color: const Color(0xFF16242D).withOpacity(0.4),
                  size: 20,
                ),
              ),
              style: const TextStyle(
                color: Color(0xFF16242D),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),

            // Campo: Enlace o contacto (nuevo)
            const Text(
              'Enlace o contacto (opcional)',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2C4A5A),
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              decoration: InputDecoration(
                hintText: 'Ej: https://mitienda.com o +57 300 123 4567',
                hintStyle: TextStyle(
                  color: const Color(0xFF16242D).withOpacity(0.35),
                  fontSize: 14,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: const Color(0xFF16242D).withOpacity(0.12),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: const Color(0xFF16242D).withOpacity(0.12),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                    color: Color(0xFF16242D),
                    width: 1.5,
                  ),
                ),
                prefixIcon: Icon(
                  Icons.link,
                  color: const Color(0xFF16242D).withOpacity(0.4),
                  size: 20,
                ),
              ),
              style: const TextStyle(
                color: Color(0xFF16242D),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 20),

            // Nota informativa
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF16242D).withOpacity(0.04),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color(0xFF16242D).withOpacity(0.08),
                ),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, size: 18, color: Color(0xFF5A7A8A)),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Las promociones serán visibles para todos los ciclistas de tu comunidad durante el tiempo seleccionado.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF5A7A8A),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Botón publicar
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Promoción publicada exitosamente 🎉'),
                      backgroundColor: Color(0xFF16242D),
                    ),
                  );
                },
                icon: const Icon(Icons.send_rounded, size: 18),
                label: const Text(
                  'Publicar Promoción',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF16242D),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
'''

# Replace the method
new_lines = lines[:promo_start] + [new_promo_banner] + lines[promo_end + 1:]
print(f"Replaced _buildPromoBanner ({promo_end - promo_start + 1} lines -> new version)")

# Now remove duplicate _showPromotionsBottomSheet
# Find all occurrences
occurrences = []
for i, line in enumerate(new_lines):
    if 'void _showPromotionsBottomSheet' in line:
        occurrences.append(i)

print(f"Found {len(occurrences)} _showPromotionsBottomSheet methods at lines: {[o+1 for o in occurrences]}")

if len(occurrences) > 1:
    # Remove the second one
    second_start = occurrences[1]
    # Find its end by counting braces
    depth = 0
    second_end = None
    for i in range(second_start, len(new_lines)):
        for ch in new_lines[i]:
            if ch == '{':
                depth += 1
            elif ch == '}':
                depth -= 1
                if depth == 0:
                    second_end = i
                    break
        if second_end is not None:
            break
    
    if second_end:
        print(f"Removing duplicate _showPromotionsBottomSheet at lines {second_start+1}-{second_end+1}")
        new_lines = new_lines[:second_start] + new_lines[second_end + 1:]

print(f"Total lines after changes: {len(new_lines)}")

with open(filepath, 'w') as f:
    f.writelines(new_lines)

print("File written successfully!")
