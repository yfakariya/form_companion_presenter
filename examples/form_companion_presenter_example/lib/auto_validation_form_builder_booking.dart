// See LICENCE file in the root.

import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_builder_companion_presenter/form_builder_companion_presenter.dart';
import 'package:form_companion_presenter/form_companion_presenter.dart';
import 'package:meta/meta.dart';

import 'l10n/locale_keys.g.dart';
import 'models.dart';
import 'routes.dart';
import 'screen.dart';

//------------------------------------------------------------------------------
// In this example, [AutovalidateMode] of the form is disabled (default value)
// and [AutovalidateMode] of fields are set to [AutovalidateMode.onUserInteraction].
// In this case, [CompanionPresenterMixin.canSubmit] returns `false` when any
// invalid inputs exist.
// Note that users can tap "submit" button in initial state, so
// [CompanionPresenterMixin.validateAndSave()] is still automatically called
// in [CompanionPresenterMixin.submit] method,
// and [CompanionPresenterMixin.duSubmit] is only called when no validation errors.
//
// This mode is predictable for users by "submit" button is shown and enabled initially,
// and users can recognize their error after input. It looks ideal but some situation
// needs "bulk auto" or "manual" mode.
// Note that FormBuilderFields requires unique names and they must be identical
// to names for `PropertyDescriptor`s.
//------------------------------------------------------------------------------

/// Page for [Booking] input which just declares [FormBuilder].
///
/// This class is required to work [CompanionPresenterMixin] correctly
/// because it uses [FormBuilder.of] to access form state which requires
/// [FormBuilder] exists in ancestor of element tree ([BuildContext]).
class AutoValidationFormBuilderBookingPage extends Screen {
  /// Constructor.
  const AutoValidationFormBuilderBookingPage({Key? key}) : super(key: key);

  @override
  String get title => LocaleKeys.auto_flutterFormBuilderBooking_title.tr();

  @override
  Widget buildPage(BuildContext context, WidgetRef ref) => FormBuilder(
        autovalidateMode: AutovalidateMode.disabled,
        child: _AutoValidationFormBuilderBookingPane(),
      );
}

