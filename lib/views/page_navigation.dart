import 'package:boat_autopilot/providers/navigation_provider.dart';
import 'package:boat_autopilot/shared/colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class PageNavigationView extends StatefulWidget {
  @override
  _PageNavigationViewState createState() => _PageNavigationViewState();
}

class _PageNavigationViewState extends State<PageNavigationView> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 85,
      child: Column(
        children: const [
          _NavigationButton(icon: Icons.directions_boat, index: 0),
          _NavigationButton(icon: Icons.explore, index: 1),
          _NavigationButton(icon: Icons.display_settings, index: 2)
        ],
      ),
    );
  }
}

class _NavigationButton extends StatelessWidget {
  final IconData icon;
  final int index;
  const _NavigationButton({Key? key, required this.icon, required this.index})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return SizedBox(
        width: constraints.maxWidth,
        height: constraints.maxWidth,
        child: Padding(
          padding: const EdgeInsets.only(right: 3, bottom: 10),
          child: Consumer<NavigationProvider>(
            builder: (context, navigationProvider, child) {
              return Opacity(
                opacity: navigationProvider.currentViewIndex == index
                    ? 1
                    : 0.6,
                child: Container(
                  child: IconButton(
                    icon: Icon(
                      icon,
                      color: navigationProvider.currentViewIndex == index
                          ? Colors.white
                          : primary,
                      size: 40,
                    ),
                    onPressed: () {
                      Provider.of<NavigationProvider>(context, listen: false)
                          .setView(index);
                    },
                  ),
                  decoration: const BoxDecoration(
                      color: primaryDark,
                      borderRadius: BorderRadius.only(
                          topRight: Radius.circular(10),
                          bottomRight: Radius.circular(10))),
                ),
              );
            },
          ),
        ),
      );
    });
  }
}
