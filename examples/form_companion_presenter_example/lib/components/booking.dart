// See LICENCE file in the root.

import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_builder_companion_presenter/form_builder_companion_presenter.dart';
import 'package:form_companion_presenter/form_companion_annotation.dart';
import 'package:form_companion_presenter/form_companion_presenter.dart';

//!macro beginNotManualOnly
//!macro importFcp
//!macro endNotManualOnly
import '../l10n/locale_keys.g.dart';
//!macro beginManualOnly
//!macro importFcp
//!macro endManualOnly
import '../models.dart';
import '../routes.dart';
import '../screen.dart';
//!macro beginRemove
import 'booking.fcp.dart';
//!macro endRemove

//!macro headerNote

/// //!macro pageDocument
class BookingPageTemplate extends Screen {
  /// Constructor.
  const BookingPageTemplate({Key? key}) : super(key: key);

  @override
  String get title => 'TITLE_TEMPLATE';

  @override
  Widget buildPage(BuildContext context, WidgetRef ref) => FormBuilder(
        //!macro formValidateMode
        child: _BookingPaneTemplate(),
      );
}

class _BookingPaneTemplate extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = DateTime.now();
    final userState = ref.watch(account);
    final bookingState = ref.watch(booking);
    final presenter = ref.watch(_presenter.notifier);

    return SingleChildScrollView(
      child: Column(
        children: [
          Text(
            bookingState is BookingRegistered
                ? LocaleKeys.booking_captionTemplate_existing.tr(
                    namedArgs: {
                      // In real apps, AccountEmpty should be avoided in navigation guard.
                      'userName': userState.name ?? 'Dummy User',
                      'bookingId': bookingState.bookingId,
                    },
                  )
                : LocaleKeys.booking_captionTemplate_new.tr(
                    namedArgs: {
                      'userName': userState.name ?? 'Dummy User',
                    },
                  ),
            style: Theme.of(context).textTheme.bodyText1,
          ),
          presenter.fields.stay(
            context,
            firstDate: presenter.stay.value?.start ?? today,
            lastDate: presenter.stay.value?.end ??
                today.add(const Duration(days: 90)),
          ),
          Text(LocaleKeys.specialOfferDate_description.tr()),
          presenter.fields.specialOfferDate(
            context,
            inputType: InputType.date,
          ),
          presenter.fields.roomType(
            context,
          ),
          presenter.fields.mealOffers(
            context,
          ),
          presenter.fields.smoking(
            context,
            title: Text(
              LocaleKeys.smoking_title.tr(),
            ),
          ),
          presenter.fields.persons(
            context,
            min: 1,
            max: 4,
            divisions: 3,
            label: LocaleKeys.persons_hint.tr(),
          ),
          presenter.fields.babyBeds(
            context,
            options: const [
              FormBuilderFieldOption(
                value: 0,
                child: Text('0'),
              ),
              FormBuilderFieldOption(
                value: 1,
                child: Text('1'),
              ),
              FormBuilderFieldOption(
                value: 2,
                child: Text('2'),
              ),
            ],
          ),
          presenter.fields.preferredPrice(
            context,
            min: 0,
            max: 1000000,
          ),
          presenter.fields.donation(context),
          presenter.fields.note(
            context,
            maxLines: null,
            textInputAction: TextInputAction.newline,
            keyboardType: TextInputType.multiline,
          ),
          // Inline validation example
          FormBuilderCheckbox(
            name: 'acceptsTermsOfUse',
            initialValue: false,
            //!macro beginAutoOnly
            autovalidateMode: AutovalidateMode.onUserInteraction,
            //!macro endAutoOnly
            validator: (accepts) => (accepts ?? false)
                ? null
                : LocaleKeys.acceptsTermsOfUse_message.tr(),
            title: Text(
              LocaleKeys.acceptsTermsOfUse_title.tr(),
            ),
          ),
          ElevatedButton(
            onPressed: presenter.submit(context),
            child: Text(
              LocaleKeys.submit.tr(),
            ),
          ),
        ],
      ),
    );
  }
}

