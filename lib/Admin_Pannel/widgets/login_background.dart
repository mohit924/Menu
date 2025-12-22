// import 'package:flutter/material.dart';

// class LoginBackground extends StatelessWidget {
//   const LoginBackground({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       children: [
//         // 1️⃣ SKY (dark → warm sunset)
//         Container(
//           decoration: const BoxDecoration(
//             gradient: LinearGradient(
//               begin: Alignment.topCenter,
//               end: Alignment.center,
//               colors: [
//                 Color(0xFF1E1B1A), // dark clouds
//                 Color(0xFF4A3327), // brownish clouds
//                 Color(0xFFB96B34), // orange sky
//               ],
//             ),
//           ),
//         ),

//         // 2️⃣ SUNSET GLOW (thin bright band)
//         Align(
//           alignment: const Alignment(0, -0.1),
//           child: Container(
//             height: 120,
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 begin: Alignment.topCenter,
//                 end: Alignment.bottomCenter,
//                 colors: [
//                   Colors.orange.withOpacity(0.85),
//                   Colors.orange.withOpacity(0.25),
//                   Colors.transparent,
//                 ],
//               ),
//             ),
//           ),
//         ),

//         // 3️⃣ CITY MASS (silhouette depth)
//         Align(
//           alignment: const Alignment(0, 0.25),
//           child: Container(
//             height: 240,
//             decoration: const BoxDecoration(
//               gradient: LinearGradient(
//                 begin: Alignment.topCenter,
//                 end: Alignment.bottomCenter,
//                 colors: [
//                   Color(0xFF2A1F1A), // buildings top
//                   Color(0xFF16100D), // deeper city
//                 ],
//               ),
//             ),
//           ),
//         ),

//         // 4️⃣ CITY LIGHT STRIP (golden line)
//         Align(
//           alignment: const Alignment(0, 0.34),
//           child: Container(
//             height: 18,
//             decoration: BoxDecoration(
//               color: const Color(0xFFFFB45C).withOpacity(0.75),
//               boxShadow: [
//                 BoxShadow(
//                   color: const Color(0xFFFFB45C).withOpacity(0.6),
//                   blurRadius: 25,
//                   spreadRadius: 6,
//                 ),
//               ],
//             ),
//           ),
//         ),

//         // 5️⃣ WATER (reflection)
//         Align(
//           alignment: Alignment.bottomCenter,
//           child: Container(
//             height: 260,
//             decoration: const BoxDecoration(
//               gradient: LinearGradient(
//                 begin: Alignment.topCenter,
//                 end: Alignment.bottomCenter,
//                 colors: [Color(0xFF1C140F), Color(0xFF0E0A07)],
//               ),
//             ),
//           ),
//         ),

//         // 6️⃣ VIGNETTE (edge darkening)
//         Container(
//           decoration: BoxDecoration(
//             gradient: RadialGradient(
//               center: Alignment.topCenter,
//               radius: 1.3,
//               colors: [Colors.transparent, Colors.black.withOpacity(0.55)],
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
