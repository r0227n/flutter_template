import 'package:flutter/material.dart';

class MenuEntry {
  const MenuEntry({
    required this.child,
    this.shortcut,
    this.onPressed,
    this.menuChildren,
  }) : assert(
          menuChildren == null || onPressed == null,
          'onPressed is ignored if menuChildren are provided',
        );

  final Widget child;

  final MenuSerializableShortcut? shortcut;
  final VoidCallback? onPressed;
  final List<MenuEntry>? menuChildren;

  static List<Widget> build(List<MenuEntry> selections) {
    Widget buildSelection(MenuEntry selection) {
      if (selection.menuChildren != null) {
        return SubmenuButton(
          menuChildren: MenuEntry.build(selection.menuChildren!),
          child: selection.child,
        );
      }

      return MenuItemButton(
        shortcut: selection.shortcut,
        onPressed: selection.onPressed,
        style: ButtonStyle(
          alignment: Alignment.center,
          backgroundColor: MaterialStateProperty.all(Colors.transparent),
          padding: MaterialStateProperty.all(EdgeInsets.zero),
        ),
        child: selection.child,
      );
    }

    return selections.map<Widget>(buildSelection).toList();
  }

  static Map<MenuSerializableShortcut, Intent> shortcuts(List<MenuEntry> selections) {
    final Map<MenuSerializableShortcut, Intent> result = <MenuSerializableShortcut, Intent>{};
    for (final MenuEntry selection in selections) {
      if (selection.menuChildren != null) {
        result.addAll(MenuEntry.shortcuts(selection.menuChildren!));
      } else {
        if (selection.shortcut != null && selection.onPressed != null) {
          result[selection.shortcut!] = VoidCallbackIntent(selection.onPressed!);
        }
      }
    }
    return result;
  }
}

class PopupMenuBar extends StatelessWidget {
  const PopupMenuBar({
    super.key,
    required this.child,
    required this.entries,
  });

  final Widget child;
  final List<MenuEntry> entries;

  @override
  Widget build(BuildContext context) {
    return MenuBar(
      style: MenuStyle(
        backgroundColor: MaterialStateProperty.all(Colors.transparent),
        shadowColor: MaterialStateProperty.all(Colors.transparent),
        surfaceTintColor: MaterialStateProperty.all(Colors.transparent),
        padding: MaterialStateProperty.all(EdgeInsets.zero),
      ),
      children: MenuEntry.build(
        [
          MenuEntry(child: child, menuChildren: entries),
        ],
      ),
    );
  }
}