/// Presenter which holds form properties.
@formCompanion
class BookingPresenterTemplate extends StateNotifier<Booking>
    with CompanionPresenterMixin, FormBuilderCompanionMixin {
  final Account _account;
  final Reader _read;

  /// Creates new [BookingPresenterTemplate].
  BookingPresenterTemplate(
    Booking initialState,
    this._account,
    this._read,
  ) : super(initialState) {
    initializeCompanionMixin(
      PropertyDescriptorsBuilder()
        ..dateTimeRange(
          name: 'stay',
          initialValue: initialState.stay,
        )
        ..dateTime(
          name: 'specialOfferDate',
          initialValue: initialState.specialOfferDate,
        )
        ..enumeratedWithField<RoomType, FormBuilderRadioGroup<RoomType>>(
          name: 'roomType',
          initialValue: initialState.roomType,
        )
        ..enumeratedList<MealType>(
          name: 'mealOffers',
          initialValues: initialState.mealOffers,
        )
        ..boolean(
          name: 'smoking',
          initialValue: initialState.smoking ?? false,
        )
        ..addWithField<int, double, FormBuilderSlider>(
          name: 'persons',
          initialValue: initialState.persons,
          valueConverter: intDoubleConverter,
        )
        ..integerWithField<FormBuilderSegmentedControl<int>>(
          name: 'babyBeds',
          initialValue: initialState.babyBeds,
        )
        ..rangeValues(
          name: 'preferredPrice',
          initialValue: initialState.price == null
              ? const RangeValues(1000, 100000)
              : RangeValues(initialState.price!, initialState.price!),
        )
        ..add<double, String>(
          name: 'donation',
          initialValue: state.donation,
          // Localized converter example
          valueConverter: StringConverter.fromCallbacks(
            parse: (v, l, e) {
              if (v == null) {
                return ConversionResult(0);
              }

              late final num number;
              try {
                number =
                    NumberFormat.decimalPattern(l.toLanguageTag()).parse(v);
              } on FormatException catch (ex) {
                return FailureResult(
                  LocaleKeys.donation_validationError.tr(),
                  e(v, ex, l),
                );
              }

              return ConversionResult(number as double);
            },
            stringify: (v, l) {
              if (v == 0) {
                return '';
              }

              return NumberFormat.decimalPattern(l.toLanguageTag()).format(v);
            },
          ),
        )
        ..string(
          name: 'note',
          initialValue: initialState.note,
        ),
    );
  }

  @override
  FutureOr<void> doSubmit() async {
    // Get saved values here to call business logic.
    final userId = _account.id ?? 'Dummy User';
    final stay = this.stay.value!;
    final specialOfferDate = this.specialOfferDate.value!;
    final roomType = this.roomType.value!;
    final mealOffers = this.mealOffers.value!;
    final smoking = this.smoking.value!;
    final persons = this.persons.value!;
    final babyBeds = this.babyBeds.value!;
    final donation = this.donation.value;
    final preferredPrice = this.preferredPrice.value!;
    final note = this.note.value!;

    // Call business logic.
    final result = await doSubmitLogic(
      userId,
      stay,
      specialOfferDate,
      roomType,
      mealOffers,
      smoking,
      persons,
      babyBeds,
      preferredPrice,
      donation,
      note,
    );
    if (result == null) {
      return;
    }

    // Set local state.
    state = Booking.registered(
      bookingId: result.bookingId,
      userId: userId,
      stay: stay,
      specialOfferDate: specialOfferDate,
      roomType: roomType,
      mealOffers: mealOffers,
      smoking: smoking,
      persons: persons,
      babyBeds: babyBeds,
      price: result.price,
      donation: donation ?? 0,
      note: note,
    );

    // Propagate to global state.
    _read(booking.state).state = state;
    router.go('/');
  }

  /// Example of business logic of submit.
  /// Returns a bool value to indicate submit is success or not.
  /// For example, this method returns `false` if the specified request cannot
  /// be satified when the server API is called (you cannot avoid this because
  /// someone may book room between validation and submit even if you use
  /// validation logic to call server side API.)
  @visibleForTesting
  FutureOr<_BookingResult?> doSubmitLogic(
    String? userId,
    DateTimeRange stay,
    DateTime specialOfferDate,
    RoomType roomType,
    List<MealType> mealOffers,
    // ignore: avoid_positional_boolean_parameters
    bool smoking,
    int persons,
    int babyBeds,
    RangeValues preferredPrice,
    double? donation,
    String note,
  ) async {
    // Write actual registration logic via API here.
    // Assuming "bookindId" and "price" are returned from server if success.
    return _BookingResult('dummy booking ID', preferredPrice.start);
  }
}

class _BookingResult {
  final String bookingId;
  final double price;

  _BookingResult(
    this.bookingId,
    this.price,
  );
}

final _presenter = StateNotifierProvider<BookingPresenterTemplate, Booking>(
  (ref) => BookingPresenterTemplate(
    ref.watch(booking),
    ref.watch(account),
    ref.read,
  ),
);
