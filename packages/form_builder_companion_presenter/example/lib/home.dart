// See LICENCE file in the root.

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'l10n/locale_keys.g.dart';
import 'models.dart';
import 'screen.dart';

/// Home page which shows persisted models.
class HomePage extends Screen {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget buildPage(BuildContext context, WidgetRef ref) {
    final accountState = ref.watch(accountStateProvider);
    final bookingState = ref.watch(bookingStateProvider);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        // ignore: avoid_redundant_argument_values
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            LocaleKeys.home_accountHeader.tr(),
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 4),
          Table(
            border: TableBorder.all(),
            columnWidths: const {0: IntrinsicColumnWidth()},
            children: [
              _cell('ID', '${accountState.asData?.value.id}'),
              _cell('Age', '${accountState.asData?.value.age}'),
              _cell('Name', '${accountState.asData?.value.name}'),
              _cell('Gender', '${accountState.asData?.value.gender}'),
              _cell(
                'Preferred regions',
                '${accountState.asData?.value.preferredRegions}',
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            LocaleKeys.home_bookingHeader.tr(),
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 4),
          Table(
            border: TableBorder.all(),
            columnWidths: const {0: IntrinsicColumnWidth()},
            children: [
              _cell('Stay', '${bookingState.asData?.value.stay}'),
              _cell(
                'Special offer date',
                '${bookingState.asData?.value.specialOfferDate}',
              ),
              _cell('Room type', '${bookingState.asData?.value.roomType}'),
              _cell('Meal offers', '${bookingState.asData?.value.mealOffers}'),
              _cell('Smoking', '${bookingState.asData?.value.smoking}'),
              _cell('Persons', '${bookingState.asData?.value.persons}'),
              _cell('Baby beds', '${bookingState.asData?.value.babyBeds}'),
              _cell('Price', '${bookingState.asData?.value.price}'),
              _cell(
                'Donation',
                bookingState.asData?.value.donation == null
                    ? 'null'
                    : NumberFormat.decimalPattern()
                        .format(bookingState.asData?.value.donation),
              ),
              _cell('Note', '${bookingState.asData?.value.note}'),
            ],
          ),
        ],
      ),
    );
  }

  TableRow _cell(String header, String content) => TableRow(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            child: Text(header),
          ),
          Container(
            padding: const EdgeInsets.all(4),
            child: Text(content),
          ),
        ],
      );

  @override
  String get title => LocaleKeys.home_title.tr();
}
