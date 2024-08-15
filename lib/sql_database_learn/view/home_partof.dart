part of 'home_view.dart';

class _PartofAppBar extends StatefulWidget implements PreferredSizeWidget {
  const _PartofAppBar({
    super.key,
  });

  @override
  State<_PartofAppBar> createState() => _PartofAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _PartofAppBarState extends State<_PartofAppBar> {
  String getFormattedDate() {
    var d = AppLocalizations.of(context);
    final now = DateTime.now();
    return "${d!.date}: ${now.day}/${now.month}/${now.year}";
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: ProjectColors.blueShade(),
      title: Text(
        ProjectString.appName.string(),
        style: TextStyle(color: ProjectColors.whiteColor()),
      ),
      actions: [
        Padding(
          padding: const _WidgetPadding.symetric(),
          child: Text(
            getFormattedDate(),
            style: TextStyle(color: ProjectColors.whiteColor()),
          ),
        ),
      ],
    );
  }
}
