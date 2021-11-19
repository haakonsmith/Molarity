import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:molarity/data/settings_bloc.dart';
import 'package:molarity/widgets/app_bar.dart';
import 'package:molarity/widgets/list_drawer.dart';
import 'package:molarity/widgets/titled_card.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    final children = [
      // SizedBox(height: 140),
      SizedBox(
        width: screenSize.width,
        height: 130,
        child: _SettingsCard(
          title: const Text('Persistance Preferences'),
          children: [
            SwitchListTile.adaptive(
              title: const Text('Should Remember Atomic Properties Selected'),
              value: ref.watch(settingsBlocProvider).shouldPersistAtomicPreviewCategories,
              onChanged: (value) {
                ref.read(settingsBlocProvider).shouldPersistAtomicPreviewCategories = value;
              },
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ],
        ),
      ),
      // Spacer(),
    ];
    return Scaffold(
      appBar: MolarityAppBar.buildTitle(context, const Text('Settings')),
      drawer: const ListDrawer(),
      body: Column(
        // mainAxisSize: MainAxisSize.max,
        children: children,
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({Key? key, this.title, this.children}) : super(key: key);

  final Widget? title;
  final List<Widget>? children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TitledCard(
        title: title ??
            const Text(
              'Add title',
            ),
        child: ListView(
          children: children ?? [],
        ),
      ),
    );
  }
}


// class _SettingsTile extends StatelessWidget {
//   const _SettingsTile({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Container();
//   }
// }