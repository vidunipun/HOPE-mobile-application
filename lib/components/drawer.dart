import 'package:auth/components/my_list_title.dart';
import 'package:flutter/material.dart';

import '../constants/colors.dart';
import '../user/edit_profile.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return  Drawer(
      backgroundColor: drawerbackgroundcolor,
      child: Column(
        children: [
          //header
          const DrawerHeader(child: Icon(Icons.person,color: Colors.white,size: 70,)),
          //home list title
          const MyListTitle(icon: Icons.home, text: "Home"),
          //profile list title
          ListTile (leading: const Icon(Icons.edit),
            title: const Text("Edit Profile"),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const EditProfilePage()),
            )
          //logout list title
      )],
      ),
    );
  }
}