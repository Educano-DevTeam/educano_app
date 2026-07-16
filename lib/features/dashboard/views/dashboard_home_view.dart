import 'package:flutter/material.dart';

import '../../../core/theme/theme.dart';

const double _spacingMinimum = 8;
const double _spacingSmall = 16;
const double _spacingMedium = 24;
const double _spacingLarge = 32;

const double _radius = 18;

class DashboardHomeView extends StatelessWidget {
  const DashboardHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(_spacingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildGreeting(context),

          const SizedBox(height: _spacingLarge),

          _buildStatistics(),

          const SizedBox(height: _spacingLarge),

          _buildActivities(context),

          const SizedBox(height: _spacingLarge),

          _buildChartsPlaceholder(),
        ],
      ),
    );
  }
}

Widget _buildGreeting(BuildContext context) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text("Olá, Miguel 👋", style: Theme.of(context).textTheme.headlineMedium),

      const SizedBox(height: _spacingMinimum),

      Text(
        "Bem-vindo(a) ao painel administrativo do Educano.",

        style: Theme.of(context).textTheme.bodyLarge,
      ),
    ],
  );
}

Widget _buildStatistics() {

  final statistics = [
    {
      "title": "Usuários",
      "value": "123",
      "subtitle": "+5 esta semana",
      "icon": Icons.people_alt_rounded,
      "color": EducanoColors.primaryBlue,
    },

    {
      "title": "Cursos",
      "value": "12",
      "subtitle": "+2 novos",
      "icon": Icons.menu_book_rounded,
      "color": EducanoColors.darkGreen,
    },

    {
      "title": "Questões",
      "value": "1.240",
      "subtitle": "+18 hoje",
      "icon": Icons.quiz_rounded,
      "color": EducanoColors.accentYellow,
    },

    {
      "title": "Itens",
      "value": "38",
      "subtitle": "+4 novos",
      "icon": Icons.shopping_bag_rounded,
      "color": EducanoColors.lightBlue,
    },
  ];

  return LayoutBuilder(
    builder: (context, constraints) {
      final width = constraints.maxWidth;

      int columns;

      if(width < 700){
        columns = 1;
      }
      else if(width < 1100){
        columns = 2;
      }
      else{
        columns = 4;
      }

      return GridView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(), 
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          crossAxisSpacing: 16,
          mainAxisExtent: 16,
          childAspectRatio: 1.45,
        ),
        itemCount: statistics.length,
        itemBuilder: (context, index) {  
          final item = statistics[index];

          return Container(
            decoration: BoxDecoration(
              color: EducanoColors.background,
              borderRadius: BorderRadius.circular(_radius),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0,4),
                ),
              ],
            ),
            // padding: ,
            child: Column (
              children:[
                CircleAvatar(
                  radius: 22,
                  backgroundColor: (item["color"] as Color).withOpacity(.15),

                  child: Icon(
                    item["icon"] as IconData,
                    color: item["color"] as Color,
                  ),
                ),

                SizedBox(height: _spacingMedium),

                Text(
                  item["title"] as String,
                ),

                Text(
                  item["value"] as String,

                  style: Theme.of(context).textTheme.headlineSmall,
                ),

                Text(
                  item["subtitle"] as String,
                ),
              ]
            )
          );
        },
      );
    },
  );
}

Widget _buildActivities(BuildContext context) {
  final activities = [
    {
      "title": "Novo usuário cadastrado",
      "description": "Miguel Soares foi cadastrado.",
      "icon": Icons.person_add_alt_rounded,
      "color": EducanoColors.primaryBlue,
    },

    {
      "title": "Curso publicado",
      "description": "Curso de Matemática Básica.",
      "icon": Icons.menu_book_rounded,
      "color": EducanoColors.darkGreen,
    },

    {
      "title": "Questão adicionada",
      "description": "Nova questão de Português.",
      "icon": Icons.quiz_rounded,
      "color": EducanoColors.accentYellow,
    },
  ];

  return Container(
    padding: const EdgeInsets.all(_spacingMedium),
    decoration: BoxDecoration(
      color: EducanoColors.background,
      borderRadius: BorderRadius.circular(_spacingSmall),
      boxShadow: const [
        BoxShadow(
          color: Colors.black12,
          blurRadius: 10,
          offset: Offset(0,4),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Últimas atividades",
          style: Theme.of(context).textTheme.titleLarge,
        ),
        Divider(),
        ...activities.map((activity){
          return ListTile(
            leading: 
              CircleAvatar(
                backgroundColor: 
                  (activity["color"] as Color).withOpacity(.15),
                child:
                  Icon(
                    activity["icon"]  as IconData,
                    color: activity["color"] as Color,
                  )
              ),
            subtitle: 
              Text(
                activity["description"] as String,
              ),
            trailing: 
              const Text(
                "Hoje",
              ),
          );
        }).toList(),
      ],
    ),
  );
}

Widget _buildChartsPlaceholder() {
  return Container(
    height: 280,
    decoration: BoxDecoration(
      color: EducanoColors.background,
      borderRadius: BorderRadius.circular(_radius),
      boxShadow: const [
        BoxShadow(
          color: Colors.black12,
          blurRadius: 10,
        ),
      ],
    ),

    child: const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.bar_chart_rounded,
            size: 60,
          ),

          SizedBox(height: _spacingSmall),

          Text(
            "Gráficos em breve",
          ),
        ],
      ),
    ),
  );
}
