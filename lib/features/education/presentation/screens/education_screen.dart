import 'package:flutter/material.dart';
import 'package:biux/core/design_system/color_tokens.dart';
class EducationScreen extends StatelessWidget {
  const EducationScreen({Key? key}) : super(key: key);
  @override Widget build(BuildContext context) {
    return Scaffold(backgroundColor: ColorTokens.neutral99,
      appBar: AppBar(title: const Text('Aprende'), backgroundColor: ColorTokens.primary30, foregroundColor: Colors.white),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        _sec(context,'Mantenimiento Basico', Icons.build, Colors.orange, [
          _Art('Lubricar la cadena','Limpia con trapo, aplica lubricante gota a gota en cada eslabon y limpia exceso.'),
          _Art('Revision de frenos','Verifica pastillas, ajusta tension del cable. Cambia pastillas si desgaste >50%.'),
          _Art('Presion de llantas','Ruta: 80-120 PSI. MTB: 30-50 PSI. Urbana: 50-70 PSI.'),
          _Art('Ajuste de cambios','Alinea desviadores, usa tornillos H y L, ajusta tension con tensor del shifter.'),
        ]),
        const SizedBox(height: 16),
        _sec(context,'Seguridad Vial', Icons.security, Colors.red, [
          _Art('Reglas basicas','Circula por derecha, senaliza giros, usa casco, respeta semaforos, luces de noche.'),
          _Art('Equipamiento','Casco certificado, luces, chaleco reflectivo, guantes, gafas, candado tipo U.'),
          _Art('En caso de accidente','1.Evalua lesiones 2.Lugar seguro 3.Llama 123 4.Fotos 5.Aseguradora'),
          _Art('Ciclismo nocturno','Min 200 lumenes frente, 50 atras. Ropa reflectiva. Evita rutas oscuras.'),
        ]),
        const SizedBox(height: 16),
        _sec(context,'Nutricion', Icons.restaurant, Colors.green, [
          _Art('Hidratacion','500ml/hora. Min 2 bidones. Electrolitos en rodadas largas.'),
          _Art('Pre-rodada','Comer 2-3h antes. Carbohidratos complejos: avena, pan integral, arroz.'),
          _Art('Post-rodada','Comer en 30min. Proteina+carbos. Estirar 10-15min. Dormir bien.'),
        ]),
        const SizedBox(height: 16),
        _sec(context,'Rutas Principiantes', Icons.map, Colors.blue, [
          _Art('Primera ruta','Planas 10-20km. Ciclovias o poco trafico. Lleva GPS. Avisa a alguien.'),
          _Art('Rodadas largas','Aumenta 10% semanal. Herramienta, camara repuesto, inflador. Paradas cada 30-40km.'),
        ]),
      ]));
  }
  Widget _sec(BuildContext c, String t, IconData ic, Color col, List<_Art> arts) {
    return Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: col.withValues(alpha: 0.1), borderRadius: const BorderRadius.vertical(top: Radius.circular(12))),
          child: Row(children: [Icon(ic, color: col), const SizedBox(width: 12), Text(t, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: col))])),
        ...arts.map((a) => ExpansionTile(tilePadding: const EdgeInsets.symmetric(horizontal: 16), childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          title: Text(a.t, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          children: [Text(a.c, style: TextStyle(fontSize: 13, color: Colors.grey[700], height: 1.5))])),
      ]));
  }
}
class _Art { final String t, c; _Art(this.t, this.c); }