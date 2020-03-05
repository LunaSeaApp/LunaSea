import 'package:flutter/material.dart';
import 'package:lunasea/core.dart';
import 'package:lunasea/routes/search/routes.dart';
import 'package:lunasea/widgets/ui.dart';

class LSSearchCategoryTile extends StatelessWidget {
    final NewznabCategoryData category;
    final int index;

    LSSearchCategoryTile({
        @required this.category,
        this.index = 0,
    });

    @override
    Widget build(BuildContext context) => LSCardTile(
        title: LSTitle(text: category.name),
        subtitle: LSSubtitle(text: category.subcategories.length == 0 ? 'No Subcategories Available': category.subcategoriesList),
        leading: LSIconButton(icon: category.icon, color: LSColors.list(index)),
        trailing: LSIconButton(icon: Icons.arrow_forward_ios),
        onTap: () => _enterSubcategories(context),
    );

    Future<void> _enterSubcategories(BuildContext context) async {
        final model = Provider.of<SearchModel>(context, listen: false);
        model?.category = category;
        model?.searchCategoryID = category.id;
        await Navigator.of(context).pushNamed(SearchSubcategories.ROUTE_NAME);
    }
}
