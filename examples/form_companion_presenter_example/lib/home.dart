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
    final accountState = ref.watch(account);
    final bookingState = ref.watch(booking);
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
            style: Theme.of(context).textTheme.headline6,
          ),
          const SizedBox(height: 4),
          Table(
            border: TableBorder.all(),
            columnWidths: const {0: IntrinsicColumnWidth()},
            children: [
              _cell('ID', '${accountState.id}'),
              _cell('Age', '${accountState.age}'),
              _cell('Name', '${accountState.name}'),
              _cell('Gender', '${accountState.gender}'),
              _cell('Preferred regions', '${accountState.preferredRegsions}'),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            LocaleKeys.home_bookingHeader.tr(),
            style: Theme.of(context).textTheme.headline6,
          ),
          const SizedBox(height: 4),
          Table(
            border: TableBorder.all(),
            columnWidths: const {0: IntrinsicColumnWidth()},
            children: [
              _cell('Stay', '${bookingState.stay}'),
              _cell('Special offer date', '${bookingState.specialOfferDate}'),
              _cell('Room type', '${bookingState.roomType}'),
              _cell('Meal offers', '${bookingState.mealOffers}'),
              _cell('Smoking', '${bookingState.smoking}'),
              _cell('Persons', '${bookingState.persons}'),
              _cell('Baby beds', '${bookingState.babyBeds}'),
              _cell('Price', '${bookingState.price}'),
              _cell(
                'Donation',
                bookingState.donation == null
                    ? 'null'
                    : NumberFormat.decimalPattern()
                        .format(bookingState.donation),
              ),
              _cell('Note', '${bookingState.note}'),
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
