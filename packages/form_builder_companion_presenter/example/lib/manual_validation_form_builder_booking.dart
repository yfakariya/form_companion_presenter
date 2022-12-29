// See LICENCE file in the root.

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_builder_companion_presenter/form_builder_companion_presenter.dart';
import 'package:form_companion_presenter/form_companion_annotation.dart';
import 'package:form_companion_presenter/form_companion_presenter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'l10n/locale_keys.g.dart';
import 'manual_validation_form_builder_booking.fcp.dart';
import 'models.dart';
import 'routes.dart';
import 'screen.dart';
part 'manual_validation_form_builder_booking.g.dart';
//------------------------------------------------------------------------------
// In this example, [AutovalidateMode] of the form and fields are disabled (default value).
// In this case, [CompanionPresenterMixin.canSubmit] always returns `true`,
// so users always tap "submit" button.
// Note that [CompanionPresenterMixin.validateAndSave()] is automatically called
// in [CompanionPresenterMixin.submit] method,
// and [CompanionPresenterMixin.duSubmit] is only called when no validation errors.
//
// This mode is predictable for users by "submit" button is always shown and enabled,
// but it might be frastrated in long form because users cannot recognize their
// error until tapping "submit" button.
// Note that FormBuilderFields requires unique names and they must be identical
// to names for `PropertyDescriptor`s.
//------------------------------------------------------------------------------

/// Page for [Booking] input which just declares [FormBuilder].
///
/// This class is required to work [CompanionPresenterMixin] correctly
/// because it uses [FormBuilder.of] to access form state which requires
/// [FormBuilder] exists in ancestor of element tree ([BuildContext]).
class ManualValidationFormBuilderBookingPage extends Screen {
  /// Constructor.
  const ManualValidationFormBuilderBookingPage({Key? key}) : super(key: key);

  @override
  String get title => LocaleKeys.manual_flutterFormBuilderBooking_title.tr();

  @override
  Widget buildPage(BuildContext context, WidgetRef ref) => FormBuilder(
        autovalidateMode: AutovalidateMode.disabled,
        child: _ManualValidationFormBuilderBookingPane(),
      );
}

class _ManualValidationFormBuilderBookingPane extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(accountStateProvider).asData?.value;
    final bookingState = ref.watch(bookingStateProvider).asData?.value;
    final state =
        ref.watch(manualValidationFormBuilderBookingPresenterProvider);

    if (state is! AsyncData<
        $ManualValidationFormBuilderBookingPresenterFormProperties>) {
      return Text('loading...');
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          Text(
            bookingState is BookingRegistered
                ? LocaleKeys.booking_captionTemplate_existing.tr(
                    namedArgs: {
                      // In real apps, AccountEmpty should be avoided in navigation guard.
                      'userName': userState?.name ?? 'Dummy User',
                      'bookingId': bookingState.bookingId,
                    },
                  )
                : LocaleKeys.booking_captionTemplate_new.tr(
                    namedArgs: {
                      'userName': userState?.name ?? 'Dummy User',
                    },
                  ),
            style: Theme.of(context).textTheme.bodyText1,
          ),
          state.value.fields.stay(
            context,
            firstDate: state.value.values.stay.start,
            lastDate: state.value.values.stay.end,
          ),
          Text(LocaleKeys.specialOfferDate_description.tr()),
          state.value.fields.specialOfferDate(
            context,
            inputType: InputType.date,
          ),
          state.value.fields.roomType(
            context,
          ),
          state.value.fields.mealOffers(
            context,
          ),
          state.value.fields.smoking(
            context,
            title: Text(
              LocaleKeys.smoking_title.tr(),
            ),
          ),
          state.value.fields.persons(
            context,
            min: 1,
            max: 4,
            divisions: 3,
            label: LocaleKeys.persons_hint.tr(),
          ),
          state.value.fields.babyBeds(
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
          state.value.fields.preferredPrice(
            context,
            min: 0,
            max: 1000000,
          ),
          state.value.fields.donation(context),
          state.value.fields.note(
            context,
            maxLines: null,
            textInputAction: TextInputAction.newline,
            keyboardType: TextInputType.multiline,
          ),
          // Inline validation example
          FormBuilderCheckbox(
            name: 'acceptsTermsOfUse',
            initialValue: false,
            validator: (accepts) => (accepts ?? false)
                ? null
                : LocaleKeys.acceptsTermsOfUse_message.tr(),
            title: Text(
              LocaleKeys.acceptsTermsOfUse_title.tr(),
            ),
          ),
          ElevatedButton(
            onPressed: state.value.submit(context),
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
@FormCompanion(autovalidate: false)
@riverpod
class ManualValidationFormBuilderBookingPresenter
    extends AutoDisposeAsyncNotifier<
        $ManualValidationFormBuilderBookingPresenterFormProperties>
    with CompanionPresenterMixin, FormBuilderCompanionMixin {
  late Account _account;

  ManualValidationFormBuilderBookingPresenter() {
    initializeCompanionMixin(
      PropertyDescriptorsBuilder()
        ..dateTimeRange(
          name: 'stay',
        )
        ..dateTime(
          name: 'specialOfferDate',
        )
        ..enumeratedWithField<RoomType, FormBuilderRadioGroup<RoomType>>(
          name: 'roomType',
        )
        ..enumeratedList<MealType>(
          name: 'mealOffers',
        )
        ..boolean(
          name: 'smoking',
        )
        ..addWithField<int, double, FormBuilderSlider>(
          name: 'persons',
          valueConverter: intDoubleConverter,
        )
        ..integerWithField<FormBuilderSegmentedControl<int>>(
          name: 'babyBeds',
        )
        ..rangeValues(
          name: 'preferredPrice',
        )
        ..add<double, String>(
          name: 'donation',
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
        ),
    );
  }

  @override
  FutureOr<$ManualValidationFormBuilderBookingPresenterFormProperties>
      build() async {
    _account = await ref.watch(accountStateProvider.future);
    final initialState = await ref.watch(bookingStateProvider.future);

    // Restore or set default for optional properties using cascading syntax.
    final builder = properties.copyWith()
      ..stay(initialState.stay)
      ..specialOfferDate(initialState.specialOfferDate)
      ..roomType(initialState.roomType)
      ..mealOffers(initialState.mealOffers)
      ..smoking(initialState.smoking ?? false)
      ..persons(initialState.persons)
      ..babyBeds(initialState.babyBeds)
      ..mealOffers(initialState.mealOffers)
      ..preferredPrice(
        initialState.price == null
            ? const RangeValues(1000, 100000)
            : RangeValues(initialState.price!, initialState.price!),
      );

    // Try to restore required fields only if stored.
    if (initialState.donation != null) {
      builder.donation(initialState.donation!);
    }
    if (initialState.note != null) {
      builder.note(initialState.note!);
    }

    return resetProperties(builder.build());
  }

  @override
  FutureOr<void> doSubmit() async {
    // Get saved values here to call business logic.
    final userId = _account.id ?? 'Dummy User';
    final stay = properties.values.stay;
    final specialOfferDate = properties.values.specialOfferDate;
    final roomType = properties.values.roomType;
    final mealOffers = properties.values.mealOffers;
    final smoking = properties.values.smoking;
    final persons = properties.values.persons;
    final babyBeds = properties.values.babyBeds;
    final donation = properties.values.donation;
    final preferredPrice = properties.values.preferredPrice;
    final note = properties.values.note;

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

    final booking = Booking.registered(
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
      donation: donation,
      note: note,
    );

    // Propagate to global state.
    await ref.read(bookingStateProvider.notifier).submit(booking);
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
