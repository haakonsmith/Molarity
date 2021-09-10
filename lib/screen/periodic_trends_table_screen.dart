// import 'package:flutter/material.dart';
// import 'package:molarity/widgets/app_bar.dart';
// import 'package:molarity/widgets/chemoinfomatics/widgets/periodic_trends_table.dart';
// import 'package:molarity/widgets/list_drawer.dart';

// /// This is the first landing page and screen which shows the basic periodic table
// class PeriodicTrendsTableScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: MolarityAppBar.buildTitle(
//           context,
//           Text(
//             "Periodic Trends",
//             style: TextStyle(color: Colors.white, fontWeight: FontWeight.w200),
//             textScaleFactor: 1.5,
//           ),
//           height: MediaQuery.of(context).size.width / 15 >= 50 ? MediaQuery.of(context).size.width / 15 : 50),
//       drawer: ListDrawer(),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.fromLTRB(30.0, 10.0, 30.0, 0),
//           child: PeriodicTrendsTable(),
//         ),
//       ),
//     );
//   }
// }
