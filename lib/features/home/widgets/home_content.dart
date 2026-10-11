import 'package:educano_app/features/home/views/home_view.dart';
import 'package:flutter/material.dart';

import '../../../core/navigation/app_menu.dart';

class HomeContent extends StatelessWidget {
   final AppMenu selectedMenu;

   const HomeContent({
      super.key,
      required this.selectedMenu,
   });

   @override
   Widget build(BuildContext context) {

      switch(selectedMenu){
         case AppMenu.home:
          return const HomeView();
        default:
          return const SizedBox();
      }
   }
}