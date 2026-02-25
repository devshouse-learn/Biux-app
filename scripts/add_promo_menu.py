#!/usr/bin/env python3
"""
Script to add 'Promociones' PopupMenuItem to the three-dot menu
in shop_screen_pro.dart
"""

filepath = '/Users/macmini/biux/lib/features/shop/presentation/screens/shop_screen_pro.dart'

with open(filepath, 'r') as f:
    content = f.read()

# 1. Add PopupMenuItem after the 'info' item
# Find the PopupMenuItem with value: 'info' and add a new one after it
# The info item structure ends with a closing ), so we look for the pattern

# Find "value: 'info'," and then find the closing of that PopupMenuItem
info_idx = content.find("value: 'info',")
if info_idx == -1:
    print("ERROR: Could not find value: 'info'")
    exit(1)

print(f"Found 'info' value at position {info_idx}")

# From info_idx, find the closing "), " or ")," for that PopupMenuItem
# We need to count parentheses to find the matching close
search_start = content.rfind('PopupMenuItem', 0, info_idx)
print(f"PopupMenuItem starts at position {search_start}")

# Count from PopupMenuItem to find its closing
depth = 0
i = search_start
found_end = -1
while i < len(content):
    if content[i] == '(':
        depth += 1
    elif content[i] == ')':
        depth -= 1
        if depth == 0:
            found_end = i
            break
    i += 1

if found_end == -1:
    print("ERROR: Could not find end of info PopupMenuItem")
    exit(1)

# Check if there's a comma after
if content[found_end + 1] == ',':
    found_end += 1

print(f"Info PopupMenuItem ends at position {found_end}")
print(f"Context: ...{content[found_end-20:found_end+20]}...")

# Insert new PopupMenuItem after the info one
new_item = """
                    PopupMenuItem<String>(
                      value: 'promociones',
                      child: Row(
                        children: [
                          Icon(Icons.campaign, size: 20, color: Colors.orange),
                          const SizedBox(width: 12),
                          Text('Promociones'),
                        ],
                      ),
                    ),"""

content = content[:found_end + 1] + new_item + content[found_end + 1:]
print("Added PopupMenuItem for 'promociones'")

# 2. Now add the _showPromotionsBottomSheet method
# Find _showOffersBottomSheet to add right before it
offers_idx = content.find('void _showOffersBottomSheet')
if offers_idx == -1:
    print("ERROR: Could not find _showOffersBottomSheet")
    exit(1)

print(f"Found _showOffersBottomSheet at position {offers_idx}")

new_method = """
  /// Bottom sheet con promociones de la comunidad
  void _showPromotionsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header con flecha atrás
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Icon(Icons.campaign, color: Colors.orange, size: 24),
                    const SizedBox(width: 8),
                    const Text(
                      'Promociones de la Comunidad',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              // Content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  child: _buildPromoBanner(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

"""

content = content[:offers_idx] + new_method + content[offers_idx:]
print("Added _showPromotionsBottomSheet method")

with open(filepath, 'w') as f:
    f.write(content)

print("File written successfully!")
