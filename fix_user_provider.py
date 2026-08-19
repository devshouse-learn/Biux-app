#!/usr/bin/env python
# -*- coding: utf-8 -*-

import re

with open('lib/features/users/presentation/providers/user_provider.dart', 'r', encoding='utf-8') as f:
    content = f.read()

# Paso 1: Cambiar el constructor
# Buscar el patrón del constructor y reemplazarlo
constructor_pattern = (
    r'  // 🔗"´ Constructor que auto-inicializa en web\n'
    r'  UserProvider\(\) : _userService = UserService\(\) \{\n'
    r'    AppLogger\.debug\(.*?\);\n'
    r'    if \(kIsWeb && !kReleaseMode\) \{.*?\n.*?_createWebTestUser\(\);.*?\n.*?\} else \{.*?\n.*?loadUserData\(\);.*?\n.*?\}\n'
    r'  \}'
)

# Reemplazo simple
constructor_replacement = (
    '  /// Constructor que inicializa el proveedor\n'
    '  UserProvider() : _userService = UserService() {\n'
    "    AppLogger.debug('UserProvider constructor llamado');\n"
    '    loadUserData();\n'
    '  }'
)

try:
    content = re.sub(
        constructor_pattern,
        constructor_replacement,
        content,
        flags=re.DOTALL | re.MULTILINE
    )
    print("Constructor modificado exitosamente")
except Exception as e:
    print(f"Error modificando constructor: {e}")

# Paso 2: Remover el método _createWebTestUser
# Buscar desde "// 🔗" que precede al método hasta el cierre "  }"
method_pattern = (
    r'  // 🔗[^\n]*\n'
    r'  Future<void> _createWebTestUser\(\) async \{.*?\n  \}\n\n'
)

content = re.sub(method_pattern, '', content, flags=re.DOTALL)
print("Método _createWebTestUser removido")

# Escribir el archivo
with open('lib/features/users/presentation/providers/user_provider.dart', 'w', encoding='utf-8') as f:
    f.write(content)

print("Archivo actualizado")