class _AutoValidationFormBuilderBookingPane extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = DateTime.now();
    final userState = ref.watch(account);
    final bookingState = ref.watch(booking);
    final state = ref.watch(_presenter);
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
          FormBuilderDateRangePicker(
            name: 'stay',
            initialValue: state.stay,
            firstDate: state.stay.start,
            lastDate: today.add(const Duration(days: 90)),
            decoration: InputDecoration(
              labelText: LocaleKeys.stay_label.tr(),
              hintText: LocaleKeys.stay_hint.tr(),
            ),
          ),
          Text(LocaleKeys.specialOffer_description.tr()),
          FormBuilderDateTimePicker(
            name: 'specialOfferDate',
            initialDate: state.specialOfferDate,
            inputType: InputType.date,
            decoration: InputDecoration(
              labelText: LocaleKeys.specialOffer_label.tr(),
              hintText: LocaleKeys.specialOffer_hint.tr(),
            ),
          ),
          FormBuilderRadioGroup(
            name: 'roomType',
            initialValue: state.roomType,
            options: [
              FormBuilderFieldOption(
                value: RoomType.standard,
                child: Text(
                  LocaleKeys.roomType_standard.tr(),
                ),
              ),
              FormBuilderFieldOption(
                value: RoomType.delux,
                child: Text(
                  LocaleKeys.roomType_delux.tr(),
                ),
              ),
              FormBuilderFieldOption(
                value: RoomType.suite,
                child: Text(
                  LocaleKeys.roomType_suite.tr(),
                ),
              ),
            ],
            decoration: InputDecoration(
              labelText: LocaleKeys.roomType_label.tr(),
              hintText: LocaleKeys.roomType_hint.tr(),
            ),
          ),
          FormBuilderFilterChip(
            name: 'mealOffers',
            initialValue: state.mealOffers,
            options: [
              FormBuilderFieldOption(
                value: MealType.halal,
                child: Text(
                  LocaleKeys.mealType_halal.tr(),
                ),
              ),
              FormBuilderFieldOption(
                value: MealType.vegan,
                child: Text(
                  LocaleKeys.mealType_vegan.tr(),
                ),
              ),
            ],
            decoration: InputDecoration(
              labelText: LocaleKeys.mealOffers_label.tr(),
              hintText: LocaleKeys.mealOffers_hint.tr(),
            ),
          ),
          FormBuilderSwitch(
            name: 'smoking',
            initialValue: state.smoking,
            title: Text(
              LocaleKeys.smoking_title.tr(),
            ),
            decoration: InputDecoration(
              labelText: LocaleKeys.smoking_label.tr(),
            ),
          ),
          FormBuilderSlider(
            name: 'persons',
            initialValue: (state.persons).toDouble(),
            min: 1,
            max: 4,
            divisions: 3,
            label: LocaleKeys.persons_hint.tr(),
            decoration: InputDecoration(
              labelText: LocaleKeys.persons_label.tr(),
            ),
          ),
          FormBuilderSegmentedControl(
            name: 'babyBeds',
            initialValue: state.babyBeds,
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
            decoration: InputDecoration(
              labelText: LocaleKeys.babyBeds_label.tr(),
              hintText: LocaleKeys.babyBeds_hint.tr(),
            ),
          ),
          // I know this example does not consider L10N.
          FormBuilderRangeSlider(
            name: 'preferredPrice',
            initialValue: RangeValues((state.price ?? 100).toDouble(),
                (state.price ?? 100).toDouble()),
            min: 0,
            max: 1000,
            decoration: InputDecoration(
              labelText: LocaleKeys.preferredPrice_label.tr(),
              hintText: LocaleKeys.preferredPrice_hint.tr(),
            ),
          ),
          FormBuilderTextField(
            name: 'note',
            initialValue: state.note,
            maxLines: null,
            textInputAction: TextInputAction.newline,
            keyboardType: TextInputType.multiline,
            decoration: InputDecoration(
              labelText: LocaleKeys.note_label.tr(),
              hintText: LocaleKeys.note_hint.tr(),
            ),
          ),
          // Inline validation example
          FormBuilderCheckbox(
            name: 'acceptsTermsOfUse',
            initialValue: false,
            autovalidateMode: AutovalidateMode.onUserInteraction,
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

/// Testable presenter.
@visibleForTesting
class AutoValidationFormBuilderBookingPresenter extends StateNotifier<Booking>
    with CompanionPresenterMixin, FormBuilderCompanionMixin {
  final Account _account;
  final Reader _read;

  /// Creates new [AutoValidationFormBuilderBookingPresenter].
  AutoValidationFormBuilderBookingPresenter(
    Booking initialState,
    this._account,
    this._read,
  ) : super(initialState) {
    initializeCompanionMixin(
      PropertyDescriptorsBuilder()
        ..add<DateTimeRange>(
          name: 'stay',
        )
        ..add<DateTime>(
          name: 'specialOfferDate',
        )
        ..add<RoomType>(
          name: 'roomType',
        )
        ..add<List<MealType>>(
          name: 'mealOffers',
        )
        ..add<bool>(
          name: 'smoking',
        )
        ..add<int>(
          name: 'persons',
        )
        ..add<int>(
          name: 'babyBeds',
        )
        ..add<RangeValues>(
          name: 'prefferedPrice',
        )
        ..add<String>(
          name: 'note',
        ),
    );
  }

  @override
  FutureOr<void> doSubmit() async {
    // Get saved values here to call business logic.
    final userId = _account.id ?? 'Dummy User';
    final stay = getSavedPropertyValue<DateTimeRange>('stay')!;
    final specialOfferDate =
        getSavedPropertyValue<DateTime>('specialOfferDate')!;
    final roomType = getSavedPropertyValue<RoomType>('roomType')!;
    final mealOffers = getSavedPropertyValue<List<MealType>>('mealOffers')!;
    final smoking = getSavedPropertyValue<bool>('smoking')!;
    final persons = getSavedPropertyValue<int>('persons')!;
    final babyBeds = getSavedPropertyValue<int>('babyBeds')!;
    final preferredPrice =
        getSavedPropertyValue<RangeValues>('prefferedPrice')!;
    final note = getSavedPropertyValue<String>('note')!;

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
      note: note,
    );

    // Propagate to global state.
    _read(booking.state).state = state;
    transitToHome(_read);
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

final _presenter =
    StateNotifierProvider<AutoValidationFormBuilderBookingPresenter, Booking>(
  (ref) => AutoValidationFormBuilderBookingPresenter(
    ref.watch(booking),
    ref.watch(account),
    ref.read,
  ),
);
